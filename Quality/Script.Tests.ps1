param(
    [parameter(Mandatory = $true, ParameterSetName = 'Multiple')]
    [string[]]$SourcePath,

    [parameter(Mandatory = $true, ParameterSetName = 'Single')]
    [string]$SourceFile,

    [parameter(Mandatory = $false)]
    [string]$SonarQubeRules
)

Describe "Script Tests" -Tag 'Script' {

    if ($PSCmdlet.ParameterSetName -eq "Single") {
        # Over-ride SourcePath with the path of the single file
        $SourcePath = @(Split-Path -Path (Get-Item -Path $SourceFile).FullName)
    }

    foreach ($scriptPath in $SourcePath) {

        $scriptTestFiles = Get-FunctionFile -Path $ScriptPath

        foreach ($scriptFile in $scriptTestFiles) {

            if ($PSCmdlet.ParameterSetName -eq "Single") {
                $scriptFile = $SourceFile
            }

            $scriptProperties = (Get-Item -Path $scriptFile)

            Context "Script : $($scriptProperties.Name) at $($scriptProperties.Directory)" {

                # This needs to get the content of the file or the content of the function inside the file
                $fileContent = Get-FileContent -File $scriptFile

                ($ParsedFile, $ErrorCount) = Get-ParsedContent -Content $fileContent

                It "check script has valid PowerShell syntax" -TestCases @{ 'ErrorCount' = $ErrorCount } {

                    $ErrorCount | Should -Be 0

                }

                It "check help must contain required elements" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                    {

                        $helpComments = ($ParsedFile | Where-Object { $_.Type -eq "Comment" } | Select-Object -First 1)

                        $helpCommentsContent = $helpComments.Content
                        Test-HelpForRequiredTokens -HelpComment $helpCommentsContent

                    } |
                        Should -Not -Throw

                }
                It "check help must not contain unspecified elements" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                    {

                        $helpComments = ($ParsedFile | Where-Object { $_.Type -eq "Comment" } | Select-Object -First 1)

                        $helpCommentsContent = $helpComments.Content
                        Test-HelpForUnspecifiedTokens -HelpComment $helpCommentsContent

                    } |
                        Should -Not -Throw

                }

                It "check help elements text is not empty" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                    {

                        $helpComments = ($ParsedFile | Where-Object { $_.Type -eq "Comment" } | Select-Object -First 1)

                        Test-HelpTokensTextIsValid -HelpComment $helpComments.Content

                    } | Should -Not -Throw

                }

                It "check help elements Min/Max counts are valid" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                    {

                        $helpComments = ($ParsedFile | Where-Object { $_.Type -eq "Comment" } | Select-Object -First 1)

                        Test-HelpTokensCountIsValid -HelpComment $helpComments.Content

                    } | Should -Not -Throw

                }

                It "check script contains [CmdletBinding] attribute" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                    $cmdletBindingCount = (@(Get-TokenMarker -ParsedFileContent $ParsedFile -Type "Attribute" -Content "CmdletBinding")).Count

                    $cmdletBindingCount | Should -Be 1

                }

                It "check script contains [OutputType] attribute" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                    $outputTypeCount = (@(Get-TokenMarker -ParsedFileContent $ParsedFile -Type "Attribute" -Content "OutputType")).Count

                    $outputTypeCount | Should -Be 1

                }

                It "check script [OutputType] attribute is not empty" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                    $outputTypeToken = (Get-Token -ParsedFileContent $ParsedFile -Type "Attribute" -Content "OutputType")

                    $outputTypeValue = @($outputTypeToken | Where-Object { $_.Type -eq "Type" })

                    $outputTypeValue | Should -Not -BeNullOrEmpty

                }

                It "check script contains param attribute" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                    $paramCount = (@(Get-TokenMarker -ParsedFileContent $ParsedFile -Type "Keyword" -Content "param")).Count

                    $paramCount | Should -Be 1

                }

                It "check script param block variables have type" -TestCases @{ 'ParsedFile' = $ParsedFile; 'fileContent' = $fileContent } {

                    $parameterVariables = Get-ScriptParameters -Content $fileContent

                    if ($parameterVariables.Count -eq 0) {

                        Set-ItResult -Inconclusive -Because "No parameters found"

                    }

                    {

                        Test-ParameterVariablesHaveType -ParameterVariables $parameterVariables

                    } | Should -Not -Throw

                }

                It "check .PARAMETER help matches variables in param block" -TestCases @{ 'ParsedFile' = $ParsedFile; 'fileContent' = $fileContent } {

                    {

                        $helpComment = ($ParsedFile | Where-Object { $_.Type -eq "Comment" } | Select-Object -First 1)

                        $parameterVariables = Get-ScriptParameters -Content $fileContent

                        Test-HelpTokensParamsMatch -helpComment $helpComment.Content -ParameterVariables $parameterVariables

                    } | Should -Not -Throw

                }

                It "check script contains no PSScriptAnalyzer suppressions" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                    $suppressCount = (@(Get-TokenMarker -ParsedFileContent $ParsedFile -Type "Attribute" -Content "Diagnostics.CodeAnalysis.SuppressMessageAttribute")).Count

                    $suppressCount | Should -Be 0

                }

                It "check script contains no PSScriptAnalyzer failures" -TestCases @{ 'scriptFile' = $scriptProperties.FullName } {

                    $AnalyserFailures = @(Invoke-ScriptAnalyzer -Path $scriptFile)

                    ($AnalyserFailures | ForEach-Object { $_.Message }) | Should -BeNullOrEmpty

                }

                It "check script contains no PSScriptAnalyser SonarQube rule failures" -TestCases @{ 'scriptFile' = $scriptProperties.FullName } {

                    if (Test-Path -Path $SonarQubeRules -ErrorAction SilentlyContinue) {

                        $AnalyserFailures = @(Invoke-ScriptAnalyzer -Path $scriptFile -CustomRulePath $SonarQubeRules)

                        ($AnalyserFailures | ForEach-Object { $_.Message }) | Should -BeNullOrEmpty

                    }
                    else {

                        Set-ItResult -Inconclusive -Because "Extra PSScriptAnalyzer rules not found"

                    }

                }

                It "check Import-Module statements have valid format" -TestCases @{ 'ParsedFile' = $ParsedFile } {

                    $importModuleTokens = @($ParsedFile | Where-Object { $_.Type -eq "Command" -and $_.Content -eq "Import-Module" })

                    if ($importModuleTokens.Count -eq 0) {

                        Set-ItResult -Inconclusive -Because "No Import-Module statements found"

                    }

                    {

                        Test-ImportModuleIsValid -ParsedFile $ParsedFile -ImportModuleTokens $importModuleTokens

                    } | Should -Not -Throw

                }

                # TODO: make sure that Set-StrictMode -Version latest is set in the script?
                # TODO: (low priority) params match the param block in order?

            }

            if ($PSCmdlet.ParameterSetName -eq "Single") {
                break
            }

        }

        if ($PSCmdlet.ParameterSetName -eq "Single") {
            break
        }

    }

}
