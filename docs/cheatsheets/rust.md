# Rust

Arch's `rust` package (cargo and rustc). Setup: `dots install rust`. Tools from
`cargo install` go to `~/.cargo/bin`, which is in `PATH`.

## A project

| Task | Command |
| ---- | ------- |
| New | `cargo new app`, a library: `cargo new --lib lib` |
| Run | `cargo run`, with arguments: `cargo run -- --flag` |
| Build | `cargo build`, optimized: `cargo build --release` (`target/release/`) |
| Check fast | `cargo check` |
| Add a crate | `cargo add serde --features derive`, dev: `cargo add --dev insta` |
| Remove | `cargo remove serde` |
| Test | `cargo test`, one: `cargo test name` |
| Lint | `cargo clippy`, fixing: `cargo clippy --fix` |
| Format | `cargo fmt` |
| Docs | `cargo doc --open` |
| Update | `cargo update` |
| Install a tool | `cargo install --locked name`; upgrade all: `dots update` |

## Common crates

| For | Crate |
| --- | ----- |
| Serialization | `serde` with `serde_json`, `toml` |
| Async | `tokio` |
| CLI | `clap` (with `derive`) |
| Errors | `anyhow` (apps), `thiserror` (libraries) |
| HTTP client | `reqwest` |
| Web server | `axum` |
| Logs | `tracing`, `tracing-subscriber` |
| TUI | `ratatui` (what most TUIs here use) |
| Database | `sqlx` |

## Editor

`pacman -S rust-analyzer` (or `dots pkg add rust-analyzer`) for Helix.
