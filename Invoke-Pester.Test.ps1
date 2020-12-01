param(
    [string] $SourceFile
)

Set-StrictMode -Version Latest

Import-Module -Name "Pester" -MinimumVersion "5.1.0" -Force
Import-Module -Name ".\Modules\Common.Pester.Functions.psd1" -Force
Import-Module -Name ".\Modules\Common.Pester.Validation.Functions.psd1" -Force
Import-Module -Name "PSScriptAnalyzer" -MinimumVersion "1.19.1" -Force

# An array of paths to search for scripts and modules

# Location of the external ScriptAnalyzer rules for SonarQube (leave empty to not run the scriptAnalyzer/SonarQube extra tests)
$SonarQubeRules = '..\ScriptAnalyzerRules\Indented.CodingConventions'

# Default Pester Parameters
$configuration = [PesterConfiguration]::Default
$configuration.Run.Exit = $false
$configuration.CodeCoverage.Enabled = $false
$configuration.Output.Verbosity = "Detailed"
$configuration.Run.PassThru = $false
$configuration.Should.ErrorAction = 'Stop'

# Test Set 4 - Pass in a single script file
$container4 = New-PesterContainer -Path ".\Quality\Script.Tests.ps1" -Data @{ SourceFile = $SourceFile; SonarQubeRules = $SonarQubeRules }
$configuration.Run.Container = $container4
Invoke-Pester -Configuration $configuration
