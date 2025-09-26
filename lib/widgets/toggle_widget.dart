import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final toggleProvider = StateProvider<bool>((ref) => false);

class ToggleWidget extends ConsumerWidget {
  const ToggleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOn = ref.watch(toggleProvider);
    return SwitchListTile(
      title: const Text("Toggle Switch"),
      value: isOn,
      onChanged: (val) => ref.read(toggleProvider.notifier).state = val,
    );
  }
}
