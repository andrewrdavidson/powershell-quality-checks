param(
    [parameter(Mandatory = $true)]
    [string[]]$SourcePath,

    [parameter(Mandatory = $true)]
    [string[]]$FunctionExtractPath
)

Describe "Function Extraction Tests" -Tag 'Setup' {

    Get-ChildItem -Path $FunctionExtractPath -Recurse | Remove-Item -Force -Recurse
    Remove-Item $FunctionExtractPath -Force -ErrorAction SilentlyContinue
    New-Item -Path $FunctionExtractPath -ItemType 'Directory'

    foreach ($scriptPath in $SourcePath) {

        $moduleTestFiles = Get-ModuleFile -Path $scriptPath

        foreach ($moduleFile in $moduleTestFiles) {

            Context "Module : $moduleFile" {

                It "function extraction should complete" -TestCases @{ 'moduleFile' = $moduleFile } {

                    {

                        Export-FunctionsFromModule -Path $moduleFile

                    } | Should -Not -Throw

                }

            }

        }
    }

}
