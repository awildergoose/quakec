@ECHO OFF

CD ../

REM ****** generate hash table ******
REM echo Generating Hash Table..
REM python bin\qc_hash_generator.py -i tools\asset_conversion_table.csv -o source\server\hash_table.qc

REM ****** create build directories ******
REM MKDIR build\fte\ 2>nul
REM MKDIR build\standard\ 2>nul

CD bin/

REM ****** build.. ******
echo Compiling FTE CSQC..
fteqcc-cli-win.exe -DFTE -Wall -srcfile ../progs/csqc.src > csqc.log
set ERR=%ERRORLEVEL%
type csqc.log | grep -e warn -e err -e fatal
if not %ERR%==0 exit /b %ERR%

echo Compiling FTE SSQC..
fteqcc-cli-win.exe -O3 -DFTE -Wall -srcfile ../progs/ssqc.src > ssqc.log
set ERR=%ERRORLEVEL%
type ssqc.log | grep -e warn -e err -e fatal
if not %ERR%==0 exit /b %ERR%

echo Compiling FTE MenuQC..
fteqcc-cli-win.exe -O3 -DFTE -Wall -srcfile ../progs/menu.src > menu.log
set ERR=%ERRORLEVEL%
type menu.log | grep -e warn -e err -e fatal
if not %ERR%==0 exit /b %ERR%

echo Compiling Standard/Id SSQC..
fteqcc-cli-win.exe -O3 -Wall -srcfile ../progs/ssqc.src > std.log
set ERR=%ERRORLEVEL%
type std.log | grep -e warn -e err -e fatal
if not %ERR%==0 exit /b %ERR%

SET GAMEDIR=G:\Games\nzp

copy ..\build\fte\csprogs.dat %GAMEDIR%\nzp\csprogs.dat
copy ..\build\fte\csprogs.lno %GAMEDIR%\nzp\csprogs.lno
copy ..\build\fte\menu.dat %GAMEDIR%\nzp\menu.dat
copy ..\build\fte\qwprogs.dat %GAMEDIR%\nzp\qwprogs.dat

pushd "%GAMEDIR%"
start "" "%GAMEDIR%\nzportable-sdl64.exe" -nosecure -noDTLS -unencrypted
popd
