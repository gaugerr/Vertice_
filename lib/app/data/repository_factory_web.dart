import 'drift_repository.dart';
import 'shopping_repository.dart';
import 'web_connection.dart';

ShoppingRepository createRepository() => DriftShoppingRepository(openWebDatabase());
