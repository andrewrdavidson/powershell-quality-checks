function Export-FunctionsFromModule {
    <#
        .DESCRIPTION
        Export functions from a PowerShell module (.psm1)

        .SYNOPSIS
        Takes a PowerShell module and outputs a single file for each function containing the code for that function

        .PARAMETER Path
        A string Path containing the full file name and path to the module

        .PARAMETER FunctionExtractPath
        A string Path containing the full path to the extraction folder

        .EXAMPLE
        Export-FunctionsFromModule -Path 'c:\path.to\module.psm1'
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [string]$Path,
        [string]$FunctionExtractPath
    )

    # Get the file properties of our module
    $fileProperties = (Get-Item -LiteralPath $Path)
    $moduleName = $fileProperties.BaseName

    # Generate a new temporary output path for our extracted functions
    $FunctionOutputPath = Join-Path -Path $FunctionExtractPath -ChildPath $moduleName
    New-Item $FunctionOutputPath -ItemType Directory

    # Get the plain content of the module file
    $ModuleFileContent = Get-Content -Path $Path -ErrorAction Stop

    # Parse the PowerShell module using PSParser
    $ParserErrors = $null
    $ParsedFileFunctions = [System.Management.Automation.PSParser]::Tokenize($ModuleFileContent, [ref]$ParserErrors)

    # Create an array of where each reference of the keyword 'function' is
    $ParsedFunctions = ($ParsedFileFunctions | Where-Object { $_.Type -eq "Keyword" -and $_.Content -like 'function' })

    # Initialise the $parsedFunction tracking variable
    $parsedFunction = 0

    foreach ($Function in $ParsedFunctions) {

        # Counter for the array $ParsedFunction to help find the 'next' function
        $parsedFunction++

        # Get the name of the current function
        # Cheat: Simply getting all properties with the same line number as the 'function' statement
        $FunctionProperties = $ParsedFileFunctions | Where-Object { $_.StartLine -eq $Function.StartLine }
        $FunctionName = ($FunctionProperties | Where-Object { $_.Type -eq "CommandArgument" }).Content

        # Establish the Start and End lines for the function in the main module file
        if ($parsedFunction -eq $ParsedFunctions.Count) {

            # This is the last function in the module so set the last line of this function to be the last line in the module file

            $StartLine = ($Function.StartLine)
            for ($line = $ModuleFileContent.Count; $line -gt $Function.StartLine; $line--) {
                if ($ModuleFileContent[$line] -like "}") {
                    $EndLine = $line
                    break
                }
            }
        }
        else {

            $StartLine = ($Function.StartLine)

            # EndLine needs to be where the last } is
            for ($line = $ParsedFunctions[$parsedFunction].StartLine; $line -gt $Function.StartLine; $line--) {
                if ($ModuleFileContent[$line] -like "}") {
                    $EndLine = $line
                    break
                }
            }

        }

        # Setup the FunctionOutputFile for the function file
        $FunctionOutputFileName = "{0}\{1}{2}" -f $FunctionOutputPath, $FunctionName, ".ps1"

        # If the file doesn't exist create an empty file so that we can Add-Content to it
        if (-not (Test-Path -Path $FunctionOutputFileName)) {
            Out-File -FilePath $FunctionOutputFileName
        }

        # Output the lines of the function to the FunctionOutputFile
        for ($line = $StartLine; $line -lt $EndLine; $line++) {
            Add-Content -Path $FunctionOutputFileName -Value $ModuleFileContent[$line]
        }

    }

}

