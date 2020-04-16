mkdir build
cd build

REM Trick to avoid CMake/sh.exe error
ren "C:\Program Files\Git\usr\bin\sh.exe" _sh.exe

set "CC=gcc.exe"
set "CXX=g++.exe"
set "FC=gfortran.exe"

cmake -G "MinGW Makefiles" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DBUILD_SHARED_LIBS=yes ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING=ON ^
    -DLAPACKE=ON ^
    -DCBLAS=ON ^
    -DBUILD_DEPRECATED=ON ^
    -Wno-dev ..

mingw32-make -j%CPU_COUNT%
mingw32-make install

ctest --output-on-failure -E "x*cblat*"
if errorlevel 1 exit 1

for %%i in (blas cblas lapack lapacke) do (
    dumpbin /exports "%LIBRARY_PREFIX%/bin/lib%%i.dll" > exports%%i.txt
    echo LIBRARY lib%%i.dll > %%i.def
    echo EXPORTS >> %%i.def
    for /f "skip=19 tokens=4" %%A in (exports%%i.txt) do echo %%A >> %%i.def
    lib /def:%%i.def /out:%%i.lib /machine:x64
    copy %%i.lib "%LIBRARY_PREFIX%/lib/%%i.lib"
)

dir "%LIBRARY_PREFIX%/lib"
