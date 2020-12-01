Set-StrictMode -Version Latest

Import-Module -Name "Pester" -MinimumVersion "5.1.0" -Force
Import-Module -Name ".\Modules\Common.Pester.Functions.psd1" -Force
Import-Module -Name ".\Modules\Common.Pester.Validation.Functions.psd1" -Force
Import-Module -Name "PSScriptAnalyzer" -MinimumVersion "1.19.1" -Force

# An array of paths to search for scripts and modules
$SourcePath = @('.\Modules', '.\TestFiles')

# Location of the external ScriptAnalyzer rules for SonarQube (leave empty to not run the scriptAnalyzer/SonarQube extra tests)
$SonarQubeRules = '..\ScriptAnalyzerRules\Indented.CodingConventions'

# Location of Extracted Module Functions
$FunctionExtractPath = Join-Path -Path $Env:TEMP -ChildPath "tmpExtraction"

# Default Pester Parameters
$configuration = [PesterConfiguration]::Default
$configuration.Run.Exit = $false
$configuration.CodeCoverage.Enabled = $false
$configuration.Output.Verbosity = "Detailed"
$configuration.Run.PassThru = $false
$configuration.Should.ErrorAction = 'Stop'

# Test Set 1 - Basic Module tests
$container1 = New-PesterContainer -Path ".\Quality\Module.Tests.ps1" -Data @{ SourcePath = $SourcePath }
$configuration.Run.Container = $container1
Invoke-Pester -Configuration $configuration

# Test Set 2 - Extract functions from module files
$container2 = New-PesterContainer -Path ".\Quality\Function-Extraction.Tests.ps1" -Data @{ SourcePath = $SourcePath; FunctionExtractPath = $FunctionExtractPath }
$configuration.Run.Container = $container2
Invoke-Pester -Configuration $configuration

# Test Set 3 - Multiple script file tests via searching all script in $SourcePath
if (Test-Path -Path $FunctionExtractPath) {
    $SourcePath = $SourcePath + $FunctionExtractPath
}
$container3 = New-PesterContainer -Path ".\Quality\Script.Tests.ps1" -Data @{ SourcePath = $SourcePath; SonarQubeRules = $SonarQubeRules }
$configuration.Run.Container = $container3
Invoke-Pester -Configuration $configuration
