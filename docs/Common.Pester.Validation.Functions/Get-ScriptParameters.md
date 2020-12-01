---
external help file: Common.Pester.Validation.Functions-help.xml
Module Name: Common.Pester.Validation.Functions
online version:
schema: 2.0.0
---

# Get-ScriptParameters

## SYNOPSIS
Get a list of the parameters in the param block

## SYNTAX

```
Get-ScriptParameters [[-Content] <String>] [<CommonParameters>]
```

## DESCRIPTION
Create a list of the parameters, and their type (if available) from the param block

## EXAMPLES

### EXAMPLE 1
```
Get-ScriptParameters -Content $Content
```

## PARAMETERS

### -Content
A string containing the text of the script

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
### System.Collections.Hashtable
## NOTES

## RELATED LINKS
