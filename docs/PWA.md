# Vértice PWA — versão publicada

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

Validação aprovada na [execução 39356623863](https://github.com/gaugerr/Vertice_/actions/runs/39356623863), commit `d8684cbe`: 11 testes Dart, análise e build web, mais o fluxo completo no Chromium. O teste confirmou bloqueio real da rede, criação offline, fechamento da aba, reabertura e valores recuperados pelo backup exportado.

[Baixar o pacote compilado vertice-pwa-28](https://github.com/gaugerr/Vertice_/actions/runs/39356623863/artifacts/12235627758). Este ZIP contém os arquivos estáticos; precisa de hospedagem HTTP/HTTPS e dos cabeçalhos indicados abaixo, não deve ser aberto diretamente como arquivo local.

- Suíte Dart original e novos testes de CRUD, backup, restauração atômica e validação.
- Playwright Chromium: restauração pela interface, alteração de quantidade, criação offline, fechamento da aba, reabertura sem rede e exportação dos registros persistidos.
- Resultado real disponível no workflow "PWA build and offline checks". A existência deste arquivo não comprova que a execução passou.
- Safari/iPhone e instalação em aparelhos físicos ainda precisam de validação.

## Vercel

`vercel.json` define build, saída `build/web`, MIME de WASM, revalidação de arquivos e cabeçalhos COOP/COEP para o banco.

A origem a publicar é a branch `feat/pwa`, não a main atual. Ao importar no painel, selecionar essa branch (ou definir a Production Branch nas configurações Git) e conferir os comandos acima. A build baixa uma versão fixa do Flutter em /tmp. Não precisa configurar chaves nem banco remoto nesta etapa.

Publicado em **https://vertice-gamma-khaki.vercel.app** no projeto `vertice`, equipe `gaugerrs-projects`, a partir do commit `d74d5333` da branch `feat/pwa`. Deployment de produção: `dpl_3BHo2Dpq72qYKJ5TgQLBMeJagoBT`, status READY. A main continua sem alterações.

A [verificação do site publicado](https://github.com/gaugerr/Vertice_/actions/runs/39358969273) passou: acesso público HTTPS, cabeçalhos COOP/COEP, MIME de SQLite WASM, manifesto, service worker e o mesmo fluxo completo de persistência offline no Chromium. A [suíte do código](https://github.com/gaugerr/Vertice_/actions/runs/39358969307) também passou.

O script baixa o arquivo oficial do Flutter 3.32.8 e confere seu SHA-256 antes de extrair. Não requer chaves de backend.

A publicação de produção foi feita explicitamente a partir dessa branch. O projeto foi importado originalmente com `main`; para automatizar futuras publicações desta etapa, definir **Settings → Git → Production Branch** como `feat/pwa` no painel da Vercel, ou continuar publicando explicitamente a branch/commit correto. Não publicar a main atual como PWA.

A conexão permite criar e consultar deployments, mas a consulta detalhada de logs pela integração retornou 403. Isso não impediu a compilação nem a verificação pública pelo GitHub Actions.

## Próximas etapas comerciais

Validar experiência em aparelhos, revisar acessibilidade, implementar login e acesso após compra, depois sincronização com resolução de conflitos. O uso comercial deve respeitar o plano de hospedagem contratado.
