# MCP (Model Context Protocol) Configuration

Este diretório contém configurações para o Model Context Protocol (MCP), que permite integrar servidores MCP com clientes como Claude Desktop.

## Arquivos de Configuração

### `claude-desktop.json`
Configuração completa para desenvolvimento com todos os servidores MCP disponíveis:
- **filesystem**: Acesso ao sistema de arquivos local
- **github**: Operações com repositórios GitHub
- **postgres**: Operações com banco PostgreSQL  
- **sqlite**: Operações com banco SQLite
- **memory**: Armazenamento persistente de contexto
- **brave-search**: Busca na web via Brave Search API
- **git**: Operações com repositórios Git
- **shell**: Execução de comandos shell
- **python**: Execução de código Python

### `claude-dev.json`
Configuração focada em desenvolvimento de software:
- Servidores essenciais para coding
- Acesso limitado ao filesystem
- Ferramentas de desenvolvimento

### `claude-research.json`
Configuração para pesquisa e análise:
- Busca na web
- Acesso a notas (Obsidian)
- Transcrições do YouTube
- Capacidades de raciocínio sequencial

### `.env-example`
Template com todas as variáveis de ambiente necessárias:
- API keys para serviços externos
- Strings de conexão com bancos de dados
- Configurações de caminhos e segurança

## Instalação

1. **Instalar servidores MCP:**
```bash
# Instalar servidores principais
uvx install mcp-server-filesystem
uvx install mcp-server-github
uvx install mcp-server-postgres
uvx install mcp-server-sqlite
uvx install mcp-server-memory
uvx install mcp-server-brave-search
uvx install mcp-server-git
uvx install mcp-server-shell
uvx install mcp-server-python

# Servidores adicionais
uvx install mcp-server-obsidian
uvx install mcp-server-youtube-transcript
uvx install mcp-server-sequential-thinking
uvx install mcp-server-time
uvx install mcp-server-puppeteer
uvx install mcp-server-docker
```

2. **Configurar variáveis de ambiente:**
```bash
# Copiar template
cp mcp/.env-example mcp/.env

# Editar com suas configurações
nano mcp/.env
```

3. **Configurar Claude Desktop:**
```bash
# Linux/macOS
mkdir -p ~/.config/claude-desktop
cp mcp/claude-desktop.json ~/.config/claude-desktop/

# Windows  
mkdir -p "$APPDATA/Claude/claude-desktop"
cp mcp/claude-desktop.json "$APPDATA/Claude/claude-desktop/"
```

## Uso

### Configurações por Contexto

**Para desenvolvimento:**
```bash
ln -sf $(pwd)/mcp/claude-dev.json ~/.config/claude-desktop/claude_desktop_config.json
```

**Para pesquisa:**
```bash
ln -sf $(pwd)/mcp/claude-research.json ~/.config/claude-desktop/claude_desktop_config.json
```

**Configuração completa:**
```bash
ln -sf $(pwd)/mcp/claude-desktop.json ~/.config/claude-desktop/claude_desktop_config.json
```

### Testando Servidores

```bash
# Testar servidor filesystem
uvx mcp-server-filesystem --help

# Testar servidor git
uvx mcp-server-git --repository . --help

# Verificar instalação
uvx list | grep mcp-server
```

## Servidores MCP Disponíveis

| Servidor | Função | Variáveis Necessárias |
|----------|--------|--------------------|
| `filesystem` | Operações com arquivos | - |
| `github` | API GitHub | `GITHUB_PERSONAL_ACCESS_TOKEN` |
| `postgres` | Banco PostgreSQL | `POSTGRES_CONNECTION_STRING` |
| `sqlite` | Banco SQLite | `SQLITE_DB_PATH` |
| `memory` | Memória persistente | - |
| `brave-search` | Busca web | `BRAVE_API_KEY` |
| `git` | Operações Git | - |
| `shell` | Comandos shell | - |
| `python` | Execução Python | - |
| `obsidian` | Notas Obsidian | `OBSIDIAN_VAULT_PATH` |
| `youtube-transcript` | Transcrições YouTube | - |
| `sequential-thinking` | Raciocínio avançado | - |
| `time` | Operações temporais | - |
| `puppeteer` | Automação web | - |
| `docker` | Containers Docker | `DOCKER_HOST` |

## Segurança

- **Nunca commite arquivos `.env`** com credenciais reais
- Configure permissões adequadas para servidores como `shell` e `filesystem`
- Use tokens com escopo limitado para APIs externas
- Revise regularmente as permissões dos servidores MCP

## Troubleshooting

### Servidor não inicia:
1. Verificar se o uvx está instalado: `uvx --version`
2. Verificar se o servidor está instalado: `uvx list | grep mcp-server`
3. Testar manualmente: `uvx mcp-server-nome --help`

### Problemas de permissão:
1. Verificar variáveis de ambiente no `.env`
2. Testar credenciais de APIs
3. Verificar permissões de filesystem

### Claude Desktop não conecta:
1. Verificar localização do arquivo de configuração
2. Validar JSON: `jq . claude-desktop.json`
3. Reiniciar Claude Desktop
4. Verificar logs em `~/.config/claude-desktop/logs/`

## Contribuindo

Para adicionar novos servidores MCP:

1. Adicionar configuração nos arquivos JSON apropriados
2. Documentar variáveis necessárias no `.env-example`
3. Atualizar este README
4. Testar a configuração

## Links Úteis

- [MCP Documentation](https://modelcontextprotocol.io/)
- [Claude Desktop Configuration](https://docs.anthropic.com/claude/docs)
- [MCP Servers Registry](https://github.com/modelcontextprotocol/servers)
- [uvx Documentation](https://docs.astral.sh/uv/)
