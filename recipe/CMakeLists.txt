cmake_minimum_required(VERSION 3.20)
project(lapack_consumers LANGUAGES C Fortran)

if(WIN32)
  set(CONDA_INCLUDE_DIR "$ENV{LIBRARY_INC}")
  set(CONDA_LIBRARY_DIR "$ENV{LIBRARY_LIB}")
else()
  set(CONDA_INCLUDE_DIR "$ENV{PREFIX}/include")
  set(CONDA_LIBRARY_DIR "$ENV{PREFIX}/lib")
endif()

find_path(CBLAS_INCLUDE_DIR cblas.h
  PATHS "${CONDA_INCLUDE_DIR}"
  NO_DEFAULT_PATH
  REQUIRED)
find_path(LAPACKE_INCLUDE_DIR lapacke.h
  PATHS "${CONDA_INCLUDE_DIR}"
  NO_DEFAULT_PATH
  REQUIRED)

foreach(library IN ITEMS blas cblas lapack lapacke)
  string(TOUPPER "${library}" library_upper)
  find_library(${library_upper}_LIBRARY
    NAMES "${library}"
    PATHS "${CONDA_LIBRARY_DIR}"
    NO_DEFAULT_PATH
    REQUIRED)
endforeach()

add_executable(cblas_lapacke_consumer test_cblas_lapacke.c)
target_include_directories(cblas_lapacke_consumer PRIVATE
  "${CBLAS_INCLUDE_DIR}"
  "${LAPACKE_INCLUDE_DIR}")
target_link_libraries(cblas_lapacke_consumer PRIVATE
  "${LAPACKE_LIBRARY}"
  "${CBLAS_LIBRARY}"
  "${LAPACK_LIBRARY}"
  "${BLAS_LIBRARY}")

add_executable(lapack_fortran_consumer test_lapack.f90)
target_link_libraries(lapack_fortran_consumer PRIVATE
  "${LAPACK_LIBRARY}"
  "${BLAS_LIBRARY}")

enable_testing()
add_test(NAME cblas_lapacke_consumer COMMAND cblas_lapacke_consumer)
add_test(NAME lapack_fortran_consumer COMMAND lapack_fortran_consumer)
