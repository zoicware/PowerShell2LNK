## PS2LNK

This PowerShell script allows you to pass a command and create a customized shortcut file (LNK) to execute the code. This can be used to bypass windows execution policy or create a fake file to run PowerShell code.

### How to Use

*Run the Script From PowerShell*  
**Example**  
```PowerShell
.\PS2LNK.ps1 -code 'Write-Host Hello World' -PSVersion 64bit -RunAsAdmin
```

**Display Help**
```PowerShell
.\PS2LNK.ps1 -Help
```
![image](https://github.com/user-attachments/assets/0b0b61b8-49e7-4bb9-97e7-f4daa37dabde)

**Change Icon**

```PowerShell
.\PS2LNK.ps1 -code 'Write-Host Hello World' -PSVersion 64bit -RunAsAdmin -Icon 173
```

### Get Icon Index

- Download IconsExtract from NirSoft - https://www.nirsoft.net/utils/iconsext.html

- Find the index of the icon you want your lnk file to have from Shell32.dll
