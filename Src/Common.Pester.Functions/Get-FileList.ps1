function Get-FileList {
    <#
        .DESCRIPTION
        Description of TestScript

        .SYNOPSIS
        A detailed synopsis of the function of the script

        .PARAMETER Path
        A string containing the message

        .PARAMETER Extension
        A string containing the message

        .EXAMPLE
        Get-TestFunction -Message 'This is a test message'
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [string]$Path,
        [string]$Extension
    )

    $Extension = $Extension

    $FileNameArray = @()

    if (Test-Path -Path $Path) {

        $SelectedFilesArray = Get-ChildItem -Path $Path -Recurse -Exclude "*.Tests.*" | Where-Object { $_.Extension -eq $Extension } | Select-Object -Property FullName
        $SelectedFilesArray | ForEach-Object { $FileNameArray += [string]$_.FullName }

    }

    return $FileNameArray

}
