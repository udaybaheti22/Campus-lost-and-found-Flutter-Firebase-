import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/claim.dart';
import '../services/auth_service.dart';
import '../services/item_service.dart';

class ItemDetailScreen extends StatefulWidget {
  final LostFoundItem item;
  const ItemDetailScreen({super.key, required this.item});
  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final _auth = AuthService();
  final _itemService = ItemService();
  final _claimController = TextEditingController();

  bool get _isOwner => widget.item.userId == _auth.currentUserId;
  bool get _isFoundItem => widget.item.category == 'Found';

  void _showClaimDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_dialogTitle),
        content: TextField(
          controller: _claimController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: _dialogHint,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitClaim();
              },
              child: Text(_actionLabel)),
        ],
      ),
    );
  }

  Future<void> _submitClaim() async {
    if (_claimController.text.trim().isEmpty) return;
    try {
      final name = await _auth.getDisplayName();
      final claim = ClaimRequest(
        id: '',
        itemId: widget.item.id,
        claimantId: _auth.currentUserId,
        claimantName: name,
        claimantRegId: _auth.currentRegId,
        message: _claimController.text.trim(),
        createdAt: DateTime.now(),
        status: 'Pending',
      );
      await _itemService.submitClaim(claim);
      _claimController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_successMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(item.imageUrl!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover),
              )
            else
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: item.category == 'Lost'
                      ? Colors.red[50]
                      : Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.category == 'Lost'
                      ? Icons.search_off
                      : Icons.check_circle_outline,
                  size: 80,
                  color: item.category == 'Lost'
                      ? Colors.red[200]
                      : Colors.green[200],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                _badge(item.category,
                    item.category == 'Lost' ? Colors.red : Colors.green),
                const SizedBox(width: 8),
                _badge(item.status, _statusColor(item.status)),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.title, 'Title', item.title),
            _infoRow(Icons.description, 'Description', item.description),
            _infoRow(Icons.location_on, 'Location', item.location),
            _infoRow(Icons.calendar_today, 'Date',
                item.date.toLocal().toString().split(' ')[0]),
            _infoRow(Icons.badge_outlined, 'Posted by',
                '${item.postedByName} (${item.postedByRegId})'),
            const Divider(height: 32),

            if (_isOwner) ...[
              Text(_ownerSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              StreamBuilder<List<ClaimRequest>>(
                stream: _itemService.getClaimsForItem(item.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final claims = snapshot.data ?? [];
                  if (claims.isEmpty) {
                    return Text(_emptyOwnerState,
                        style: const TextStyle(color: Colors.grey));
                  }
                  return Column(
                      children:
                          claims.map((c) => _claimCard(c)).toList());
                },
              ),
            ] else ...[
              FutureBuilder<bool>(
                future: _itemService.hasUserClaimed(
                    item.id, _auth.currentUserId),
                builder: (context, snapshot) {
                  final alreadyClaimed = snapshot.data ?? false;
                  if (alreadyClaimed) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.hourglass_top,
                              color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                                _pendingMessage,
                                style:
                                    TextStyle(color: Colors.orange)),
                          ),
                        ],
                      ),
                    );
                  }
                  if (item.status == 'Open') {
                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _showClaimDialog,
                        icon: Icon(_isFoundItem
                            ? Icons.handshake
                            : Icons.notifications_active),
                        label: Text(_actionLabel),
                      ),
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'This item is ${item.status.toLowerCase()}.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _claimCard(ClaimRequest claim) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(claim.claimantName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    Text(claim.claimantRegId,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
                _badge(claim.status, _claimStatusColor(claim.status)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(claim.message),
            ),
            const SizedBox(height: 4),
            Text(
              '${_submissionLabel}: ${claim.createdAt.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            if (claim.status == 'Pending' &&
                widget.item.status != 'Closed') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    onPressed: () => _itemService.approveClaim(
                        claim.id, widget.item.id),
                    icon: const Icon(Icons.check,
                        color: Colors.white, size: 16),
                    label: Text(_approveLabel,
                        style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _itemService.rejectClaim(claim.id),
                    icon: const Icon(Icons.close, size: 16),
                    label: Text(_rejectLabel),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.green;
      case 'Claimed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _claimStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String get _dialogTitle =>
      _isFoundItem ? 'Submit Claim' : 'Notify Owner';

  String get _dialogHint => _isFoundItem
      ? 'Describe why this item belongs to you (unique features, contents, etc.)...'
      : 'Describe where you found this item and how the owner can verify it...';

  String get _actionLabel =>
      _isFoundItem ? 'Claim This Item' : 'I Found This Item';

  String get _successMessage => _isFoundItem
      ? 'Claim submitted! Waiting for owner approval.'
      : 'Owner notified. Waiting for their response.';

  String get _ownerSectionTitle =>
      _isFoundItem ? 'Claim Requests' : 'Found Notifications';

  String get _emptyOwnerState => _isFoundItem
      ? 'No claims yet.'
      : 'No one has reported finding this item yet.';

  String get _pendingMessage => _isFoundItem
      ? 'Your claim is pending owner approval.'
      : 'Your notification has been sent to the owner.';

  String get _submissionLabel =>
      _isFoundItem ? 'Submitted' : 'Notified';

  String get _approveLabel =>
      _isFoundItem ? 'Approve' : 'Mark Resolved';

  String get _rejectLabel =>
      _isFoundItem ? 'Reject' : 'Dismiss';

  @override
  void dispose() {
    _claimController.dispose();
    super.dispose();
  }
}
