# Estabilização antes do PWA

Branch: `fix/base-confiavel-pwa`. Não mesclar na main antes da validação.

## Estado desta entrega

Foi adicionado um workflow para compilar o app atual em APK debug. Isso não significa que os consertos abaixo foram implementados ou que a compilação passou. Consultar a execução no GitHub Actions.

O APK usa o identificador `com.ggaugerr.vertice.preview` e o nome Vertice Teste, para instalar separado do aplicativo original. Seus dados também ficam separados. Não desinstalar o original para testar esta versão. As chaves debug de diferentes execuções podem ser diferentes; uma atualização pode exigir reinstalar somente o app de teste, perdendo os dados dele.

## Consertos pendentes, em ordem

1. Substituir a migração destrutiva do DatabaseHelper por migrações que preservem dados. Inspecionar o schema histórico antes de decidir como converter bancos antigos.
2. Definir preço por unidade de medida e quantidade, unificar os totais e arredondar dinheiro de forma explícita. Diferenciar previsto e comprado. Conferir como a interface atual apresenta kg e L antes de converter valores existentes.
3. Tratar falhas de persistência sem deixar a tela divergente do banco; mostrar o erro e restaurar o estado ou atualizar somente após a gravação.
4. Implementar updateShoppingList e validar nomes, números finitos, preço não negativo e quantidade positiva.
5. Usar transação na criação da lista com suas categorias.
6. Separar acesso a dados em repositório antes de migrar para Drift.
7. Validar Drift no Android e na web, cache offline e backup; somente depois implementar autenticação e sincronização.

Testes prioritários: migração de banco com dados, totais com quantidades fracionadas, rollback de gravações e atomicidade da criação.

## Como obter o APK

Abrir a aba Actions, localizar Android test APK e selecionar a execução desta branch. Quando concluir com sucesso, baixar o artefato vertice-teste-N. Extrair o ZIP e instalar app-debug.apk em um Android. O navegador pode pedir login no GitHub para baixar o artefato.

A instalação pode exigir autorização para instalar apps dessa origem. É um APK de desenvolvimento, não uma publicação na Play Store.

## Roteiro manual

- Criar uma lista e conferir as seis categorias.
- Adicionar produtos por unidade, kg e L, incluindo quantidades fracionadas.
- Editar preço, quantidade e nome; marcar e desmarcar comprado.
- Conferir os totais da lista e das categorias.
- Fechar completamente e reabrir o app; conferir persistência.
- Repetir sem internet.
- Excluir itens e uma lista; reabrir e conferir.
- Registrar resultado, modelo do aparelho, versão do Android e número do artefato.

Este roteiro não substitui testes automatizados e não comprova compatibilidade web. O app ainda usa sqflite.
