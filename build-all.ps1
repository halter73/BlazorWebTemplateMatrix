foreach ($appName in ls -directory) {
    pushd $appName
    if (Test-Path $appName) {
        cd $appName
    }

    dotnet build
    if (!$?) { return $lastexitcode }

    popd
}