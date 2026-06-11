# Rust Cheatsheet

## Core commands

| Command                 | What it does                        |
| ----------------------- | ----------------------------------- |
| `rustc --version`       | Show Rust compiler version          |
| `cargo build`           | Build debug binary                  |
| `cargo run`             | Build and run project               |
| `cargo test`            | Run tests                           |
| `cargo check`           | Fast compile checks                 |
| `cargo fmt`             | Format Rust code                    |
| `cargo clippy`          | Lint with best-practice suggestions |
| `cargo update`          | Update dependencies in lockfile     |
| `cargo test -p <crate>` | Run tests for one crate             |
| `cargo clean`           | Remove build artifacts              |

## Common workflows

| Workflow            | Command                                   |
| ------------------- | ----------------------------------------- |
| Quick quality check | `cargo fmt && cargo clippy && cargo test` |
| Fast edit loop      | `cargo check`                             |
| Release build       | `cargo build --release`                   |

## Examples

```bash
# Daily quality pass
cargo fmt
cargo clippy
cargo test

# Build optimized release binary
cargo build --release
```

## Tips

| Tip                                      | Why it helps                       |
| ---------------------------------------- | ---------------------------------- |
| Use `cargo check` while coding           | Much faster than full builds       |
| Run `cargo clippy` regularly             | Improves code quality and idioms   |
| Keep toolchain updated (`rustup update`) | Better diagnostics and performance |
| Test specific crates in workspaces       | Faster feedback in large projects  |
