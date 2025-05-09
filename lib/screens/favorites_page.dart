import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesPage extends StatelessWidget {
  final String userId = 'demo_user';

  @override
  Widget build(BuildContext context) {
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites');

    return Scaffold(
      appBar: AppBar(title: Text('Mes favoris')),
      body: StreamBuilder<QuerySnapshot>(
        stream: favRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text("Aucun favori pour l'instant"));
          }

          return ListView(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                leading: Image.network(data['image']),
                title: Text(data['title']),
                subtitle: Text(data['artist']),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
