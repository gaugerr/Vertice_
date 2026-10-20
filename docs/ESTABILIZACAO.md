# Estabilização antes do PWA

Branch: `fix/base-confiavel-pwa`. A main permanece separada.

## Alterações

- Banco versão 3: renomeia tabelas e colunas legadas em português, preservando IDs, valores e relacionamentos. Schemas ambíguos interrompem a migração sem apagar as tabelas. A atualização é transacional pelo openDatabase. Dados já apagados por versões anteriores não podem ser recuperados.
- Criação de lista e categorias em uma transação.
- Total por item = preço por un/kg/L multiplicado pela quantidade, arredondado a centavos; categorias e listas somam esses valores e somente itens comprados. O total da lista filtra seu identificador.
- Valores antigos não são reinterpretados nem convertidos: conferir preços de kg/L que tenham sido cadastrados como valor total em versões anteriores.
- Renomeação de listas persistida.
- Gravações serializadas; alterações na memória só depois da confirmação do banco; falhas exibidas por SnackBar.
- Nomes não vazios até 50 caracteres, quantidade finita positiva, preço finito não negativo e unidade conhecida.
- Edição numérica confirmada pelo teclado ou toque fora do campo.
- Botão de criação desabilitado durante o salvamento.

## Validação

A suíte em test/stabilization_test.dart cobre cálculos, falhas de gravação, migração legada, atualização do schema atual, criação atômica e persistência da renomeação. O workflow executa os testes antes de compilar. Consultar o resultado da execução: a existência deste documento não afirma aprovação.

Ainda é necessária validação manual em aparelho físico. Não há migração para Drift, PWA ou Supabase nesta etapa.

## APK profile

Na aba Actions, abrir a última execução bem-sucedida de Android test APK desta branch. Baixar o artefato vertice-profile-N, extrair e instalar app-profile.apk no Android.

O identificador com.ggaugerr.vertice.preview e o nome Vertice Teste mantêm instalação e dados separados do app original. Não desinstalar o original. Chaves de teste podem variar entre execuções; se a atualização falhar, reinstalar somente a versão de teste apaga os dados dela. O artefato fica disponível por 14 dias. O GitHub pode exigir login para o download.

## Roteiro manual

1. Criar uma lista; conferir as seis categorias.
2. Marcar um item de 0,5 kg com preço de R$ 20/kg: total R$ 10.
3. Conferir totais por item, categoria e lista; desmarcar itens e conferir redução.
4. Editar e renomear; fechar e reabrir; conferir persistência.
5. Informar números inválidos e conferir que não substituem os valores salvos.
6. Excluir item e lista; reabrir e conferir.
7. Repetir o uso sem conexão.
8. Registrar aparelho, Android e número do artefato.
