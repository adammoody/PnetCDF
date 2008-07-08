/* -*- Mode: C; c-basic-offset:4 ; -*- */
/*  
 *  (C) 2001 by Argonne National Laboratory.
 *      See COPYRIGHT in top-level directory.
 *
 * This file is automatically generated by buildiface -infile=../lib/pnetcdf.h -deffile=defs
 * DO NOT EDIT
 */
#include "mpinetcdf_impl.h"


#ifdef F77_NAME_UPPER
#define nfmpi_get_var1_int2_ NFMPI_GET_VAR1_INT2
#elif defined(F77_NAME_LOWER_2USCORE)
#define nfmpi_get_var1_int2_ nfmpi_get_var1_int2__
#elif !defined(F77_NAME_LOWER_USCORE)
#define nfmpi_get_var1_int2_ nfmpi_get_var1_int2
/* Else leave name alone */
#endif


/* Prototypes for the Fortran interfaces */
#include "mpifnetcdf.h"
FORTRAN_API int FORT_CALL nfmpi_get_var1_int2_ ( int *v1, int64_t *v2, int64_t v3[], short*v4 ){
    int ierr;
    int l2 = *v2 - 1;
    MPI_Offset *l3 = 0;

    { int ln = ncmpixVardim(*v1,*v2-1);
    if (ln > 0) {
        int li;
        l3 = (MPI_Offset *)malloc( ln * sizeof(MPI_Offset) );
        for (li=0; li<ln; li++) 
            l3[li] = v3[ln-1-li] - 1;
    }
    else if (ln < 0) {
        /* Error return */
        ierr = ln; 
	return ierr;
    }
    }
    ierr = ncmpi_get_var1_short( *v1, l2, l3, v4 );

    if (l3) { free(l3); }
    return ierr;
}
