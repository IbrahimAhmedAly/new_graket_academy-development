import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/debug_print.dart';
import 'package:http/http.dart' as http;
import 'package:new_graket_acadimy/core/constants/app_apis.dart';

import '../constants/app_strings.dart';
import '../functions/check_internet_function.dart';
import '../services/services.dart';

// Create a custom HTTP client with better configuration
http.Client _createHttpClient() {
  if (kIsWeb) {
    return http.Client();
  }
  // ignore: avoid_dynamic_calls
  return _createNativeHttpClient();
}

http.Client _createNativeHttpClient() {
  // dart:io imports are safe here since this is only called on non-web
  // We use a plain client to stay compatible; for certificate handling
  // use a proper certificate setup in production.
  return http.Client();
}

/// Build headers depending on whether a token is provided
Map<String, String> myHeaders({String? token}) {
  final headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Connection": "keep-alive",
    "Accept-Encoding": "gzip, deflate",
    "Accept-Language": "en-US,en;q=0.9",
    "language": "en",
  };

  if (token != null && token.isNotEmpty) {
    headers["Authorization"] = "Bearer $token";
  }

  return headers;
}

bool _isHandlingUnauthorized = false;
Future<String?>? _refreshFuture;
const String _loginRoute = "/LoginScreen";

Map<String, dynamic> _parseErrorResponse(String body, int statusCode) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      return {
        "status": decoded["status"] ?? statusCode,
        "message": decoded["message"] ?? "Session expired, please login again.",
      };
    }
    return {
      "status": statusCode,
      "message": "Session expired, please login again.",
    };
  } catch (_) {
    return {
      "status": statusCode,
      "message": "Session expired, please login again.",
    };
  }
}

void _handleUnauthorized({String? message}) {
  if (_isHandlingUnauthorized) return;
  _isHandlingUnauthorized = true;

  if (Get.isRegistered<MyServices>()) {
    final prefs = Get.find<MyServices>().sharedPreferences;
    prefs.remove(AppSharedPrefKeys.userTokenKey);
    prefs.remove(AppSharedPrefKeys.refreshTokenKey);
    prefs.setBool(AppSharedPrefKeys.savedLoginKey, false);
    prefs.remove('token'); // legacy key
  }

  Future.microtask(() {
    Get.offAllNamed(
      _loginRoute,
      arguments: {"message": message ?? "Session expired"},
    );
    _isHandlingUnauthorized = false;
  });
}

Future<String?> _refreshAccessToken() async {
  if (_refreshFuture != null) return _refreshFuture;
  _refreshFuture = _doRefreshAccessToken();
  final token = await _refreshFuture;
  _refreshFuture = null;
  return token;
}

Future<String?> _doRefreshAccessToken() async {
  if (!Get.isRegistered<MyServices>()) return null;
  final prefs = Get.find<MyServices>().sharedPreferences;
  final refreshToken =
      prefs.getString(AppSharedPrefKeys.refreshTokenKey) ??
          prefs.getString('refreshToken') ??
          '';
  if (refreshToken.isEmpty) return null;

  try {
    final response = await http.post(
      Uri.parse(AppApis.refreshToken),
      body: jsonEncode({"refreshToken": refreshToken}),
      headers: myHeaders(token: null),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final data = decoded['data'];
        if (data is Map && data['access'] is Map) {
          final access = data['access'] as Map;
          final token = access['token']?.toString() ?? '';
          if (token.isNotEmpty) {
            prefs.setString(AppSharedPrefKeys.userTokenKey, token);
            return token;
          }
        }
      }
    }
  } catch (_) {}

  _handleUnauthorized(message: "Session expired");
  return null;
}

class DataRequest {
  late final http.Client _client;

  DataRequest() {
    _client = _createHttpClient();
  }

