[CmdletBinding()]
param (
)

Import-Module -Name Install.Dependency -RequiredVersion 1.0.0

Install-Dependency -DependencyFile 'Invoke.Depend.psd1'
