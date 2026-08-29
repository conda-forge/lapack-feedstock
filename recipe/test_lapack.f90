program lapack_fortran_consumer
  implicit none
  integer, parameter :: n = 2, nrhs = 1, lda = 2, ldb = 2
  double precision :: a(lda, n), b(ldb, nrhs)
  integer :: ipiv(n), info

  a = reshape([3.0d0, 1.0d0, 1.0d0, 2.0d0], shape(a))
  b(:, 1) = [9.0d0, 8.0d0]

  call dgesv(n, nrhs, a, lda, ipiv, b, ldb, info)
  if (info /= 0) error stop 1
  if (abs(b(1, 1) - 2.0d0) > 1.0d-12) error stop 2
  if (abs(b(2, 1) - 3.0d0) > 1.0d-12) error stop 3
end program lapack_fortran_consumer
