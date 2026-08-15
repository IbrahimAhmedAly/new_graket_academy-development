/// Returns a video seek target constrained to the playable time range.
///
/// Keeping the calculation independent from the player makes both backward
/// and forward controls follow the same boundary rules.
Duration clampedVideoSeekTarget({
  required Duration currentPosition,
  required Duration offset,
  required Duration totalDuration,
}) {
  final durationMs = totalDuration.isNegative
      ? 0
      : totalDuration.inMilliseconds;
  final targetMs = currentPosition.inMilliseconds + offset.inMilliseconds;

  return Duration(milliseconds: targetMs.clamp(0, durationMs).toInt());
}
