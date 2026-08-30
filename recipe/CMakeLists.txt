cmake_minimum_required(VERSION 3.20)
project(lapack_consumers LANGUAGES C Fortran)

if(WIN32)
  set(CONDA_PREFIX "$ENV{LIBRARY_PREFIX}")
else()
  set(CONDA_PREFIX "$ENV{PREFIX}")
endif()

find_package(LAPACK CONFIG REQUIRED
  PATHS "${CONDA_PREFIX}"
  NO_DEFAULT_PATH)
find_package(CBLAS CONFIG REQUIRED
  PATHS "${CONDA_PREFIX}"
  NO_DEFAULT_PATH)
find_package(LAPACKE CONFIG REQUIRED
  PATHS "${CONDA_PREFIX}"
  NO_DEFAULT_PATH)

add_executable(cblas_lapacke_consumer test_cblas_lapacke.c)
target_link_libraries(cblas_lapacke_consumer PRIVATE
  lapacke
  cblas)

add_executable(lapack_fortran_consumer test_lapack.f90)
target_link_libraries(lapack_fortran_consumer PRIVATE
  lapack
  blas)

enable_testing()
add_test(NAME cblas_lapacke_consumer COMMAND cblas_lapacke_consumer)
add_test(NAME lapack_fortran_consumer COMMAND lapack_fortran_consumer)
