import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SlideInOutWidget(),
    );
  }
}

class SlideInOutWidget extends StatefulWidget {
  const SlideInOutWidget({Key? key}) : super(key: key);

  @override
  _SlideInOutWidgetState createState() => _SlideInOutWidgetState();
}

class _SlideInOutWidgetState extends State<SlideInOutWidget>
    with SingleTickerProviderStateMixin {
  List<String> seasons = ['winter', 'spring', 'summer', 'autumn'];
  var seasonIndex = 0;
  var horizontalSwipe = 0.0;
  int threshold = 8;
  AnimationController? _animationController;
  Animation<Offset>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 0),
    ).animate(_animationController!);
  }

  void changeSeason(int delta) {
    setState(() {
      seasonIndex = (seasonIndex + delta) % seasons.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(seasons[seasonIndex]),
      ),
      body: Column(
        children: [
          Expanded(
            child: SizedBox.expand(
              child: GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  horizontalSwipe = details.velocity.pixelsPerSecond.dx;
                  if (horizontalSwipe > threshold) {
                    // Swipe right
                    changeSeason(-1);
                    _animation = Tween<Offset>(
                      begin: const Offset(-1, 0),
                      end: const Offset(0, 0),
                    ).animate(_animationController!);
                    _animationController!.forward(from: 0);
                  } else if (horizontalSwipe < -threshold) {
                    // Swipe left
                    changeSeason(1);
                    _animation = Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: const Offset(0, 0),
                    ).animate(_animationController!);
                    _animationController!.forward(from: 0);
                  }
                },
                child: AnimatedBuilder(
                  animation: _animationController!,
                  builder: (BuildContext context, Widget? child) {
                    return Stack(
                      children: [
                        slideTransition(
                          child: Container(
                            key: ValueKey<int>(seasonIndex),
                            color: Colors.grey,
                            child: Center(
                              child: Text(
                                seasons[seasonIndex],
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          position: _animation!,
                        ),
                        slideTransition(
                          child: Container(
                            key: ValueKey<int>(
                                (seasonIndex - 1) % seasons.length),
                            color: Colors.green,
                            child: Center(
                              child: Text(
                                horizontalSwipe < -threshold
                                    ? seasons[
                                        (seasonIndex - 1) % seasons.length]
                                    : horizontalSwipe > threshold
                                        ? seasons[
                                            (seasonIndex + 1) % seasons.length]
                                        : seasons[seasonIndex],
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          position: Tween<Offset>(
                            begin: const Offset(0, 0),
                            end: horizontalSwipe > threshold
                                ? const Offset(1, 0)
                                : horizontalSwipe < -threshold
                                    ? const Offset(-1, 0)
                                    : const Offset(0, 0),
                          ).animate(_animationController!),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget slideTransition(
      {required Widget child, required Animation<Offset> position}) {
    return SlideTransition(
      position: position,
      child: child,
    );
  }
}
