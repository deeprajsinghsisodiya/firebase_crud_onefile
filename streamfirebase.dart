import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// [START listen_to_realtime_updates_listen_for_updates2]
class UserInformation extends StatefulWidget {
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {

  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('users').where("userid", isEqualTo: "userid").snapshots();

  final db = FirebaseFirestore.instance;
User? user = FirebaseAuth.instance.currentUser;

  void listenToRealtimeUpdates_viewUpdatesBetweenChanges() {
    // [START listen_to_realtime_updates_view_updates_between_changes]
    final listener = db
        .collection("cities")
        .where("state", isEqualTo: "CA")
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            print("New City: ${change.doc.data()}");
            break;
          case DocumentChangeType.modified:
            print("Modified City: ${change.doc.data()}");
            break;
          case DocumentChangeType.removed:
            print("Removed City: ${change.doc.data()}");
            break;
        }
      }
    });
    // [END listen_to_realtime_updates_view_updates_between_changes]
    listener.cancel();
  }
  void listenToRealtimeUpdates_detachAListener() {
    // [START listen_to_realtime_updates_detach_a_listener]
    final collection = db.collection("cities");
    final listener = collection.snapshots().listen((event) {
      print('hello');
    });
    listener.cancel();
    // [END listen_to_realtime_updates_detach_a_listener]
  }


    @override

    void listenToRealtimeUpdates_eventsForLocalChanges() {
      // [START listen_to_realtime_updates_events_for_local_changes]
      final docRef = db.collection("cities").doc("SF");
      docRef.snapshots().listen(
            (event) {
          final source = (event.metadata.hasPendingWrites) ? "Local" : "Server";
          print("$source data: ${event.data()}");
        },
        onError: (error) => print("Listen failed: $error"),
      );

      // [END listen_to_realtime_updates_events_for_local_changes]
    }

  void listenToRealtimeUpdates_listToMultipleDocuments() {
    // [START listen_to_realtime_updates_list_to_multiple_documents]
    db
        .collection("cities")
        .where("state", isEqualTo: "CA")
        .snapshots()
        .listen((event) {
      final cities = [];
      for (var doc in event.docs) {
        cities.add(doc.data()["name"]);
      }
      print("cities in CA: ${cities.join(", ")}");
    });
    // [END listen_to_realtime_updates_list_to_multiple_documents]
  }


  void listenToRealtimeUpdates_handleListenErrors() {
    // [START listen_to_realtime_updates_handle_listen_errors]
    final docRef = db.collection("cities");
    docRef.snapshots().listen(
          (event) => print("listener attached"),
      onError: (error) => print("Listen failed: $error"),
    );
    // [END listen_to_realtime_updates_handle_listen_errors]
  }

    Widget build(BuildContext context) {

      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.deepPurple,
            leading: TextButton.icon(onPressed: () =>listenToRealtimeUpdates_handleListenErrors(),
            icon: Icon(Icons.icecream_outlined),
            label: Text(user?.uid as String))),
        body: StreamBuilder(


          stream: FirebaseFirestore.instance.collection('users').where("uid", isEqualTo: user?.uid as String ).snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }

            return ListView(
              children: snapshot.data!.docs
                  .map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
                return ListTile(
                  title: Text(data ['email'].toString()),
                  subtitle: Text(data ['username']),
                );
              })
                  .toList()
                  .cast(),
            );
          },
        ),
      );
    }
  }
