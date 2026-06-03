import 'dart:async';

import '../../domain/repositories/zone_repository.dart';

class ZoneRepositoryImpl implements ZoneRepository {
  @override
  Stream<List<Map<String, dynamic>>> getLiveDemandUpdates() async* {
    // Disabled automated random ticker so the map remains perfectly static
    // final random = Random();
    // 
    // while (true) {
    //   await Future.delayed(const Duration(seconds: 3));
    //   
    //   // Generate some random updates for our 256 zones (IDs 0 to 255)
    //   final int numberOfUpdates = random.nextInt(10) + 5; // 5 to 15 updates
    //   final List<Map<String, dynamic>> updates = [];
    //   
    //   for (int i = 0; i < numberOfUpdates; i++) {
    //     updates.add({
    //       "zoneId": random.nextInt(256), // Random zone from 0 to 255
    //       "demandLevel": random.nextInt(100), // Demand level 0 to 99
    //     });
    //   }
    //   
    //   yield updates;
    // }
  }
}
