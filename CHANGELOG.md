# Changelog

Todos os feitos, remendos e exorcismos do Abobrinator (Ruby Edition) serão documentados aqui.
O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto segue [Versionamento Semântico](https://semver.org/lang/pt-BR/).

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
