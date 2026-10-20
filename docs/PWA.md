# Vértice PWA — primeira versão local

Branch: `feat/pwa`, baseada na versão estabilizada que gerou o APK profile. A main não foi alterada.

## Escopo

- Flutter Web, Drift 2.28.2 e SQLite WASM 2.9.4 no navegador.
- OPFS ou IndexedDB conforme suporte. Modos somente em memória ou sem coordenação segura entre abas são recusados.
- Repositório desacoplado das telas. Android mantém o sqflite e as migrações já testadas nesta primeira etapa.
- Listas, categorias, itens, preços, quantidades, totais, edição e exclusão locais.
- Backup JSON validado e restauração transacional. A restauração substitui os dados atuais após confirmação explícita.
- Manifesto, ícones e cache da versão completa para instalação e reabertura offline.
- Aviso de conexão, preparo offline e atualização disponível.
- Sem autenticação, pagamento ou sincronização. Esta versão é um protótipo funcional para validação, ainda sem controle de acesso dos compradores.

O armazenamento pertence ao domínio e navegador. Android e navegador não compartilham dados automaticamente; usar exportação/restauração. Limpar dados do site pode apagar registros. O pedido de armazenamento persistente pode ser recusado pelo navegador. Navegação privada não é indicada.

## Executar e compilar

Flutter fixado em 3.32.8. Scripts precisam de Bash, Python 3, curl e acesso às distribuições oficiais do Flutter/SQLite.

```sh
bash tool/prepare_assets.sh
flutter test
flutter analyze --no-fatal-infos --no-fatal-warnings
bash tool/build_web.sh
python3 tool/serve_web.py
```

Abrir http://127.0.0.1:8080. Aguardar "Pronto para usar offline" antes de desconectar.

O build contém o CanvasKit, as fontes, o worker e SQLite WASM no próprio domínio. Não depende de CDN para abrir offline. O service worker só sinaliza pronto após o cache da versão ter sido instalado.

A atualização aguarda confirmação do usuário ou fechamento das abas antigas; não apaga o banco local. Concluir edições antes de aceitar a atualização.

## Testes

- Suíte Dart original e novos testes de CRUD, backup, restauração atômica e validação.
- Playwright Chromium: restauração pela interface, alteração de quantidade, criação offline, fechamento da aba, reabertura sem rede e exportação dos registros persistidos.
- Resultado real disponível no workflow "PWA build and offline checks". A existência deste arquivo não comprova que a execução passou.
- Safari/iPhone e instalação em aparelhos físicos ainda precisam de validação.

## Vercel

`vercel.json` define build, saída `build/web`, MIME de WASM, revalidação de arquivos e cabeçalhos COOP/COEP para o banco.

A origem a publicar é a branch `feat/pwa`, não a main atual. Ao importar no painel, selecionar essa branch (ou definir a Production Branch nas configurações Git) e conferir os comandos acima. A build baixa uma versão fixa do Flutter em /tmp. Não precisa configurar chaves nem banco remoto nesta etapa.

A conexão do assistente retornou 403 para criação de projeto na equipe gaugerrs-projects. Nenhum projeto novo foi criado por essa tentativa. A publicação depende de acesso válido à equipe ou da configuração pelo próprio titular no painel. Não é necessário fornecer tokens no chat.

## Próximas etapas comerciais

Validar experiência em aparelhos, revisar acessibilidade, implementar login e acesso após compra, depois sincronização com resolução de conflitos. O uso comercial deve respeitar o plano de hospedagem contratado.
