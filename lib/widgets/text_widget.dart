import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final textProvider = StateProvider<String>((ref) => "Hello, Riverpod!");

class TextWidget extends ConsumerWidget {
  const TextWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(textProvider);
    return Column(
      children: [
        Text(text, style: const TextStyle(fontSize: 20)),
        ElevatedButton(
          onPressed: () => ref.read(textProvider.notifier).state = "Text Updated!",
          child: const Text("Update Text"),
        ),
      ],
    );
  }
}
