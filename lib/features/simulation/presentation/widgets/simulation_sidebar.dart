import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zona_x_16_4/features/simulation/data/models/simulation_config.dart';
import 'package:zona_x_16_4/features/simulation/presentation/bloc/simulation_bloc.dart';
import 'package:zona_x_16_4/features/simulation/presentation/bloc/simulation_event.dart';
import 'package:zona_x_16_4/features/simulation/presentation/bloc/simulation_state.dart';

/// A compact, glassmorphic sidebar for simulation controls.
/// Sits on the left side of the map with vertical layout.
class SimulationSidebar extends StatefulWidget {
  const SimulationSidebar({super.key});

  @override
  State<SimulationSidebar> createState() => _SimulationSidebarState();
}

class _SimulationSidebarState extends State<SimulationSidebar>
    with SingleTickerProviderStateMixin {
  double _speedFactor = 100.0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SimulationBloc, SimulationState>(
      builder: (context, state) {
        final isRunning = state is SimulationRunning;
        final isPaused = state is SimulationPaused;
        final isStopped = state is SimulationStopped || state is SimulationInitial;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: 56.w,
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 6.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status indicator dot
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final opacity = isRunning
                          ? 0.5 + _pulseController.value * 0.5
                          : 1.0;
                      return Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isRunning
                              ? Colors.greenAccent.withValues(alpha: opacity)
                              : isPaused
                                  ? Colors.orangeAccent
                                  : Colors.grey,
                          boxShadow: isRunning
                              ? [
                                  BoxShadow(
                                    color: Colors.greenAccent.withValues(alpha: 0.4 * opacity),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 14.h),

                  // Simulation time label (vertical)
                  if (isRunning)
                    _buildTimeLabel((state as SimulationRunning).status.currentTime),

                  if (isRunning) SizedBox(height: 10.h),

                  // Play / Pause / Resume button
                  if (isStopped)
                    _buildIconButton(
                      icon: Icons.play_arrow_rounded,
                      color: const Color(0xFF4CAF50),
                      tooltip: 'Start',
                      onTap: () => _startSimulation(context),
                    ),
                  if (isRunning)
                    _buildIconButton(
                      icon: Icons.pause_rounded,
                      color: const Color(0xFFFF9800),
                      tooltip: 'Pause',
                      onTap: () => context.read<SimulationBloc>().add(PauseSimulation()),
                    ),
                  if (isPaused)
                    _buildIconButton(
                      icon: Icons.play_arrow_rounded,
                      color: const Color(0xFF4CAF50),
                      tooltip: 'Resume',
                      onTap: () => context.read<SimulationBloc>().add(ResumeSimulation()),
                    ),

                  SizedBox(height: 6.h),

                  // Stop button
                  if (!isStopped)
                    _buildIconButton(
                      icon: Icons.stop_rounded,
                      color: const Color(0xFFF44336),
                      tooltip: 'Stop',
                      onTap: () => context.read<SimulationBloc>().add(StopSimulation()),
                    ),

                  SizedBox(height: 14.h),

                  // Speed label
                  Text(
                    '${_speedFactor.toInt()}x',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Vertical speed slider
                  SizedBox(
                    height: 120.h,
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3.h,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                          overlayShape: RoundSliderOverlayShape(overlayRadius: 12.r),
                          activeTrackColor: const Color(0xFF64B5F6),
                          inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                          thumbColor: const Color(0xFF42A5F5),
                          overlayColor: const Color(0xFF42A5F5).withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: _speedFactor,
                          min: 1,
                          max: 200,
                          divisions: 199,
                          onChanged: (v) => setState(() => _speedFactor = v),
                          onChangeEnd: (v) {
                            if (!isStopped) {
                              context.read<SimulationBloc>().add(UpdateSimulationSpeed(v));
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Speed icon
                  Icon(Icons.speed_rounded, color: Colors.white38, size: 16.sp),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeLabel(String time) {
    // Show only the hour portion for compactness
    String display = time;
    if (time.contains('T')) {
      display = time.split('T').last.replaceAll('Z', '');
      if (display.length > 5) display = display.substring(0, 5);
    }
    return Text(
      display,
      style: TextStyle(
        color: Colors.white60,
        fontSize: 8.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
      ),
    );
  }

  void _startSimulation(BuildContext context) {
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
  }
}
