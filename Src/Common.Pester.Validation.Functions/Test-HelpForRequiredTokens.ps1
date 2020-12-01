function Test-HelpForRequiredTokens {
    <#
        .SYNOPSIS
        Check that help tokens contain required tokens

        .DESCRIPTION
        Check that the help comments contain tokens that are specified in the external verification data file

        .PARAMETER HelpComment
        A string containing the text of the Help Comment

        .EXAMPLE
        Test-HelpForRequiredTokens -HelpComment $helpComment
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param (
        [string]$HelpComment
    )

    try {

        try {
            $foundTokens = Convert-Help -HelpComment $HelpComment
        }
        catch {
            throw $_
        }

        if (Test-Path -Path ".\Quality\HelpElementRules.psd1") {

            $helpTokens = (Import-PowerShellDataFile -Path ".\Quality\HelpElementRules.psd1")

        }
        else {

            throw "Unable to load HelpElementRules.psd1"

        }

        $tokenErrors = @()

        for ($order = 1; $order -le $helpTokens.Count; $order++) {

            $token = $helpTokens."$order"

            if ($token.Key -notin $foundTokens.Keys ) {

                if ($token.Required -eq $true) {

                    $tokenErrors += $token.Key

                }

            }

        }

        if ($tokenErrors.Count -ge 1) {
            throw "Missing required token(s): $tokenErrors"
        }

    }
    catch {

        throw $_.Exception.Message

    }

}
