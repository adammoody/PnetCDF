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
#define nfmpi_put_varn_ NFMPI_PUT_VARN
#elif defined(F77_NAME_LOWER_2USCORE)
#define nfmpi_put_varn_ nfmpi_put_varn__
#elif !defined(F77_NAME_LOWER_USCORE)
#define nfmpi_put_varn_ nfmpi_put_varn
/* Else leave name alone */
#endif


/* Prototypes for the Fortran interfaces */
#include "mpifnetcdf.h"
FORTRAN_API int FORT_CALL nfmpi_put_varn_ ( int *v1, int *v2, int *v3, void*v4, MPI_Offset *v5, MPI_Fint *v6 ){
    int ierr;
    int l2 = *v2 - 1;
    ierr = ncmpi_put_varn( *v1, l2, *v3, v4, *v5, MPI_Type_f2c(*v6) );
    return ierr;
}