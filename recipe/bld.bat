mkdir build
cd build

REM Trick to avoid CMake/sh.exe error
ren "C:\Program Files\Git\usr\bin\sh.exe" _sh.exe

cmake -G "MinGW Makefiles" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_C_COMPILER=clang-cl ^
    -DCMAKE_Fortran_COMPILER=flang ^
    -DBUILD_SHARED_LIBS=yes ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DLAPACKE=ON ^
    -DCBLAS=ON ^
    -DCMake_GNUtoMS=ON ^
    -Wno-dev ..

mingw32-make -j%CPU_COUNT%
mingw32-make install

ctest --output-on-failure
