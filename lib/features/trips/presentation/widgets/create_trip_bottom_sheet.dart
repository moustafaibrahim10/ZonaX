import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/bloc/map_grid_bloc.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/bloc/map_grid_event.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/bloc/map_grid_state.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';
import '../../data/models/trip_create_dto.dart';

class CreateTripBottomSheet extends StatefulWidget {
  final int initialPickupZoneId;

  const CreateTripBottomSheet({super.key, required this.initialPickupZoneId});

  @override
  State<CreateTripBottomSheet> createState() => _CreateTripBottomSheetState();
}

class _CreateTripBottomSheetState extends State<CreateTripBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late int? _pickupLocationId;
  int? _dropoffLocationId;
  final _fareController = TextEditingController();
  final _tipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pickupLocationId = widget.initialPickupZoneId == 0 ? null : widget.initialPickupZoneId;
  }

  @override
  void dispose() {
    _fareController.dispose();
    _tipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Create New Trip",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            BlocConsumer<TripBloc, TripState>(
              listener: (context, state) {
                if (state is TripSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                  );
                  // Refresh Map Data
                  context.read<MapGridBloc>().add(InitializeGrid());
                  Navigator.pop(context); // Close bottom sheet
                } else if (state is TripError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BlocBuilder<MapGridBloc, MapGridState>(
                            builder: (context, gridState) {
                              List<int> availableZones = [];
                              if (gridState is GridReady) {
                                availableZones = gridState.demandLookUp.keys.toList();
                                if (_pickupLocationId != null && !availableZones.contains(_pickupLocationId)) {
                                   availableZones.add(_pickupLocationId!);
                                }
                              }
                              
                              return Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<int>(
                                      value: _pickupLocationId,
                                      decoration: const InputDecoration(
                                        labelText: 'Pickup Zone',
                                        border: OutlineInputBorder(),
                                        filled: true,
                                        fillColor: Colors.black26,
                                      ),
                                      dropdownColor: const Color(0xFF1E1E2A),
                                      style: const TextStyle(color: Colors.white),
                                      items: availableZones.map((zoneId) {
                                        return DropdownMenuItem<int>(
                                          value: zoneId,
                                          child: Text('Zone $zoneId'),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setState(() => _pickupLocationId = val),
                                      validator: (val) => val == null ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<int>(
                                      value: _dropoffLocationId,
                                      decoration: const InputDecoration(
                                        labelText: 'Dropoff Zone',
                                        border: OutlineInputBorder(),
                                        filled: true,
                                        fillColor: Colors.black26,
                                      ),
                                      dropdownColor: const Color(0xFF1E1E2A),
                                      style: const TextStyle(color: Colors.white),
                                      items: availableZones.map((zoneId) {
                                        return DropdownMenuItem<int>(
                                          value: zoneId,
                                          child: Text('Zone $zoneId'),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setState(() => _dropoffLocationId = val),
                                      validator: (val) => val == null ? 'Required' : null,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _fareController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Fare Amount',
                              prefixIcon: Icon(Icons.attach_money, color: Colors.green),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.black26,
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Required';
                              if (double.tryParse(val) == null) return 'Invalid number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _tipController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Tip Amount (Optional)',
                              prefixIcon: Icon(Icons.volunteer_activism, color: Colors.orange),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.black26,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: state is TripLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      final dto = TripCreateDto(
                                        pickupLocationId: _pickupLocationId!,
                                        dropoffLocationId: _dropoffLocationId!,
                                        fareAmount: double.parse(_fareController.text),
                                        tipAmount: double.tryParse(_tipController.text) ?? 0.0,
                                      );
                                      context.read<TripBloc>().add(CreateTripRequested(dto));
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blueAccent,
                            ),
                            child: state is TripLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Create Trip', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
