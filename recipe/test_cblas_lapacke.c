#include <math.h>
#include <stdio.h>

#include <cblas.h>
#include <lapacke.h>

int main(void) {
    const double x[] = {1.0, 2.0, 3.0};
    const double y[] = {4.0, 5.0, 6.0};
    double a[] = {3.0, 1.0, 1.0, 2.0};
    double b[] = {9.0, 8.0};
    lapack_int ipiv[2];
    lapack_int info;

    if (fabs(cblas_ddot(3, x, 1, y, 1) - 32.0) > 1e-12) {
        fprintf(stderr, "CBLAS ddot returned an unexpected value\n");
        return 1;
    }

    info = LAPACKE_dgesv(LAPACK_COL_MAJOR, 2, 1, a, 2, ipiv, b, 2);
    if (info != 0 || fabs(b[0] - 2.0) > 1e-12 ||
        fabs(b[1] - 3.0) > 1e-12) {
        fprintf(stderr, "LAPACKE dgesv failed: info=%d, x=(%.17g, %.17g)\n",
                (int)info, b[0], b[1]);
        return 2;
    }

    return 0;
}
