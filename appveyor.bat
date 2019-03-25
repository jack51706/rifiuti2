@echo off
:: Copyright 2018-19 Abel Cheung
:: License same as main package

set OLDPATH=%PATH%
PATH C:\msys64\%MSYSTEM%\bin;C:\msys64\usr\bin;%OLDPATH%

cd %APPVEYOR_BUILD_FOLDER%
goto %1

echo Unknown build target.
exit 1


:build
@echo on

:: Build fails (unresolved dep) w/o updated msys2 runtime :-/
pacman.exe --noconfirm --noprogressbar -Syu

:: Second invocation updates everything else
:: Wastes too much time updating unnecessary non-core stuff
:: pacman --noconfirm --noprogressbar -Syu

pacman.exe --noconfirm --noprogressbar -S --needed markdown mingw-w64-%MSYS2_ARCH%-glib2
bash -lc "./autogen.sh && ./configure --enable-static && make -C po rifiuti.pot && make all"

@echo off
goto :eof


:check
@echo on

file.exe src\rifiuti.exe
ldd.exe  src\rifiuti.exe

file.exe src\rifiuti-vista.exe
ldd.exe  src\rifiuti-vista.exe

bash -lc "make check"

@echo off
goto :eof


:package
@echo on

if "%APPVEYOR_REPO_TAG%" == "true" (
    echo "*** Building official release ***"
    bash -lc "make dist-win"
) else (
    bash -lc "make dist-win ZIPNAME=%APPVEYOR_PROJECT_SLUG%-%APPVEYOR_REPO_COMMIT:~0,8%-win-%MSYS2_ARCH%"
)

@echo off
goto :eof