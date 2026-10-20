import '../helpers/database_helper.dart';
import 'shopping_repository.dart';

ShoppingRepository createRepository() => DatabaseHelper.instance;
