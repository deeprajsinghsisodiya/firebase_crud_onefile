import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:kush/views/createNotes.dart';
import 'package:kush/views/crudfirebase.dart';
import 'package:kush/views/homeScreen.dart';

import 'noteedit.dart';

class crudfirebase extends StatefulWidget {
  const crudfirebase({Key? key}) : super(key: key);

  @override
  State<crudfirebase> createState() => _crudfirebaseState();
}

class _crudfirebaseState extends State<crudfirebase> {
  User? userid = FirebaseAuth.instance.currentUser;
  // String? userid1 = userid?.email;
  final db = FirebaseFirestore.instance;
  final city = <String, String>{
    "name": "Los Angeles",
    "state": "CA",
    "country": "USA"
  };

  void addData_setADocument() {
    print('entry');
    db
        .collection("cities")
        .doc("LA")
        .set(city)
        .onError((e, _) => print("Error writing document: $e"));
    // [END add_data_set_document_1]
  }

  void addData_setADocument2() {
    // [START add_data_set_document_2]
    // Update one field, creating the document if it does not already exist.
    final data = {"capital": true};
    // creating the document if it does not already exist.
    db.collection("cities").doc("BJ").set(data, SetOptions(merge: true));

    // Update one field,
    db.collection("cities").doc("LA").set(data, SetOptions(merge: true));
    // [END add_data_set_document_2]
  }

  void addData_dataTypes() {
    // [START add_data_data_types]
    final docData = {
      "stringExample": "Hello world!",
      "booleanExample": true,
      "numberExample": 3.14159265,
      "dateExample": Timestamp.now(),
      "listExample": [1, 2, 3],
      "nullExample": null
    };

    final nestedData = {
      "a": 5,
      "b": true,
    };

    docData["objectExample"] = nestedData;

    db
        .collection("data")
        .doc("one")
        .set(docData)
        .onError((e, _) => print("Error writing document: $e"));
    // [END add_data_data_types]
  }

  void addData_customObjects2() async {
    // [START add_data_custom_objects2]
    final city = City(
      name: "Los Angeles",
      state: "CA",
      country: "USA",
      capital: false,
      population: 900000,
      regions: ["west_coast", "social"],
    );
    final docRef = db
        .collection("cities").doc("LA")
        .withConverter(
          fromFirestore: City.fromFirestore,
          toFirestore: (City city,_ ) => city.toFirestore(),
        );
    await docRef.set(city);
    // [END add_data_custom_objects2]
  }

  void addData_addADocument() {
    // [START add_data_add_a_document]
    db.collection("cities").doc("new-city-id").set({"name": "Chicago"});
    // [END add_data_add_a_document]
  }

  void addData_addADocument2() {
    // [START add_data_add_a_document_2]
    // Add a new document with a generated id.
    final data = {"name": "Tokyo", "country": "Japan"};

    db.collection("cities").add(data).then((documentSnapshot) =>
        print("Added Data with ID: ${documentSnapshot.id}"));
    // [END add_data_add_a_document_2]
  }

  void addData_addADocument3() {
    // [START add_data_add_a_document_3]
    // Add a new document with a generated id.
    final data = <String, dynamic>{};

    final newCityRef = db.collection("cities").doc();

    // Later...
    newCityRef.set(data);

    // [END add_data_add_a_document_3]
  }

  void addData_updateADocument() {
    // [START add_data_update_a_document]
    final washingtonRef = db.collection("cities").doc("LA");
    washingtonRef.update({"capital": true}).then(
        (value) => print("DocumentSnapshot successfully updated!"),
        onError: (e) => print("Error updating document $e"));
    // [END add_data_update_a_document]
  }

  void addData_serverTimestamp() {
    // [START add_data_server_timestamp]  //LA before didnt have this field so this created ne field and stored the data
    final docRef = db.collection("cities").doc("LA");
    final updates = <String, dynamic>{
      "timestamp": FieldValue.serverTimestamp(),
    };

    docRef.update(updates).then(
        (value) => print("DocumentSnapshot successfully updated!"),
        onError: (e) => print("Error updating document $e"));
    // [END add_data_server_timestamp]
  }

