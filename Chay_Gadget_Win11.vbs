' Minecraft Win11 Mini Gadget VBS Launcher
Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
currentDir = fso.GetParentFolderName(WScript.ScriptFullName)
psScript = currentDir & "\Minecraft_Gadget_Win11.ps1"

cmd = "powershell.exe -Sta -WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File """ & psScript & """"
WshShell.Run cmd, 0, False
