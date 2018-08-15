# https://github.com/stayradiated/terminal.sexy

cd "C:\msys64\home\$env:USERNAME"
git clone https://github.com/joonro/ConEmu-Color-Themes.git

cd "C:\msys64\home\$env:USERNAME\ConEmu-Color-Themes"
foreach($file in dir themes)
{
   if ($File.Name -ne "monokai.xml") {
     .\Install-ConEmuTheme.ps1 -ConfigPath "C:\cmder\vendor\conemu-maximus5\ConEmu.xml" -Operation Add -ThemePathOrName "themes\$File"
  }
}
