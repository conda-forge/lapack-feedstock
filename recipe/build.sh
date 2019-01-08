#!/bin/sh

set -e

mkdir build
cd build

mkdir -p ${PREFIX}/include

if [[ $(uname) == "Linux" ]]; then
    # workaround a binutils bug
    export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,$(pwd)/lib"
    export LDFLAGS=$(echo "${LDFLAGS}" | sed "s/-Wl,--as-needed//g")
fi

if [[ $(uname) == "Darwin" ]]; then
    export SDKROOT="${CONDA_BUILD_SYSROOT}"
    export CFLAGS="${CFLAGS} -isysroot ${CONDA_BUILD_SYSROOT}"
    export FFLAGS="${FFLAGS} -isysroot ${CONDA_BUILD_SYSROOT}"
    export LDFLAGS=$(echo "${LDFLAGS}" | sed "s/-Wl,-dead_strip_dylibs//g")
fi

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

if [[ $(uname) == "Darwin" ]]; then
  # testing with shared libraries does not work. skip them
  # to test that program exits if wrong parameters are given, what the testsuite
  # do is that the symbol xerbla (xerbla logs the error and exits) is overriden
  # by the test program's own version which reports to the test program that
  # xerbla was called. This does not work with dylibs on osx and dlls on windows
  ctest --output-on-failure -E "x*cblat2|x*cblat3"
else
  # Ref: https://github.com/Reference-LAPACK/lapack/issues/85
  ulimit -s unlimited
  ctest --output-on-failure
fi
make install


if [[ $(uname) == "Darwin" ]]; then
    for lib in blas cblas lapack lapacke; do
        mv $PREFIX/lib/lib$lib.dylib $PREFIX/lib/lib$lib.$PKG_VERSION.dylib
        install_name_tool -id $PREFIX/lib/lib$lib.3.dylib $PREFIX/lib/lib$lib.$PKG_VERSION.dylib
        ln -s  $PREFIX/lib/lib$lib.$PKG_VERSION.dylib $PREFIX/lib/lib$lib.dylib
        ln -s  $PREFIX/lib/lib$lib.$PKG_VERSION.dylib $PREFIX/lib/lib$lib.3.dylib
    done
fi