  void addData_updateFieldsInNestedObjects() {
    // [START add_data_update_fields_in_nested_objects]
    // Assume the document contains:
    // {

    // }
    db
        .collection("userf")
        .doc("franks")
        .update({"age": 13, "favorite.color": "Red"});
    // [END add_data_update_fields_in_nested_objects]
  }

  void addfrank() {
    final franks = {
      "name": "Frank",
      "age": 12,
    };

    final favorites = {"food": "Pizza", "color": "Blue", "subject": "recess"};

    franks["favorite"] = favorites;

    db.collection('userf').doc('franks').set(franks);
  }

  void addData_updateElementsInArray() {
    // [START add_data_update_elements_in_array]
    final washingtonRef = db.collection("cities").doc("LA");

    // Atomically add a new region to the "regions" array field.
    washingtonRef.update({
      "regions": FieldValue.arrayUnion(["greater_virginia"]),
    });

    // Atomically remove a region from the "regions" array field.
    washingtonRef.update({
      "regions": FieldValue.arrayRemove(["west_coast"]),
    });
    // [END add_data_update_elements_in_array]
  }

  void addData_incrementANumericValue() {
    // [START add_data_increment_a_numeric_value]
    var washingtonRef = db.collection('cities').doc('LA');

    // Atomically increment the population of the city by 50.
    washingtonRef.update(
      {"population": FieldValue.increment(50)},
    );
    // [END add_data_increment_a_numeric_value]
  }


  void transactions_updatingDataWithTransactions() {
    // [START transactions_updating_data_with_transactions]
    final sfDocRef = db.collection("cities").doc("LA");
    db.runTransaction((transaction) async {
      final snapshot = await transaction.get(sfDocRef);
      // Note: this could be done without a transaction
      //       by updating the population using FieldValue.increment()
      final newPopulation = snapshot.get("population") + 1;
      transaction.update(sfDocRef, {"population": newPopulation});
    }).then(
          (value) => print("DocumentSnapshot successfully updated!"),
      onError: (e) => print("Error updating document $e"),
    );
    // [END transactions_updating_data_with_transactions]
  }


  void transactions_passingInformationOutOfTransactions() {
    // TODO: ewindmill@ - either the above example (using asnyc) or this example
    // using (then) is "more correct". Figure out which one.
    // [START transactions_passing_information_out_of_transactions]
    final sfDocRef = db.collection("cities").doc("LA");
    db.runTransaction((transaction) {
      return transaction.get(sfDocRef).then((sfDoc) {
        final newPopulation = sfDoc.get("population") + 1;
        transaction.update(sfDocRef, {"population": newPopulation});
        return newPopulation;
      });
    }).then(
          (newPopulation) => print("Population increased to $newPopulation"),
      onError: (e) => print("Error updating document $e"),
    );
    // [END transactions_passing_information_out_of_transactions]
  }
  void transactions_batchedWrites() {
    // [START transactions_batched_writes]
    // Get a new write batch
    final batch = db.batch();

    // Set the value of 'NYC'
    var nycRef = db.collection("cities").doc("NYC");
    batch.set(nycRef, {"name": "New York City"});

    // Update the population of 'SF'
    var sfRef = db.collection("cities").doc("LA");
    batch.update(sfRef, {"population": 1000000});

    // Delete the city 'LA'
    var laRef = db.collection("cities").doc("BJ");
    batch.delete(laRef);

    // Commit the batch
    batch.commit().then((_) {
      print('all task dome ');
    });
    // [END transactions_batched_writes]
  }

  void performSimpleAndCompoundQueries_exampleData() {
    // [START perform_simple_and_compound_queries_example_data]
    final cities = db.collection("cities");
    final data1 = <String, dynamic>{
      "name": "San Francisco",
      "state": "CA",
      "country": "USA",
      "capital": false,
      "population": 860000,
      "regions": ["west_coast", "norcal"]
    };
    cities.doc("SF").set(data1);

    final data2 = <String, dynamic>{
      "name": "Los Angeles",
      "state": "CA",
      "country": "USA",
      "capital": false,
      "population": 3900000,
      "regions": ["west_coast", "socal"],
    };
    cities.doc("LA").set(data2);

    final data3 = <String, dynamic>{
      "name": "Washington D.C.",
      "state": null,
      "country": "USA",
      "capital": true,
      "population": 680000,
      "regions": ["east_coast"]
    };
    cities.doc("DC").set(data3);

    final data4 = <String, dynamic>{
      "name": "Tokyo",
      "state": null,
      "country": "Japan",
      "capital": true,
      "population": 9000000,
      "regions": ["kanto", "honshu"]
    };
    cities.doc("TOK").set(data4);

    final data5 = <String, dynamic>{
      "name": "Beijing",
      "state": null,
      "country": "China",
      "capital": true,
      "population": 21500000,
      "regions": ["jingjinji", "hebei"],
    };
    cities.doc("BJ").set(data5);
    // [END perform_simple_and_compound_queries_example_data]
  }

