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

#include "nc.h"
#include "ncx.h"
#include <mpi.h>
#include <stdio.h>
#include <unistd.h>
#ifdef HAVE_STDLIB_H
#include <stdlib.h>
#endif
#include <assert.h>

#include "macro.h"


/* ftype is the variable's nc_type defined in file, eg. int64
 * btype is the I/O buffer's C data type, eg. long long
 * buftype is I/O bufer's MPI data type, eg. MPI_UNSIGNED_LONG_LONG
 * apitype is data type appeared in the API names, eg. ncmpi_get_vara_longlong
 */
dnl
dnl PUT_VARA(ncid, varid, start, count, buf, bufcount, buftype)
dnl
define(`PUT_VARA',dnl
`dnl
/*----< ncmpi_put_vara$1() >--------------------------------------------------*/
int
ncmpi_put_vara$1(int               ncid,
                 int               varid,
                 const MPI_Offset  start[],
                 const MPI_Offset  count[],
                 const void       *buf,
                 MPI_Offset        bufcount,
                 MPI_Datatype      buftype)
{
    int     status;
    NC     *ncp;
    NC_var *varp=NULL;

    SANITY_CHECK(ncid, ncp, varp, WRITE_REQ, $2, status)

    /* put_vara is a special case of put_vars */
    return ncmpii_getput_vars(ncp, varp, start, count, NULL,
                              (void*)buf, bufcount, buftype,
                              WRITE_REQ, $2);
}
')dnl

dnl PnetCDF flexible APIs
PUT_VARA(    , INDEP_IO)
PUT_VARA(_all, COLL_IO)

dnl
dnl GET_VARA(ncid, varid, start, count, buf, bufcount, buftype)
dnl
define(`GET_VARA',dnl
`dnl
/*----< ncmpi_get_vara$1() >--------------------------------------------------*/
int
ncmpi_get_vara$1(int               ncid,
                 int               varid,
                 const MPI_Offset  start[],
                 const MPI_Offset  count[],
                 void             *buf,
                 MPI_Offset        bufcount,
                 MPI_Datatype      buftype)
{
    int     status;
    NC     *ncp;
    NC_var *varp=NULL;

    SANITY_CHECK(ncid, ncp, varp, READ_REQ, $2, status)

    /* get_vara is a special case of get_vars */
    return ncmpii_getput_vars(ncp, varp, start, count, NULL,
                              buf, bufcount, buftype,
                              READ_REQ, $2);
}
')dnl

dnl PnetCDF flexible APIs
GET_VARA(    , INDEP_IO)
GET_VARA(_all, COLL_IO)

dnl
dnl PUT_VARA_TYPE(ncid, varid, start, count, op)
dnl
define(`PUT_VARA_TYPE',dnl
`dnl
/*----< ncmpi_put_vara_$1() >-------------------------------------------------*/
int
ncmpi_put_vara_$1(int               ncid,
                  int               varid,
                  const MPI_Offset  start[],
                  const MPI_Offset  count[],
                  const $2         *op)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset  nelems;

    SANITY_CHECK(ncid, ncp, varp, WRITE_REQ, $4, status)

    GET_NUM_ELEMENTS(nelems)

    /* put_vara is a special case of put_vars */
    return ncmpii_getput_vars(ncp, varp, start, count, NULL,
                              (void*)op, nelems, $3,
                              WRITE_REQ, $4);
}
')dnl

PUT_VARA_TYPE(text,      char,               MPI_CHAR,               INDEP_IO)
PUT_VARA_TYPE(schar,     schar,              MPI_BYTE,               INDEP_IO)
PUT_VARA_TYPE(uchar,     uchar,              MPI_UNSIGNED_CHAR,      INDEP_IO)
PUT_VARA_TYPE(short,     short,              MPI_SHORT,              INDEP_IO)
PUT_VARA_TYPE(ushort,    ushort,             MPI_UNSIGNED_SHORT,     INDEP_IO)
PUT_VARA_TYPE(int,       int,                MPI_INT,                INDEP_IO)
PUT_VARA_TYPE(uint,      uint,               MPI_UNSIGNED,           INDEP_IO)
PUT_VARA_TYPE(long,      long,               MPI_LONG,               INDEP_IO)
PUT_VARA_TYPE(float,     float,              MPI_FLOAT,              INDEP_IO)
PUT_VARA_TYPE(double,    double,             MPI_DOUBLE,             INDEP_IO)
PUT_VARA_TYPE(longlong,  long long,          MPI_LONG_LONG_INT,      INDEP_IO)
PUT_VARA_TYPE(ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG, INDEP_IO)
dnl PUT_VARA_TYPE(string, char*,             MPI_CHAR,               INDEP_IO)
dnl string is not yet supported

PUT_VARA_TYPE(text_all,      char,               MPI_CHAR,              COLL_IO)
PUT_VARA_TYPE(schar_all,     schar,              MPI_BYTE,              COLL_IO)
PUT_VARA_TYPE(uchar_all,     uchar,              MPI_UNSIGNED_CHAR,     COLL_IO)
PUT_VARA_TYPE(short_all,     short,              MPI_SHORT,             COLL_IO)
PUT_VARA_TYPE(ushort_all,    ushort,             MPI_UNSIGNED_SHORT,    COLL_IO)
PUT_VARA_TYPE(int_all,       int,                MPI_INT,               COLL_IO)
PUT_VARA_TYPE(uint_all,      uint,               MPI_UNSIGNED,          COLL_IO)
PUT_VARA_TYPE(long_all,      long,               MPI_LONG,              COLL_IO)
PUT_VARA_TYPE(float_all,     float,              MPI_FLOAT,             COLL_IO)
PUT_VARA_TYPE(double_all,    double,             MPI_DOUBLE,            COLL_IO)
PUT_VARA_TYPE(longlong_all,  long long,          MPI_LONG_LONG_INT,     COLL_IO)
PUT_VARA_TYPE(ulonglong_all, unsigned long long, MPI_UNSIGNED_LONG_LONG,COLL_IO)
dnl PUT_VARA_TYPE(string_all, char*,             MPI_CHAR,              COLL_IO)
dnl string is not yet supported


dnl
dnl GET_VARA_TYPE(ncid, varid, start, count, ip)
dnl
define(`GET_VARA_TYPE',dnl
`dnl
/*----< ncmpi_get_vara_$1() >-------------------------------------------------*/
int
ncmpi_get_vara_$1(int               ncid,
                  int               varid,
                  const MPI_Offset  start[],
                  const MPI_Offset  count[],
                  $2               *ip)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset  nelems;

    SANITY_CHECK(ncid, ncp, varp, READ_REQ, $4, status)

    GET_NUM_ELEMENTS(nelems)

    /* get_vara is a special case of get_vars */
    return ncmpii_getput_vars(ncp, varp, start, count, NULL,
                              ip, nelems, $3,
                              READ_REQ, $4);
}
')dnl

GET_VARA_TYPE(text,      char,               MPI_CHAR,               INDEP_IO)
GET_VARA_TYPE(schar,     schar,              MPI_BYTE,               INDEP_IO)
GET_VARA_TYPE(uchar,     uchar,              MPI_UNSIGNED_CHAR,      INDEP_IO)
GET_VARA_TYPE(short,     short,              MPI_SHORT,              INDEP_IO)
GET_VARA_TYPE(ushort,    ushort,             MPI_UNSIGNED_SHORT,     INDEP_IO)
GET_VARA_TYPE(int,       int,                MPI_INT,                INDEP_IO)
GET_VARA_TYPE(uint,      uint,               MPI_UNSIGNED,           INDEP_IO)
GET_VARA_TYPE(long,      long,               MPI_LONG,               INDEP_IO)
GET_VARA_TYPE(float,     float,              MPI_FLOAT,              INDEP_IO)
GET_VARA_TYPE(double,    double,             MPI_DOUBLE,             INDEP_IO)
GET_VARA_TYPE(longlong,  long long,          MPI_LONG_LONG_INT,      INDEP_IO)
GET_VARA_TYPE(ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG, INDEP_IO)
dnl GET_VARA_TYPE(string, char*,             MPI_CHAR,               INDEP_IO)
dnl string is not yet supported

GET_VARA_TYPE(text_all,      char,               MPI_CHAR,              COLL_IO)
GET_VARA_TYPE(schar_all,     schar,              MPI_BYTE,              COLL_IO)
GET_VARA_TYPE(uchar_all,     uchar,              MPI_UNSIGNED_CHAR,     COLL_IO)
GET_VARA_TYPE(short_all,     short,              MPI_SHORT,             COLL_IO)
GET_VARA_TYPE(ushort_all,    ushort,             MPI_UNSIGNED_SHORT,    COLL_IO)
GET_VARA_TYPE(int_all,       int,                MPI_INT,               COLL_IO)
GET_VARA_TYPE(uint_all,      uint,               MPI_UNSIGNED,          COLL_IO)
GET_VARA_TYPE(long_all,      long,               MPI_LONG,              COLL_IO)
GET_VARA_TYPE(float_all,     float,              MPI_FLOAT,             COLL_IO)
GET_VARA_TYPE(double_all,    double,             MPI_DOUBLE,            COLL_IO)
GET_VARA_TYPE(longlong_all,  long long,          MPI_LONG_LONG_INT,     COLL_IO)
GET_VARA_TYPE(ulonglong_all, unsigned long long, MPI_UNSIGNED_LONG_LONG,COLL_IO)
dnl GET_VARA_TYPE(string_all, char*,             MPI_CHAR,              COLL_IO)
dnl string is not yet supported
