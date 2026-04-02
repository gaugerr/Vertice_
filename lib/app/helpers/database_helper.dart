import 'package:path/path.dart';
import 'package:rancho_consciente/app/model/categoria_model.dart';
import 'package:rancho_consciente/app/model/item_model.dart';
import 'package:rancho_consciente/app/model/rancho_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // A. SINGLETON: Garante que exista apenas UMA instância dessa classe no app todo.
  // Isso evita que duas telas tentem abrir o banco ao mesmo tempo.
  static final DatabaseHelper instance = DatabaseHelper._init();

  // B. O OBJETO DATABASE: É a variável que segura a conexão real com o arquivo .db.
  static Database? _database;

  // C. CONSTRUTOR PRIVADO: O "._init()" impede que você crie a classe
  // usando "DatabaseHelper()" em outros arquivos.
  DatabaseHelper._init();

  // D. O GETTER: É por aqui que você acessa o banco.
  // Se ele já estiver aberto, devolve o que existe. Se não, chama a inicialização.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(
      'vertice_app.db',
    ); // Aqui chamamos o método abaixo
    return _database!;
  }

  // E. MÉTODO DE INICIALIZAÇÃO (O que resolve o seu erro):
  // Ele localiza a pasta correta no Android/iOS e abre o arquivo.
  Future<Database> _initDB(String filePath) async {
    final dbPath =
        await getDatabasesPath(); // Busca a pasta de bancos do sistema
    final path = join(
      dbPath,
      filePath,
    ); // Junta a pasta com o nome do seu arquivo

    return await openDatabase(
      path,
      version: 1,
      onCreate:
          _createDB, // Indica qual função criará as tabelas na primeira vez
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // F. CRIAÇÃO DAS TABELAS: Onde o SQL acontece.
  Future _createDB(Database db, int version) async {
    // 1. Tabela de Listas de Compras (A Raiz)
    await db.execute('''
      CREATE TABLE shoppingLists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mercado TEXT NOT NULL,
        data INTEGER NOT NULL,
        descricao TEXT
      )
    ''');

    // 2. Tabela de Categorias (Ligada a shoppingLists)
    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tituloCategoria TEXT NOT NULL,
        shoppingListId INTEGER,
        FOREIGN KEY (shoppingListId) REFERENCES shoppingLists (id) ON DELETE CASCADE
      )
    ''');

    // 3. Tabela de Itens (Ligada à Categoria)
    await db.execute('''
      CREATE TABLE itens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomeItem TEXT NOT NULL,
        preco REAL NOT NULL,
        quantidade REAL NOT NULL,
        unidade TEXT NOT NULL,
        isComprado INTEGER NOT NULL,
        categoriaId INTEGER,
        shoppingListId INTEGER,
        FOREIGN KEY (shoppingListId) REFERENCES shoppingLists (id) ON DELETE CASCADE,
        FOREIGN KEY (categoriaId) REFERENCES categorias (id) ON DELETE CASCADE
      )
    ''');
  }

  //FUNÇÕES PRA INSERÇÃO DE DADOS

  //INSERIR RANCHO
  // Insere um novo Rancho e retorna o ID gerado pelo banco
  Future<int> insertRancho(ShoppingListModel rancho) async {
    final db = await instance.database; // Abre a conexão

    // O 'insert' traduz o objeto para SQL automaticamente usando o toMap
    return await db.insert('shoppingLists', rancho.toMap());
  }

  //INSERIR CATEGORIAS PADRÃO
  // Insere uma categoria ligada a um Rancho específico
  Future<int> insertCategoria(
    CategoriaModel categoria,
    int shoppingListId,
  ) async {
    final db = await instance.database;

    // Criamos o mapa da categoria
    final map = categoria.toMap();

    // Adicionamos manualmente a chave estrangeira para o banco saber a quem ela pertence
    map['shoppingListId'] = shoppingListId;

    return await db.insert('categorias', map);
  }

  //CRIA UM RANCHO COM AS CAT. PADRÃO JÁ INCLUSAS
  Future<int> criarNovoRanchoComCategorias(ShoppingListModel novoRancho) async {
    // 1. Salva o Rancho e pega o ID dele
    final idDoRancho = await insertRancho(novoRancho);

    // 2. Pega a lista de categorias padrão que você criou no Model
    final categoriasPadrao = CategoriaModel.gerarCategoriasPadrao();

    // 3. Salva cada categoria ligando-a ao ID do rancho
    for (var categoria in categoriasPadrao) {
      await insertCategoria(categoria, idDoRancho);
    }
    return idDoRancho;
  }

  // BUSCA OS shoppingLists JÁ SALVOS NO BANCO
  Future<List<ShoppingListModel>> getAllRanchos() async {
    // 1. Obtém a instância do banco de dados
    final db = await instance.database;

    // 2. Faz a query na tabela 'shoppingLists'
    final result = await db.query('shoppingLists');

    // 3. Converte a lista de Mapas para uma lista de Objetos RanchoModel
    return result.map((json) => ShoppingListModel.fromMap(json)).toList();
  }

  // BUSCAR UM RANCHO ESPECIFIC0 PELO ID
  Future<ShoppingListModel?> getRanchoById(int id) async {
    // 1. Acessa a instância do banco
    final db = await instance.database;

    // 2. Realiza a busca com um filtro (WHERE)
    final maps = await db.query(
      'shoppingLists',
      columns: [
        'id',
        'mercado',
        'data',
        'descricao',
      ], // Especifica as colunas por segurança
      where: 'id = ?', // O '?' previne SQL Injection
      whereArgs: [id], // O valor que substituirá o '?'
    );

    // 3. Verifica se encontrou algo
    if (maps.isNotEmpty) {
      return ShoppingListModel.fromMap(maps.first);
    } else {
      return null; // Caso o ID não exista
    }
  }

  // BUSCA AS CATEGORIAS LIGADAS A UM RANCHO ESPECIFICO
  Future<List<CategoriaModel>> getCategoriasPorRancho(
    int shoppingListId,
  ) async {
    final db = await instance.database;

    // Filtramos a tabela categorias onde o shoppingListId seja igual ao ID passado
    final result = await db.query(
      'categorias',
      where: 'shoppingListId = ?',
      whereArgs: [shoppingListId],
    );

    return result.map((json) => CategoriaModel.fromMap(json)).toList();
  }

  // BUSCA OS ITENS DE UMA CATEGORIA ESPECÍFICA
  Future<List<ItemModel>> getItensPorCategoria(int categoriaId) async {
    // 1. Obtém a instância do banco de dados
    final db = await instance.database;

    // 2. Faz a consulta filtrando pelo ID da categoria
    final result = await db.query(
      'itens',
      where: 'categoriaId = ?',
      whereArgs: [categoriaId],
      orderBy: 'isComprado ASC, id ASC',
    );

    // 3. Converte os mapas vindos do banco para objetos Dart
    return result.map((json) => ItemModel.fromMap(json)).toList();
  }

  Future<List<ItemModel>> getItensPorRancho(int shoppingListId) async {
    final db = await instance.database;

    // 1. Fazemos a busca filtrando pelo ID do Rancho
    final result = await db.query(
      'itens', // Nome da sua tabela
      where: 'shoppingListId = ?',
      whereArgs: [shoppingListId],
    );

    // 2. Transformamos a lista de Maps (JSON) em uma lista de ItemModel

    return result.map((json) => ItemModel.fromMap(json)).toList();
  }

  // ATUALIZA O ITEM INTEIRO
  Future<int> updateItem(ItemModel item) async {
    final db = await instance.database;
    return await db.update(
      'itens',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // DELETA UM ITEM
  Future<int> deleteItem(int id) async {
    final db = await instance.database;
    return await db.delete('itens', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteRancho(int id) async {
    final db = await instance.database;
    return await db.delete('shoppingLists', where: 'id = ?', whereArgs: [id]);
  }

  // INSERIR ITEM
  Future<int> insertItem(ItemModel item, int categoriaId) async {
    final db = await instance.database;

    final map = item.toMap();

    // Injeta o ID da categoria pai no mapa antes de salvar
    // Isso garante que o banco saiba a qual categoria esse item pertence
    map['categoriaId'] = categoriaId;

    // 4. Executa o comando de inserção na tabela 'itens'
    final id = await db.insert('itens', map);

    return id;
  }
}
