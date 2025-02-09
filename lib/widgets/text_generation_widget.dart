import 'package:flutter/material.dart';
import '../services/pollinations_service.dart';

class TextGenerationWidget extends StatefulWidget {
  const TextGenerationWidget({super.key});

  @override
  State<TextGenerationWidget> createState() => _TextGenerationWidgetState();
}

class _TextGenerationWidgetState extends State<TextGenerationWidget> {
  final _pollinationsService = PollinationsService();
  final _promptController = TextEditingController();
  String _generatedText = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _promptController.dispose();
    _pollinationsService.dispose();
    super.dispose();
  }

  Future<void> _generateText() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _pollinationsService.generateText(_promptController.text);
      setState(() {
        _generatedText = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _promptController,
            decoration: const InputDecoration(
              labelText: 'Enter your prompt',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _generateText,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Generate Text'),
        ),
        if (_generatedText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_generatedText),
              ),
            ),
          ),
      ],
    );
  }
}
