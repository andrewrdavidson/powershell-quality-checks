function Convert-Help {
    <#
        .SYNOPSIS
        Convert the help comment into an object

        .DESCRIPTION
        Convert the help comment into an object containing all the elements from the help comment

        .PARAMETER HelpComment
        A string containing the Help Comment

        .EXAMPLE
        $helpObject = Convert-Help -HelpComment $helpComment
    #>
    [CmdletBinding()]
    [OutputType([HashTable], [System.Exception])]
    param (
        [string]$HelpComment
    )

    # These are the possible Help Comment elements that the script will look for
    # .SYNOPSIS
    # .DESCRIPTION
    # .PARAMETER
    # .EXAMPLE
    # .INPUTS
    # .OUTPUTS
    # .NOTES
    # .LINK
    # .COMPONENT
    # .ROLE
    # .FUNCTIONALITY
    # .FORWARDHELPTARGETNAME
    # .FORWARDHELPCATEGORY
    # .REMOTEHELPRUNSPACE
    # .EXTERNALHELP

    # This function will go through the help and work out which elements are where and what text they contain

    try {

        if (-not(
                $HelpComment.StartsWith("<#") -and
                $HelpComment.EndsWith("#>")
            )) {
            throw "Help does not appear to be a comment block"
        }

        # an array of string help elements to look for
        $helpElementsToFind =
        '.SYNOPSIS',
        '.DESCRIPTION',
        '.PARAMETER',
        '.EXAMPLE',
        '.INPUTS',
        '.OUTPUTS',
        '.NOTES',
        '.LINK',
        '.COMPONENT',
        '.ROLE',
        '.FUNCTIONALITY',
        '.FORWARDHELPTARGETNAME',
        '.FORWARDHELPCATEGORY',
        '.REMOTEHELPRUNSPACE',
        '.EXTERNALHELP'

        # Split the single comment string into it's line components
        $commentArray = ($HelpComment -split '\n').Trim()

        # initialise an empty HashTable ready for the found help elements to be stored
        $foundElements = @{}
        $numFound = 0

        # loop through all the 'lines' of the help comment
        for ($line = 0; $line -lt $commentArray.Count; $line++) {

            # get the first 'word' of the help comment. This is required so that we can
            # match '.PARAMETER' since it has a parameter name after it
            $helpElementName = ($commentArray[$line] -split " ")[0]

            # see whether the $helpElements array contains the first 'word'
            if ($helpElementsToFind -contains $helpElementName) {

                $numFound++

                if ($numFound -ge 2) {

                    # of it's the second element then we must set the help comment text of the
                    # previous element to the found text so far, then reset it

                    $lastElement = @($foundElements[$lastHelpElement])
                    $lastElement[$lastElement.Count - 1].Text = $help
                    $foundElements[$lastHelpElement] = $lastElement

                    $help = $null
                }

                # this should be an array of HashTables {LineNumber, Name & Text}
                $currentElement = @($foundElements[$helpElementName])

                $newElement = @{}
                $newElement.LineNumber = $line
                $newElement.Name = ($commentArray[$line] -split " ")[1]
                $newElement.Text = ""

                if ($null -eq $currentElement[0]) {

                    $currentElement = $newElement

                }
                else {
                    $currentElement += $newElement
                }

                # update the foundItems HashTable with the new found element
                $foundElements[$helpElementName] = $currentElement

                $lastHelpElement = $helpElementName

            }
            else {

                if ($numFound -ge 1 -and $line -ne ($commentArray.Count - 1)) {

                    $help += $commentArray[$line]

                }

            }

        }

        # process the very last one
        $currentElement = @($foundElements[$lastHelpElement])
        $currentElement[$currentElement.Count - 1].Text = $help
        $foundElements[$lastHelpElement] = $currentElement

        return $foundElements
    }
    catch {

        throw $_.Exception.Message

    }

}

function Get-ScriptParameters {
    <#
        .SYNOPSIS
        Get a list of the parameters in the param block

        .DESCRIPTION
        Create a list of the parameters, and their type (if available) from the param block

        .PARAMETER Content
        A string containing the text of the script

        .EXAMPLE
        Get-ScriptParameters -Content $Content
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [HashTable])]
    param
    (
        [String]$Content
    )

    try {

        $parsedScript = [System.Management.Automation.Language.Parser]::ParseInput($Content, [ref]$null, [ref]$null)

        [string]$paramBlock = $parsedScript.ParamBlock

        ($ParsedContent, $ParserErrorCount) = Get-ParsedContent -Content $paramBlock

        $paramBlockArray = ($paramBlock -split '\n').Trim()

        $parametersFound = @{}

        for ($line = 0; $line -le $paramBlockArray.Count; $line++) {

            $paramToken = @($ParsedContent | Where-Object { $_.StartLine -eq $line })

            foreach ($token in $paramToken) {

                if ($token.Type -eq 'Attribute' -and $token.Content -eq "Parameter") {

                    # break the inner loop because this token doesn't contain a variable for definite
                    break
                }

                if ($token.Type -eq 'Type') {

                    # Found a type for a parameter
                    $foundType = $token.Content

                }

                if ($token.Type -eq 'Variable') {

                    # Found a variable
                    $parametersFound[$token.Content] = $foundType
                    $foundType = $null
                    break

                }

            }


        }

        return $parametersFound

    }
    catch {

        throw $_.Exception.Message

    }

}

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

