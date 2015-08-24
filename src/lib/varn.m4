dnl Process this m4 file to produce 'C' language file.
dnl
dnl If you see this line, you can ignore the next one.
/* Do not edit this file. It is produced from the corresponding .m4 source */
dnl
/*
 *  Copyright (C) 2014, Northwestern University and Argonne National Laboratory
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
 *            APIs, indicating the I/O buffer memory layout. When buftype is
 *            MPI_DATATYPE_NULL, bufcount is ignored and the data type of buf
 *            is considered matched the variable data type defined in the file.
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

define(`CollIndep', `ifelse(`$1',`_all', `COLL_IO', `INDEP_IO')')dnl
define(`BufConst',  `ifelse(`$1', `put', `const')')dnl
define(`ReadWrite', `ifelse(`$1', `get', `READ_REQ', `WRITE_REQ')')dnl

dnl
dnl VARN_FLEXIBLE(ncid, varid, num starts, counts, buf, bufcount, buftype)
dnl
define(`VARN_FLEXIBLE',dnl
`dnl
/*----< ncmpi_$1_varn$2() >---------------------------------------------------*/
int
ncmpi_$1_varn$2(int                ncid,
                int                varid,
                int                num,
                MPI_Offset* const  starts[],
                MPI_Offset* const  counts[],
                BufConst($1) void *buf,
                MPI_Offset         bufcount,
                MPI_Datatype       buftype)
{
    return ncmpii_getput_varn(ncid, varid, num, starts, counts, (void*)buf,
                              bufcount, buftype, ReadWrite($1), CollIndep($2));
}
')dnl

dnl PnetCDF flexible APIs
VARN_FLEXIBLE(put)
VARN_FLEXIBLE(put, _all)
VARN_FLEXIBLE(get)
VARN_FLEXIBLE(get, _all)

