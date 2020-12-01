[CmdletBinding()]
param (
)

Import-Module -Name Install.Dependency -RequiredVersion 1.0.0

Install-Dependency -DependencyFile 'Build.Depend.psd1'

