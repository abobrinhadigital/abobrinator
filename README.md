# Abobrinator
> **Versão:** `v1.0.0`

CLI em Ruby para transformar transcrições brutas e caóticas em posts elaborados e polidos de blog, operando sob a inteligência sarcástica do Google Gemini. Implementação oficial e definitiva, substituindo a versão legada em Python.

## Funcionalidades

- **Reescrita Narrativa:** Limpa vícios de linguagem e estrutura o texto caótico do _Whisper_ em Markdown fluido.
- **Processamento em Lote:** Lê e unifica todos os `.txt` de uma pasta em uma única payload consolidada.
- **Integração Jekyll:** Gera e injeta nativamente o Front-Matter YAML diretamente no arquivo.
- **Comunicação REST Pura:** Conecta à API do Google via bibliotecas nativas (`net/http`), dispensando SDKs frágeis ou defeitos de gRPC.
- **Prevenção de Erros (JSON):** Força o LLM a separar os metadados do Jekyll em blocos JSON estritos para evitar a quebra do parser do blog.
- **Simetria Absoluta:** O nome final do arquivo `.md` é idêntico ao Asset `.txt` gerado, linkando-os internamente via tag `{{ASSET_LINK}}` automaticamente.
- **Personalidade Dinâmica:** Instruções de comportamento da IA desacoplados do código via `data/ai_persona.md`.

---

## Requisitos

### Sistema

| Dependência | Versão mínima | Finalidade |
|---|---|---|
| **Ruby** | 3.0+ | Linguagem principal do motor |
| **Bundler** | — | Gerenciamento de gems (`dotenv`, `thor`) |
| **Google API Key**| — | Chave de acesso à API do Gemini |

---

## Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/abobrinhadigital/abobrinator.git
cd abobrinator
```

### 2. Instale as gems Ruby

```bash
bundle install
```

### 3. A Alma do Projeto (Obrigatório)

Crie a pasta `data` na raiz do projeto e crie o arquivo `ai_persona.md`. Cole as diretrizes comportamentais e instruções de como a IA deve responder. Sem isso, a sua IA (no caso aqui é o Pollux) entra em colapso existencial.

---

## Configuração (.env)

Crie um arquivo `.env` na raiz do projeto baseado no exemplo abaixo:

```env
GEMINI_API_KEY="XXXXXXXXXXXXXXXXXXXXXXXXX"
GEMINI_MODEL="models/gemini-2.0-flash"

JEKYLL_POSTS_DIR="/caminho/do/seu/blog/_posts/"
JEKYLL_DRAFTS_DIR="/caminho/do/seu/blog/_drafts/"
JEKYLL_TRANSCRIPTION_DIR="/caminho/do/seu/blog/assets/transcricoes/"

TOMATEXTOR_NEW_DIR="/caminho/para/tomatextor/transcricoes/novas/"
TOMATEXTOR_HISTORY_DIR="/caminho/para/tomatextor/transcricoes/processadas/"
TIMEZONE_OFFSET="-0400"
```

| Variável | Descrição | Padrão |
|---|---|---|
| `GEMINI_API_KEY` | Sua chave de serviço no Google AI Studio | — |
| `GEMINI_MODEL` | O modelo do Gemini a ser consultado | `models/gemini-2.0-flash` |
| `JEKYLL_POSTS_DIR` | Pasta final de publicação dos artigos Jekyll | — |
| `JEKYLL_DRAFTS_DIR` | Pasta temporária de rascunhos Jekyll | — |
| `JEKYLL_TRANSCRIPTION_DIR` | Pasta no Jekyll onde o backup bruto em TXT será salvo | — |
| `TOMATEXTOR_NEW_DIR` | Diretório contendo as transcrições a serem processadas | — |
| `TOMATEXTOR_HISTORY_DIR` | Diretório de arquivamento das transcrições lidas | — |
| `TIMEZONE_OFFSET` | Fuso horário injetado na data do Post | `-0400` |

---

## Comandos

O executável primário, gerido pelo utilitário `Thor`, está dentro da pasta padrão `bin/`. Você gerencia tudo por lá.

```bash
bundle exec bin/abobrinator <comando> [opções]
```

### `process` (Padrão)

Consolida todas as transcrições da fila (`TOMATEXTOR_NEW_DIR`), envia ao Gemini, trata as respostas (JSON e Markdown), salva o post oficialmente no `JEKYLL_POSTS_DIR` e arquiva as transcrições lidas.
_Não é necessário digitar o nome do comando se usá-lo sozinho._

```bash
# Executa o pipeline completo (produção)
bundle exec bin/abobrinator
bundle exec bin/abobrinator process
```

**Modo Rascunho:**
Adicionando a flag `--rascunho`, o Abobrinator salva o Markdown final em `JEKYLL_DRAFTS_DIR` e o TXT em `JEKYLL_DRAFTS_DIR` no lugar das pastas oficiais, protegendo você contra desastres públicos.

```bash
bundle exec bin/abobrinator --rascunho
```

### `models`

Consulta a API do Google rest e lista todos os modelos generativos ou ferramentas que a sua `GEMINI_API_KEY` tem acesso atualmente. Útil para descobrir o nome exato dos novos lançamentos do Google para colocar no `GEMINI_MODEL` do arquivo `.env`.

```bash
bundle exec bin/abobrinator models

# Exemplo de Saída:
# - models/gemini-2.0-flash (Suporta: generateContent, countTokens)
# - models/nano-banana-pro-preview (Suporta: generateContent, countTokens)
```

---

## Arquivos de Dados

### Instruções da IA (`data/ai_persona.md`)

Este arquivo define como a Inteligência Artificial deve interpretar a entrada de texto do usuário e que formato restrito de saída ela precisa retornar (um JSON com o Front Matter seguido do Markdown do post). _Sempre ignorado pelo Git._

---

*Este projeto é mantido sob as bênçãos do Gêmeo Imortal para a glória do Abobrinha Digital.*
