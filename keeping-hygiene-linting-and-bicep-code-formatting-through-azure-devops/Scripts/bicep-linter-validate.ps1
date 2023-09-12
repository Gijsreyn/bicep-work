<#
    .SYNOPSIS
        Validates .sarif files for errors/warnings from bicep lint command

    .DESCRIPTION
        Validates .sarif files for errors/warnings from bicep lint command

    .PARAMETER Path
        The path to look for .sarif file(s)

    .EXAMPLE
        PS> & .\Scripts\bicep-linter-validate.ps1 -Path C:\MyOutput

    .NOTES
        Author: Gijs Reijn (@GijsReyn)
#>
[CmdletBinding()]
Param (
    $Path 
)

$Files = Get-ChildItem -Path $Path -Filter *.sarif 
foreach ($File in $Files)
{
    $Json = ConvertFrom-Json -InputObject (Get-Content $File.FullName -Raw)

    if ($json.runs.results | Where-Object {$_.level -eq $null})
    {
        Write-Host -Message ("##[warning]Please inspect the 'Scans' tab in the pipeline run as 'Warnings' found in file - {0}" -f $File.Name)
    }

    if ($Json.runs.results.level -eq 'error')
    {
        Write-Error -Message ("##[error]Please inspect the 'Scans' tab in the pipeline for error(s) in file - {0}" -f $File.Name)
    }
}