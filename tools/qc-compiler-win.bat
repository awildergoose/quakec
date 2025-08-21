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
fteqcc-cli-win.exe -DFTE -Wall -srcfile ../progs/csqc.src | grep -i error
echo Compiling FTE SSQC..
fteqcc-cli-win.exe -O3 -DFTE -Wall -srcfile ../progs/ssqc.src | grep -i error
echo Compiling FTE MenuQC..
fteqcc-cli-win.exe -O3 -DFTE -Wall -srcfile ../progs/menu.src | grep -i error
echo Compiling Standard/Id SSQC..
fteqcc-cli-win.exe -O3 -Wall -srcfile ../progs/ssqc.src | grep -i error

SET GAMEDIR=G:\Games\nzp

echo %GAMEDIR%

copy ..\build\fte\csprogs.dat %GAMEDIR%\nzp\csprogs.dat
copy ..\build\fte\csprogs.lno %GAMEDIR%\nzp\csprogs.lno
copy ..\build\fte\menu.dat %GAMEDIR%\nzp\menu.dat
copy ..\build\fte\qwprogs.dat %GAMEDIR%\nzp\qwprogs.dat

pushd "G:\Games\nzp"
start "" "G:\Games\nzp\nzportable-sdl64.exe"
popd
