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
#define nfmpi_copy_att_ NFMPI_COPY_ATT
#elif defined(F77_NAME_LOWER_2USCORE)
#define nfmpi_copy_att_ nfmpi_copy_att__
#elif !defined(F77_NAME_LOWER_USCORE)
#define nfmpi_copy_att_ nfmpi_copy_att
/* Else leave name alone */
#endif


/* Prototypes for the Fortran interfaces */
#include "mpifnetcdf.h"
FORTRAN_API int FORT_CALL nfmpi_copy_att_ ( int *v1, int64_t *v2, char *v3 FORT_MIXED_LEN(d3), int64_t *v4, int64_t *v5 FORT_END_LEN(d3) ){
    int ierr;
    int l2 = *v2 - 1;
    char *p3;
    int l5 = *v5 - 1;

    {char *p = v3 + d3 - 1;
     int  li;
        while (*p == ' ' && p > v3) p--;
        p++;
        p3 = (char *)malloc( p-v3 + 1 );
        for (li=0; li<(p-v3); li++) { p3[li] = v3[li]; }
        p3[li] = 0; 
    }
    ierr = ncmpi_copy_att( *v1, l2, p3, *v4, l5 );
    free( p3 );
    return ierr;
}
