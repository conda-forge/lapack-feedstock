mkdir build
cd build

:: Trick to avoid CMake/sh.exe error
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
if %ERRORLEVEL% NEQ 0 exit 1

:: testing with shared libraries does not work - skip them.
:: This is because: to test that the program exits if wrong parameters are given,
:: the testsuite overrides the symbol xerbla (xerbla logs the error and exits) with
:: its own version that reports to the test program in case of an error.
:: This does not work with dylibs on osx and dlls on windows.
ctest --output-on-failure -E "x*cblat*"
if %ERRORLEVEL% NEQ 0 exit 1

for %%i in (blas cblas lapack lapacke) do (
    dumpbin /exports "%LIBRARY_PREFIX%/bin/lib%%i.dll" > exports%%i.txt
    echo LIBRARY lib%%i.dll > %%i.def
    echo EXPORTS >> %%i.def
    for /f "skip=19 tokens=4" %%A in (exports%%i.txt) do echo %%A >> %%i.def
    lib /def:%%i.def /out:%%i.lib /machine:x64
    copy %%i.lib "%LIBRARY_PREFIX%/lib/%%i.lib"
)

dir "%LIBRARY_PREFIX%/lib"
