function Get-TokenBetweenLines {
    <#
        .DESCRIPTION
        Description of TestScript

        .SYNOPSIS
        A detailed synopsis of the function of the script

        .PARAMETER ParsedFileContent
        A string containing the message

        .PARAMETER StartLine
        A string containing the message

        .PARAMETER EndLine
        A string containing the message

        .EXAMPLE
        Get-TestFunction -Message 'This is a test message'
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [System.Object[]]$ParsedFileContent,
        [int]$StartLine,
        [int]$EndLine
    )

    $tokens = @()
    for ($loop = $StartLine; $loop -le $EndLine; $loop++) {

        $tk = Get-TokenComponent -ParsedFileContent $ParsedFileContent -StartLine $loop

        $tokens += $tk

    }

    return $tokens

}
