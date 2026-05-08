import 'package:flutter/material.dart';

import '../models/course.dart';

class StudyPage extends StatefulWidget {
  final List<Course> cards;

  const StudyPage({super.key, required this.cards});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  int _index = 0;
  bool _showFront = true;

  void _flipCard() {
    setState(() {
      _showFront = !_showFront;
    });
  }

  void _goNext() {
    if (_index < widget.cards.length - 1) {
      setState(() {
        _index++;
        _showFront = true;
      });
    }
  }

  void _goPrevious() {
    if (_index > 0) {
      setState(() {
        _index--;
        _showFront = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.cards[_index];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Cards'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Card ${_index + 1} of ${widget.cards.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedCrossFade(
                  firstChild: _buildCardSide(
                    text: card.title,
                    label: 'Front',
                    key: const ValueKey('front'),
                  ),
                  secondChild: _buildCardSide(
                    text: card.description,
                    label: 'Back',
                    key: const ValueKey('back'),
                  ),
                  crossFadeState: _showFront ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 250),
                  firstCurve: Curves.easeOut,
                  secondCurve: Curves.easeOut,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _index > 0 ? _goPrevious : null,
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _index < widget.cards.length - 1 ? _goNext : null,
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSide({
    required String text,
    required String label,
    required Key key,
  }) {
    return Card(
      key: key,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
