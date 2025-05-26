import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:searchgpt/auth/auth_bloc.dart';
import 'package:searchgpt/auth/auth_event.dart';
import 'package:searchgpt/auth/auth_repository.dart';
import 'package:searchgpt/auth/auth_wrapper.dart';
import 'package:searchgpt/database/db/db.dart';
import 'package:searchgpt/screens/home/chat.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationDocumentsDirectory();

  // Wrap the directory in HydratedStorageDirectory
  final hydratedStorage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(directory.path),
  );

  HydratedBloc.storage = hydratedStorage;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppDatabase db = await AppDatabase.instance;
  runApp(MyApp(db: db));
}

class MyApp extends StatelessWidget {
  final AppDatabase db;

  const MyApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create: (context) =>
            AuthBloc(authRepository: context.read<AuthRepository>())
              ..add(const AuthStatusChecked()),
        child: MaterialApp(
          title: 'Search GPT',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          home: AuthWrapper(
            db: db,
            authenticated: ChatScreenPage(db: db),
            unauthenticated: ChatScreenPage(db: db),
          ),
        ),
      ),
    );
  }
}
