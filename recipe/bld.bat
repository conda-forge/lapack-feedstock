@echo on

:: add CBLAS_DLL markers to RowMajorStrg/CBLAS_CallFromC in CBLAS/{src,testing}
for %%f in (CBLAS\src\*.c) do (
    sed -i.bak "s/extern int RowMajorStrg;/CBLAS_DLL extern int RowMajorStrg;/g" %%f
    sed -i.bak "s/extern int CBLAS_CallFromC;/CBLAS_DLL extern int CBLAS_CallFromC;/g" %%f
)
for %%f in (CBLAS\testing\*.c) do (
    sed -i.bak "s/extern int RowMajorStrg;/CBLAS_DLL extern int RowMajorStrg;/g" %%f
)

mkdir build
cd build

cmake -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DBUILD_SHARED_LIBS=yes ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_SHARED_LIBRARY_PREFIX=lib ^
    -DBUILD_TESTING=ON ^
    -DLAPACKE=ON ^
    -DCBLAS=ON ^
    -DBUILD_DEPRECATED=ON ^
    -Wno-dev ..

ninja -j%CPU_COUNT%
if %ERRORLEVEL% NEQ 0 exit 1

ninja install
if %ERRORLEVEL% NEQ 0 exit 1

:: strip "lib" prefix from import libraries, in line with previous naming
move %LIBRARY_LIB%\libblas.lib %LIBRARY_LIB%\blas.lib
move %LIBRARY_LIB%\libcblas.lib %LIBRARY_LIB%\cblas.lib
move %LIBRARY_LIB%\liblapack.lib %LIBRARY_LIB%\lapack.lib
move %LIBRARY_LIB%\liblapacke.lib %LIBRARY_LIB%\lapacke.lib
move %LIBRARY_LIB%\libtmglib.lib %LIBRARY_LIB%\tmglib.lib

:: testing with shared libraries does not work - skip them.
:: This is because: to test that the program exits if wrong parameters are given,
:: the testsuite overrides the symbol xerbla (xerbla logs the error and exits) with
:: its own version that reports to the test program in case of an error.
:: This does not work with dylibs on osx and dlls on windows.
ctest --output-on-failure -E "x*cblat*"
if %ERRORLEVEL% NEQ 0 exit 1
