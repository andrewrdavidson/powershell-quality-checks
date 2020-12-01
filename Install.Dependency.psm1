function Install-Dependency {
    [CmdletBinding()]
    param (
        $SourceFolder = $PSScriptRoot,
        $DependencyFile = 'PSDepend.psd1',
        $Repository = (Get-PSRepository)[0].Name
    )

    # Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force <= Not required in PS 7?
    Set-PSRepository -Name $Repository -InstallationPolicy Trusted

    if (-not (Get-Module PSDepend -ListAvailable)) {
        Install-Module PSDepend -Repository $Repository -Scope CurrentUser
    }

    if (Test-Path -Path $DependencyFile) {
        Invoke-PSDepend -Path $DependencyFile -Confirm:$false
    }

    if (Test-Path -Path $SourceFolder) {
        Invoke-PSDepend -Path $SourceFolder -Confirm:$false
    }

}
