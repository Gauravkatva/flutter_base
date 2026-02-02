import 'package:my_appp/app/app.dart';
import 'package:my_appp/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
