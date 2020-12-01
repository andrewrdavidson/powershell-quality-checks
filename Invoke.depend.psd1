@{
    PSDependOptions = @{
        Target = 'CurrentUser'
    }
    Configuration = 'Latest'
    Pester = @{
        Name = 'Pester'
        Version = '5.1.0'
        Parameters = @{
            AllowPrerelease = $true
            SkipPublisherCheck = $true
        }
    }
    PSScriptAnalyzer = 'Latest'
}
