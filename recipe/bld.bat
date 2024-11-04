@echo on

mkdir build
cd build

cmake -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DBUILD_SHARED_LIBS=yes ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING=ON ^
    -DLAPACKE=ON ^
    -DCBLAS=ON ^
    -DBUILD_DEPRECATED=ON ^
    -Wno-dev ..

ninja -j%CPU_COUNT%
ninja install
if %ERRORLEVEL% NEQ 0 exit 1

:: testing with shared libraries does not work - skip them.
:: This is because: to test that the program exits if wrong parameters are given,
:: the testsuite overrides the symbol xerbla (xerbla logs the error and exits) with
:: its own version that reports to the test program in case of an error.
:: This does not work with dylibs on osx and dlls on windows.
ctest --output-on-failure -E "x*cblat*"
if %ERRORLEVEL% NEQ 0 exit 1
