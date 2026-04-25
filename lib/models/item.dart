import 'package:cloud_firestore/cloud_firestore.dart';

class LostFoundItem {
  final String id;
  final String title;
  final String category;
  final String description;
  final String location;
  final DateTime date;
  final String status;
  final String? imageUrl;
  final String userId;
  final String postedByName;
  final String postedByRegId;

  LostFoundItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.date,
    required this.status,
    this.imageUrl,
    required this.userId,
    required this.postedByName,
    required this.postedByRegId,
  });

  factory LostFoundItem.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return LostFoundItem(
      id: doc.id,
      title: d['title'] ?? '',
      category: d['category'] ?? 'Lost',
      description: d['description'] ?? '',
      location: d['location'] ?? '',
      date: (d['date'] as Timestamp).toDate(),
      status: d['status'] ?? 'Open',
      imageUrl: d['imageUrl'],
      userId: d['userId'] ?? '',
      postedByName: d['postedByName'] ?? '',
      postedByRegId: d['postedByRegId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category,
        'description': description,
        'location': location,
        'date': Timestamp.fromDate(date),
        'status': status,
        'imageUrl': imageUrl,
        'userId': userId,
        'postedByName': postedByName,
        'postedByRegId': postedByRegId,
      };
}