function Test-HelpForUnspecifiedTokens {
    <#
        .SYNOPSIS
        Check that help tokens do not contain unspecified tokens

        .DESCRIPTION
        Check that the help comments do not contain tokens that are not specified in the external verification data file

        .PARAMETER HelpComment
        A string containing the text of the Help Comment

        .EXAMPLE
        Test-HelpForUnspecifiedTokens -HelpComment $helpComment
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

            $helpElementRules = (Import-PowerShellDataFile -Path ".\Quality\HelpElementRules.psd1")

        }
        else {

            throw "Unable to load HelpElementRules.psd1"

        }

        $tokenErrors = @()
        $helpTokensKeys = @()

        # Create an array of the help element rules elements
        for ($order = 1; $order -le $helpElementRules.Count; $order++) {

            $token = $helpElementRules."$order"

            $helpTokensKeys += $token.key

        }

        # search through the found tokens and match them against the rules
        foreach ($key in $foundTokens.Keys) {

            if ( $key -notin $helpTokensKeys ) {

                $tokenErrors += $key

            }

        }

        if ($tokenErrors.Count -ge 1) {
            throw "Found extra, non-specified, token(s): $tokenErrors"
        }

    }
    catch {

        throw $_.Exception.Message

    }

}

function Test-HelpTokensCountIsValid {
    <#
        .SYNOPSIS
        Check that help tokens count is valid

        .DESCRIPTION
        Check that the help tokens count is valid by making sure that they appear between Min and Max times

        .PARAMETER HelpComment
        A string containing the text of the Help Comment

        .EXAMPLE
        Test-HelpTokensCountIsValid -HelpComment $helpComment

        .NOTES
        This function will only check the Min/Max counts of required help tokens
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

            $helpElementRules = (Import-PowerShellDataFile -Path ".\Quality\HelpElementRules.psd1")

        }
        else {

            throw "Unable to load HelpElementRules.psd1"

        }

        # create a HashTable for tracking whether the element has been found
        $tokenFound = @{}
        for ($order = 1; $order -le $helpElementRules.Count; $order++) {
            $token = $helpElementRules."$order".Key
            $tokenFound[$token] = $false
        }

        $tokenErrors = @()

        # loop through all the found tokens
        foreach ($key in $foundTokens.Keys) {

            # loop through all the help element rules
            for ($order = 1; $order -le $helpElementRules.Count; $order++) {

                $token = $helpElementRules."$order"

                # if the found token matches against a rule
                if ( $token.Key -eq $key ) {

                    $tokenFound[$key] = $true

                    # if the count is not between min and max AND is required
                    # that's an error
                    if ($foundTokens.$key.Count -lt $token.MinOccurrences -or
                        $foundTokens.$key.Count -gt $token.MaxOccurrences -and
                        $token.Required -eq $true) {

                        $tokenErrors += "Found $(($foundTokens.$key).Count) occurrences of '$key' which is not between $($token.MinOccurrences) and $($token.MaxOccurrences). "

                    }

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

function Test-ImportModuleIsValid {
    <#
        .SYNOPSIS
        Test that the Import-Module commands are valid

        .DESCRIPTION
        Test that the Import-Module commands contain a -Name parameter, and one of RequiredVersion, MinimumVersion or MaximumVersion

        .PARAMETER ParsedFile
        An object containing the source file parsed into its Tokenizer components

        .PARAMETER ImportModuleTokens
        An object containing the Import-Module calls found

        .EXAMPLE
        TestImportModuleIsValid -ParsedFile $parsedFile
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param(
        [System.Object[]]$ParsedFile,
        [System.Object[]]$ImportModuleTokens
    )

    try {

        $errString = ""

        # loop through each token found looking for the -Name and one of RequiredVersion, MinimumVersion or MaximumVersion
        foreach ($token in $importModuleTokens) {

            # Get the full details of the command
            $importModuleStatement = Get-TokenComponent -ParsedFileContent $ParsedFile -StartLine $token.StartLine

            # Get the name of the module to be imported (for logging only)
            $name = ($importModuleStatement | Where-Object { $_.Type -eq "String" } | Select-Object -First 1).Content

            # if the -Name parameter is not found
            if (-not($importModuleStatement | Where-Object { $_.Type -eq "CommandParameter" -and $_.Content -eq "-Name" })) {

                $errString += "Import-Module for '$name' : Missing -Name parameter keyword. "

            }

            # if one of RequiredVersion, MinimumVersion or MaximumVersion is not found
            if (-not($importModuleStatement | Where-Object { $_.Type -eq "CommandParameter" -and ( $_.Content -eq "-RequiredVersion" -or $_.Content -eq "-MinimumVersion" -or $_.Content -eq "-MaximumVersion" ) })) {

                $errString += "Import-Module for '$name' : Missing -RequiredVersion, -MinimumVersion or -MaximumVersion parameter keyword. "

            }

        }

        # If there are any problems throw to fail the test
        if (-not ([string]::IsNullOrEmpty($errString))) {

            throw $errString

        }

    }
    catch {

        throw $_.Exception.Message

    }

}

function Test-ParameterVariablesHaveType {
    <#
        .SYNOPSIS
        Check that all the passed parameters have a type variable set.

        .DESCRIPTION
        Check that all the passed parameters have a type variable set.

        .PARAMETER ParameterVariables
        A HashTable containing the parameters from the param block

        .EXAMPLE
        Test-ParameterVariablesHaveType -ParameterVariables $ParameterVariables
    #>
    [CmdletBinding()]
    [OutputType([System.Exception], [System.Void])]
    param
    (
        [HashTable]$ParameterVariables
    )

    $variableErrors = @()

    try {

        foreach ($key in $ParameterVariables.Keys) {

            if ([string]::IsNullOrEmpty($ParameterVariables.$key)) {

                $variableErrors += "Parameter '$key' does not have a type defined. "

            }

        }

        if ($variableErrors.Count -ge 1) {

            throw $variableErrors
        }

    }
    catch {

        throw $_.Exception.Message

    }

}

