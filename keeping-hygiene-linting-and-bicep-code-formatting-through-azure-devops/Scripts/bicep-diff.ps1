<#
    .SYNOPSIS
        Grabs the differences of Bicep file(s) by running git diff and outputting the results to a file

    .DESCRIPTION
        Grabs the differences of Bicep file(s) by running git diff and outputting the results to a file

    .PARAMETER OutputPath
        The output path to save results in

    .EXAMPLE
        PS> & .\Scripts\bicep-diff.ps1 -OutputPath C:\Temp

    .NOTES
        Author: Gijs Reijn (@GijsReyn)
#>
[CmdletBinding()]
Param (
    $OutputPath
)

$Diffs = git diff --name-only
foreach ($Diff in $Diffs)
{
    $FileName = Split-Path $Diff -Leaf
    $OutFile = Join-Path -Path $OutputPath -ChildPath $FileName

    if ([System.IO.Path]::GetExtension($FileName) -eq '.bicep')
    {
        $OutFile = $OutFile.Replace('.bicep', '.txt')
        Write-Host -Object ("Outputting differences in file - {0}" -f $FileName) 
        git diff --output $OutFile --unified=0 $diff

        Write-Warning -Message ("##[warning]Differences found when formatting file - {0}" -f $FileName)
        Write-Host "##vso[task.complete result=SucceededWithIssues;]"
    }
}