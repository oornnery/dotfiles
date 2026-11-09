# Go

Setup: `dots install go`. `GOPATH` is `~/.local/share/go`, and tools from
`go install` land in its `bin`, which is in `PATH` (`env.d/go.sh`).

## A project

| Task | Command |
| ---- | ------- |
| New module | `go mod init github.com/oornnery/app` |
| Run | `go run .` |
| Build | `go build -o app .` |
| Add a package | `go get github.com/x/y@latest`, or import it and `go mod tidy` |
| Tidy | `go mod tidy` |
| Test | `go test ./...`, one: `go test -run Name ./pkg`, verbose: `-v` |
| Format, check | `gofmt -w .`, `go vet ./...` |
| Install a tool | `go install github.com/x/tool@latest` |
| Build for Windows | `GOOS=windows GOARCH=amd64 go build -o app.exe .` |
| Docs of a package | `go doc net/http Client` |

## Common libraries

| For | Library |
| --- | ------- |
| CLI | `github.com/spf13/cobra`; simple: `flag` (standard) |
| TUI | `github.com/charmbracelet/bubbletea`, `lipgloss` (what gum is made of) |
| HTTP | `net/http` (standard, routes with methods since 1.22); `chi` |
| Logs | `log/slog` (standard) |
| Postgres | `github.com/jackc/pgx/v5`; queries as code: `sqlc` |
| SQLite | `modernc.org/sqlite` (no C) |
| Config | `github.com/BurntSushi/toml`, `gopkg.in/yaml.v3` |
| Tests | `testing` (standard), `github.com/stretchr/testify` |

## Editor

`go install golang.org/x/tools/gopls@latest` for Helix.
