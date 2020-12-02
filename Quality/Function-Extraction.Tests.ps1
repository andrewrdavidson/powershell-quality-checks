param(
    [parameter(Mandatory = $true)]
    [string[]]$SourcePath,

    [parameter(Mandatory = $true)]
    [string]$FunctionExtractPath
)

Describe "Function Extraction Tests" -Tag 'Setup' {

    if ( -not (Test-Path -Path $FunctionExtractPath)) {
        # New-Item -Path $extractPath.Parent -ItemType 'Directory'
        New-Item -Path $FunctionExtractPath -ItemType 'Directory'
    }
    else {
        $extractPath = Get-Item -Path $FunctionExtractPath
        Get-ChildItem -Path $FunctionExtractPath -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse
        Remove-Item $FunctionExtractPath -Force -ErrorAction SilentlyContinue
        # New-Item -Path $extractPath.Parent -ItemType 'Directory'
        New-Item -Path $FunctionExtractPath -ItemType 'Directory'
    }

    foreach ($scriptPath in $SourcePath) {

        $moduleTestFiles = Get-ModuleFile -Path $scriptPath

        foreach ($moduleFile in $moduleTestFiles) {

            Context "Module : $moduleFile" {

                It "function extraction should complete" -TestCases @{ 'moduleFile' = $moduleFile } {

                    {

                        Export-FunctionsFromModule -Path $moduleFile -FunctionExtractPath $FunctionExtractPath

                    } | Should -Not -Throw

                }

            }

        }
    }

}
