import 'package:flutter/material.dart';
import '../../models/table.dart';

enum TableSizePreset { s, m, l, xl }

const tableSizeMap = {
  TableSizePreset.s: Size(80, 80),
  TableSizePreset.m: Size(120, 120),
  TableSizePreset.l: Size(160, 160),
  TableSizePreset.xl: Size(200, 200),
};

typedef TableChangeSizeCallback = void Function(
    double newWidth,
    double newHeight,
    );

class TableCard extends StatelessWidget {
  final TableModel table;
  final bool hasOpenSession;
  final VoidCallback onTap;
  final VoidCallback onDeactivate;
  final TableChangeSizeCallback onChangeSize;

  const TableCard({
    super.key,
    required this.table,
    required this.hasOpenSession,
    required this.onTap,
    required this.onDeactivate,
    required this.onChangeSize,
  });

  bool get isCircle => table.shape == 'circle';

  @override
  Widget build(BuildContext context) {
    final color = hasOpenSession ? Colors.orange : Colors.green;
    final body = _buildBody(context, color);

    return Draggable<TableModel>(
      data: table,
      feedback: Opacity(opacity: 0.7, child: body),
      childWhenDragging: const SizedBox.shrink(),
      child: body,
    );
  }

  Widget _buildBody(BuildContext context, Color color) {
    final width = table.width;
    final height = isCircle ? table.width : table.height;

    return GestureDetector(
      onTap: onTap,
      onLongPress: hasOpenSession
          ? null
          : () => _showEditDialog(context),
      child: SizedBox(
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black),
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                table.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasOpenSession ? 'Served' : 'Free',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== EDIT TABLE POPUP =====
  void _showEditDialog(BuildContext context) {
    final widthCtrl =
    TextEditingController(text: table.width.toInt().toString());
    final heightCtrl =
    TextEditingController(text: table.height.toInt().toString());

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Edit table "${table.name}"'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===== PRESET SIZE =====
                const Text(
                  'Preset size',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: TableSizePreset.values.map((preset) {
                    return ElevatedButton(
                      onPressed: () {
                        final size = tableSizeMap[preset]!;
                        final w = size.width;
                        final h = isCircle ? w : size.height;

                        onChangeSize(w, h);
                        Navigator.pop(context);
                      },
                      child: Text(preset.name.toUpperCase()),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                /// ===== CUSTOM SIZE =====
                const Text(
                  'Custom size',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: widthCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Width',
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: heightCtrl,
                  keyboardType: TextInputType.number,
                  enabled: !isCircle,
                  decoration: InputDecoration(
                    labelText: 'Height',
                    helperText:
                    isCircle ? 'Circle uses width only' : null,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final w = double.tryParse(widthCtrl.text);
                      final h = isCircle
                          ? w
                          : double.tryParse(heightCtrl.text);

                      if (w == null || h == null) return;

                      onChangeSize(w, h);
                      Navigator.pop(context);
                    },
                    child: const Text('Apply size'),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                /// ===== DEACTIVATE =====
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Deactivate table'),
                          content: Text(
                            'Deactivate table "${table.name}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text('Deactivate'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) onDeactivate();
                    },
                    child: const Text('Deactivate table'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
