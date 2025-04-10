import 'package:flutter/material.dart';

class ResponsiveScreen extends StatelessWidget {
  const ResponsiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          String screenSize = "Small";

          if (width >= 1024) {
            screenSize = "Large";
          } else if (width >= 600) {
            screenSize = "Medium";
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Screen Size: $screenSize',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: width < 600
                      ? Column(
                          children: _buildBoxes(),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _buildBoxes(),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildBoxes() {
    return List.generate(4, (index) {
      return Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[(index + 1) * 200],
          borderRadius: BorderRadius.circular(12),
        ),
      );
    });
  }
}
