import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zona_x_16_4/features/map/data/datasources/hive_local_data_source.dart';
import 'package:zona_x_16_4/features/map/presentation/screens/heatmap_screen.dart';
import 'package:zona_x_16_4/features/home/presentation/screens/main_screen.dart';
import 'package:zona_x_16_4/features/map/presentation/cubit/map_cubit.dart';
import 'package:zona_x_16_4/features/map/data/repositories/map_repository_impl.dart';
import 'package:zona_x_16_4/features/map/data/datasources/map_mock_data_source.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '');
  
  await Supabase.initialize(
      url: "https://xoiqadbokgbrnwgthzfl.supabase.co",
      anonKey: "sb_publishable_wsTLf4VUTJtr66kGcvUUaw_dM0V-Pvr");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      extensions: [AppColors.light()],
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      extensions: [AppColors.dark()],
    );

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'ZonaX',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          home: BlocProvider(
            create: (context) => MapCubit(
              MapRepositoryImpl(MapMockDataSourceImpl()),
              HiveLocalDataSourceImpl(),
            ),
            child: const MainScreen(),
          ),
        );
      },
    );
  }
}
