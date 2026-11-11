# Go: modules, cache and installed tools under ~/.local/share/go, not ~/go.
export GOPATH="$XDG_DATA_HOME/go"
export GOTELEMETRY=off
_path_add "$GOPATH/bin"   # go install puts tools here
