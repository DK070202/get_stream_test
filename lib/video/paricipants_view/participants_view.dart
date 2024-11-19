import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:stream_video_flutter/src/call_participants/screen_share_call_participants_content.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart'
    hide
        ToggleSpeakerphoneOption,
        ToggleCameraOption,
        ToggleMicrophoneOption,
        LeaveCallOption,
        FlipCameraOption;

import 'controller/flip_camera_option.dart';
import 'controller/leave_call_option.dart';
import 'controller/speaker_option.dart';
import 'controller/toggle_camera_option.dart';
import 'controller/toggle_microphone_option.dart';

/// Widget that renders all the [StreamCallParticipant], based on the number
/// of people in a call.
class ParticipantsView extends StatefulWidget {
  /// Creates a new instance of [StreamCallParticipant].
  ParticipantsView({
    super.key,
    required this.call,
    required this.participants,
    this.filter = _defaultFilter,
    Sort<CallParticipantState>? sort,
    this.enableLocalVideo,
    this.callParticipantBuilder = _defaultParticipantBuilder,
    this.localVideoParticipantBuilder,
    this.screenShareContentBuilder,
    this.screenShareParticipantBuilder = _defaultParticipantBuilder,
    this.layoutMode = ParticipantLayoutMode.grid,
  }) : sort = sort ?? layoutMode.sorting;

  /// Represents a call.
  final Call call;

  /// The list of participants to display.
  final Iterable<CallParticipantState> participants;

  /// Used for filtering the call participants.
  final Filter<CallParticipantState> filter;

  /// Used for sorting the call participants.
  final Sort<CallParticipantState> sort;

  /// Enable local video view for the local participant.
  final bool? enableLocalVideo;

  /// Builder function used to build a participant grid item.
  final CallParticipantBuilder callParticipantBuilder;

  /// Builder function used to build a local video participant widget.
  final CallParticipantBuilder? localVideoParticipantBuilder;

  /// Builder function used to build a screen sharing item.
  final ScreenShareContentBuilder? screenShareContentBuilder;

  /// Builder function used to build participant item in screen sharing mode.
  final ScreenShareParticipantBuilder screenShareParticipantBuilder;

  /// The layout mode used to display the participants.
  final ParticipantLayoutMode layoutMode;

  // The default participant filter.
  static bool _defaultFilter(CallParticipantState participant) => true;

  // The default participant builder.
  static Widget _defaultParticipantBuilder(
    BuildContext context,
    Call call,
    CallParticipantState participant,
  ) {
    return StreamCallParticipant(
      // We use the sessionId as the key to map the state to the participant.
      key: Key(participant.sessionId),
      call: call,
      participant: participant,
    );
  }

  @override
  State<ParticipantsView> createState() => _ParticipantsViewState();
}

class _ParticipantsViewState extends State<ParticipantsView> {
  List<CallParticipantState> _participants = [];
  CallParticipantState? _screenShareParticipant;

  @override
  void initState() {
    _recalculateParticipants();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ParticipantsView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!const ListEquality<CallParticipantState>().equals(
      widget.participants.toList(),
      oldWidget.participants.toList(),
    )) {
      _recalculateParticipants();
    }
  }

  void _recalculateParticipants() {
    final participants = [...widget.participants].where(widget.filter).toList();
    mergeSort(participants, compare: widget.sort);

    final screenShareParticipant = participants.firstWhereOrNull(
      (it) {
        final screenShareTrack = it.screenShareTrack;
        final isScreenShareEnabled = it.isScreenShareEnabled;

        if (screenShareTrack == null || !isScreenShareEnabled) return false;

        return true;
      },
    );

    if (mounted) {
      setState(() {
        _participants = participants.toList();
        _screenShareParticipant = screenShareParticipant;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.layoutMode == ParticipantLayoutMode.pictureInPicture) {
      return widget.callParticipantBuilder(
        context,
        widget.call,
        _participants.first,
      );
    }

    if (_screenShareParticipant != null) {
      return ScreenShareCallParticipantsContent(
        call: widget.call,
        participants: _participants,
        screenSharingParticipant: _screenShareParticipant!,
        screenShareContentBuilder: widget.screenShareContentBuilder,
        screenShareParticipantBuilder: widget.screenShareParticipantBuilder,
      );
    }

    return UnikonParticipantsContent(
      call: widget.call,
      participants: _participants,
    );
  }
}

class UnikonParticipantsContent extends StatefulWidget {
  const UnikonParticipantsContent({
    super.key,
    required this.call,
    required this.participants,
  });

  final Call call;
  final Iterable<CallParticipantState> participants;

  @override
  State<UnikonParticipantsContent> createState() =>
      _UnikonParticipantsContentState();
}

class _UnikonParticipantsContentState extends State<UnikonParticipantsContent> {
  @override
  Widget build(BuildContext context) {
    final localParticipant = widget.participants.firstWhere(
      (e) => e.isLocal,
    );

    final participant = widget.participants.firstWhere(
      (e) => !e.isLocal,
    );

    return Stack(
      children: [
        // Participants.
        Column(
          children: [
            Expanded(
              child: StreamCallParticipant(
                key: ValueKey(localParticipant.userId),
                showConnectionQualityIndicator: true,
                showParticipantLabel: false,
                participant: localParticipant,
                call: widget.call,
              ),
            ),
            const UnikonBrandingStrip(),
            Expanded(
              child: StreamCallParticipant(
                key: ValueKey(participant.userId),
                showConnectionQualityIndicator: true,
                showParticipantLabel: false,
                participant: participant,
                call: widget.call,
              ),
            ),
          ],
        ),

        // video controller.
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: VideoController(
            call: widget.call,
            localParticipant: localParticipant,
          ),
        ),
      ],
    );
  }
}

class UnikonBrandingStrip extends StatelessWidget {
  const UnikonBrandingStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal,
      width: MediaQuery.of(context).size.width,
      height: 32,
    );
  }
}

class VideoController extends StatelessWidget {
  final Call call;
  final CallParticipantState localParticipant;

  const VideoController({
    super.key,
    required this.call,
    required this.localParticipant,
  });

  @override
  Widget build(BuildContext context) {
    return StreamCallControlsTheme(
      data: const StreamCallControlsThemeData(
        optionBackgroundColor: Colors.black26,
        optionIconColor: Colors.white,
        elevation: 0,
      ),
      child: Container(
        height: 70,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ToggleSpeakerphoneOption(
              call: call,
            ),
            ToggleCameraOption(
              call: call,
              localParticipant: localParticipant,
            ),
            LeaveCallOption(
              call: call,
            ),
            FlipCameraOption(
              call: call,
              localParticipant: localParticipant,
            ),
            ToggleMicrophoneOption(
              call: call,
              localParticipant: localParticipant,
            )
          ],
        ),
      ),
    );
  }
}
