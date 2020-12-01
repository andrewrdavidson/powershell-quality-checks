---
external help file: Common.Pester.Validation.Functions-help.xml
Module Name: Common.Pester.Validation.Functions
online version:
schema: 2.0.0
---

# Test-HelpForUnspecifiedTokens

## SYNOPSIS
Check that help tokens do not contain unspecified tokens

## SYNTAX

```
Test-HelpForUnspecifiedTokens [[-HelpComment] <String>] [<CommonParameters>]
```

## DESCRIPTION
Check that the help comments do not contain tokens that are not specified in the external verification data file

## EXAMPLES

### EXAMPLE 1
```
Test-HelpForUnspecifiedTokens -HelpComment $helpComment
```

## PARAMETERS

### -HelpComment
A string containing the text of the Help Comment

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Exception
### System.Void
## NOTES

## RELATED LINKS
