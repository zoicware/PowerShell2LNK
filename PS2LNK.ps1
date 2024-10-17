
param(
    [string]$code,
    [switch]$encoded,
    [string]$outputDir,
    [string]$fileName,
    [ValidateSet('32bit', '64bit', 'Pwsh7')]
    [string]$PSVersion,
    [switch]$RunAsAdmin,
    [string]$Icon,
    [switch]$Help
)

if ($Help) {
    Write-Host 'Usage: .\YourScript.ps1 [-code <string>] [-encoded] [-outputDir <string>] [-fileName <string>] [-PSVersion {32bit | 64bit | Pwsh7}] [-RunAsAdmin] [-Icon <string>] [-Help]'
    Write-Host ''
    Write-Host 'Parameters:'
    Write-Host '  -code       : The PowerShell code to execute.'
    Write-Host '  -encoded    : Indicates if the code is base64 encoded.'
    Write-Host '  -outputDir  : The directory where the shortcut will be created.'
    Write-Host '  -fileName   : The name of the shortcut file.'
    Write-Host '  -PSVersion  : The PowerShell version to use (32bit, 64bit, Pwsh7).'
    Write-Host '  -RunAsAdmin : Creates the shortcut to run with highest privileges.'
    Write-Host '  -Icon       : The icon index to use for the shortcut.'
    Write-Host '  -Help       : Displays this help message.'
    return
}

#check output dir if not use scriptroot
if ($null -ne $outputDir) {
    if (!(test-path $outputDir -ErrorAction SilentlyContinue)) {
        $outputDir = $PSScriptRoot
    }
}
else {
    $outputDir = $PSScriptRoot
}

#get ps version bin
$PSPath = $null
#check if pshome returns 32bit or 64bit
if ($PSHOME -like '*SysWOW64*') {
    $homePATH = 32
}
elseif ($PSHOME -like '*System32*') {
    $homePATH = 64
}
else {
    $homePATH = 7
}
    
switch ($PSVersion) {
    '32Bit' { 
        if ($homePATH -eq 32) {
            $PSPath = "$PSHOME\powershell.exe"
        }
        elseif ($homePATH -eq 64) {
            $replacedPath = $PSHOME -replace 'System32', 'SysWOW64'
            $PSPath = "$replacedPath\powershell.exe"
        }
        else {
            $PSPath = 'C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe'
        }
       
    }
    '64Bit' {
        if ($homePATH -eq 64) {
            $PSPath = "$PSHOME\powershell.exe"
        }
        elseif ($homePATH -eq 32) {
            $replacedPath = $PSHOME -replace 'SysWOW64' , 'System32'
            $PSPath = "$replacedPath\powershell.exe"
        }
        else {
            $PSPath = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
        }
    }
    'Pwsh7' {
        if ($homePATH -eq 7) {
            $PSPath = "$PSHOME\pwsh.exe"
        }
        else {
            $ps7Path = 'C:\Program Files\PowerShell\7\pwsh.exe'
            if (Test-Path $ps7Path) {
                $PSPath = $ps7Path
            }
        }
            
        
    }
    default {
        if ($homePATH -eq 7) {
            $PSPath = "$PSHOME\pwsh.exe"
        }
        else {
            $PSPath = "$PSHOME\powershell.exe"
        } 
    }
    
}

    
if ($encoded) {
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($code)
    $base64Command = [Convert]::ToBase64String($bytes)
    $shortcutargs = "-ep Bypass -ec $base64Command"
    $fullArg = "$PSPath -ep Bypass -ec $base64Command"
}
else {
    $shortcutargs = "-ep Bypass -c $code"
    $fullArg = "$PSPath -ep Bypass -c $code"
}
#make sure commandline args arent greater than 4096
if ($fullArg.Length -gt 259) {
    Write-Error 'Code is Greater than 259 Characters'
    exit
}
    
#create shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$outputDir\$fileName.lnk")
$Shortcut.TargetPath = $PSPath
$Shortcut.Arguments = $shortcutargs
if ($Icon) {
    $Shortcut.IconLocation = "C:\Windows\system32\shell32.dll,$Icon"
}
$Shortcut.Save()

  

if ($RunAsAdmin) {
    #edit shortcut bytes to run with highest privileges available
    $bytes = [System.IO.File]::ReadAllBytes($Shortcut.FullName)
    $bytes[0x15] = $bytes[0x15] -bor 0x20
    [System.IO.File]::WriteAllBytes($Shortcut.FullName, $bytes)
}
    
