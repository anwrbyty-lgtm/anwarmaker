import 'package:flutter/material.dart';

class MathSymbolsBar extends StatelessWidget {
  final Function(String) onSymbolSelected;

  const MathSymbolsBar({super.key, required this.onSymbolSelected});

  final List<String> symbols = const [
    'π', '√', '²', '³', '½', '¼', '±', '≠', '≈', '≤', '≥', '∞', 'Δ', 'θ', 'Ω', '∫', '∑', '→'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.grey[200],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: symbols.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => onSymbolSelected(symbols[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: Text(
                symbols[index],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
