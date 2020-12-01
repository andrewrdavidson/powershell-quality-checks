function Get-FunctionFile {
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

    return (Get-FileList -Path $Path -Extension ".ps1")

}
