mkdir build
cd build

cmake -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_C_COMPILER=clang-cl ^
    -DCMAKE_Fortran_COMPILER=flang ^
    -DBUILD_SHARED_LIBS=yes ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DLAPACKE=ON ^
    -DCBLAS=ON ^
    -Wno-dev ..

ninja -j%CPU_COUNT%
ninja install

ctest --output-on-failure
