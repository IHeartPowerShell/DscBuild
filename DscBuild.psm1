#Requires -Version 5

# Import all functions
Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath Functions) -Filter *.ps1 -File -PipelineVariable File | ForEach-Object {
    New-Item -Path function:$($File.BaseName) -Value (Get-Content -Path $File.FullName | Out-String)
}

Export-ModuleMember -Function *