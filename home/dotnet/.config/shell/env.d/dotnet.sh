# .NET: no telemetry, no first-run banner; dotnet tool install -g goes to PATH.
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_NOLOGO=1
_path_add "$HOME/.dotnet/tools"
