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
