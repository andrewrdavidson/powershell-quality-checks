function Get-TokenMarker {
    <#
        .DESCRIPTION
        Description of TestScript

        .SYNOPSIS
        A detailed synopsis of the function of the script

        .PARAMETER ParsedFileContent
        A string containing the message

        .PARAMETER Type
        A string containing the message

        .PARAMETER Content
        A string containing the message

        .EXAMPLE
        Get-TestFunction -Message 'This is a test message'
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [System.Object[]]$ParsedFileContent,
        [string]$Type,
        [string]$Content
    )

    #* This is just to satisfy the PSScriptAnalyzer
    #* which can't find the variables in the 'Where-Object' clause (even though it's valid)
    $Type = $Type
    $Content = $Content

    $token = @($ParsedFileContent | Where-Object { $_.Type -eq $Type -and $_.Content -eq $Content })

    return $token

}
