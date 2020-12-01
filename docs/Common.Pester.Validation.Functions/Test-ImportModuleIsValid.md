---
external help file: Common.Pester.Validation.Functions-help.xml
Module Name: Common.Pester.Validation.Functions
online version:
schema: 2.0.0
---

# Test-ImportModuleIsValid

## SYNOPSIS
Test that the Import-Module commands are valid

## SYNTAX

```
Test-ImportModuleIsValid [[-ParsedFile] <Object[]>] [[-ImportModuleTokens] <Object[]>] [<CommonParameters>]
```

## DESCRIPTION
Test that the Import-Module commands contain a -Name parameter, and one of RequiredVersion, MinimumVersion or MaximumVersion

## EXAMPLES

### EXAMPLE 1
```
TestImportModuleIsValid -ParsedFile $parsedFile
```

## PARAMETERS

### -ParsedFile
An object containing the source file parsed into its Tokenizer components

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ImportModuleTokens
An object containing the Import-Module calls found

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
