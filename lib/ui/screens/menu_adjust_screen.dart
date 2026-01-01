import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../services/firestore_service.dart';

enum ItemFilter { all, available, unavailable }

class AdminScreen extends StatefulWidget {
  final VoidCallback onBack;

  // ❗ KHÔNG required – để HomeScreen không nổ
  final String restaurantId;
  final String branchId;
  final FirestoreService firestore;

  AdminScreen({
    super.key,
    required this.onBack,
    String? restaurantId,
    String? branchId,
    FirestoreService? firestore,
  })  : restaurantId = restaurantId ?? 'ickJ0BIvEs7QJaHZTdyE',
        branchId = branchId ?? 't1GJgJlLQXebFyGIBtF8',
        firestore = firestore ?? FirestoreService();

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String? _selectedCategoryId;
  String _searchText = '';
  ItemFilter _filter = ItemFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add category',
            onPressed: _showCreateCategoryDialog,
          ),
        ],
      ),
      body: Row(
        children: [
          /// ===== CATEGORY LIST =====
          SizedBox(
            width: 280,
            child: StreamBuilder<List<MenuCategory>>(
              stream: widget.firestore.streamMenuCategories(
                widget.restaurantId,
                widget.branchId,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = snapshot.data!
                    .where((c) => c.isActive)
                    .toList()
                  ..sort((a, b) => a.order.compareTo(b.order));

                if (categories.isEmpty) {
                  return const Center(child: Text('No categories'));
                }

                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final c = categories[index];
                    return ListTile(
                      title: Text(c.name),
                      selected: c.id == _selectedCategoryId,
                      onTap: () =>
                          setState(() => _selectedCategoryId = c.id),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => _showEditCategoryDialog(c),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const VerticalDivider(width: 1),

          /// ===== MENU ITEMS =====
          Expanded(
            child: _selectedCategoryId == null
                ? const Center(child: Text('Select a category'))
                : Column(
              children: [
                _buildItemToolbar(),
                Expanded(
                  child: StreamBuilder<List<MenuItem>>(
                    stream: widget.firestore.streamMenuItems(
                      widget.restaurantId,
                      widget.branchId,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            snapshot.error.toString(),
                            style:
                            const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final items = _applyFilter(
                        snapshot.data!
                            .where((i) =>
                        i.categoryId ==
                            _selectedCategoryId)
                            .toList(),
                      );

                      if (items.isEmpty) {
                        return const Center(
                            child: Text('No items'));
                      }

                      return ListView(
                        children: items.map((item) {
                          return ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                                '${item.price} ${item.currency}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: item.isAvailable,
                                  onChanged: (v) {
                                    widget.firestore
                                        .updateMenuItemAvailability(
                                      widget.restaurantId,
                                      widget.branchId,
                                      item.id,
                                      v,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon:
                                  const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showEditItemDialog(
                                          item),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ===== TOOLBAR =====

  Widget _buildItemToolbar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          SizedBox(
            width: 240,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search item...',
              ),
              onChanged: (v) =>
                  setState(() => _searchText = v.toLowerCase()),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<ItemFilter>(
            value: _filter,
            onChanged: (v) => setState(() => _filter = v!),
            items: const [
              DropdownMenuItem(
                  value: ItemFilter.all, child: Text('All')),
              DropdownMenuItem(
                  value: ItemFilter.available,
                  child: Text('Available')),
              DropdownMenuItem(
                  value: ItemFilter.unavailable,
                  child: Text('Unavailable')),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add item'),
            onPressed: _showCreateItemDialog,
          ),
        ],
      ),
    );
  }

  List<MenuItem> _applyFilter(List<MenuItem> items) {
    return items.where((item) {
      if (_searchText.isNotEmpty &&
          !item.name.toLowerCase().contains(_searchText)) {
        return false;
      }
      if (_filter == ItemFilter.available && !item.isAvailable) {
        return false;
      }
      if (_filter == ItemFilter.unavailable && item.isAvailable) {
        return false;
      }
      return true;
    }).toList();
  }

  /// ===== CATEGORY DIALOGS =====

  void _showCreateCategoryDialog() {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New category'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.firestore.createMenuCategory(
                widget.restaurantId,
                widget.branchId,
                ctrl.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(MenuCategory c) {
    final ctrl = TextEditingController(text: c.name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit category'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.firestore.disableMenuCategory(
                widget.restaurantId,
                widget.branchId,
                c.id,
              );
              Navigator.pop(context);
            },
            child: const Text('Disable'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.firestore.renameMenuCategory(
                widget.restaurantId,
                widget.branchId,
                c.id,
                ctrl.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// ===== ITEM DIALOGS =====

  void _showCreateItemDialog() => _showItemDialog();
  void _showEditItemDialog(MenuItem item) =>
      _showItemDialog(item: item);

  void _showItemDialog({MenuItem? item}) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final priceCtrl =
    TextEditingController(text: item?.price.toString() ?? '');
    final descCtrl =
    TextEditingController(text: item?.description ?? '');
    final imgCtrl =
    TextEditingController(text: item?.imageUrl ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'New item' : 'Edit item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                  hintText: 'VD: Trà sữa trân châu',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: 'VD: 25000',
                  suffixText: 'VND',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Mô tả ngắn (có thể để trống)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imgCtrl,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://... (có thể để trống)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final newItem = MenuItem(
                id: item?.id ?? '',
                categoryId: _selectedCategoryId!,
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                price: double.tryParse(priceCtrl.text) ?? 0,
                imageUrl: imgCtrl.text.trim(),
                currency: 'VND',
                isAvailable: true,
                createdAt: item?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              if (item == null) {
                widget.firestore.createMenuItem(
                  widget.restaurantId,
                  widget.branchId,
                  newItem,
                );
              } else {
                widget.firestore.updateMenuItem(
                  widget.restaurantId,
                  widget.branchId,
                  newItem,
                );
              }

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