dnl
dnl VARN(ncid, varid, starts, counts, buf)
dnl
define(`VARN',dnl
`dnl
/*----< ncmpi_$1_varn_$3$2() >------------------------------------------------*/
int
ncmpi_$1_varn_$3$2(int                ncid,
                   int                varid,
                   int                num,
                   MPI_Offset* const  starts[],
                   MPI_Offset* const  counts[],
                   BufConst($1) $4   *buf)
{
    /* set bufcount to -1 indicating non-flexible API */
    return ncmpii_getput_varn(ncid, varid, num, starts, counts, (void*)buf,
                              -1, $5, ReadWrite($1), CollIndep($2));
}
')dnl

VARN(put,     , text,      char,               MPI_CHAR)
VARN(put,     , schar,     schar,              MPI_BYTE)
VARN(put,     , uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARN(put,     , short,     short,              MPI_SHORT)
VARN(put,     , ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARN(put,     , int,       int,                MPI_INT)
VARN(put,     , uint,      uint,               MPI_UNSIGNED)
VARN(put,     , long,      long,               MPI_LONG)
VARN(put,     , float,     float,              MPI_FLOAT)
VARN(put,     , double,    double,             MPI_DOUBLE)
VARN(put,     , longlong,  long long,          MPI_LONG_LONG_INT)
VARN(put,     , ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)

VARN(put, _all, text,      char,               MPI_CHAR)
VARN(put, _all, schar,     schar,              MPI_BYTE)
VARN(put, _all, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARN(put, _all, short,     short,              MPI_SHORT)
VARN(put, _all, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARN(put, _all, int,       int,                MPI_INT)
VARN(put, _all, uint,      uint,               MPI_UNSIGNED)
VARN(put, _all, long,      long,               MPI_LONG)
VARN(put, _all, float,     float,              MPI_FLOAT)
VARN(put, _all, double,    double,             MPI_DOUBLE)
VARN(put, _all, longlong,  long long,          MPI_LONG_LONG_INT)
VARN(put, _all, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)

VARN(get,     , text,      char,               MPI_CHAR)
VARN(get,     , schar,     schar,              MPI_BYTE)
VARN(get,     , uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARN(get,     , short,     short,              MPI_SHORT)
VARN(get,     , ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARN(get,     , int,       int,                MPI_INT)
VARN(get,     , uint,      uint,               MPI_UNSIGNED)
VARN(get,     , long,      long,               MPI_LONG)
VARN(get,     , float,     float,              MPI_FLOAT)
VARN(get,     , double,    double,             MPI_DOUBLE)
VARN(get,     , longlong,  long long,          MPI_LONG_LONG_INT)
VARN(get,     , ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)

VARN(get, _all, text,      char,               MPI_CHAR)
VARN(get, _all, schar,     schar,              MPI_BYTE)
VARN(get, _all, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARN(get, _all, short,     short,              MPI_SHORT)
VARN(get, _all, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARN(get, _all, int,       int,                MPI_INT)
VARN(get, _all, uint,      uint,               MPI_UNSIGNED)
VARN(get, _all, long,      long,               MPI_LONG)
VARN(get, _all, float,     float,              MPI_FLOAT)
VARN(get, _all, double,    double,             MPI_DOUBLE)
VARN(get, _all, longlong,  long long,          MPI_LONG_LONG_INT)
VARN(get, _all, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)


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
    int i, j, el_size, status=NC_NOERR, min_st, err, free_cbuf=0;
    int req_id=NC_REQ_NULL, st, isSameGroup, position;
    void *cbuf=NULL;
    char *bufp;
    MPI_Offset packsize=0, **_counts=NULL;
    MPI_Datatype ptype;
    NC     *ncp;
    NC_var *varp=NULL;

    /* check if ncid is valid, if yes, get varp from varid */
    SANITY_CHECK(ncid, ncp, varp, rw_flag, io_method, status)
    if (status != NC_NOERR) goto err_check;

    /* check for zero-size request */
    if (num == 0 || bufcount == 0) goto err_check;

    /* it is illegal for starts to be NULL */
    if (starts == NULL) {
        status = NC_ENULLSTART;
        goto err_check;
    }

    if (buftype == MPI_DATATYPE_NULL) {
        /* In this case, bufcount is ignored and will be recalculated to match
         * counts[]. Note buf's data type must match the data type of
         * variable defined in the file - no data conversion will be done.
         */
        bufcount = 0;
        for (j=0; j<num; j++) {
            MPI_Offset bufcount_j = 1;
            for (i=0; i<varp->ndims; i++) {
                if (counts[j][i] < 0) { /* no negative counts[][] */
                    err = NC_ENEGATIVECNT;
                    goto err_check;
                }
                bufcount_j *= counts[j][i];
            }
            bufcount += bufcount_j;
        }
        /* assign buftype match with the variable's data type */
        buftype = ncmpii_nc2mpitype(varp->type);
    }

    cbuf = buf;
    if (bufcount > 0) { /* flexible API is used */
        /* pack buf into cbuf, a contiguous buffer */
        int isderived, iscontig_of_ptypes;
        MPI_Offset bnelems;

        /* ptype (primitive MPI data type) from buftype
         * el_size is the element size of ptype
         * bnelems is the total number of ptype elements in buftype
         */
        status = ncmpii_dtype_decode(buftype, &ptype, &el_size, &bnelems,
                                     &isderived, &iscontig_of_ptypes);

        if (status != NC_NOERR) goto err_check;

        if (bufcount != (int)bufcount) {
            status = NC_EINTOVERFLOW;
            goto err_check;
        }

        /* check if buftype is contiguous, if not, pack to one, cbuf */
        if (! iscontig_of_ptypes && bnelems > 0) {
            position = 0;
            packsize  = bnelems*el_size;
            if (packsize != (int)packsize) {
                status = NC_EINTOVERFLOW;
                goto err_check;
            }
            cbuf = NCI_Malloc((size_t)packsize);
            free_cbuf = 1;
            if (rw_flag == WRITE_REQ)
                MPI_Pack(buf, (int)bufcount, buftype, cbuf, (int)packsize,
                         &position, MPI_COMM_SELF);
        }
    }
    else {
        /* this subroutine is called from a high-level API */
        status = NCMPII_ECHAR(varp->type, buftype);
        if (status != NC_NOERR) goto err_check;

        ptype = buftype;
        el_size = ncmpix_len_nctype(varp->type);
    }

    /* We allow counts == NULL and treat this the same as all 1s */
    if (counts == NULL) {
        _counts    = (MPI_Offset**) NCI_Malloc((size_t)num * sizeof(MPI_Offset*));
        _counts[0] = (MPI_Offset*)  NCI_Malloc((size_t)(num * varp->ndims *
                                                        SIZEOF_MPI_OFFSET));
        for (i=1; i<num; i++)
            _counts[i] = _counts[i-1] + varp->ndims;
        for (i=0; i<num; i++)
            for (j=0; j<varp->ndims; j++)
                _counts[i][j] = 1;
    }
    else
        _counts = (MPI_Offset**) counts;

    /* break buf into num pieces */
    isSameGroup=0;
    bufp = (char*)cbuf;
    for (i=0; i<num; i++) {
        MPI_Offset buflen;
        for (buflen=1, j=0; j<varp->ndims; j++) {
            if (_counts[i][j] < 0) { /* any negative counts[][] is illegal */
                status = NC_ENEGATIVECNT;
                goto err_check;
            }
            buflen *= _counts[i][j];
        }
        if (buflen == 0) continue;
        status = ncmpii_igetput_varm(ncp, varp, starts[i], _counts[i], NULL,
                                     NULL, bufp, buflen, ptype, &req_id,
                                     rw_flag, 0, isSameGroup);
        if (status != NC_NOERR) goto err_check;

        /* use isSamegroup so we end up with one nonblocking request (only the
         * first request gets a request ID back, the rest reuse the same ID.
         * This single ID represents num nonblocking requests */
        isSameGroup=1;
        bufp += buflen * el_size;
    }

err_check:
    if (_counts != NULL && _counts != counts) {
        NCI_Free(_counts[0]);
        NCI_Free(_counts);
    }

    if (ncp->safe_mode == 1 && io_method == COLL_IO) {
        int mpireturn;
        TRACE_COMM(MPI_Allreduce)(&status, &min_st, 1, MPI_INT, MPI_MIN,
                                  ncp->nciop->comm);
        if (min_st != NC_NOERR) {
            if (req_id != NC_REQ_NULL) /* cancel pending nonblocking request */
                ncmpii_cancel(ncp, 1, &req_id, &st);
            if (free_cbuf) NCI_Free(cbuf);
            return status;
        }
    }

    if (io_method == INDEP_IO && status != NC_NOERR) {
        if (req_id != NC_REQ_NULL) /* cancel pending nonblocking request */
            ncmpii_cancel(ncp, 1, &req_id, &st);
        if (free_cbuf) NCI_Free(cbuf);
        return status;
    }

    num = 1;
    if (status != NC_NOERR)
        /* This can only be reached for COLL_IO and safe_mode == 0.
           Set num=0 just so this process can participate the collective
           calls in wait_all */
        num = 0;

    if (io_method == COLL_IO)
        err = ncmpi_wait_all(ncid, num, &req_id, &st);
    else
        err = ncmpi_wait(ncid, num, &req_id, &st);

    /* unpack to user buf, if buftype is contiguous */
    if (rw_flag == READ_REQ && free_cbuf) {
        position = 0;
        MPI_Unpack(cbuf, (int)packsize, &position, buf, (int)bufcount, buftype,
                   MPI_COMM_SELF);
    }

    /* return the first error, if there is one */
    if (status == NC_NOERR) status = err;
    if (status == NC_NOERR) status = st;

    if (free_cbuf) NCI_Free(cbuf);

    return status;
}
