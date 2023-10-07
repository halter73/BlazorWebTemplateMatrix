$aspnetcoreRepo = $env:ASPNETCORE_REPO
$aspnetcoreLink = "https://github.com/dotnet/aspnetcore/tree/$(git -C $aspnetcoreRepo rev-parse HEAD)"
if (!$?) { return $lastexitcode }

dotnet pack $aspnetcoreRepo\src\ProjectTemplates\Web.ProjectTemplates\Microsoft.DotNet.Web.ProjectTemplates.csproj
dotnet new uninstall Microsoft.DotNet.Web.ProjectTemplates.8.0
dotnet new install $aspnetcoreRepo\artifacts\packages\Debug\Shipping\Microsoft.DotNet.Web.ProjectTemplates.8.0.8.0.0-dev.nupkg
if (!$?) { return $lastexitcode }

dotnet new globaljson
dotnet new gitignore
cp $aspnetcoreRepo\NuGet.config .
cp $aspnetcoreRepo\.gitattributes .

git init
git add -A
git commit -m "Initial commit" -m "" -m $aspnetcoreLink

$argArray = @('-au Individual', '-au None') |
%{ @($_, "$_ -ai") } |
%{ @("$_ -int None", "$_ -int Server", "$_ -int WebAssembly", "$_ -int Auto") } |
%{ @($_, "$_ -uld") } |
%{ @($_, "$_ -e") } |
%{ @($_, "$_ --use-program-main") } |
?{ $_ -notmatch '-ai -int None' }

foreach ($templateArgs in $argArray) {
    "dotnet new blazor $templateArgs"
    $appName = $templateArgs`
        -replace '-au Individual','auth'`
        -replace '-au None','noAuth'`
        -replace '--use-program-main','-upm'`
        -replace ' '

    mkdir $appName
    pushd $appName

    dotnet new blazor --no-restore $templateArgs.Split(' ')
    if (!$?) { return $lastexitcode }

    @("$appName.csproj", "$appName\$appName.csproj", "$appName.Client\$appName.Client.csproj") |
    ?{ Test-Path $_ } | %{ (cat $_) -replace '8.0.0-dev','8.0.0-*' | Set-Content $_ }

    git add -A
    git commit -m "dotnet new blazor $templateArgs" -m "" -m $aspnetcoreLink

    popd
}