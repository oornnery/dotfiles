# Build tools

`make` is installed; the rest come with their languages or `pacman`.

## make

```make
# Makefile: targets, what they need, and their commands (indented with a tab)
.PHONY: run test clean
run: build
	./app
build:
	go build -o app .
test:
	go test ./...
clean:
	rm -f app
```

| Command | Does |
| ------- | ---- |
| `make` | The first target |
| `make test` | One target |
| `make -n test` | Show the commands, run nothing |
| `make -j8` | In parallel |
| `make -C dir` | In another folder |

## C and C++

| Task | Command |
| ---- | ------- |
| One file | `cc main.c -o app`, with warnings: `-Wall -Wextra -O2` |
| CMake project | `cmake -B build && cmake --build build` (`dots pkg add cmake`) |
| Install it | `sudo cmake --install build` |
| Debug | `gdb ./app` (`dots pkg add gdb`) |

## Other languages

| Language | Build | Page |
| -------- | ----- | ---- |
| Go | `go build` | `dots help go` |
| Rust | `cargo build --release` | `dots help rust` |
| Python | `uv build` (a wheel) | `dots help python` |
| Node | `pnpm build` (the `build` script) | `dots help node` |
| Arch packages | `makepkg -si` in a folder with a PKGBUILD | `dots help pacman` |
