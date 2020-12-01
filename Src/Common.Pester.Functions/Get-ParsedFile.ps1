function Get-ParsedFile {
    <#
        .DESCRIPTION
        Description of TestScript

        .SYNOPSIS
        A detailed synopsis of the function of the script

        .PARAMETER Path
        A string containing the message

        .EXAMPLE
        Get-TestFunction -Message 'This is a test message'
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [string]$Path
    )

    try {
        if (-not(Test-Path -Path $Path)) {
            throw "$Path doesn't exist"
        }
    }
    catch {
        throw $_
    }

    $fileContent = Get-Content -Path $Path -Raw

    ($ParsedModule, $ParserErrorCount) = Get-ParsedContent -Content $fileContent

    return $ParsedModule, $ParserErrorCount

}
