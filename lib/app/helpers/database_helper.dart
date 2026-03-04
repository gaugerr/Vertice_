import 'package:path/path.dart';
import 'package:rancho_consciente/app/model/categoria_model.dart';
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
    _database = await _initDB('rancho_app.db'); // Aqui chamamos o método abaixo
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
    );
  }

  // F. CRIAÇÃO DAS TABELAS: Onde o SQL acontece.
  Future _createDB(Database db, int version) async {
    // 1. Tabela de Ranchos (A Raiz)
    await db.execute('''
      CREATE TABLE ranchos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mercado TEXT NOT NULL,
        data INTEGER NOT NULL,
        descricao TEXT
      )
    ''');

    // 2. Tabela de Categorias (Ligada ao Rancho)
    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tituloCategoria TEXT NOT NULL,
        ranchoId INTEGER,
        FOREIGN KEY (ranchoId) REFERENCES ranchos (id) ON DELETE CASCADE
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
        FOREIGN KEY (categoriaId) REFERENCES categorias (id) ON DELETE CASCADE
      )
    ''');
  }

  //FUNÇÕES PRA INSERÇÃO DE DADOS

  //INSERIR RANCHO
  // Insere um novo Rancho e retorna o ID gerado pelo banco
  Future<int> insertRancho(RanchoModel rancho) async {
    final db = await instance.database; // Abre a conexão

    // O 'insert' traduz o objeto para SQL automaticamente usando o toMap
    return await db.insert('ranchos', rancho.toMap());
  }

  //INSERIR CATEGORIAS PADRÃO
  // Insere uma categoria ligada a um Rancho específico
  Future<int> insertCategoria(CategoriaModel categoria, int ranchoId) async {
    final db = await instance.database;

    // Criamos o mapa da categoria
    final map = categoria.toMap();

    // Adicionamos manualmente a chave estrangeira para o banco saber a quem ela pertence
    map['ranchoId'] = ranchoId;

    return await db.insert('categorias', map);
  }

  //CRIA UM RANCHO COM AS CAT. PADRÃO JÁ INCLUSAS
  Future<void> criarNovoRanchoComCategorias(RanchoModel novoRancho) async {
    // 1. Salva o Rancho e pega o ID dele
    final idDoRancho = await insertRancho(novoRancho);

    // 2. Pega a lista de categorias padrão que você criou no Model
    final categoriasPadrao = CategoriaModel.gerarCategoriasPadrao();

    // 3. Salva cada categoria ligando-a ao ID do rancho
    for (var categoria in categoriasPadrao) {
      await insertCategoria(categoria, idDoRancho);
    }
  }
}
