# get all the directories in the modules folder which relates to each module to generate

$moduleLocation = (Get-Item -Path ".\Modules").FullName

$moduleFolders = Get-ChildItem -Path ".\Src" -Directory

$overwriteModule = $true

foreach ($folder in $moduleFolders) {

    # generate a module

    # generate the name of the module
    $moduleName = "{0}{1}" -f $folder.Name, '.psm1'
    $moduleName = Join-Path -Path $moduleLocation -ChildPath $moduleName

    # remove the module if it exists
    if ((Test-Path -Path $moduleName) -and ($overwriteModule -eq $true)) {
        Remove-Item -Path $moduleName -Force
    }

    # now loop through each folder at get the files
    # these are the functions
    $functionFiles = Get-ChildItem -Path $folder -File
    $functionsToExport = @()

    foreach ($function in $functionFiles) {

        # Add the content of the function file
        Get-Content -Path $function.FullName | Add-Content -Path $moduleName

        $functionsToExport += $function.BaseName

        # add a blank line between the functions
        "" | Add-Content -Path $moduleName

    }

    # generate a manifest

    # generate the name of the module
    $manifestName = "{0}{1}" -f $folder.Name, '.psd1'
    $manifestName = Join-Path -Path $moduleLocation -ChildPath $manifestName

    # remove the module if it exists
    if ((Test-Path -Path $manifestName) -and ($overwriteModule -eq $true)) {
        Remove-Item -Path $manifestName -Force
    }

    $newModuleManifest = @{
        Path = $manifestName
        Guid = (New-Guid).Guid
        RootModule = ("{0}{1}" -f $folder.Name, '.psm1')
        ModuleVersion = '1.0.0'
        PowerShellVersion = '7.0'
        FunctionsToExport = $functionsToExport
    }

    New-ModuleManifest @newModuleManifest

    Import-Module -Name $manifestName -Force

    New-MarkdownHelp -Module $folder.Name -OutputFolder ".\docs\$($folder.Name)"
    New-ExternalHelp ".\docs\$($folder.Name)" -OutputPath '.\docs\en-GB'

}
