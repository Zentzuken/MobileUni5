import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterProvider = StateProvider<int>((ref) => 0);

class CounterWidget extends ConsumerWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Column(
      children: [
        Text("Counter: $count", style: const TextStyle(fontSize: 18)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => ref.read(counterProvider.notifier).state++,
            ),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => ref.read(counterProvider.notifier).state--,
            ),
          ],
        ),
      ],
    );
  }
}
