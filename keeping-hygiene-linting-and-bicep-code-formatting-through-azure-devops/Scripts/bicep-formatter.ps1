<#
    .SYNOPSIS
        Formats Bicep file(s) by calling bicep format command

    .DESCRIPTION
        Formats Bicep file(s) by calling bicep format command

    .PARAMETER SourcePath
        The source path to look for Bicep file(s)

    .EXAMPLE
        PS> & .\Scripts\bicep-formatter.ps1 -SourcePath src

    .NOTES
        Author: Gijs Reijn (@GijsReyn)
#>
[CmdletBinding()]
Param (
    [string]$SourcePath
)

$Source = Split-Path -Path $SourcePath -Parent

$BicepConfigPath = Join-Path -Path $Source -ChildPath 'bicepconfig.json'
if (Test-Path $BicepConfigPath)
{
    Write-Host -Object ("Using Bicep config file - {0}" -f $BicepConfigPath)
    $Content = Get-Content $BicepConfigPath -Raw | ConvertFrom-Json
    if ($Content.formatting.newlineKind)
    {
        $NewLineKind = $Content.formatting.newlineKind
    }
    else 
    {
        $NewLineKind = 'LF'
    }

    if ($Content.formatting.indentKind)
    {
        $IndentKind = $Content.formatting.indentKind
    }
    else 
    {
        $IndentKind = 'Space'
    }

    if ($Content.formatting.indentSize)
    {
        $IndentSize = $Content.formatting.indentSize
    }
    else 
    {
        $IndentSize = '2'
    }
}
else 
{
    Write-Host -Object "Using defaults"
    $NewLineKind = 'LF'
    $IndentKind = 'Space'
    $IndentSize = '2'
}

$FormatFile = Get-ChildItem -Path $SourcePath -Recurse -Include '*.bicep'

Write-Host -Object ("Counting {0} to be formatted" -f $FormatFile.Count)

foreach ($File in $FormatFile)
{
    Write-Host -Object ("Formatting file - {0}" -f $File.Name)
    # No --width option
    bicep format $File.FullName --newLine $NewLineKind `
        --indentKind $IndentKind `
        --indentSize $IndentSize `
        --insertFinalNewLine
}