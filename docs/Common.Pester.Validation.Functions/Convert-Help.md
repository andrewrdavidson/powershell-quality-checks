---
external help file: Common.Pester.Validation.Functions-help.xml
Module Name: Common.Pester.Validation.Functions
online version:
schema: 2.0.0
---

# Convert-Help

## SYNOPSIS
Convert the help comment into an object

## SYNTAX

```
Convert-Help [[-HelpComment] <String>] [<CommonParameters>]
```

## DESCRIPTION
Convert the help comment into an object containing all the elements from the help comment

## EXAMPLES

### EXAMPLE 1
```
$helpObject = Convert-Help -HelpComment $helpComment
```

## PARAMETERS

### -HelpComment
A string containing the Help Comment

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

### System.Collections.Hashtable
### System.Exception
## NOTES

## RELATED LINKS
