import 'package:flutter/material.dart';
import '../../models/session.dart';
import '../../models/session_item.dart';
import '../../models/table.dart';
import '../../services/firestore_service.dart';

class SessionCard extends StatefulWidget {
  final Session session;
  final String restaurantId;
  final String branchId;
  final Map<String, TableModel> tableMap;

  const SessionCard({
    super.key,
    required this.session,
    required this.restaurantId,
    required this.branchId,
    required this.tableMap,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  bool _expanded = false;

  @override
  void didUpdateWidget(covariant SessionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu status chuyển sang paying, bật popup hóa đơn
    if (widget.session.status == SessionStatus.paying &&
        oldWidget.session.status != SessionStatus.paying) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPaymentPopup();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;

    if (session.status == SessionStatus.closed) return const SizedBox.shrink();

    final tableName = widget.tableMap[session.tableId]?.name ?? session.tableId;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            title: Text('Table: $tableName (${session.type.name})'),
            subtitle: Text(
                'Status: ${session.status.name}, Total: ${session.totalAmount}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
                PopupMenuButton<SessionStatus>(
                  onSelected: (newStatus) async {
                    await FirestoreService().updateSessionStatus(
                        widget.restaurantId,
                        widget.branchId,
                        session.id,
                        newStatus);
                    setState(() => session.status = newStatus);
                  },
                  itemBuilder: (_) => SessionStatus.values
                      .map((s) => PopupMenuItem(value: s, child: Text(s.name)))
                      .toList(),
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          ),
          if (_expanded)
            StreamBuilder<List<SessionItem>>(
              stream: FirestoreService()
                  .sessions(widget.restaurantId, widget.branchId)
                  .doc(session.id)
                  .collection('items')
                  .snapshots()
                  .map((snap) => snap.docs
                  .map((d) => SessionItem.fromMap(d.data(), d.id))
                  .toList()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  );
                }
                final items = snapshot.data!;
                if (items.isEmpty)
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('No items'),
                  );

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: items
                        .map((item) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${item.nameSnapshot} x${item.quantity}${item.note.isNotEmpty ? ' - ${item.note}' : ''}'),
                        DropdownButton<ItemStatus>(
                          value: item.status,
                          onChanged: (newStatus) async {
                            if (newStatus == null) return;
                            await FirestoreService()
                                .updateSessionItemStatus(
                              widget.restaurantId,
                              widget.branchId,
                              session.id,
                              item.id,
                              newStatus,
                            );
                            setState(() => item.status = newStatus);
                          },
                          items: ItemStatus.values
                              .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s.name)))
                              .toList(),
                        ),
                      ],
                    ))
                        .toList(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// ===== POPUP HÓA ĐƠN =====
  void _showPaymentPopup() async {
    final session = widget.session;
    final itemsSnapshot = await FirestoreService()
        .sessions(widget.restaurantId, widget.branchId)
        .doc(session.id)
        .collection('items')
        .get();

    final items = itemsSnapshot.docs
        .map((d) => SessionItem.fromMap(d.data(), d.id))
        .toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Invoice'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Restaurant: DEMO Restaurant'),
                Text('Branch: DEMO Branch'),
                Text('Table: ${widget.tableMap[session.tableId]?.name ?? session.tableId}'),
                Text('Start: ${session.createdAt.toString()}'),
                Text('End: ${session.closedAt != null ? session.closedAt.toString() : '-'}'),
                const SizedBox(height: 12),
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...items.map((i) {
                  final total = i.priceSnapshot * i.quantity;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${i.nameSnapshot} x${i.quantity}')),
                      Text('${i.priceSnapshot}'),
                      Text('Total: $total'),
                    ],
                  );
                }),
                const SizedBox(height: 12),
                Text(
                  'Grand Total: ${items.fold<double>(0.0, (sum, i) => sum + i.priceSnapshot * i.quantity)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Khi confirm payment, chuyển status sang closed
              await FirestoreService().updateSessionStatus(
                  widget.restaurantId,
                  widget.branchId,
                  session.id,
                  SessionStatus.closed);
              setState(() => session.status = SessionStatus.closed);
            },
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }
}
