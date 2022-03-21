import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bcov/src/controls_widget.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({
    Key? key,
    required this.isPlaying,
    required this.totalTime,
    required this.currentTime,
    required this.creationParams,
    required this.onPlatformViewCreated,
    required this.onPlayStateChanged,
  }) : super(key: key);

  /// When [isPlaying] is `true`, the play button displays a pause icon. When
  /// it is `false`, the button shows a play icon.
  final bool isPlaying;

  /// This is the total time length of the audio track that is being played.
  final Duration totalTime;

  /// The [currentTime] is displayed between the play/pause button and the seek
  /// bar. This value also affects the current position of the seek bar in
  /// relation to the total time. An audio plugin can update this value as it
  /// is playing to let the user know the current time in the audio track.
  final Duration currentTime;

  final Map<String, dynamic> creationParams;

  /// Callback that is called when the view is created in the platform.
  final ValueChanged<int> onPlatformViewCreated;

  /// This is called when a user has pressed the play/pause button. You should
  /// update [isPlaying] and then rebuild the widget with the new value.
  final ValueChanged<bool> onPlayStateChanged;

  @override
  _PlayerViewState createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  /// Determinate if the controls are visible or not over the widget.
  late bool _visible;

  /// Timer to auto hide the controller after a few seconds.
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    _visible = true;
    _setAutoHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Stack(
          children: <Widget>[
            UiKitView(
              viewType: 'bcov.flutter/player_view',
              creationParams: widget.creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: widget.onPlatformViewCreated,
            ),
            _buildToggleWidget(),
          ],
        ),
        _buildMediaController(),
      ],
    );
  }

  /// Builds the overlay widget that detects the tap gesture to toggle the
  /// media controls.
  Widget _buildToggleWidget() {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleController,
        child: Container(),
      ),
    );
  }

  /// Builds the media controls over the widget in the stack.
  Widget _buildMediaController() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Offstage(
        offstage: !_visible,
        child: Controls(
          isPlaying: widget.isPlaying,
          totalTime: widget.totalTime,
          currentTime: widget.currentTime,
          onUserInteractControls: () {
            _userInteractWithControls();
          },
          onPlayStateChanged: widget.onPlayStateChanged,
        ),
      ),
    );
  }

  /// Sets the auto hide timer.
  void _setAutoHideTimer() {
    _cancelAutoHideTimer();
    _autoHideTimer = Timer(const Duration(milliseconds: 3000), () {
      _toggleController(visibility: false);
    });
  }

  /// Cancels the auto hide timer.
  void _cancelAutoHideTimer() {
    _autoHideTimer?.cancel();
  }

  /// Changes the state of the visibility of the controls and rebuilds
  /// the widget. If [visibility] is set then is used as a new value of
  /// visibility.
  void _toggleController({bool? visibility}) {
    setState(() {
      _visible = visibility ?? !_visible;
    });
    _resolveAutoHide();
  }

  /// Resolve if the auto hide timer should be set or cancelled.
  void _resolveAutoHide() {
    if (_visible) {
      _setAutoHideTimer();
    } else {
      _cancelAutoHideTimer();
    }
  }

  void _userInteractWithControls() {
    _cancelAutoHideTimer();
    _setAutoHideTimer();
  }
}
