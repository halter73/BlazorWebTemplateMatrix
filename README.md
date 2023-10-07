These are all new projects generated using `dotnet new blazor {param-matrix}` using the template updates from https://github.com/dotnet/aspnetcore/pull/51134.

Look at [generate.ps1](generate.ps1) for more details about how the project names are determined. They align closely with the command line parameters that generated the folder. For example folder `auth-ai-intAuto` means that it was generated with `dotnet new blazor -au Individual -ai -int Auto`.

You can also look at the message for the commit that added the folder to see the command line parameters that were used to generate it.

```pwsh
# Snippet from generate.ps1 showing how the project names are determined

$argArray = @('-au Individual', '-au None') |
%{ @($_, "$_ -ai") } |
%{ @("$_ -int None", "$_ -int Server", "$_ -int WebAssembly", "$_ -int Auto") } |
%{ @($_, "$_ -uld") } |
%{ @($_, "$_ -e") } |
%{ @($_, "$_ --use-program-main") }

foreach ($templateArgs in $argArray) {
    "dotnet new blazor $templateArgs"
    $appName = $templateArgs`
        -replace '-au Individual','auth'`
        -replace '-au None','noAuth'`
        -replace '--use-program-main','-upm'`
        -replace ' '
```

**WARNING:** This does not include the two runtime changes from the PR, so the global interactivity (e.g. `-ai` or `-all-interactivity`) will not work until this is updated with an SDK that uses those fixes.

> #### Runtime changes
> - Public API change to make `AddComponentRenderMode`'s `renderMode` param nullable to support disabling interactivity on a per-page basis with the help of `@rendermode="null"` (effectively).
>  - **IMPORTANT:** This will need follow up in the Razor Compiler. See https://github.com/dotnet/razor/issues/9343
>  - API Proposal issue: #51170
>  - This is a e necessary to support the changes to add global interactivity to Identity components @SteveSandersonMS made in #50920 and have now been included in this PR.
> - [Add antiforgery token to forms rendered interactively on the server](https://github.com/dotnet/aspnetcore/pull/51134/commits/425bd12a5a442711271761df91b580c785f38fa5)
>  - This bug fix is necessary to make the logout button work without throwing antiforgery errors when it is rendered interactively on the server.

### Regenerate

This was built with https://github.com/dotnet/aspnetcore/tree/051c204125f437db02f23894ae1bd2b3022aa947
Make sure that `. .\activate.ps1` was run in the root of the aspnetcore repo so that the following `dotnet pack` command will work.

```pwsh
dotnet pack $aspnetcore\src\ProjectTemplates\Web.ProjectTemplates\Microsoft.DotNet.Web.ProjectTemplates.csproj
```

```pwsh
$env:ASPNETCORE_REPO = C:\dev\dotnet\aspnetcore
$newFolder = "C:\dev\temp\blazor-templates"

# Run generate.ps1 outside of an existing git repo
mkdir $newFolder
cp generate.ps1 $newFolder
cp build-all.ps1 $newFolder

cd $newFolder

.\generate.ps1
.\build-all.ps1
```
