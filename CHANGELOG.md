# Changelog

Todos os feitos, remendos e exorcismos do Abobrinator (Ruby Edition) serão documentados aqui.
O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto segue [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [2.1.0] - O Tuberculo Multiverso (Hugging Face) - 2026-03-04

### Adicionado
- **Provedores Pluggaveis de Imagem**: Implementada arquitetura `IMAGE_PROVIDER` no `.env` permitindo ao usuário chavear entre motores gráficos (Atualmente: `huggingface` e `gemini`).
- Construída a classe `HuggingFaceClient` integrando nativamente consumos da Inference API pública de modelos text-to-image de ponta como FLUX.1.
- Extração binária ultra-leve da HF sem necessidade de encoding em Base64, economizando processamento.
- **Ecossistema Draft Isolado**: Imagens geradas com a flag `--draft` agora são salvas na pasta `JEKYLL_DRAFTS_IMAGE_DIR` e transcrições na `JEKYLL_DRAFTS_TRANSCRIPTION_DIR` protegendo os links estáticos do Jekyll.

## [2.0.0] - A Imagem é Tudo (Integração Photator) - 2026-03-04

### Adicionado
- **Geração Nativa de Imagens de Capa (`photator`)**: A responsabilidade do Photator foi absorvida nativamente. Agora, a cada post gerado, o "Abobrinator" lê o novo parâmetro `image_prompt` no JSON, consome automaticamente a API do Google para gerar uma arte, extrai o Base64, e salva no disco.
- Mapeamento nativo da tag `image: /assets/images/...jpg` direto pro Front Matter do Jekyll (focado no jekyll-seo-tag).
- **Flag `--no-image`**: Novo botão de pânico no comando `process` para inibir as chamadas à geração gráfica.

### Modificado
- A gem independente `base64` foi explícita no Gemfile para manter compatibilidade com a limpa do Ruby 3.4+.
- A flag `--rascunho` foi universalizada para `--draft`.

## [1.1.0] - O Catálogo do Oráculo - 2026-03-04

### Adicionado
- **Comando `models`**: Novo utilitário na CLI (`bin/abobrinator models`) que faz requisição direta nativa no endpoint `/models` do Gemini para consultar e listar em tela todos os LLMs disponíveis para uso na chave de API atual do `.env`. Aposenta o antigo utilitário em Python solto.

## [1.0.0] - O Renascimento Ruby - 2026-03-04

### Adicionado
- **Arquitetura modular:** Reescrevi completamente o Abobrinator baseando-me na arquitetura rubista do Tomatextor (CLI via `Thor`, arquivos separados em `lib/`).
- **Comunicação REST Pura:** Novo `GeminiClient` que faz requisições diretas à API do Google via linguagem padrão (`net/http`), eliminando o uso frágil da gem oficial/gRPC.
- **Extração via JSON:** O LLM agora recebe a instrução estrita de devolver metadados do Jekyll embutidos num bloco ````json```` no topo da resposta. O Ruby cuida do parseamento para evitar os clássicos erros de formatação de YAML frouxo de IAs.
- **Dicionário em `data/`**: Mudança do arquivo `pollux_instructions.txt` raiz para `data/ai_persona.md`.
- **Placeholder Universal:** Substituição das terríveis referências manuais regex `/assets/...txt` do prompt no modelo por uma tag universal simples e robusta `{{ASSET_LINK}}`.
- Explicações nativas no `.gitignore`.

### Removido
- **Legacy Python Codebase:** Removidos scripts `.py` antigos, dependência do `google-genai` pip package, scripts em `.sh` e monólitos da versão v2.2 anterior. Todo o código legadão python descansa agora em paz (na tag `[LEGADO]`).
