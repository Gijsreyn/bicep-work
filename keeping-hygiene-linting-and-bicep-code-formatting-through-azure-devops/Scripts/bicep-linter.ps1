<#
    .SYNOPSIS
        Runs bicep lint command through command line to retrieve the output in Sarif format if rules are violated

    .DESCRIPTION
        Runs bicep lint command through command line to retrieve the output in Sarif format if rules are violated

    .PARAMETER SourcePath
        The source path to look for Bicep file(s)
    
    .PARAMETER OutputPath 
        The output path to save SARIF file(s) in

    .EXAMPLE
        PS> & .\Scripts\bicep-linter.ps1 -SourcePath src -OutputPath C:\MyResults

    .NOTES
        Author: Gijs Reijn (@GijsReyn)
#>
[CmdletBinding()]
Param (
    [string]$SourcePath,
    [string]$ExcludeFolder = 'resources',
    [string]$OutputPath 
)

$Files = Get-ChildItem $SourcePath -Filter *.bicep -Recurse | Where-Object { $_.DirectoryName -notmatch $ExcludeFolder }

foreach ($File in $Files) {
    Write-Host -Object ("Start linting file - {0} in directory {1}" -f $File.Name, $File.DirectoryName)
    $Output = cmd /c bicep lint $File.FullName --diagnostics-format Sarif '2>&1'

    $Json = $Output | ConvertFrom-Json -ErrorAction SilentlyContinue

    if ($Json) {
        Write-Host -Object ("Checking for violations")
        # Warning is null
        $Violations = $Json.runs.results | Where-Object { $_.level -in @("error", $null) }
        if ($Violations.Count -gt 0) {
            Write-Host -Object ("Outputting violating linting results for - {0}" -f $File.Name)
            $OutFile = Join-Path -Path $OutputPath -ChildPath $File.Name.Replace(".bicep", ".sarif")
            Out-File -FilePath $OutFile -Encoding utf8 -Force -InputObject $Output
        }
        else 
        {
            Write-Host -Object ("No violations for file - {0}" -f $File.Name)
        }
    }
}