  /// Send JSON body request (for login, register, etc.)
  Future<Either<(RequestStatus, Map<String, dynamic>), (RequestStatus, Map)>>
  postDataJsonBody(String url, Map data, {String? token}) async {
    try {
      if (await checkInternetFunction()) {
        appPrint("================================================");
        appPrint("🔵 STARTING POST REQUEST");
        appPrint("➡️ URL: $url");
        appPrint("📤 Body: ${jsonEncode(data)}");
        appPrint("📋 Headers: ${myHeaders(token: token)}");
        appPrint("================================================");

        final response = await _client.post(
          Uri.parse(url),
          body: jsonEncode(data), // ✅ send JSON
          headers: myHeaders(token: token),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            appPrint("⏱️ REQUEST TIMEOUT after 30 seconds");
            throw Exception("Request timeout");
          },
        );

        appPrint("================================================");
        appPrint("✅ RESPONSE RECEIVED");
        appPrint("⬅️ Status: ${response.statusCode}");
        appPrintJson(jsonDecode(response.body));
        appPrint("================================================");

        if (response.statusCode == 401 || response.statusCode == 403) {
          final error = _parseErrorResponse(response.body, response.statusCode);
          if (token != null &&
              token.isNotEmpty &&
              url != AppApis.refreshToken) {
            final newToken = await _refreshAccessToken();
            if (newToken != null && newToken.isNotEmpty) {
              final retryResponse = await _client.post(
                Uri.parse(url),
                body: jsonEncode(data),
                headers: myHeaders(token: newToken),
              );
              if (retryResponse.statusCode >= 200 &&
                  retryResponse.statusCode < 300) {
                final Map receivedData = jsonDecode(retryResponse.body);
                return Right((RequestStatus.success, receivedData));
              }
            }
            _handleUnauthorized(message: error["message"]?.toString());
          }
          return Left((RequestStatus.serverFailure, error));
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final Map receivedData = jsonDecode(response.body);
          if (kDebugMode) print(receivedData);
          return Right((RequestStatus.success, receivedData));
        } else {
          return Left((
            RequestStatus.serverFailure,
            _parseErrorResponse(response.body, response.statusCode),
          ));
        }
      } else {
        return Left((
          RequestStatus.offline,
          {"status": 410, "message": "No Internet Connection"},
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception in postDataJsonBody: $e");
      }
      return Left((
        RequestStatus.serverException,
        {"status": 404, "message": "Server Exception"},
      ));
    }
  }

  /// Send JSON body PUT request — same envelope + auth-retry behaviour as POST.
  Future<Either<(RequestStatus, Map<String, dynamic>), (RequestStatus, Map)>>
  putDataJsonBody(String url, Map data, {String? token}) async {
    try {
      if (await checkInternetFunction()) {
        appPrint("================================================");
        appPrint("🟣 STARTING PUT REQUEST");
        appPrint("➡️ URL: $url");
        appPrint("📤 Body: ${jsonEncode(data)}");
        appPrint("================================================");

        final response = await _client.put(
          Uri.parse(url),
          body: jsonEncode(data),
          headers: myHeaders(token: token),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception("Request timeout");
          },
        );

        if (response.statusCode == 401 || response.statusCode == 403) {
          final error = _parseErrorResponse(response.body, response.statusCode);
          if (token != null &&
              token.isNotEmpty &&
              url != AppApis.refreshToken) {
            final newToken = await _refreshAccessToken();
            if (newToken != null && newToken.isNotEmpty) {
              final retryResponse = await _client.put(
                Uri.parse(url),
                body: jsonEncode(data),
                headers: myHeaders(token: newToken),
              );
              if (retryResponse.statusCode >= 200 &&
                  retryResponse.statusCode < 300) {
                final Map receivedData = jsonDecode(retryResponse.body);
                return Right((RequestStatus.success, receivedData));
              }
            }
            _handleUnauthorized(message: error["message"]?.toString());
          }
          return Left((RequestStatus.serverFailure, error));
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final Map receivedData = jsonDecode(response.body);
          return Right((RequestStatus.success, receivedData));
        } else {
          return Left((
            RequestStatus.serverFailure,
            _parseErrorResponse(response.body, response.statusCode),
          ));
        }
      } else {
        return Left((
          RequestStatus.offline,
          {"status": 410, "message": "No Internet Connection"},
        ));
      }
    } catch (e) {
      if (kDebugMode) print("❌ Exception in putDataJsonBody: $e");
      return Left((
        RequestStatus.serverException,
        {"status": 404, "message": "Server Exception"},
      ));
    }
  }

  /// Send form-data request (only if API specifically expects it)
  Future<Either<RequestStatus, Map>> postDataAsForm(
    String url,
    Map data, {
    String? token,
  }) async {
    try {
      if (await checkInternetFunction()) {
        final response = await _client.post(
          Uri.parse(url),
          body: data, // ❌ form-url-encoded
          headers: myHeaders(token: token),
        );

        appPrint("================================================");
        appPrint("➡️ POST $url");
        appPrint("📤 Form Body: $data");
        appPrint("⬅️ Status: ${response.statusCode}");
        appPrint("⬅️ Response: ${response.body}");
        appPrint("================================================");

        if (response.statusCode == 401 || response.statusCode == 403) {
          if (token != null && token.isNotEmpty) {
            final error = _parseErrorResponse(
              response.body,
              response.statusCode,
            );
            _handleUnauthorized(message: error["message"]?.toString());
          }
          return const Left(RequestStatus.serverFailure);
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final Map receivedData = jsonDecode(response.body);
          if (kDebugMode) print(receivedData);
          return Right(receivedData);
        } else {
          return const Left(RequestStatus.serverFailure);
        }
      } else {
        return const Left(RequestStatus.offline);
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception in postDataAsForm: $e");
      }
      return const Left(RequestStatus.serverException);
    }
  }

