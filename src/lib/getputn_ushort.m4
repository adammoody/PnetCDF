dnl Process this m4 file to produce 'C' language file.
dnl
dnl If you see this line, you can ignore the next one.
/* Do not edit this file. It is produced from the corresponding .m4 source */
dnl
/*
 *  Copyright (C) 2003, Northwestern University and Argonne National Laboratory
 *  See COPYRIGHT notice in top-level directory.
 */
/* $Id$ */

#if HAVE_CONFIG_H
# include <ncconfig.h>
#endif

#include <mpi.h>

#include "nc.h"
#include "ncx.h"

/* ftype is the variable's nc_type defined in file, eg. int64
 * btype is the I/O buffer's C data type, eg. long long
 * buftype is I/O bufer's MPI data type, eg. MPI_UNSIGNED_LONG_LONG
 * apitype is data type appeared in the API names, eg. ncmpi_get_vara_longlong
 */

/*---- x_ushort -------------------------------------------------------------*/

#ifndef SIZEOF_UINT
#error "SIZEOF_UINT undefined"
#endif
#ifndef SIZEOF_USHORT
#error "SIZEOF_USHORT undefined"
#endif

#if USHORT_MAX == X_USHORT_MAX
    typedef unsigned short ix_ushort;
    #define SIZEOF_IX_USHORT  SIZEOF_USHORT
    #define IX_USHORT_MAX     SHORT_MAX
#elif UINT_MAX >= X_USHORT_MAX
    typedef unsigned int ix_ushort;
    #define SIZEOF_IX_USHORT  SIZEOF_UINT
    #define IX_USHORT_MAX     UINT_MAX
#elif ULONG_MAX >= X_USHORT_MAX
    typedef unsigned long ix_ushort;
    #define SIZEOF_IX_USHORT  SIZEOF_ULONG
    #define IX_USHORT_MAX     ULONG_MAX
#else
    #error "ix_ushort implementation"
#endif

static void
get_ix_ushort(const void *xp, ix_ushort *ip)
{
    const uchar *cp = (const uchar *) xp;
    *ip = *cp++ << 8;
#if SIZEOF_IX_USHORT > X_SIZEOF_USHORT
    if (*ip & 0x8000) /* extern is negative */
        *ip |= (~(0xffff)); /* N.B. Assumes "twos complement" */
#endif
    *ip |= *cp;
}

static void
put_ix_ushort(void *xp, const ix_ushort *ip)
{
    uchar *cp = (uchar *) xp;
    *cp++ = (*ip) >> 8;
    *cp = (*ip) & 0xff;
}


#if X_SIZEOF_USHORT != SIZEOF_USHORT
/*----< ncmpix_get_ushort_ushort() >-----------------------------------------*/
static int
ncmpix_get_ushort_ushort(const void *xp, ushort *ip)
{
#if SIZEOF_IX_USHORT == SIZEOF_USHORT && IX_USHORT_MAX == USHORT_MAX
    get_ix_ushort(xp, (ix_ushort *)ip);
    return NC_NOERR;
#else
    ix_ushort xx;
    get_ix_ushort(xp, &xx);
    *ip = xx;
#   if IX_USHORT_MAX > USHORT_MAX
    if (xx > USHORT_MAX)
        return NC_ERANGE;
#   endif
    return NC_NOERR;
#endif
}
#endif

/*----< ncmpix_get_ushort_int() >--------------------------------------------*/
static int
ncmpix_get_ushort_int(const void *xp, int *ip)
{
    ix_ushort xx;
    get_ix_ushort(xp, &xx);
    *ip = xx;
#if IX_USHORT_MAX > INT_MAX
    if (xx > INT_MAX)
        return NC_ERANGE;
#endif
    return NC_NOERR;
}

/*----< ncmpix_get_ushort_uint() >-------------------------------------------*/
static int
ncmpix_get_ushort_uint(const void *xp, uint *ip)
{
#if SIZEOF_IX_USHORT == SIZEOF_UINT && IX_USHORT_MAX == UINT_MAX
    get_ix_ushort(xp, (ix_ushort *)ip);
    return NC_NOERR;
#else
    ix_ushort xx;
    get_ix_ushort(xp, &xx);
    *ip = xx;
#   if IX_USHORT_MAX > UINT_MAX
    if(xx > UINT_MAX)
        return NC_ERANGE;
#   endif
    return NC_NOERR;
#endif
}

