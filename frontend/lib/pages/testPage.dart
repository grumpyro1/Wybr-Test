import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wybr/provider/wms_provider.dart';

class Testpage extends ConsumerStatefulWidget {
  const Testpage({super.key});

  @override
  ConsumerState<Testpage> createState() => _TestpageState();
}

class _TestpageState extends ConsumerState<Testpage> {
  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(dataProvider("users"));

    return Scaffold(
      appBar: AppBar(title: const Text("Test Page")),
      body: dataAsync.when(
        data: (data) {
          // Print each item to console
          for (var item in data) {
            print("Name: ${item['name']}, Email: ${item['email']}");
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return ListTile(
                title: Text(item['name']),
                subtitle: Text(item['email']),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),

        
      ),
    );
  }
}