---
external help file: Common.Pester.Validation.Functions-help.xml
Module Name: Common.Pester.Validation.Functions
online version:
schema: 2.0.0
---

# Test-ParameterVariablesHaveType

## SYNOPSIS
Check that all the passed parameters have a type variable set.

## SYNTAX

```
Test-ParameterVariablesHaveType [[-ParameterVariables] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION
Check that all the passed parameters have a type variable set.

## EXAMPLES

### EXAMPLE 1
```
Test-ParameterVariablesHaveType -ParameterVariables $ParameterVariables
```

## PARAMETERS

### -ParameterVariables
A HashTable containing the parameters from the param block

```yaml
Type: Hashtable
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