/*----< ncmpix_get_ushort_long() >-------------------------------------------*/
static int
ncmpix_get_ushort_long(const void *xp, long *ip)
{
#if SIZEOF_IX_USHORT == SIZEOF_LONG && IX_USHORT_MAX == LONG_MAX
    get_ix_ushort(xp, (ix_ushort *)ip);
    return NC_NOERR;
#else
    /* assert(LONG_MAX >= X_USHORT_MAX); */
    ix_ushort xx;
    get_ix_ushort(xp, &xx);
    *ip = xx;
    return NC_NOERR;
#endif
}

dnl
dnl GET_USHORT(xp, ip)
dnl
define(`GET_USHORT',dnl
`dnl
/*----< ncmpix_get_ushort_$1() >----------------------------------------------*/
static int
ncmpix_get_ushort_$1(const void *xp, $1 *ip)
{
    ix_ushort xx;
    get_ix_ushort(xp, &xx); /* get a ushort in the form of local Endianness */
    *ip = xx;               /* typecast to schar */
    $2      /* check if can fit into $1 */
    return NC_NOERR;
}
')dnl

GET_USHORT(schar, if (xx > SCHAR_MAX) return NC_ERANGE;)
GET_USHORT(uchar, if (xx > UCHAR_MAX) return NC_ERANGE;)
GET_USHORT(short, if (xx > SHORT_MAX) return NC_ERANGE;)
GET_USHORT(float)
GET_USHORT(double)
GET_USHORT(int64)
GET_USHORT(uint64)

/*----< ncmpix_put_ushort_schar() >------------------------------------------*/
static int
ncmpix_put_ushort_schar(void *xp, const schar *ip)
{
    uchar *cp = (uchar *) xp;

    /* copy the signed bit from schar to short */
    if (*ip & 0x80)    /* 0x80 = 10000000(bin) = -127(dec) */
        /* ip is negative */
           *cp++ = 0xff;  /* 0xff = 11111111(bin) = -0(dec) */
        /* now the higher 8 bits are all 1s */
    else
        /* ip is positive */
           *cp++ = 0;

    *cp = (uchar)*ip;  /* the lower 8-bits */

    if (*ip < 0) return NC_ERANGE;

    return NC_NOERR;
}

/*----< ncmpix_put_ushort_uchar() >------------------------------------------*/
static int
ncmpix_put_ushort_uchar(void *xp, const uchar *ip)
{
    uchar *cp = (uchar *) xp;
    *cp++ = 0;
    *cp = *ip;
    return NC_NOERR;
}

#if X_SIZEOF_USHORT != SIZEOF_USHORT
/*----< ncmpix_put_ushort_ushort() >-----------------------------------------*/
static int
ncmpix_put_ushort_ushort(void *xp, const ushort *ip)
{
#if SIZEOF_IX_USHORT == SIZEOF_USHORT && X_USHORT_MAX == USHORT_MAX
    put_ix_ushort(xp, (const ix_ushort *)ip);
    return NC_NOERR;
#else
    ix_ushort xx = (ix_ushort)*ip;
    put_ix_ushort(xp, &xx);
# if X_USHORT_MAX < USHORT_MAX
    if (*ip > X_USHORT_MAX)
        return NC_ERANGE;
# endif
    return NC_NOERR;
#endif
}
#endif

/*----< ncmpix_put_ushort_uint() >-------------------------------------------*/
static int
ncmpix_put_ushort_uint(void *xp, const uint *ip)
{
#if SIZEOF_IX_USHORT == SIZEOF_UINT && X_USHORT_MAX == UINT_MAX
    put_ix_ushort(xp, (const ix_ushort *)ip);
    return NC_NOERR;
#else
    ix_ushort xx = (ix_ushort)*ip;  /* typecasting int to ushort */
    put_ix_ushort(xp, &xx);
# if X_USHORT_MAX < UINT_MAX
    if (*ip > X_USHORT_MAX)
        return NC_ERANGE;
# endif
    return NC_NOERR;
#endif
}

/*----< ncmpix_put_ushort_long() >-------------------------------------------*/
static int
ncmpix_put_ushort_long(void *xp, const long *ip)
{
#if SIZEOF_IX_USHORT == SIZEOF_LONG && X_USHORT_MAX == LONG_MAX
    put_ix_ushort(xp, (const ix_ushort *)ip);
    return NC_NOERR;
#else
    ix_ushort xx = (ix_ushort)*ip;
    put_ix_ushort(xp, &xx);
# if X_USHORT_MAX < LONG_MAX
    if(*ip > X_USHORT_MAX || *ip < 0)
        return NC_ERANGE;
# endif
    return NC_NOERR;
#endif
}

dnl
dnl PUT_USHORT(xp, ip)
dnl
define(`PUT_USHORT',dnl
`dnl
/*----< ncmpix_put_ushort_$1() >----------------------------------------------*/
static int
ncmpix_put_ushort_$1(void *xp, const $1 *ip)
{
    ix_ushort xx = (ix_ushort)*ip;  /* typecasting int to ushort */
    put_ix_ushort(xp, &xx);
    $2                     /* check if can fit into ushort */
    return NC_NOERR;
}
')dnl

PUT_USHORT(short,  if (*ip < 0) return NC_ERANGE;)
PUT_USHORT(int,    if (*ip > X_USHORT_MAX || *ip < 0) return NC_ERANGE;)
PUT_USHORT(float,  if (*ip > X_USHORT_MAX || *ip < 0) return NC_ERANGE;)
PUT_USHORT(double, if (*ip > X_USHORT_MAX || *ip < 0) return NC_ERANGE;)
PUT_USHORT(int64,  if (*ip > X_USHORT_MAX || *ip < 0) return NC_ERANGE;)
PUT_USHORT(uint64, if (*ip > X_USHORT_MAX) return NC_ERANGE;)


dnl
dnl GETN_USHORT(xpp, nelems, tp)
dnl
define(`GETN_USHORT',dnl
`dnl
/*----< ncmpix_$1() >---------------------------------------------------------*/
int
ncmpix_$1(const void **xpp, MPI_Offset nelems, $2 *tp)
{
    const char *xp = (const char *) *xpp;
    int status = NC_NOERR;

    for ( ; nelems != 0; nelems--, xp += X_SIZEOF_USHORT, tp++) {
        const int lstatus = ncmpix_get_ushort_$2(xp, tp);
        if (lstatus != NC_NOERR) status = lstatus;
    }

    if ($3 && nelems % 2 != 0)
    	xp += X_SIZEOF_USHORT;

    *xpp = (void *)xp;
    return status;
}
')dnl

GETN_USHORT(    getn_ushort_schar,  schar,  0)
GETN_USHORT(    getn_ushort_uchar,  uchar,  0)
GETN_USHORT(    getn_ushort_short,  short,  0)
GETN_USHORT(    getn_ushort_int,    int,    0)
GETN_USHORT(    getn_ushort_long,   long,   0)
GETN_USHORT(    getn_ushort_float,  float,  0)
GETN_USHORT(    getn_ushort_double, double, 0)
GETN_USHORT(    getn_ushort_uint,   uint,   0)
GETN_USHORT(    getn_ushort_int64,  int64,  0)
GETN_USHORT(    getn_ushort_uint64, uint64, 0)

GETN_USHORT(pad_getn_ushort_schar,  schar,  1)
GETN_USHORT(pad_getn_ushort_uchar,  uchar,  1)
GETN_USHORT(pad_getn_ushort_short,  short,  1)
GETN_USHORT(pad_getn_ushort_int,    int,    1)
GETN_USHORT(pad_getn_ushort_long,   long,   1)
GETN_USHORT(pad_getn_ushort_float,  float,  1)
GETN_USHORT(pad_getn_ushort_double, double, 1)
GETN_USHORT(pad_getn_ushort_uint,   uint,   1)
GETN_USHORT(pad_getn_ushort_int64,  int64,  1)
GETN_USHORT(pad_getn_ushort_uint64, uint64, 1)

/*----< ncmpix_getn_ushort_ushort() >----------------------------------------*/
/*----< ncmpix_pad_getn_ushort_ushort() >------------------------------------*/
#if X_SIZEOF_USHORT == SIZEOF_USHORT
/* optimized version */
int
ncmpix_getn_ushort_ushort(const void **xpp, MPI_Offset nelems, ushort *tp)
{
# ifdef WORDS_BIGENDIAN
    memcpy(tp, *xpp, nelems * sizeof(ushort));
# else
    ncmpii_swapn2b(tp, *xpp, nelems);
# endif
    *xpp = (const void *)((const char *)(*xpp) + nelems * X_SIZEOF_USHORT);
    return NC_NOERR;
}
int
ncmpix_pad_getn_ushort_ushort(const void **xpp, MPI_Offset nelems, ushort *tp)
{
    const MPI_Offset rndup = nelems % 2;
# ifdef WORDS_BIGENDIAN
    memcpy(tp, *xpp, nelems * sizeof(ushort));
# else
    ncmpii_swapn2b(tp, *xpp, nelems);
# endif
    *xpp = (const void *)((const char *)(*xpp) + nelems * X_SIZEOF_USHORT + rndup);
    return NC_NOERR;
}
#else
GETN_USHORT(    getn_ushort_ushort, ushort, 0)
GETN_USHORT(pad_getn_ushort_ushort, ushort, 1)
#endif

dnl
dnl PUTN_USHORT(xpp, nelems, tp)
dnl
define(`PUTN_USHORT',dnl
`dnl
/*----< ncmpix_$1() >---------------------------------------------------------*/
int
ncmpix_$1(void **xpp, MPI_Offset nelems, const $2 *tp)
{   /* put tp[nelems] (type "$2") to xpp[nelems] (type ushort) */
    char *xp = (char *) *xpp;
    int status = NC_NOERR;

    for ( ; nelems != 0; nelems--, xp += X_SIZEOF_USHORT, tp++) {
        int lstatus = ncmpix_put_ushort_$2(xp, tp);
        if (lstatus != NC_NOERR) status = lstatus;
    }

    if ($3 && nelems % 2 != 0) {
        memcpy(xp, nada, X_SIZEOF_USHORT);
    	xp += X_SIZEOF_USHORT;
    }

    *xpp = (void *)xp;
    return status;
}
')dnl

PUTN_USHORT(    putn_ushort_schar,  schar,  0)
PUTN_USHORT(    putn_ushort_uchar,  uchar,  0)
PUTN_USHORT(    putn_ushort_short,  short,  0)
PUTN_USHORT(    putn_ushort_int,    int,    0)
PUTN_USHORT(    putn_ushort_long,   long,   0)
PUTN_USHORT(    putn_ushort_float,  float,  0)
PUTN_USHORT(    putn_ushort_double, double, 0)
PUTN_USHORT(    putn_ushort_uint,   uint,   0)
PUTN_USHORT(    putn_ushort_int64,  int64,  0)
PUTN_USHORT(    putn_ushort_uint64, uint64, 0)

PUTN_USHORT(pad_putn_ushort_schar,  schar,  1)
PUTN_USHORT(pad_putn_ushort_uchar,  uchar,  1)
PUTN_USHORT(pad_putn_ushort_short,  short,  1)
PUTN_USHORT(pad_putn_ushort_int,    int,    1)
PUTN_USHORT(pad_putn_ushort_long,   long,   1)
PUTN_USHORT(pad_putn_ushort_float,  float,  1)
PUTN_USHORT(pad_putn_ushort_double, double, 1)
PUTN_USHORT(pad_putn_ushort_uint,   uint,   1)
PUTN_USHORT(pad_putn_ushort_int64,  int64,  1)
PUTN_USHORT(pad_putn_ushort_uint64, uint64, 1)

/*----< ncmpix_putn_ushort_ushort() >----------------------------------------*/
/*----< ncmpix_pad_putn_ushort_ushort() >------------------------------------*/
#if X_SIZEOF_USHORT == SIZEOF_USHORT
/* optimized version */
int
ncmpix_putn_ushort_ushort(void **xpp, MPI_Offset nelems, const ushort *tp)
{
# ifdef WORDS_BIGENDIAN
    memcpy(*xpp, tp, nelems * X_SIZEOF_USHORT);
# else
    ncmpii_swapn2b(*xpp, tp, nelems);
# endif
    *xpp = (void *)((char *)(*xpp) + nelems * X_SIZEOF_USHORT);
    return NC_NOERR;
}
int
ncmpix_pad_putn_ushort_ushort(void **xpp, MPI_Offset nelems, const ushort *tp)
{
    const MPI_Offset rndup = nelems % 2;
# ifdef WORDS_BIGENDIAN
    memcpy(*xpp, tp, nelems * X_SIZEOF_USHORT);
# else
    ncmpii_swapn2b(*xpp, tp, nelems);
# endif
    *xpp = (void *)((char *)(*xpp) + nelems * X_SIZEOF_USHORT + rndup);
    return NC_NOERR;
}
#else
PUTN_USHORT(    putn_ushort_ushort, ushort, 0)
PUTN_USHORT(pad_putn_ushort_ushort, ushort, 1)
#endif