function Get-FileContent {
    <#
        .DESCRIPTION
        Description of TestScript

        .SYNOPSIS
        A detailed synopsis of the function of the script

        .PARAMETER File
        A string containing the message

        .EXAMPLE
        Get-TestFunction -Message 'This is a test message'
    #>
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param (
        [string]$File
    )

    $fileContent = Get-Content -Path $File

    $parserErrors = $null
    $parsedFileFunctions = [System.Management.Automation.PSParser]::Tokenize($fileContent, [ref]$parserErrors)

    # Create an array of where each reference of the keyword 'function' is
    $parsedFunctions = ($parsedFileFunctions | Where-Object { $_.Type -eq "Keyword" -and $_.Content -like 'function' })

    if ($parsedFunctions) {

        foreach ($function in $parsedFunctions) {

            $startLine = ($function.StartLine)

            for ($line = $fileContent.Count; $line -gt $function.StartLine; $line--) {

                if ($fileContent[$line] -like "}") {

                    $endLine = $line
                    break

                }

            }

            # Output the lines of the function to the FunctionOutputFile
            for ($line = $startLine; $line -lt $endLine; $line++) {
                $parsedFileContent += $fileContent[$line]
                $parsedFileContent += "`n"
            }

        }

    }
    else {

        for ($line = 0; $line -lt $fileContent.Count; $line++) {
            $parsedFileContent += $fileContent[$line]
            $parsedFileContent += "`n"
        }

    }

    return $parsedFileContent

}

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

function Get-FunctionCount {
    <#
        .DESCRIPTION
        Description of TestScript

        .SYNOPSIS
        A detailed synopsis of the function of the script

        .PARAMETER ModuleFile
        A string containing the message

        .PARAMETER ManifestFile
        A string containing the message

        .EXAMPLE
        Get-TestFunction -Message 'This is a test message'
    #>
    [CmdletBinding()]
    [OutputType([Int[]])]
    param (
        [string]$ModuleFile,
        [string]$ManifestFile
    )

    $CommandFoundInModuleCount = 0
    $CommandFoundInManifestCount = 0
    $CommandInModule = 0

    $ExportedCommands = (Test-ModuleManifest -Path $ManifestFile -ErrorAction Stop).ExportedCommands

    ($ParsedModule, $ParserErrors) = Get-ParsedFile -Path $ModuleFile

    foreach ($ExportedCommand in $ExportedCommands.Keys) {

        if ( ($ParsedModule | Where-Object { $_.Type -eq "CommandArgument" -and $_.Content -eq $ExportedCommand })) {

            $CommandFoundInModuleCount++

        }

    }

    $functionNames = @()

    $functionKeywords = ($ParsedModule | Where-Object { $_.Type -eq "Keyword" -and $_.Content -eq "function" })
    $functionKeywords | ForEach-Object {

        $functionLineNo = $_.StartLine
        $functionNames += ($ParsedModule | Where-Object { $_.Type -eq "CommandArgument" -and $_.StartLine -eq $functionLineNo })

    }

    $functionNames | ForEach-Object {

        $CommandInModule++
        if ($ExportedCommands.ContainsKey($_.Content)) {

            $CommandFoundInManifestCount++

        }

    }

    return ($ExportedCommands.Count, $CommandFoundInModuleCount, $CommandInModule, $CommandFoundInManifestCount)

}

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

function Get-ModuleFile {
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

    return (Get-FileList -Path $Path -Extension ".psm1")

}

function Get-ParsedContent {
    <#
        .DESCRIPTION
        Description of TestScript

        .SYNOPSIS
        A detailed synopsis of the function of the script

        .PARAMETER Content
        A string containing the message

        .EXAMPLE
        Get-TestFunction -Message 'This is a test message'
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [string]$Content
    )

    $ParserErrors = $null
    $ParsedModule = [System.Management.Automation.PSParser]::Tokenize($Content, [ref]$ParserErrors)

    return $ParsedModule, ($ParserErrors.Count)

}

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

function Get-TokenComponent {
    <#
        .DESCRIPTION
        Description of TestScript

        .SYNOPSIS
        A detailed synopsis of the function of the script

        .PARAMETER ParsedFileContent
        A string containing the message

        .PARAMETER StartLine
        A string containing the message

        .EXAMPLE
        Get-TestFunction -Message 'This is a test message'
    #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [System.Object[]]$ParsedFileContent,
        [int]$StartLine
    )

    #* This is just to satisfy the PSScriptAnalyzer
    #* which can't find the variables in the 'Where-Object' clause (even though it's valid)
    $StartLine = $StartLine

    $tokenComponents = @($ParsedFileContent | Where-Object { $_.StartLine -eq $StartLine })

    return $tokenComponents

}

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

