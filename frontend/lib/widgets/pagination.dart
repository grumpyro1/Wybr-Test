import 'package:flutter/material.dart';

class Pagination extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int rowsPerPage;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const Pagination({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.rowsPerPage,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: currentPage > 0 ? onPrevious : null,
            child: const Text("Previous"),
          ),
          Text(
            "Page ${currentPage + 1} of ${(totalItems / rowsPerPage).ceil()}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: (currentPage + 1) * rowsPerPage < totalItems
                ? onNext
                : null,
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }
}
