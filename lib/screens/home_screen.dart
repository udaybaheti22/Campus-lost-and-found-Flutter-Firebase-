import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/auth_service.dart';
import '../services/item_service.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _itemService = ItemService();
  final _auth = AuthService();
  String _search = '';
  String _searchLocation = '';
  String? _filterCategory;
  String? _filterStatus;

  List<LostFoundItem> _applyFilters(List<LostFoundItem> items) {
    return items.where((item) {
      final q = _search.toLowerCase();
      final lq = _searchLocation.toLowerCase();
      final matchSearch = q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q);
      final matchLocation =
          lq.isEmpty || item.location.toLowerCase().contains(lq);
      final matchCat =
          _filterCategory == null || item.category == _filterCategory;
      final matchStatus = _filterStatus == null
          ? item.status != 'Closed'
          : item.status == _filterStatus;
      return matchSearch && matchLocation && matchCat && matchStatus;
    }).toList();
  }

  void _toggleCategory(String val) =>
      setState(() => _filterCategory = _filterCategory == val ? null : val);

  void _toggleStatus(String val) =>
      setState(() => _filterStatus = _filterStatus == val ? null : val);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Lost & Found'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Search by title or description...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                child: TextField(
                  onChanged: (v) => setState(() => _searchLocation = v),
                  decoration: InputDecoration(
                    hintText: 'Search by location...',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  children: [
                    _chip('Lost', _filterCategory == 'Lost',
                        () => _toggleCategory('Lost'), Colors.red),
                    _chip('Found', _filterCategory == 'Found',
                        () => _toggleCategory('Found'), Colors.green),
                    const SizedBox(width: 12),
                    _chip('Open', _filterStatus == 'Open',
                        () => _toggleStatus('Open'), Colors.blue),
                    _chip('Claimed', _filterStatus == 'Claimed',
                        () => _toggleStatus('Claimed'), Colors.orange),
                    _chip('Closed', _filterStatus == 'Closed',
                        () => _toggleStatus('Closed'), Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<LostFoundItem>>(
        stream: _itemService.getItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = _applyFilters(snapshot.data ?? []);
          if (items.isEmpty) {
            return const Center(child: Text('No items found.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: item.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.imageUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover),
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: item.category == 'Lost'
                                ? Colors.red[50]
                                : Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            item.category == 'Lost'
                                ? Icons.search_off
                                : Icons.check_circle_outline,
                            color: item.category == 'Lost'
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                  title: Text(item.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${item.category} • ${item.location}\n'
                    '${item.date.toLocal().toString().split(' ')[0]}',
                  ),
                  isThreeLine: true,
                  trailing: _statusBadge(item.status),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ItemDetailScreen(item: item)),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, '/report-item'),
        icon: const Icon(Icons.add),
        label: const Text('Report Item'),
      ),
    );
  }

  Widget _chip(
      String label, bool selected, VoidCallback onTap, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? color : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected ? color : Colors.grey.shade300),
          ),
          child: Text(label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              )),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = status == 'Open'
        ? Colors.green
        : status == 'Claimed'
            ? Colors.orange
            : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(status,
          style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }
}
