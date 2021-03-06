cdef double cproxLq(double x, double t, double q, double tol=*)
cdef double cproxLq_dx(double x, double t, double q, double tol=*)
cdef double cproxLq_dt(double x, double t, double q, double tol=*)
cdef double cproxLq_inv(double z, double t, double q)

cdef double _cproxLq(double x, double t, double q, double tol)
cdef double _cproxLq_dt(double x, double t, double q, double tol)
cdef double _cproxLq_dx(double x, double t, double q, double tol)

