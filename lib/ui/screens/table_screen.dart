import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/session.dart';
import '../../state/app_state.dart';
import '../widgets/table_card.dart';
import '../../services/firestore_service.dart';
import '../../models/table.dart';

class TableScreen extends StatelessWidget {
  final VoidCallback onBack;
  final String zoneId = 'ZKu00SLzf3EGk0qfkaVV';

  const TableScreen({super.key, required this.onBack});

  static const double zoneWidth = 1200;
  static const double zoneHeight = 800;
  static const double gridSize = 20;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final firestore = FirestoreService();

    final inactiveTables =
    appState.tables.where((t) => !t.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        actions: [
          /// CREATE TABLE
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create table',
            onPressed: () {
              _showCreateTableDialog(
                context,
                firestore,
                appState,
              );
            },
          ),

          /// INACTIVE TABLES
          if (inactiveTables.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: DropdownButton<TableModel>(
                hint: const Text(
                  'Inactive tables',
                  style: TextStyle(color: Colors.black),
                ),
                dropdownColor: Colors.grey[900],
                iconEnabledColor: Colors.grey,
                onChanged: (table) async {
                  if (table == null) return;

                  await firestore.updateTable(
                    appState.restaurantId,
                    appState.branchId,
                    zoneId,
                    table..isActive = true,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                      Text('Table ${table.name} reactivated'),
                    ),
                  );
                },
                items: inactiveTables
                    .map(
                      (t) => DropdownMenuItem<TableModel>(
                    value: t,
                    child: Text(
                      t.name,
                      style:
                      const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
        ],
      ),
      body: Center(
        child: Container(
          width: zoneWidth,
          height: zoneHeight,
          color: Colors.grey[200],
          child: DragTarget<TableModel>(
            onAcceptWithDetails: (details) async {
              final table = details.data;

              final RenderBox box =
              context.findRenderObject() as RenderBox;
              final local = box.globalToLocal(details.offset);

              double newX = local.dx - table.width / 2;
              double newY = local.dy - table.height / 2;

              // SNAP GRID
              newX = (newX / gridSize).round() * gridSize;
              newY = (newY / gridSize).round() * gridSize;

              // BOUNDARY
              newX = newX.clamp(0, zoneWidth - table.width);
              newY = newY.clamp(0, zoneHeight - table.height);

              await firestore.updateTable(
                appState.restaurantId,
                appState.branchId,
                zoneId,
                table
                  ..x = newX
                  ..y = newY,
              );
            },
            builder: (context, _, __) => Stack(
              children: appState.tables
                  .where((t) => t.isActive)
                  .map((table) {
                final hasOpenSession = appState.sessions.any(
                      (s) =>
                  s.tableId == table.id &&
                      s.status != SessionStatus.closed,
                );

                return Positioned(
                  left: table.x,
                  top: table.y,
                  width: table.width,
                  height: table.shape == 'circle'
                      ? table.width
                      : table.height,
                  child: TableCard(
                    table: table,
                    hasOpenSession: hasOpenSession,

                    /// TAP = open session
                    onTap: () async {
                      if (hasOpenSession) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Table ${table.name} already has an open session',
                            ),
                          ),
                        );
                        return;
                      }

                      final session = Session(
                        id: '',
                        tableId: table.id,
                        type: SessionType.dine_in,
                        status: SessionStatus.open,
                        totalAmount: 0,
                        createdAt: DateTime.now(),
                        createdBy: 'WAITER',
                      );

                      await firestore.createSession(
                        appState.restaurantId,
                        appState.branchId,
                        session,
                      );
                    },

                    /// LONG PRESS = deactivate
                    onDeactivate: () async {
                      await firestore.updateTable(
                        appState.restaurantId,
                        appState.branchId,
                        zoneId,
                        table..isActive = false,
                      );
                    },

                    /// RESIZE (chỉ khi KHÔNG có session)
                    onChangeSize: (newWidth, newHeight) async {
                      await firestore.updateTable(
                        appState.restaurantId,
                        appState.branchId,
                        zoneId,
                        table
                          ..width = newWidth
                          ..height = newHeight,
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// ===== POPUP CREATE TABLE =====
  void _showCreateTableDialog(
      BuildContext context,
      FirestoreService firestore,
      AppState appState,
      ) {
    final nameCtrl = TextEditingController();
    final widthCtrl = TextEditingController(text: '100');
    final heightCtrl = TextEditingController(text: '100');

    String shape = 'rectangle';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create new table'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widthCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Width'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: heightCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Height'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: shape,
                    onChanged: (v) {
                      if (v != null) setState(() => shape = v);
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'rectangle',
                        child: Text('rectangle'),
                      ),
                      DropdownMenuItem(
                        value: 'circle',
                        child: Text('circle'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;

                    final w = double.parse(widthCtrl.text);
                    final h = shape == 'circle'
                        ? w
                        : double.parse(heightCtrl.text);

                    final table = TableModel(
                      id: '',
                      name: nameCtrl.text.trim(),
                      shape: shape,
                      width: w,
                      height: h,
                      x: (zoneWidth - w) / 2,
                      y: (zoneHeight - h) / 2,
                      isActive: true,
                    );

                    await firestore.createTable(
                      appState.restaurantId,
                      appState.branchId,
                      zoneId,
                      table,
                    );

                    Navigator.pop(context);
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
