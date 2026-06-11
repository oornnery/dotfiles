# Go Cheatsheet

## Core commands

| Command                       | What it does                    |
| ----------------------------- | ------------------------------- |
| `go version`                  | Show Go version                 |
| `go mod tidy`                 | Sync and clean dependencies     |
| `go run .`                    | Run current module              |
| `go build ./...`              | Build all packages              |
| `go test ./...`               | Run all tests                   |
| `go test -v ./...`            | Verbose tests                   |
| `go fmt ./...`                | Format all Go files             |
| `go vet ./...`                | Static checks for common issues |
| `go test ./... -run TestName` | Run specific tests by regex     |
| `go clean -testcache`         | Clear test cache                |

## Common workflows

| Workflow               | Command                                         |
| ---------------------- | ----------------------------------------------- |
| Quick quality check    | `go fmt ./... && go vet ./... && go test ./...` |
| Fast test loop         | `go test ./...`                                 |
| Build optimized binary | `go build -ldflags="-s -w"`                     |

## Examples

```bash
# Standard quality pass
go fmt ./...
go vet ./...
go test ./...

# Run one package tests
go test ./cmd/...
```

## Tips

| Tip                                        | Why it helps                      |
| ------------------------------------------ | --------------------------------- |
| Run `go mod tidy` after dependency changes | Keeps `go.mod` and `go.sum` clean |
| Use `go vet` before commit                 | Catches subtle mistakes           |
| Prefer package-scoped tests when debugging | Faster feedback                   |
| Clear test cache on flaky results          | Prevents stale-cache confusion    |
