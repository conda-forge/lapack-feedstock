#!/bin/sh

mkdir build
cd build

# CMAKE_INSTALL_LIBDIR="lib" suppresses CentOS default of lib64 (conda expects lib)

cmake \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_LIBDIR="lib" \
  -DBUILD_TESTING=ON \
  -DBUILD_SHARED_LIBS=ON \
  -DLAPACKE=ON \
  -DCBLAS=ON \
  ..

make -j${CPU_COUNT}
ctest --output-on-failure
make install


if [[ $(uname) == "Darwin" ]]; then
    for lib in blas cblas lapack lapacke; do
        mv $PREFIX/lib/lib$lib.dylib $PREFIX/lib/lib$lib.$PKG_VERISON.dylib
        ln -s  $PREFIX/lib/lib$lib.$PKG_VERISON.dylib $PREFIX/lib/lib$lib.dylib
        ln -s  $PREFIX/lib/lib$lib.$PKG_VERISON.dylib $PREFIX/lib/lib$lib.3.dylib
    done
fi
