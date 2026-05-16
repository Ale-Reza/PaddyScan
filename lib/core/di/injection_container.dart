import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:paddy_scan/data/repositories/homeRepositoryImpl.dart';
// import 'package:isar/isar.dart';
// import 'package:paddy_scan/main.dart';
import '../../data/services/api_service.dart';
import '../../presentation/blocs/home/home_bloc.dart';

// sl stands for Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  // 1. External Dependencies
  sl.registerLazySingleton(() => http.Client());

  // 2. Services (Data Layer)
  sl.registerLazySingleton<ApiService>(() => ApiService());

  // 3. Repositories (Data Layer)
  // Register the implementation as the interface type
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(apiService: sl()),
  );

  // 4. BLoCs (Presentation Layer)
  // HomeBloc needs HomeRepository, and GetIt now knows how to provide it
  sl.registerFactory(
    () => HomeBloc(
      apiService: sl(), // Pass the registered ApiService
      homeRepository: sl(), // Pass the registered HomeRepository
    ),
  );
}
