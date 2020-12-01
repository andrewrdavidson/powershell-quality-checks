function Test-HelpTokensTextIsValid {
    <#
        .SYNOPSIS
        Check that Help Tokens text is valid

        .DESCRIPTION
        Check that the Help Tokens text is valid by making sure that they its not empty

        .PARAMETER HelpComment
        A string containing the text of the Help Comment

        .EXAMPLE
        Test-HelpTokensTextIsValid -HelpComment $helpComment
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

        # Check that the help blocks aren't empty
        foreach ($key in $foundTokens.Keys) {

            $tokenCount = @($foundTokens.$key)

            for ($loop = 0; $loop -lt $tokenCount.Count; $loop++) {

                $token = $foundTokens.$key[$loop]

                if ([string]::IsNullOrWhitespace($token.Text)) {

                    $tokenErrors += "Found '$key' does not have any text. "

                }

            }

        }

        if ($tokenErrors.Count -ge 1) {

            throw $tokenErrors

        }

    }
    catch {

        throw $_.Exception.Message

    }

}