  Future<Either<(RequestStatus, Map<String, dynamic>), (RequestStatus, Map)>>
  getData(String url, {String? token, Map<String, dynamic>? queryParameters}) async {
    try {
      if (await checkInternetFunction()) {
        // Build URL with query parameters if provided
        Uri uri = Uri.parse(url);
        if (queryParameters != null && queryParameters.isNotEmpty) {
          uri = uri.replace(queryParameters: queryParameters.map((key, value) => MapEntry(key, value.toString())));
        }

        final response = await _client.get(
          uri,
          headers: myHeaders(token: token),
        );

        appPrint("================================================");
        appPrint("➡️ GET ${uri.toString()}");
        appPrint("⬅️ Status: ${response.statusCode}");
        appPrintJson(jsonDecode(response.body));
        appPrint("================================================");

        if (response.statusCode == 401 || response.statusCode == 403) {
          final error = _parseErrorResponse(response.body, response.statusCode);
          if (token != null &&
              token.isNotEmpty &&
              url != AppApis.refreshToken) {
            final newToken = await _refreshAccessToken();
            if (newToken != null && newToken.isNotEmpty) {
              final retryResponse = await _client.get(
                uri,
                headers: myHeaders(token: newToken),
              );
              if (retryResponse.statusCode >= 200 &&
                  retryResponse.statusCode < 300) {
                final Map receivedData = jsonDecode(retryResponse.body);
                return Right((RequestStatus.success, receivedData));
              }
            }
            _handleUnauthorized(message: error["message"]?.toString());
          }
          return Left((RequestStatus.serverFailure, error));
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final Map receivedData = jsonDecode(response.body);
          return Right((RequestStatus.success, receivedData));
        } else {
          return Left((
            RequestStatus.serverFailure,
            _parseErrorResponse(response.body, response.statusCode),
          ));
        }
      } else {
        return Left((
          RequestStatus.offline,
          {"status": 410, "message": "No Internet Connection"},
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception in postDataJsonBody: $e");
      }
      return Left((
        RequestStatus.serverException,
        {"status": 404, "message": "Server Exception"},
      ));
    }
  }

  Future<Either<(RequestStatus, Map<String, dynamic>), (RequestStatus, Map)>>
      deleteData(String url, {String? token, Map? body}) async {
    try {
      if (await checkInternetFunction()) {
        final response = await _client.delete(
          Uri.parse(url),
          headers: myHeaders(token: token),
          body: body == null ? null : jsonEncode(body),
        );

        appPrint("================================================");
        appPrint("➡️ DELETE $url");
        if (body != null) {
          appPrint("📤 Body: ${jsonEncode(body)}");
        }
        appPrint("⬅️ Status: ${response.statusCode}");
        appPrintJson(jsonDecode(response.body));
        appPrint("================================================");

        if (response.statusCode == 401 || response.statusCode == 403) {
          final error = _parseErrorResponse(response.body, response.statusCode);
          if (token != null &&
              token.isNotEmpty &&
              url != AppApis.refreshToken) {
            final newToken = await _refreshAccessToken();
            if (newToken != null && newToken.isNotEmpty) {
              final retryResponse = await _client.delete(
                Uri.parse(url),
                headers: myHeaders(token: newToken),
                body: body == null ? null : jsonEncode(body),
              );
              if (retryResponse.statusCode >= 200 &&
                  retryResponse.statusCode < 300) {
                final Map receivedData = jsonDecode(retryResponse.body);
                return Right((RequestStatus.success, receivedData));
              }
            }
            _handleUnauthorized(message: error["message"]?.toString());
          }
          return Left((RequestStatus.serverFailure, error));
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final Map receivedData = jsonDecode(response.body);
          return Right((RequestStatus.success, receivedData));
        } else {
          return Left((
            RequestStatus.serverFailure,
            _parseErrorResponse(response.body, response.statusCode),
          ));
        }
      } else {
        return Left((
          RequestStatus.offline,
          {"status": 410, "message": "No Internet Connection"},
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception in deleteData: $e");
      }
      return Left((
        RequestStatus.serverException,
        {"status": 404, "message": "Server Exception"},
      ));
    }
  }

  // 🔹 Optional: File upload (commented for now)
  // Future<Either<RequestStatus, Map>> postFileRequest(
  //     String url, Map data, File? file, {String? token}) async {
  //   if (file == null) {
  //     return postDataJsonBody(url, data, token: token);
  //   } else {
  //     if (await checkInternetFunction()) {
  //       var request = http.MultipartRequest("POST", Uri.parse(url));
  //
  //       var fileLength = await file.length();
  //       var stream = http.ByteStream(file.openRead());
  //       var multiPartFile = http.MultipartFile(
  //         "file",
  //         stream,
  //         fileLength,
  //         filename: file.path.split("/").last,
  //       );
  //
  //       request.headers.addAll(myHeaders(token: token));
  //       request.files.add(multiPartFile);
  //
  //       data.forEach((key, value) {
  //         request.fields[key] = value.toString();
  //       });
  //
  //       var lastRequest = await request.send();
  //       var response = await http.Response.fromStream(lastRequest);
  //
  //       if (response.statusCode == 200 || response.statusCode == 201) {
  //         Map receivedData = jsonDecode(response.body);
  //         return Right(receivedData);
  //       } else {
  //         return const Left(RequestStatus.serverFailure);
  //       }
  //     } else {
  //       return const Left(RequestStatus.offline);
  //     }
  //   }
  // }
}
