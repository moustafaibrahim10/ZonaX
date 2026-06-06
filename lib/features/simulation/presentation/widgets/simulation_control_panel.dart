import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zona_x_16_4/features/simulation/data/models/simulation_config.dart';
import 'package:zona_x_16_4/features/simulation/presentation/bloc/simulation_bloc.dart';
import 'package:zona_x_16_4/features/simulation/presentation/bloc/simulation_event.dart';
import 'package:zona_x_16_4/features/simulation/presentation/bloc/simulation_state.dart';

class SimulationControlPanel extends StatefulWidget {
  const SimulationControlPanel({super.key});

  @override
  State<SimulationControlPanel> createState() => _SimulationControlPanelState();
}

class _SimulationControlPanelState extends State<SimulationControlPanel> {
  double _speedFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SimulationBloc, SimulationState>(
      builder: (context, state) {
        bool isRunning = state is SimulationRunning;
        bool isPaused = state is SimulationPaused;
        bool isStopped = state is SimulationStopped || state is SimulationInitial;

        String statusText = "Stopped";
        if (isRunning) statusText = "Running (Sim Time: \${(state as SimulationRunning).status.currentTime})";
        if (isPaused) statusText = "Paused";
        if (state is SimulationError) statusText = "Error: \${state.message}";

        return Container(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Simulation Control",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                "Status: $statusText",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (isStopped)
                    _buildButton(
                      icon: Icons.play_arrow,
                      color: Colors.green,
                      onPressed: () {
                        context.read<SimulationBloc>().add(
                              StartSimulation(
                                SimulationConfig(
                                  durationHours: 24,
                                  speedFactor: _speedFactor.toInt(),
                                  totalDrivers: 100,
                                  zoneCount: 100,
                                  startTime: '2024-01-15T00:00:00Z',
                                ),
                              ),
                            );
                      },
                    ),
                  if (isRunning)
                    _buildButton(
                      icon: Icons.pause,
                      color: Colors.orange,
                      onPressed: () {
                        context.read<SimulationBloc>().add(PauseSimulation());
                      },
                    ),
                  if (isPaused)
                    _buildButton(
                      icon: Icons.play_arrow,
                      color: Colors.green,
                      onPressed: () {
                        context.read<SimulationBloc>().add(ResumeSimulation());
                      },
                    ),
                  if (!isStopped)
                    _buildButton(
                      icon: Icons.stop,
                      color: Colors.red,
                      onPressed: () {
                        context.read<SimulationBloc>().add(StopSimulation());
                      },
                    ),
                ],
              ),
              SizedBox(height: 15.h),
              Text(
                "Speed: ${_speedFactor.toStringAsFixed(1)}x",
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              ),
              Slider(
                value: _speedFactor,
                min: 1.0,
                max: 200.0,
                divisions: 199,
                activeColor: Colors.blueAccent,
                onChanged: (value) {
                  setState(() {
                    _speedFactor = value;
                  });
                },
                onChangeEnd: (value) {
                  if (!isStopped) {
                    context.read<SimulationBloc>().add(UpdateSimulationSpeed(value));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: color, size: 28.sp),
      ),
    );
  }
}
