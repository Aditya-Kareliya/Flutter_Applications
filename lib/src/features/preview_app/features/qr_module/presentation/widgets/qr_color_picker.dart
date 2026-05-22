import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../logic/preview_provider.dart';

class QRColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;
  final String label;
  final List<Color> presetColors;

  const QRColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
    required this.label,
    this.presetColors = const [
      Colors.black,
      Colors.white,
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ],
  });

  @override
  Widget build(BuildContext context) {
    final isCupertino = context.watch<PlatformProvider>().useCupertinoStyle;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isCupertino 
                ? CupertinoColors.label.resolveFrom(context)
                : Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...presetColors.map((color) => _ColorCircle(
              color: color,
              isSelected: selectedColor.value == color.value,
              onTap: () => onColorChanged(color),
            )),
            _CustomColorButton(
              currentColor: selectedColor,
              onColorSelected: onColorChanged,
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorCircle({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            width: isSelected ? 3 : 2,
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey.withOpacity(0.3),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}

class _CustomColorButton extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorSelected;

  const _CustomColorButton({
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isCupertino = context.watch<PlatformProvider>().useCupertinoStyle;
    
    return GestureDetector(
      onTap: () => _showColorPicker(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 2,
            color: Colors.grey.withOpacity(0.5),
          ),
          gradient: LinearGradient(
            colors: [
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.green,
              Colors.blue,
              Colors.indigo,
              Colors.purple,
            ],
          ),
        ),
        child: Center(
          child: Icon(
            isCupertino ? CupertinoIcons.color_filter : Icons.colorize,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final isCupertino = Provider.of<PlatformProvider>(context, listen: false).useCupertinoStyle;
    
    if (isCupertino) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => _CupertinoColorPicker(
          initialColor: currentColor,
          onColorSelected: onColorSelected,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => _MaterialColorPicker(
          initialColor: currentColor,
          onColorSelected: onColorSelected,
        ),
      );
    }
  }
}

class _CupertinoColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;

  const _CupertinoColorPicker({
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<_CupertinoColorPicker> createState() => _CupertinoColorPickerState();
}

class _CupertinoColorPickerState extends State<_CupertinoColorPicker> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pick Color',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  widget.onColorSelected(_selectedColor);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _generateColorPalette().length,
              itemBuilder: (context, index) {
                final color = _generateColorPalette()[index];
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: _selectedColor.value == color.value ? 3 : 1,
                        color: _selectedColor.value == color.value
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.separator,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _generateColorPalette() {
    final colors = <Color>[];
    // Generate a practical color palette with good spacing
    for (int r = 0; r < 256; r += 85) {
      for (int g = 0; g < 256; g += 85) {
        for (int b = 0; b < 256; b += 85) {
          colors.add(Color.fromRGBO(r, g, b, 1));
        }
      }
    }
    // Add some common colors
    colors.addAll([
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
      Colors.white,
    ]);
    return colors;
  }
}

class _MaterialColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;

  const _MaterialColorPicker({
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<_MaterialColorPicker> createState() => _MaterialColorPickerState();
}

class _MaterialColorPickerState extends State<_MaterialColorPicker> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick Color'),
      content: SizedBox(
        width: 300,
        height: 300,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _generateColorPalette().length,
          itemBuilder: (context, index) {
            final color = _generateColorPalette()[index];
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: _selectedColor.value == color.value ? 3 : 1,
                    color: _selectedColor.value == color.value
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onColorSelected(_selectedColor);
            Navigator.pop(context);
          },
          child: const Text('Select'),
        ),
      ],
    );
  }

  List<Color> _generateColorPalette() {
    final colors = <Color>[];
    // Generate a practical color palette with good spacing
    for (int r = 0; r < 256; r += 85) {
      for (int g = 0; g < 256; g += 85) {
        for (int b = 0; b < 256; b += 85) {
          colors.add(Color.fromRGBO(r, g, b, 1));
        }
      }
    }
    // Add some common colors
    colors.addAll([
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
      Colors.white,
    ]);
    return colors;
  }
}
