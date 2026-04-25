param(
    [string]$EnvFile = ".env",
    [string[]]$FlutterArgs = @("run")
)

if (-not (Test-Path -LiteralPath $EnvFile)) {
    Write-Error "Environment file '$EnvFile' was not found. Copy .env.example to .env and fill in the values."
    exit 1
}

$dartDefines = @()
Get-Content -LiteralPath $EnvFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -ne "" -and -not $line.StartsWith("#")) {
        $parts = $line -split "=", 2
        if ($parts.Length -eq 2) {
            $name = $parts[0].Trim()
            $value = $parts[1].Trim().Trim('"').Trim("'")
            if ($name -ne "" -and $value -ne "") {
                $dartDefines += "--dart-define=$name=$value"
            }
        }
    }
}

flutter @FlutterArgs @dartDefines
