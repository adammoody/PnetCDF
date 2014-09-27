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

#include <stdio.h>
#include <unistd.h>
#ifdef HAVE_STDLIB_H
#include <stdlib.h>
#endif
#include <assert.h>

#include <mpi.h>

#include "nc.h"
#include "ncx.h"
#include "ncmpidtype.h"
#include "macro.h"

/* ncmpi_get/put_varn_<type>_<mode> API:
 *    type:   data type of I/O buffer, buf
 *    mode:   indpendent (<nond>) or collective (_all)
 *
 * arguments:
 *    num:    number of start and count pairs
 *    starts: an 2D array of size [num][ndims]. Each starts[i][*] indicates
 *            the starting array indices for a subarray request. ndims is
 *            the number of dimensions of the defined netCDF variable.
 *    counts: an 2D array of size [num][ndims]. Each counts[i][*] indicates
 *            the number of array elements to be accessed. This argument
 *            can be NULL, equivalent to counts with all 1s.
 *    bufcount and buftype: these 2 arguments are only available for flexible
 *            APIs, indicating the I/O buffer memory layout
 */

static int
ncmpii_getput_varn(int               ncid,
                   int               varid,
                   int               num,
                   MPI_Offset* const starts[],  /* [num][varp->ndims] */
                   MPI_Offset* const counts[],  /* [num][varp->ndims] */
                   void             *buf,
                   MPI_Offset        bufcount,
                   MPI_Datatype      buftype,   /* data type of the bufer */
                   int               rw_flag,
                   int               io_method);

