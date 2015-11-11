#Requires -Version 5

<#
.SYNOPSIS
    Imports a PowerShell data file as a hashtable.
#>
[OutputType([Hashtable])]
[CmdletBinding()]
param
(
    [Parameter(Mandatory,Position=0,ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [string] $Path
)

process
{
    # Ensure the file exists
    if (!(Test-Path -Path $Path -PathType Leaf))
    {
        Write-Error -Message "Cannot find '$($Path)' because it does not exist or access is denied." -ErrorAction Stop -Category ReadError
    }

    # Ensure the content of the file is parsable like a script block
    $Content = Get-Content -Path $Path -ErrorAction Stop | Out-String

    try
    {
        $ScriptBlock = [ScriptBlock]::Create($Content)
    }
    catch [System.Management.Automation.MethodInvocationException]
    {
        Write-Error -Message "The file '$($Path)' cannot be imported because of syntax errors: $($_.Exception.InnerException.Message)" -ErrorAction Stop -Category InvalidData
    }

    # Temporarily change the path to the directory of the configuration file
    Push-Location -Path (Split-Path -Path $Path -Parent) -ErrorAction Stop

    try
    {
        # Load the PSD1 file like a data section, allow nested commands to load other DSC data
        Invoke-Expression -Command "DATA -SupportedCommand Import-DscConfigurationData,Import-PSEncryptedCredential,Import-PSEncryptedData {$($Content)}" -ErrorAction Stop
    }
    finally
    {
        Pop-Location -ErrorAction Stop
    }
}