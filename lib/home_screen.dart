import 'package:flutter/material.dart';
import 'widgets/counter_widget.dart';
import 'widgets/toggle_widget.dart';
import 'widgets/text_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("Empty Dialog"),
        content: SizedBox(height: 50, child: Center(child: Text("This is empty."))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Demo")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image
            Image.asset("assets/sample.png", height: 200),

            const SizedBox(height: 20),

            // Widgets
            const CounterWidget(),
            const ToggleWidget(),
            const TextWidget(),

            const SizedBox(height: 20),

            // Option Button
            ElevatedButton(
              onPressed: () => _openDialog(context),
              child: const Text("Open Dialog"),
            ),
          ],
        ),
      ),
    );
  }
}
