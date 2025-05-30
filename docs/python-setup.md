# Python Development Setup

## Configuração para Desenvolvimento Python3

### Scripts Utilitários Disponíveis

#### Em `utils/`:
- **backup.py**: Script de backup inteligente
- **directory.py**: Utilitários para manipulação de diretórios  
- **install_packages.py**: Instalador automático de pacotes
- **utils.py** & **utils2.py**: Funções utilitárias diversas

#### Em `home/scripts/`:
- **update-resolution.py**: Script para atualizar resolução de tela
- Diversos scripts de monitoramento e automação

### Configuração do Ambiente Python

#### 1. Instalar dependências essenciais:
```bash
# Arch Linux
sudo pacman -S python python-pip python-pipx python-virtualenv

# Debian/Ubuntu  
sudo apt install python3 python3-pip python3-venv python3-dev
```

#### 2. Ferramentas recomendadas via pipx:
```bash
pipx install black        # Formatador de código
pipx install flake8       # Linter
pipx install mypy         # Type checker
pipx install poetry       # Gerenciador de dependências
pipx install jupyter      # Notebooks interativos
pipx install ipython      # REPL melhorado
pipx install pytest       # Framework de testes
pipx install pre-commit   # Git hooks
```

#### 3. Configurar ambiente virtual padrão:
```bash
# Criar venv padrão para projetos
python3 -m venv ~/.venv/default
source ~/.venv/default/bin/activate

# Instalar pacotes essenciais
pip install requests pandas numpy matplotlib seaborn
```

### Configuração do VSCode para Python

#### Extensions recomendadas:
- Python (ms-python.python)
- Pylance (ms-python.vscode-pylance)  
- Python Docstring Generator
- autoDocstring
- Python Test Explorer
- Jupyter

#### Settings.json para Python:
```json
{
    "python.defaultInterpreterPath": "~/.venv/default/bin/python",
    "python.formatting.provider": "black",
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.testing.pytestEnabled": true,
    "jupyter.askForKernelRestart": false
}
```

### Configuração do Neovim para Python

#### Plugins recomendados (via lazy.nvim):
```lua
{
  "nvim-treesitter/nvim-treesitter",
  "neovim/nvim-lspconfig",  -- LSP
  "williamboman/mason.nvim", -- LSP installer
  "jose-elias-alvarez/null-ls.nvim", -- Formatters/linters
  "jupyter-vim/jupyter-vim", -- Jupyter integration
}
```

### Scripts de Desenvolvimento

#### Servidor HTTP rápido:
```bash
# Incluído no rofi launcher
python3 -m http.server 8000
```

#### REPL melhorado:
```bash
# Auto-complete e syntax highlighting
ipython
```

#### Jupyter Lab:
```bash
# Notebooks interativos
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser
```

### Aliases úteis para ZSH

Adicione ao seu `.zshrc`:
```bash
# Python aliases
alias py="python3"
alias pip="python3 -m pip"
alias venv="python3 -m venv"
alias activate="source venv/bin/activate"
alias server="python3 -m http.server"
alias nb="jupyter notebook"
alias lab="jupyter lab"

# Formatação e testes
alias black-format="black ."
alias flake8-check="flake8 ."
alias pytest-run="pytest -v"
alias mypy-check="mypy ."
```

### Estrutura de Projeto Python

#### Template recomendado:
```
projeto/
├── src/
│   └── projeto/
│       ├── __init__.py
│       └── main.py
├── tests/
│   ├── __init__.py
│   └── test_main.py
├── requirements.txt
├── pyproject.toml
├── README.md
├── .gitignore
└── .pre-commit-config.yaml
```

### Dicas de Produtividade

#### 1. Pre-commit hooks:
```bash
pre-commit install
```

#### 2. Formatação automática:
```bash
black --line-length 88 .
```

#### 3. Debugging com ipdb:
```python
import ipdb; ipdb.set_trace()
```

#### 4. Profile de performance:
```bash
python -m cProfile -o profile.prof script.py
```

### Integração com Window Managers

#### I3WM keybindings para Python:
```bash
# Em ~/.config/i3/config
bindsym $mod+Shift+p exec alacritty -e python3
bindsym $mod+Shift+j exec alacritty -e jupyter lab
bindsym $mod+Shift+i exec alacritty -e ipython
```

#### Rofi launcher entries (já incluído):
- Python REPL
- Jupyter Notebook  
- Python Web Server
- VS Code

---

**Setup otimizado para desenvolvimento Python3 produtivo! 🐍**
