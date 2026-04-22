<div align="center">

# 🛒 Vértice

### *O ponto de encontro entre necessidade e gasto*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/SQLite-sqflite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)](https://pub.dev/packages/sqflite)
[![Status](https://img.shields.io/badge/Status-Em%20Desenvolvimento-orange?style=for-the-badge)](#)

</div>

---

> **Vértice** é um gerenciador de listas de compras inteligente, 100% offline, desenvolvido com Flutter.  
> Organize suas idas ao mercado por loja, categorize cada item, controle preços e quantidades — tudo em uma interface limpa e com tema escuro.

---

## ✨ Funcionalidades

| Funcionalidade | Descrição |
|---|---|
| 📋 **Listas de Compras** | Crie listas por mercado com nome, data e descrição |
| 🗂️ **Categorias Automáticas** | Cada lista já vem com 6 categorias padrão (Essenciais, Hortifruti, Higiene e Limpeza, Padaria e Laticínios, Carnes e Bebidas, Outros) |
| ✅ **Controle de Itens** | Adicione itens e marque como comprado com um toque |
| 💰 **Preço e Quantidade** | Defina preço, quantidade e unidade (un / kg / L) por item |
| 🧮 **Totais em Tempo Real** | Total calculado automaticamente por categoria e por lista |
| ✏️ **Edição In-line** | Renomeie ou exclua qualquer lista ou item diretamente |
| 🌙 **Tema Escuro** | Interface dark com destaque em roxo |
| 📱 **Offline First** | Todos os dados persistidos localmente via SQLite — sem internet |

---

## 📸 Demo

<img src="gif/gif.gif" width="260" alt="Demonstração do Vértice" />

---

## 🛠️ Stack Tecnológica

```
Flutter 3.x  ·  Dart 3.x  ·  SQLite (sqflite)  ·  Material 3  ·  Cupertino
```

| Camada | Tecnologia |
|---|---|
| Framework de UI | Flutter + Material 3 |
| Navegação | `CupertinoPageRoute` (transições estilo iOS) |
| Linguagem | Dart |
| Banco de Dados Local | SQLite via `sqflite` |
| Gerenciamento de Estado | `ChangeNotifier` + `ListenableBuilder` |
| Resolução de Caminhos | pacote `path` |

---

## 🏗️ Arquitetura

O Vértice segue o padrão **MVVM (Model-View-ViewModel)** com separação clara de responsabilidades:

```
lib/
└── app/
    ├── model/                   # Camada de dados
    │   ├── shopping_list_model.dart
    │   ├── category_model.dart
    │   └── item_model.dart
    │
    ├── helpers/                 # Acesso ao banco (Singleton)
    │   └── database_helper.dart
    │
    ├── view_model/              # Lógica de negócio + estado
    │   └── shopping_list_viewmodel.dart
    │
    ├── view/                    # Telas
    │   ├── add_shopping_list_form.dart
    │   ├── categories_view.dart
    │   └── items_view.dart
    │
    ├── widgets/                 # Componentes reutilizáveis
    │   ├── cards/
    │   │   ├── shopping_list_card.dart
    │   │   ├── category_card.dart
    │   │   └── item_card.dart
    │   ├── bottom_sheet.dart
    │   ├── confirm_action_dialog.dart
    │   ├── rename_action_dialog.dart
    │   ├── popup_menu_button.dart
    │   ├── grid_builder.dart
    │   └── list_view_builder.dart
    │
    ├── utils/
    │   └── utils.dart
    │
    └── app.dart                 # Widget raiz
```

### Fluxo de Dados

```
View  ──→  ViewModel  ──→  DatabaseHelper  ──→  SQLite
           (notifica)        (CRUD)
  ↑_________|
  ListenableBuilder
```

---

## 🗄️ Schema do Banco de Dados

```sql
shoppingLists (id, storeName, date, description)
      │
      └──→ categories (id, title, shoppingListId)
                │
                └──→ items (id, name, price, quantity, unit, isPurchased,
                            categoryId, shoppingListId)
```

Todas as chaves estrangeiras usam `ON DELETE CASCADE` — ao excluir uma lista, todas as categorias e itens vinculados são removidos automaticamente.

---

## 🚀 Como Rodar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.8.1`
- Dart `^3.0`
- **Dispositivo Android físico ou emulador Android**

> ⚠️ O banco de dados local (`sqflite`) **não é compatível com Windows/Linux/Web desktop**. O app deve ser rodado em Android (emulador ou dispositivo real).

### Instalação

```bash
# Clone o repositório
git clone https://github.com/ggaugerr/vertice.git

# Entre na pasta do projeto
cd vertice

# Instale as dependências
flutter pub get

# Rode o app
flutter run
```

---

## 🧑‍💻 Autor

**Gustavo Gauger**  
[![GitHub](https://img.shields.io/badge/GitHub-gaugerr-181717?style=flat-square&logo=github)](https://github.com/gaugerr)

---

<div align="center">

*Feito com 💜 usando Flutter*

</div>
