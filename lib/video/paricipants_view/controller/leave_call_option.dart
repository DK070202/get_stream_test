import 'package:flutter/material.dart';
import 'package:ram/video/paricipants_view/controller/controller_option.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

/// A widget that represents a call control option to leave a call.
class LeaveCallOption extends StatelessWidget {
  /// Creates a new instance of [LeaveCallOption].
  const LeaveCallOption({
    super.key,
    required this.call,
    this.icon = Icons.call_end_rounded,
    this.onLeaveCallTap,
  });

  /// Represents a call.
  final Call call;

  /// The icon of the leave call button.
  final IconData icon;

  /// The action to perform when the leave call button is tapped.
  final VoidCallback? onLeaveCallTap;

  @override
  Widget build(BuildContext context) {
    return ControllerOption(
      icon: Icon(icon),
      iconColor: Colors.white,
      backgroundColor: Colors.red,
      onPressed: () {
        if (onLeaveCallTap != null) {
          onLeaveCallTap!();
        } else {
          call.leave();
        }
      },
    );
  }
}
