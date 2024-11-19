import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

import 'paricipants_view/participants_view.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({
    super.key,
    required this.call,
  });

  final Call call;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final StreamSubscription<StreamCallEvent> callEvents;

  @override
  void initState() {
    super.initState();

    callEvents = widget.call.callEvents.listen((event) {
      print(
        'event is ${event.runtimeType}  ',
      );

      if (event is StreamCallSfuTrackPublishedEvent) {
        print(event.userId);
      }
    });
  }

  @override
  void dispose() {
    callEvents.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamCallContainer(
        pictureInPictureConfiguration: const PictureInPictureConfiguration(
          enablePictureInPicture: true,
        ),
        call: widget.call,
        callContentBuilder: (context, call, callState) {
          return StreamCallContent(
            call: call,
            callState: callState,
            callControlsBuilder: (_, __, callState) => const SizedBox.shrink(),
            callAppBarBuilder: (_, __, callState) =>
                const EmptyPreferredSizeWidget(),
            callParticipantsBuilder: (context, call, callState) {
              return ParticipantsView(
                call: call,
                participants: callState.callParticipants,
              );
            },
          );
        },
      ),
    );
  }
}

class EmptyPreferredSizeWidget extends StatelessWidget
    implements PreferredSizeWidget {
  const EmptyPreferredSizeWidget({super.key});

  @override
  Size get preferredSize => Size.zero;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
