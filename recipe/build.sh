#!/bin/sh

set -e

mkdir build
cd build

mkdir -p ${PREFIX}/include

if [[ "$target_platform" == linux-* ]]; then
    # workaround a binutils bug
    export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,$(pwd)/lib"
    export LDFLAGS=$(echo "${LDFLAGS}" | sed "s/-Wl,--as-needed//g")
fi

if [[ "$target_platform" == osx-* ]]; then
    export SDKROOT="${CONDA_BUILD_SYSROOT}"
    export CFLAGS="${CFLAGS} -isysroot ${CONDA_BUILD_SYSROOT}"
    export FFLAGS="${FFLAGS} -isysroot ${CONDA_BUILD_SYSROOT}"
    export LDFLAGS=$(echo "${LDFLAGS}" | sed "s/-Wl,-dead_strip_dylibs//g")
fi

export LDFLAGS="$LDFLAGS -fno-optimize-sibling-calls"
export FFLAGS="$FFLAGS -fno-optimize-sibling-calls"

# CMAKE_INSTALL_LIBDIR="lib" suppresses CentOS default of lib64 (conda expects lib)

cmake \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_LIBDIR="lib" \
  -DBUILD_TESTING=ON \
  -DBUILD_SHARED_LIBS=ON \
  -DLAPACKE=ON \
  -DCBLAS=ON \
  -DBUILD_DEPRECATED=ON \
  -DTEST_FORTRAN_COMPILER=OFF \
  ${CMAKE_ARGS} ..

make install -j${CPU_COUNT} VERBOSE=1

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
  if [[ "$target_platform" == osx-* ]]; then
    # testing with shared libraries does not work. skip them
    # to test that program exits if wrong parameters are given, what the testsuite
    # do is that the symbol xerbla (xerbla logs the error and exits) is overriden
    # by the test program's own version which reports to the test program that
    # xerbla was called. This does not work with dylibs on osx and dlls on windows
    ctest --output-on-failure -E "x*cblat2|x*cblat3" -j${CPU_COUNT}
  else
    ctest --output-on-failure -j${CPU_COUNT}
  fi
fi


if [[ "${target_platform}" == osx-* ]]; then
    for lib in blas cblas lapack lapacke tmglib; do
        mv $PREFIX/lib/lib$lib.dylib $PREFIX/lib/lib$lib.$PKG_VERSION.dylib
        install_name_tool -id $PREFIX/lib/lib$lib.3.dylib $PREFIX/lib/lib$lib.$PKG_VERSION.dylib
        ln -s  $PREFIX/lib/lib$lib.$PKG_VERSION.dylib $PREFIX/lib/lib$lib.dylib
        ln -s  $PREFIX/lib/lib$lib.$PKG_VERSION.dylib $PREFIX/lib/lib$lib.3.dylib
    done
fi