dnl
dnl VARN_FLEXIBLE(ncid, varid, num starts, counts, buf, bufcount, buftype)
dnl
define(`VARN_FLEXIBLE',dnl
`dnl
/*----< ncmpi_$1_varn$4() >---------------------------------------------------*/
int
ncmpi_$1_varn$4(int                ncid,
                int                varid,
                int                num,
                MPI_Offset* const  starts[],
                MPI_Offset* const  counts[],
                $2 void           *buf,
                MPI_Offset         bufcount,
                MPI_Datatype       buftype)
{
    return ncmpii_getput_varn(ncid, varid, num, starts, counts, (void*)buf,
                              bufcount, buftype, $3, $5);
}
')dnl

dnl PnetCDF flexible APIs
VARN_FLEXIBLE(put, const, WRITE_REQ,     , INDEP_IO)
VARN_FLEXIBLE(put, const, WRITE_REQ, _all,  COLL_IO)
VARN_FLEXIBLE(get,      ,  READ_REQ,     , INDEP_IO)
VARN_FLEXIBLE(get,      ,  READ_REQ, _all,  COLL_IO)

dnl
dnl VARN(ncid, varid, starts, counts, buf)
dnl
define(`VARN',dnl
`dnl
/*----< ncmpi_$1_varn_$6$4() >------------------------------------------------*/
int
ncmpi_$1_varn_$6$4(int                ncid,
                   int                varid,
                   int                num,
                   MPI_Offset* const  starts[],
                   MPI_Offset* const  counts[],
                   $2 $7             *buf)
{
    /* set bufcount to -1 indicating non-flexible API */
    return ncmpii_getput_varn(ncid, varid, num, starts, counts, (void*)buf,
                              -1, $8, $3, $5);
}
')dnl

VARN(put, const, WRITE_REQ,     , INDEP_IO, text,      char,               MPI_CHAR)
VARN(put, const, WRITE_REQ,     , INDEP_IO, schar,     schar,              MPI_BYTE)
VARN(put, const, WRITE_REQ,     , INDEP_IO, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARN(put, const, WRITE_REQ,     , INDEP_IO, short,     short,              MPI_SHORT)
VARN(put, const, WRITE_REQ,     , INDEP_IO, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARN(put, const, WRITE_REQ,     , INDEP_IO, int,       int,                MPI_INT)
VARN(put, const, WRITE_REQ,     , INDEP_IO, uint,      uint,               MPI_UNSIGNED)
VARN(put, const, WRITE_REQ,     , INDEP_IO, long,      long,               MPI_LONG)
VARN(put, const, WRITE_REQ,     , INDEP_IO, float,     float,              MPI_FLOAT)
VARN(put, const, WRITE_REQ,     , INDEP_IO, double,    double,             MPI_DOUBLE)
VARN(put, const, WRITE_REQ,     , INDEP_IO, longlong,  long long,          MPI_LONG_LONG_INT)
VARN(put, const, WRITE_REQ,     , INDEP_IO, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)
dnl VARN(put, const, WRITE_REQ, , INDEP_IO, string,    char*,              MPI_CHAR)
dnl string is not yet supported
dnl
VARN(put, const, WRITE_REQ, _all,  COLL_IO, text,      char,               MPI_CHAR)
VARN(put, const, WRITE_REQ, _all,  COLL_IO, schar,     schar,              MPI_BYTE)
VARN(put, const, WRITE_REQ, _all,  COLL_IO, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARN(put, const, WRITE_REQ, _all,  COLL_IO, short,     short,              MPI_SHORT)
VARN(put, const, WRITE_REQ, _all,  COLL_IO, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARN(put, const, WRITE_REQ, _all,  COLL_IO, int,       int,                MPI_INT)
VARN(put, const, WRITE_REQ, _all,  COLL_IO, uint,      uint,               MPI_UNSIGNED)
VARN(put, const, WRITE_REQ, _all,  COLL_IO, long,      long,               MPI_LONG)
VARN(put, const, WRITE_REQ, _all,  COLL_IO, float,     float,              MPI_FLOAT)
VARN(put, const, WRITE_REQ, _all,  COLL_IO, double,    double,             MPI_DOUBLE)
VARN(put, const, WRITE_REQ, _all,  COLL_IO, longlong,  long long,          MPI_LONG_LONG_INT)
VARN(put, const, WRITE_REQ, _all,  COLL_IO, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)
dnl VARN(put, const, WRITE_REQ, _all, COLL_IO, string, char*,              MPI_CHAR)
dnl string is not yet supported

VARN(get,      ,  READ_REQ,     , INDEP_IO, text,      char,               MPI_CHAR)
VARN(get,      ,  READ_REQ,     , INDEP_IO, schar,     schar,              MPI_BYTE)
VARN(get,      ,  READ_REQ,     , INDEP_IO, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARN(get,      ,  READ_REQ,     , INDEP_IO, short,     short,              MPI_SHORT)
VARN(get,      ,  READ_REQ,     , INDEP_IO, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARN(get,      ,  READ_REQ,     , INDEP_IO, int,       int,                MPI_INT)
VARN(get,      ,  READ_REQ,     , INDEP_IO, uint,      uint,               MPI_UNSIGNED)
VARN(get,      ,  READ_REQ,     , INDEP_IO, long,      long,               MPI_LONG)
VARN(get,      ,  READ_REQ,     , INDEP_IO, float,     float,              MPI_FLOAT)
VARN(get,      ,  READ_REQ,     , INDEP_IO, double,    double,             MPI_DOUBLE)
VARN(get,      ,  READ_REQ,     , INDEP_IO, longlong,  long long,          MPI_LONG_LONG_INT)
VARN(get,      ,  READ_REQ,     , INDEP_IO, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)
dnl VARN(get,      ,  READ_REQ, , INDEP_IO, string,    char*,              MPI_CHAR)
dnl string is not yet supported
dnl
VARN(get,      ,  READ_REQ, _all,  COLL_IO, text,      char,               MPI_CHAR)
VARN(get,      ,  READ_REQ, _all,  COLL_IO, schar,     schar,              MPI_BYTE)
VARN(get,      ,  READ_REQ, _all,  COLL_IO, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARN(get,      ,  READ_REQ, _all,  COLL_IO, short,     short,              MPI_SHORT)
VARN(get,      ,  READ_REQ, _all,  COLL_IO, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARN(get,      ,  READ_REQ, _all,  COLL_IO, int,       int,                MPI_INT)
VARN(get,      ,  READ_REQ, _all,  COLL_IO, uint,      uint,               MPI_UNSIGNED)
VARN(get,      ,  READ_REQ, _all,  COLL_IO, long,      long,               MPI_LONG)
VARN(get,      ,  READ_REQ, _all,  COLL_IO, float,     float,              MPI_FLOAT)
VARN(get,      ,  READ_REQ, _all,  COLL_IO, double,    double,             MPI_DOUBLE)
VARN(get,      ,  READ_REQ, _all,  COLL_IO, longlong,  long long,          MPI_LONG_LONG_INT)
VARN(get,      ,  READ_REQ, _all,  COLL_IO, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)
dnl VARN(get,      ,  READ_REQ, _all, COLL_IO, string, char*,              MPI_CHAR)
dnl string is not yet supported



/*----< ncmpii_getput_varn() >------------------------------------------------*/
static int
ncmpii_getput_varn(int               ncid,
                   int               varid,
                   int               num,
                   MPI_Offset* const starts[],  /* [num][varp->ndims] */
                   MPI_Offset* const counts[],  /* [num][varp->ndims] */
                   void             *buf,
                   MPI_Offset        bufcount,
                   MPI_Datatype      buftype,   /* data type of the bufer */
                   int               rw_flag,   /* WRITE_REQ or READ_REQ */
                   int               io_method) /* COLL_IO or INDEP_IO */
{
    int i, j, el_size, status=NC_NOERR, min_st, err;
    int *req_ids=NULL, *statuses=NULL;
    void *cbuf=NULL;
    char *bufp;
    MPI_Offset **_counts=NULL;
    MPI_Datatype ptype;
    NC     *ncp;
    NC_var *varp=NULL;

    SANITY_CHECK(ncid, ncp, varp, rw_flag, io_method, status)
    if (status != NC_NOERR) goto err_check;

    if (num == 0 || bufcount == 0) goto err_check;

    if (starts == NULL) {
        status = NC_ENULLSTART;
        goto err_check;
    }

    cbuf = buf;
    if (bufcount > 0) { /* flexible API is used */
        int isderived, iscontig_of_ptypes;
        MPI_Offset bnelems;
        /* pack buf into cbuf, a contiguous buffer */
        /* ptype (primitive MPI data type) from buftype
         * el_size is the element size of ptype
         * bnelems is the total number of ptype elements in buftype
         */
        status = ncmpii_dtype_decode(buftype, &ptype, &el_size, &bnelems,
                                     &isderived, &iscontig_of_ptypes);

        if (status != NC_NOERR) goto err_check;

        /* check if buftype is contiguous, if not, pack to one, cbuf */
        if (! iscontig_of_ptypes && bnelems > 0) {
            int position=0, outsize=bnelems*el_size;
            cbuf = NCI_Malloc(outsize);
            MPI_Pack(buf, bufcount, buftype, cbuf, outsize, &position,
                     MPI_COMM_SELF);
        }
    }
    else {
        ptype = buftype;
        el_size = ncmpix_len_nctype(varp->type);
    }

    /* We allow counts == NULL and treat this the same as all 1s */
    if (counts == NULL) {
        _counts    = (MPI_Offset**) NCI_Malloc(num * sizeof(MPI_Offset*));
        _counts[0] = (MPI_Offset*)  NCI_Malloc(num * varp->ndims *
                                               sizeof(MPI_Offset));
        for (i=1; i<num; i++)
            _counts[i] = _counts[i-1] + varp->ndims;
        for (i=0; i<num; i++)
            for (j=0; j<varp->ndims; j++)
                _counts[i][j] = 1;
    }
    else
        _counts = (MPI_Offset**) counts;

    /* break buf into num pieces */
    req_ids  = (int*) NCI_Malloc(2 * num * sizeof(int));
    statuses = req_ids + num;

    bufp = (char*)cbuf;
    for (i=0; i<num; i++) {
        MPI_Offset buflen;
        for (buflen=1, j=0; j<varp->ndims; j++) buflen *= _counts[i][j];
        status = ncmpii_igetput_varm(ncp, varp, starts[i], _counts[i], NULL,
                                     NULL, bufp, buflen,
                                     ptype, &req_ids[i], rw_flag, 0);
        if (status != NC_NOERR) goto err_check;
        bufp += buflen * el_size;
    }
    if (counts == NULL) {
        NCI_Free(_counts[0]);
        NCI_Free(_counts);
    }

err_check:
    if (ncp->safe_mode == 1 && io_method == COLL_IO) {
        MPI_Allreduce(&status, &min_st, 1, MPI_INT, MPI_MIN, ncp->nciop->comm);
        if (min_st != NC_NOERR) {
            if (req_ids != NULL) NCI_Free(req_ids);
            return status;
        }
    }

    if (io_method == INDEP_IO && status != NC_NOERR) {
        if (req_ids != NULL) NCI_Free(req_ids);
        return status;
    }

    if (status != NC_NOERR)
        /* this can only be reached for COLL_IO and safe_mode == 0, set num=0
           just so this process can participate the collective calls in
           wait_all */
        num = 0;

    if (io_method == COLL_IO)
        err = ncmpi_wait_all(ncid, num, req_ids, statuses);
    else
        err = ncmpi_wait(ncid, num, req_ids, statuses);

    /* return the first error, if there is one */
    if (status == NC_NOERR) status = err;

    if (cbuf != buf && cbuf != NULL) NCI_Free(cbuf);

    if (status == NC_NOERR) {
        /* return the first error, if there is one */
        for (i=0; i<num; i++)
            if (statuses[i] != NC_NOERR) {
                status = statuses[i];
                break;
            }
    }
    if (req_ids != NULL) NCI_Free(req_ids);

    return status;
}
