mkdir build
cd build

REM Trick to avoid CMake/sh.exe error
ren "C:\Program Files\Git\usr\bin\sh.exe" _sh.exe

cmake -G "MinGW Makefiles" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DBUILD_SHARED_LIBS=yes ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DLAPACKE=ON ^
    -DCBLAS=ON ^
    -DCMAKE_GNUtoMS=ON ^
    -Wno-dev ..

mingw32-make -j%CPU_COUNT%
mingw32-make install

ctest --output-on-failure

move "%LIBRARY_LIB%\libblas.lib"    "%LIBRARY_LIB%\cblas.lib"
move "%LIBRARY_LIB%\libcblas.lib"   "%LIBRARY_LIB%\cblas.lib"
move "%LIBRARY_LIB%\liblapack.lib"  "%LIBRARY_LIB%\lapack.lib"
move "%LIBRARY_LIB%\liblapacke.lib" "%LIBRARY_LIB%\lapacke.lib"
