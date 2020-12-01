function Test-HelpTokensParamsMatch {
    <#
        .SYNOPSIS
        Description of TestScript

        .DESCRIPTION
        A detailed synopsis of the function of the script

        .PARAMETER HelpComment
        A string containing the text of the Help Comment

        .PARAMETER ParameterVariables
        A object containing the parameters from the param block

        .EXAMPLE
        Test-HelpTokensParamsMatch -HelpComment $helpComment -ParameterVariables $ParameterVariables
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.String[]])]
    param (
        [string]$HelpComment,
        [PSCustomObject]$ParameterVariables
    )
    try {

        try {

            $foundTokens = Convert-Help -HelpComment $HelpComment

        }
        catch {

            throw $_

        }

        $foundInHelpErrors = @()
        $foundInParamErrors = @()

        # Loop through each of the parameters from the param block looking for that variable in the PARAMETER help
        foreach ($key in $ParameterVariables.Keys) {

            $foundInHelp = $false

            foreach ($token in $foundTokens.".PARAMETER") {

                if ($key -eq $token.Name) {

                    # If we find a match, exit out from the loop
                    $foundInHelp = $true
                    break

                }

            }

            if ($foundInHelp -eq $false) {

                $foundInHelpErrors += "Parameter block variable '$key' was not found in help. "

            }

        }

        # Loop through each of the PARAMETER from the help looking for parameters from the param block
        foreach ($token in $foundTokens.".PARAMETER") {

            $foundInParams = $false

            foreach ($key in $ParameterVariables.Keys) {

                if ($key -eq $token.Name) {

                    # If we find a match, exit out from the loop
                    $foundInParams = $true
                    break

                }

            }

            if ($foundInParams -eq $false) {

                $foundInParamErrors += "Help defined variable '$($token.Name)' was not found in parameter block definition. "

            }

        }

        if ($foundInHelpErrors.Count -ge 1 -or $foundInParamErrors.Count -ge 1) {

            $allErrors = $foundInHelpErrors + $foundInParamErrors
            throw $allErrors

        }

    }
    catch {

        throw $_.Exception.Message

    }

}
