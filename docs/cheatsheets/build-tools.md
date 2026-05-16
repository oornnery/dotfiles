# Build Tools Cheatsheet

## Commands

| Command                              | What it does                    |
| ------------------------------------ | ------------------------------- |
| `make`                               | Runs default build target       |
| `make <target>`                      | Runs specific target            |
| `cmake -S . -B build`                | Configure project into `build/` |
| `cmake --build build -j`             | Build configured project        |
| `ninja -C build`                     | Build with Ninja in build dir   |
| `gcc main.c -o app`                  | Compile C file                  |
| `cmake --build build --target clean` | Clean build artifacts           |
| `ctest --test-dir build`             | Run CMake tests                 |

## Shortcuts

| Shortcut                             | Action                    |
| ------------------------------------ | ------------------------- |
| `make -j$(nproc)`                    | Parallel build            |
| `cmake --build build --target clean` | Clean generated artifacts |

## Examples

```bash
# CMake + Ninja workflow
cmake -S . -B build -G Ninja
cmake --build build -j
ctest --test-dir build

# Classic Make workflow
make -j$(nproc)
make test
```

## Tips

| Tip                                  | Why it helps                        |
| ------------------------------------ | ----------------------------------- |
| Prefer out-of-source builds          | Keeps repo clean                    |
| Use Ninja when available             | Faster incremental builds           |
| Use explicit targets in CI           | Predictable and reproducible builds |
| Rebuild from clean state for release | Avoid stale artifact issues         |
