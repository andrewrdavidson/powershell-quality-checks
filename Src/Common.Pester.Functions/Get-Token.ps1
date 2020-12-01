function Get-Token {
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

    $token = Get-TokenMarker -ParsedFileContent $ParsedFileContent -Type $Type -Content $Content

    $tokens = Get-TokenComponent -ParsedFileContent $ParsedFileContent -StartLine $token.StartLine

    return $tokens

}
