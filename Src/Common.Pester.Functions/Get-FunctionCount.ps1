function Get-FunctionCount {
    <#
        .DESCRIPTION
        Description of TestScript

        .SYNOPSIS
        A detailed synopsis of the function of the script

        .PARAMETER ModuleFile
        A string containing the message

        .PARAMETER ManifestFile
        A string containing the message

        .EXAMPLE
        Get-TestFunction -Message 'This is a test message'
    #>
    [CmdletBinding()]
    [OutputType([Int[]])]
    param (
        [string]$ModuleFile,
        [string]$ManifestFile
    )

    $CommandFoundInModuleCount = 0
    $CommandFoundInManifestCount = 0
    $CommandInModule = 0

    $ExportedCommands = (Test-ModuleManifest -Path $ManifestFile -ErrorAction Stop).ExportedCommands

    ($ParsedModule, $ParserErrors) = Get-ParsedFile -Path $ModuleFile

    foreach ($ExportedCommand in $ExportedCommands.Keys) {

        if ( ($ParsedModule | Where-Object { $_.Type -eq "CommandArgument" -and $_.Content -eq $ExportedCommand })) {

            $CommandFoundInModuleCount++

        }

    }

    $functionNames = @()

    $functionKeywords = ($ParsedModule | Where-Object { $_.Type -eq "Keyword" -and $_.Content -eq "function" })
    $functionKeywords | ForEach-Object {

        $functionLineNo = $_.StartLine
        $functionNames += ($ParsedModule | Where-Object { $_.Type -eq "CommandArgument" -and $_.StartLine -eq $functionLineNo })

    }

    $functionNames | ForEach-Object {

        $CommandInModule++
        if ($ExportedCommands.ContainsKey($_.Content)) {

            $CommandFoundInManifestCount++

        }

    }

    return ($ExportedCommands.Count, $CommandFoundInModuleCount, $CommandInModule, $CommandFoundInManifestCount)

}
