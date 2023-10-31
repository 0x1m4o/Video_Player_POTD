import 'package:flutter/material.dart';
import 'package:smooth_video_progress/smooth_video_progress.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _videoPlayerController;

  String currentPositionInSeconds = "-:-";

  bool showPrevious = false;
  bool showNext = false;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse("https://ik.imagekit.io/demo/sample-video.mp4"),
    )..initialize().then((_) {
        setState(() {});
      });
    _videoPlayerController.addListener(() {
      setState(() {
        updatePosition();
      });
    });
    _videoPlayerController.play();
    super.initState();
  }

  void updatePosition() {
    final position = _videoPlayerController.value.position;
    setState(() {
      currentPositionInSeconds =
          "${position.inMinutes.toString()}:${position.inSeconds.toString()}";
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (showPrevious == true) {
      Future.delayed(
        const Duration(seconds: 2),
        () {
          setState(() {
            showPrevious = false;
          });
        },
      );
      setState(() {
        showNext = false;
      });
    } else if (showNext == true) {
      Future.delayed(
        const Duration(seconds: 2),
        () {
          setState(() {
            showNext = false;
          });
        },
      );
      setState(() {
        showPrevious = false;
      });
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Video Player'),
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: () {
            _videoPlayerController.value.isPlaying
                ? _videoPlayerController.pause()
                : _videoPlayerController.play();
          },
          child: AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: Stack(
                children: [
                  VideoPlayer(_videoPlayerController),
                  _videoPlayerController.value.isPlaying
                      ? Center(child: Container())
                      : Center(
                          child: Container(
                            color: Colors.black26,
                            child: const Center(
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 100.0,
                                semanticLabel: 'Play',
                              ),
                            ),
                          ),
                        ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onDoubleTap: () {
                        _videoPlayerController.seekTo(Duration(
                            seconds: _videoPlayerController
                                    .value.position.inSeconds -
                                10));

                        setState(() {
                          showPrevious = true;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: _videoPlayerController.value.size.height,
                        child: AnimatedOpacity(
                          opacity: showPrevious ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: const Center(
                            child: Icon(
                              Icons.skip_previous_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onDoubleTap: () {
                        _videoPlayerController.seekTo(Duration(
                            seconds: _videoPlayerController
                                    .value.position.inSeconds +
                                10));

                        setState(() {
                          showNext = true;
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: _videoPlayerController.value.size.height,
                        color: Colors.transparent,
                        child: AnimatedOpacity(
                          opacity: showNext ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: const Center(
                            child: Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Expanded(
                            child: SmoothVideoProgress(
                              controller: _videoPlayerController,
                              builder: (context, position, duration, _) =>
                                  _VideoProgressSlider(
                                controller: _videoPlayerController,
                                swatch: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(
                              currentPositionInSeconds,
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )),
        ));
  }
}

class _VideoProgressSlider extends StatelessWidget {
  const _VideoProgressSlider({
    required this.controller,
    required this.swatch,
  });

  final VideoPlayerController controller;
  final Color swatch;

  @override
  Widget build(BuildContext context) {
    if (controller.value.isInitialized) {
      return Theme(
        data: ThemeData.from(
          colorScheme: const ColorScheme.light(),
          useMaterial3: true,
        ),
        child: Slider(
          min: 0,
          max: controller.value.duration.inMilliseconds.toDouble(),
          value: controller.value.position.inMilliseconds.toDouble(),
          onChanged: (value) =>
              controller.seekTo(Duration(milliseconds: value.toInt())),
          onChangeStart: (_) => controller.pause(),
          onChangeEnd: (_) => controller.play(),
        ),
      );
    } else {
      return const CircularProgressIndicator(); // Display a loading indicator while video is still loading.
    }
  }
}