  void getDataOnce_getADocument() {
    // [START get_data_once_get_a_document]
    final dcRef = db.collection("cities").doc("SF");
    dcRef.get().then(
          (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        print(data);
      },
      onError: (e) => print("Error getting document: $e"),
    );
    // [END get_data_once_get_a_document]
  }


  void getDataOnce_sourceOptions() {
    // [START get_data_once_source_options]
    final docRef = db.collection("cities").doc("SF");

    // Source can be CACHE, SERVER, or DEFAULT.
    const source = Source.cache;

    docRef.get(const GetOptions(source: source)).then(
            (DocumentSnapshot doc) {
              final data = doc.data() as Map<String, dynamic>;
              print(data);
            },
      onError: (e) => print("Error completing: $e"),
    );
    // [END get_data_once_source_options]
  }


  void getDataOnce_customObjects() async {
    // [START get_data_once_custom_objects]
    final ref = db.collection("cities").doc("LA").withConverter(
      fromFirestore: City.fromFirestore,
      toFirestore: (City city, _) => city.toFirestore(),   // _ iski jagah we can use options
    );
    final docSnap = await ref.get();
    final city = docSnap.data(); // Convert to City object
    if (city != null) {
      print(city.name);   // when we print docSnap.data() then also result will be Instance of 'City' otherwise snapshop.data will print the complete data
    } else {
      print("No such document.");
    }
    // [END get_data_once_custom_objects]
  }


  void getDataOnce_multipleDocumentsFromACollection() {
    // [START get_data_once_multiple_documents_from_a_collection]
    db.collection("cities").where("capital", isEqualTo: true).get().then(
          (querySnapshot) {
        print("Successfully completed");
        for (var docSnapsht in querySnapshot.docs) {  // changing spelling wont efffect docsnapshot and query snapshop
          print('${docSnapsht.id} => ${docSnapsht.data()}');
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
    // [END get_data_once_multiple_documents_from_a_collection]
  }

  void getDataOnce_getAllDocumentsInACollection() {
    // [START get_data_once_get_all_documents_in_a_collection]
    db.collection("cities").get().then(
          (querySnapshot) {
        print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          print('${docSnapshot.id} => ${docSnapshot.data()}');
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
    // [END get_data_once_get_all_documents_in_a_collection]
  }

  Map <String , dynamic>? laal;
  void listenToRealtimeUpdates_listenForUpdates() {
    // [START listen_to_realtime_updates_listen_for_updates]
    Map <String , dynamic>? lal  ;
    final docRef = db.collection("cities").doc("LA");
    docRef.snapshots().listen(
          (event) => {
            print("current data: ${event.data()}"),
            lal = event.data(),
          setState(() {
          laal = lal;
          })

          },
        onError: (error) => print("Listen failed: $error"),
    );


    // [END listen_to_realtime_updates_listen_for_updates]
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crud Firebase')),
      body: Center(
        child: Text(laal.toString()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          transactions_updatingDataWithTransactions();
        listenToRealtimeUpdates_listenForUpdates();
        } ,
      ),
    );
  }
}



class City {
  final String? name;
  final String? state;
  final String? country;
  final bool? capital;
  final int? population;
  final List<String>? regions;

  City({
    this.name,
    this.state,
    this.country,
    this.capital,
    this.population,
    this.regions,
  });

  factory City.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return City(
      name: data?['name'],
      state: data?['state'],
      country: data?['country'],
      capital: data?['capital'],
      population: data?['population'],
      regions:
          data?['regions'] is Iterable ? List.from(data?['regions']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (state != null) "state": state,
      if (country != null) "country": country,
      if (capital != null) "capital": capital,
      if (population != null) "population": population,
      if (regions != null) "regions": regions,
    };
  }
}
