// lib/screens/speed_reading_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

class SpeedReadingScreen extends StatefulWidget {
  final String text;
  final String mode; // 'word' 또는 'highlight'

  const SpeedReadingScreen({
    super.key,
    required this.text,
    required this.mode,
  });

  @override
  State<SpeedReadingScreen> createState() => _SpeedReadingScreenState();
}

class _SpeedReadingScreenState extends State<SpeedReadingScreen>
    with SingleTickerProviderStateMixin {
  late List<String> words;
  int currentIndex = 0;
  double speed = 0.2;
  Timer? timer;
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    words = widget.text
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (speed * 1000).toInt()),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  void startReading() {
    timer?.cancel();
    timer =
        Timer.periodic(Duration(milliseconds: (speed * 1000).toInt()), (timer) {
      if (currentIndex < words.length - 1) {
        setState(() {
          currentIndex++;
        });
        _controller.reset();
        _controller.forward();
      } else {
        timer.cancel();
      }
    });
  }

  void stopReading() {
    timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (currentIndex + 1) / words.length;

    return Scaffold(
      appBar: AppBar(title: const Text("속독 모드")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 8.0,
              children: [0.1, 0.2, 0.3, 0.4, 0.5].map((s) {
                return ChoiceChip(
                  label: Text('${s}s'),
                  selected: speed == s,
                  onSelected: (_) {
                    setState(() {
                      speed = s;
                      _controller.duration =
                          Duration(milliseconds: (speed * 1000).toInt());
                      stopReading();
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text('${(progress * 100).toStringAsFixed(1)}% 읽음'),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _opacity,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacity.value,
                      child: widget.mode == 'word'
                          ? Text(
                              words[currentIndex],
                              style: const TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )
                          : RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: words.asMap().entries.map((entry) {
                                  int idx = entry.key;
                                  String word = entry.value;
                                  return TextSpan(
                                    text: "$word ",
                                    style: TextStyle(
                                      fontSize: 28,
                                      color: idx == currentIndex
                                          ? Colors.black
                                          : Colors.grey[400],
                                      fontWeight: idx == currentIndex
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: startReading,
                  child: const Text("▶ 시작"),
                ),
                ElevatedButton(
                  onPressed: stopReading,
                  child: const Text("⏸ 정지"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
