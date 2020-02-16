## IRONScripter_raise-the-dead-with-this-powershell-challenge
#Ubuntu/KDE Tash Location
#cd .local/share/Trash

<###
1. Calc how much space is being used by files in trash
2. move back to original file location
###>

#1.
$TrashSum = Get-ChildItem ~/.local/share/Trash/files | Measure-Object Length -Sum
"$($($TrashSum.Sum) / 1000)MB"

#2.
Get-ChildItem ~/.local/share/Trash/files | fl *