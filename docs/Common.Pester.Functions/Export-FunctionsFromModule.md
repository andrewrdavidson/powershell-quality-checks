---
external help file: Common.Pester.Functions-help.xml
Module Name: Common.Pester.Functions
online version:
schema: 2.0.0
---

# Export-FunctionsFromModule

## SYNOPSIS
Takes a PowerShell module and outputs a single file for each function containing the code for that function

## SYNTAX

```
Export-FunctionsFromModule [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION
Export functions from a PowerShell module (.psm1)

## EXAMPLES

### EXAMPLE 1
```
Export-FunctionsFromModule -Path 'c:\path.to\module.psm1'
```

## PARAMETERS

### -Path
A string Path containing the full file name and path to the module

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

### System.Void
## NOTES

## RELATED LINKS
