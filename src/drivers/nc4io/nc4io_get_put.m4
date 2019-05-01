dnl Process this m4 file to produce 'C' language file.
dnl
dnl If you see this line, you can ignore the next one.
/* Do not edit this file. It is produced from the corresponding .m4 source */
dnl
/*
 *  Copyright (C) 2018, Northwestern University and Argonne National Laboratory
 *  See COPYRIGHT notice in top-level directory.
 */
/* $Id$ */
dnl
include(`foreach.m4')dnl
include(`utils.m4')dnl
dnl
define(`upcase', `translit(`$*', `a-z', `A-Z')')dnl
dnl
define(`GETATTTYPE',dnl
`dnl
    ifelse($1, `MPI_CHAR', , `else ')if (itype == $1)
        err = ifelse($1, `MPI_DATATYPE_NULL', `nc_get_att', `nc_get_att_')$2(nc4p->ncid, varid, name, ($3*) buf);
')dnl
dnl
define(`PUTATTTYPE',dnl
`dnl
    ifelse($1, `MPI_CHAR', , `else ')if (itype == $1)
        err = ifelse($1, `MPI_DATATYPE_NULL', `nc_put_att', `nc_put_att_')$2(nc4p->ncid, varid, name, ifelse($1, `MPI_CHAR', , `xtype, ')len, ($3*) value);
')dnl
dnl
define(`GETVARTYPE',dnl
`dnl
        ifelse($2, `MPI_CHAR', , `else ')if (buftype == $2) {
            err = nc_get_$1_$3(nc4p->ncid, varid, ifelse($1, `var1', `sstart, ', $1, `vara', `sstart, scount, ', $1, `vars', `sstart, scount, sstride, ', $1, `varm', `sstart, scount, sstride, simap, ')($4*) buf);
        }
')dnl
dnl
define(`PUTVARTYPE',dnl
`dnl
        ifelse($2, `MPI_CHAR', , `else ')if (buftype == $2) {
            err = nc_put_$1_$3(nc4p->ncid, varid, ifelse($1, `var1', `sstart, ', $1, `vara', `sstart, scount, ', $1, `vars', `sstart, scount, sstride, ', $1, `varm', `sstart, scount, sstride, simap, ')($4*) buf);
        }
')dnl
dnl
define(`GETVAR',dnl
`dnl
    ifelse($1, `var', , `else ')if (apikind == NC4_API_KIND_$2) {
foreach(`dt', (`(`MPI_CHAR', `text', `char')', dnl
               `(`MPI_SIGNED_CHAR', `schar', `signed char')', dnl
               `(`MPI_UNSIGNED_CHAR', `uchar', `unsigned char')', dnl
               `(`MPI_SHORT', `short', `short')', dnl
               `(`MPI_UNSIGNED_SHORT', `ushort', `unsigned short')', dnl
               `(`MPI_INT', `int', `int')', dnl
               `(`MPI_UNSIGNED', `uint', `unsigned int')', dnl
               `(`MPI_LONG', `long', `long')', dnl
               `(`MPI_FLOAT', `float', `float')', dnl
               `(`MPI_DOUBLE', `double', `double')', dnl
               `(`MPI_LONG_LONG_INT', `longlong', `long long')', dnl
               `(`MPI_UNSIGNED_LONG_LONG', `ulonglong', `unsigned long long')', dnl
               ), `GETVARTYPE($1, translit(dt, `()'))')dnl
        else {
            if (ndims > 0) {
                if (sstart  != NULL) NCI_Free(sstart);
                if (scount  != NULL) NCI_Free(scount);
                if (sstride != NULL) NCI_Free(sstride);
                if (simap   != NULL) NCI_Free(simap);
            }
            DEBUG_RETURN_ERROR(NC_ENOTSUPPORT)
        }
    }
')dnl
dnl
define(`PUTVAR',dnl
`dnl
    ifelse($1,`var',,`else ')if (apikind == NC4_API_KIND_$2) {
foreach(`dt', (`(`MPI_CHAR', `text', `char')', dnl
               `(`MPI_SIGNED_CHAR', `schar', `signed char')', dnl
               `(`MPI_UNSIGNED_CHAR', `uchar', `unsigned char')', dnl
               `(`MPI_SHORT', `short', `short')', dnl
               `(`MPI_UNSIGNED_SHORT', `ushort', `unsigned short')', dnl
               `(`MPI_INT', `int', `int')', dnl
               `(`MPI_UNSIGNED', `uint', `unsigned int')', dnl
               `(`MPI_LONG', `long', `long')', dnl
               `(`MPI_FLOAT', `float', `float')', dnl
               `(`MPI_DOUBLE', `double', `double')', dnl
               `(`MPI_LONG_LONG_INT', `longlong', `long long')', dnl
               `(`MPI_UNSIGNED_LONG_LONG', `ulonglong', `unsigned long long')', dnl
               ), `PUTVARTYPE($1, translit(dt, `()'))')dnl
        else {
            if (ndims > 0) {
                if (sstart  != NULL) NCI_Free(sstart);
                if (scount  != NULL) NCI_Free(scount);
                if (sstride != NULL) NCI_Free(sstride);
                if (simap   != NULL) NCI_Free(simap);
            }
            DEBUG_RETURN_ERROR(NC_ENOTSUPPORT)
        }
    }
')dnl

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

/* Note, netcdf header must come first due to conflicting constant definition */
#include <netcdf.h>

#include <stdio.h>
#include <stdlib.h>

#include <mpi.h>
#include <pnc_debug.h>
#include <common.h>
#include <nc4io_driver.h>

static int getelementsize(NC_nc4 *nc4p, int varid, MPI_Offset *size){
    int err;
    nc_type xtype;
    size_t xsize;

    err = nc_inq_vartype(nc4p->ncid, varid, &xtype);
    if (err != NC_NOERR){
        return err;
    }

    err = nc_inq_type(nc4p->ncid, xtype, NULL, &xsize);
    if (err != NC_NOERR){
        return err;
    }

    *size = (MPI_Offset)xsize;

    return NC_NOERR;
}

static int getvarsize(NC_nc4 *nc4p, int varid, int ndim, MPI_Offset *size){
    int i, err = NC_NOERR;
    int *dimids;
    size_t ret, dsize;

    dimids = (int*)NCI_Malloc(sizeof(int) * ndim);

    err = nc_inq_vardimid(nc4p->ncid, varid, dimids);
    if (err != NC_NOERR){
        ret = 0;
        goto fn_out;
    }

    ret = 1;
    for(i = 0; i < ndim; i++){
        err = nc_inq_dimlen(nc4p->ncid, dimids[i], &dsize);
        if (err != NC_NOERR){
            ret = 0;
            goto fn_out;
        }
        ret *= dsize;
    }

    *size = (MPI_Offset)ret;
      
fn_out:;

    NCI_Free(dimids);

    return err;
}


int
nc4io_get_att(void         *ncdp,
              int           varid,
              const char   *name,
              void         *buf,
              MPI_Datatype  itype)
{
    int err;
    size_t xsize, len;
    nc_type xtype;
    NC_nc4 *nc4p = (NC_nc4*)ncdp;

    /* when attribute length is > 0, buf cannot be BULL */
    err = nc_inq_att(nc4p->ncid, varid, name, &xtype, &len);
    if (err != NC_NOERR) DEBUG_RETURN_ERROR(err);

    /* zero-length attribute */
    if (len == 0) return NC_NOERR;

    if (itype != MPI_DATATYPE_NULL) {
        /* No character conversions are allowed. */
        err = (((xtype == NC_CHAR) == (itype != MPI_CHAR)) ? NC_ECHAR : NC_NOERR);
        if (err != NC_NOERR) DEBUG_RETURN_ERROR(err)
    }

    /* when len > 0, buf cannot be NULL */
    if (len && buf == NULL) DEBUG_RETURN_ERROR(NC_EINVAL)

    /* Count get size */
    err = nc_inq_type(nc4p->ncid, xtype, NULL, &xsize);
    if (err != NC_NOERR){
        return 0;
    }
    
    /* Call nc_get_att_<type> */
foreach(`dt', (`(`MPI_CHAR', `text', `char')', dnl
               `(`MPI_SIGNED_CHAR', `schar', `signed char')', dnl
               `(`MPI_UNSIGNED_CHAR', `uchar', `unsigned char')', dnl
               `(`MPI_SHORT', `short', `short')', dnl
               `(`MPI_UNSIGNED_SHORT', `ushort', `unsigned short')', dnl
               `(`MPI_INT', `int', `int')', dnl
               `(`MPI_UNSIGNED', `uint', `unsigned int')', dnl
               `(`MPI_FLOAT', `float', `float')', dnl
               `(`MPI_DOUBLE', `double', `double')', dnl
               `(`MPI_LONG_LONG_INT', `longlong', `long long')', dnl
               `(`MPI_UNSIGNED_LONG_LONG', `ulonglong', `unsigned long long')', dnl
               `(`MPI_DATATYPE_NULL', `', `void')', dnl
               ), `GETATTTYPE(translit(dt, `()'))')dnl
    else{
        DEBUG_ASSIGN_ERROR(err, NC_EUNSPTETYPE)
    }

    if (err == NC_NOERR){
        nc4p->getsize += (MPI_Offset)(xsize * len);
    }

    return err;
}

int
nc4io_put_att(void         *ncdp,
              int           varid,
              const char   *name,
              nc_type       xtype,
              MPI_Offset    nelems,
              const void    *value,
              MPI_Datatype  itype)
{
    int err;
    size_t xsize, len;
    NC_nc4 *nc4p = (NC_nc4*)ncdp;

    /* zero-length attribute is allowed, but
     * value cannot be NULL when nelems > 0 */
    if (nelems && value == NULL) DEBUG_RETURN_ERROR(NC_EINVAL)

    if (fIsSet(nc4p->mode, NC_NETCDF4) &&
        fIsSet(nc4p->mode, NC_CLASSIC_MODEL) &&
        !fIsSet(nc4p->flag, NC_MODE_DEF)) { /* when in data mode */
        /* check if attribute already exists */
        err = nc_inq_att(nc4p->ncid, varid, name, NULL, &len);
        if (err == NC_ENOTATT) /* adding new attribute cannot be in data mode */
            DEBUG_RETURN_ERROR(NC_ENOTINDEFINE)
        if (err == NC_NOERR && nelems > len)
            /* if attribute exists, nelems must be <= len */
            DEBUG_RETURN_ERROR(NC_ENOTINDEFINE)
    }

    /* Convert from MPI_Offset to size_t */
    len = (size_t)nelems;

    /* Count put size */
    err = nc_inq_type(nc4p->ncid, xtype, NULL, &xsize);
    if (err != NC_NOERR){
        return 0;
    }

    /* Call nc_put_att_<type> */
foreach(`dt', (`(`MPI_CHAR', `text', `char')', dnl
               `(`MPI_SIGNED_CHAR', `schar', `signed char')', dnl
               `(`MPI_UNSIGNED_CHAR', `uchar', `unsigned char')', dnl
               `(`MPI_SHORT', `short', `short')', dnl
               `(`MPI_UNSIGNED_SHORT', `ushort', `unsigned short')', dnl
               `(`MPI_INT', `int', `int')', dnl
               `(`MPI_UNSIGNED', `uint', `unsigned int')', dnl
               `(`MPI_FLOAT', `float', `float')', dnl
               `(`MPI_DOUBLE', `double', `double')', dnl
               `(`MPI_LONG_LONG_INT', `longlong', `long long')', dnl
               `(`MPI_UNSIGNED_LONG_LONG', `ulonglong', `unsigned long long')', dnl
               `(`MPI_DATATYPE_NULL', `', `void')', dnl
               ), `PUTATTTYPE(translit(dt, `()'))')dnl
    else{
        DEBUG_ASSIGN_ERROR(err, NC_EUNSPTETYPE)
    }

    if (err == NC_NOERR){
        nc4p->putsize += (MPI_Offset)(xsize * len);
    }
    
    return err;
}

int
nc4io_get_var(void             *ncdp,
              int               varid,
              const MPI_Offset *start,
              const MPI_Offset *count,
              const MPI_Offset *stride,
              const MPI_Offset *imap,
              void             *buf,
              MPI_Offset        bufcount,
              MPI_Datatype      buftype,
              int               reqMode)
{
    int i, err, status, apikind, ndims;
    size_t *sstart=NULL, *scount=NULL;
    ptrdiff_t *sstride=NULL, *simap=NULL;
    MPI_Offset getsize, vsize;
    NC_nc4 *nc4p = (NC_nc4*)ncdp;

    /* Inq variable dim */
    status = nc_inq_varndims(nc4p->ncid, varid, &ndims);

    if (reqMode & NC_REQ_ZERO) {
        /* only collective put can arrive here.
         * Warning: HDF5 may not like zero-length requests in collective
         */
        apikind = NC4_API_KIND_VARA;
        sstart = (size_t*) NCI_Calloc(ndims, sizeof(size_t));
        scount = (size_t*) NCI_Calloc(ndims, sizeof(size_t));
    }
    else {
        if (start == NULL)
            apikind = NC4_API_KIND_VAR;
        else if (count == NULL)
            apikind = NC4_API_KIND_VAR1;
        else if (imap != NULL) /* stride may be NULL */
            apikind = NC4_API_KIND_VARM;
        else if (stride != NULL)
            apikind = NC4_API_KIND_VARS;
        else
            apikind = NC4_API_KIND_VARA;

        /* Convert from MPI_Offset to size_t */
        if (ndims > 0) {
            if (start != NULL) {
                sstart = (size_t*)NCI_Malloc(sizeof(size_t) * ndims);
                for (i=0; i<ndims; i++) sstart[i] = (size_t)start[i];
            }
            if (count != NULL) {
                scount = (size_t*)NCI_Malloc(sizeof(size_t) * ndims);
                for (i=0; i<ndims; i++) scount[i] = (size_t)count[i];
            }
            if (stride != NULL) {
                sstride = (ptrdiff_t*)NCI_Malloc(sizeof(ptrdiff_t) * ndims);
                for (i=0; i<ndims; i++) sstride[i] = (ptrdiff_t)stride[i];
            }
            else if (apikind == NC4_API_KIND_VARM) {
                sstride = (ptrdiff_t*)NCI_Malloc(sizeof(ptrdiff_t) * ndims);
                for (i=0; i<ndims; i++) sstride[i] = 1;
            }
            if (imap != NULL) {
                simap = (ptrdiff_t*)NCI_Malloc(sizeof(ptrdiff_t) * ndims);
                for (i=0; i<ndims; i++) simap[i] = (ptrdiff_t)imap[i];
            }
        }
        else {
            sstart = scount = NULL;
            sstride = simap = NULL;
        }
    }

foreach(`api', `(var, var1, vara, vars, varm)', `GETVAR(api, upcase(api))') dnl

    /* Count get size */
    if (!(reqMode & NC_REQ_ZERO)){
        err = getelementsize(nc4p, varid, &getsize);
        if (err != NC_NOERR){
            return err;
        }

        if (scount != NULL){
            for(i = 0; i < ndims; i++){
                getsize *= scount[i];
            }
        }
        else{
            if (apikind == NC4_API_KIND_VAR){
                err = getvarsize(nc4p, varid, ndims, &vsize);
                if (err != NC_NOERR){
                    return err;
                }

                getsize *= vsize;
            }
        }
        nc4p->getsize += getsize;
    }

    /* Free buffers if needed */
    if (ndims > 0) {
        if (sstart  != NULL) NCI_Free(sstart);
        if (scount  != NULL) NCI_Free(scount);
        if (sstride != NULL) NCI_Free(sstride);
        if (simap   != NULL) NCI_Free(simap);
    }

    return (status != NC_NOERR) ? status : err;
}

int
nc4io_put_var(void             *ncdp,
              int               varid,
              const MPI_Offset *start,
              const MPI_Offset *count,
              const MPI_Offset *stride,
              const MPI_Offset *imap,
              const void       *buf,
              MPI_Offset        bufcount,
              MPI_Datatype      buftype,
              int               reqMode)
{
    int i, err, status, apikind, ndims;
    size_t *sstart=NULL, *scount=NULL;
    ptrdiff_t *sstride=NULL, *simap=NULL;
    MPI_Offset putsize, vsize;
    NC_nc4 *nc4p = (NC_nc4*)ncdp;

    /* Inq variable dim */
    status = nc_inq_varndims(nc4p->ncid, varid, &ndims);

    if (reqMode & NC_REQ_ZERO) {
        /* only collective put can arrive here.
         * Warning: HDF5 may not like zero-length requests in collective
         */
        apikind = NC4_API_KIND_VARA;
        sstart = (size_t*) NCI_Calloc(ndims, sizeof(size_t));
        scount = (size_t*) NCI_Calloc(ndims, sizeof(size_t));
    }
    else {
        if (start == NULL)
            apikind = NC4_API_KIND_VAR;
        else if (count == NULL)
            apikind = NC4_API_KIND_VAR1;
        else if (imap != NULL) /* stride may be NULL */
            apikind = NC4_API_KIND_VARM;
        else if (stride != NULL)
            apikind = NC4_API_KIND_VARS;
        else
            apikind = NC4_API_KIND_VARA;

        /* Convert to MPI_Offset if not scalar */
        if (ndims > 0) {
            if (start != NULL) {
                sstart = (size_t*)NCI_Malloc(sizeof(size_t) * ndims);
                for (i=0; i<ndims; i++) sstart[i] = (size_t)start[i];
            }
            if (count != NULL) {
                scount = (size_t*)NCI_Malloc(sizeof(size_t) * ndims);
                for (i=0; i<ndims; i++) scount[i] = (size_t)count[i];
            }
            if (stride != NULL) {
                sstride = (ptrdiff_t*)NCI_Malloc(sizeof(ptrdiff_t) * ndims);
                for (i=0; i<ndims; i++) sstride[i] = (ptrdiff_t)stride[i];
            }
            else if (apikind == NC4_API_KIND_VARM) {
                sstride = (ptrdiff_t*)NCI_Malloc(sizeof(ptrdiff_t) * ndims);
                for (i=0; i<ndims; i++) sstride[i] = 1;
            }
            if (imap != NULL) {
                simap = (ptrdiff_t*)NCI_Malloc(sizeof(ptrdiff_t) * ndims);
                for (i=0; i<ndims; i++) simap[i] = (ptrdiff_t)imap[i];
            }
        }
        else {
            sstart = scount = NULL;
            sstride = simap = NULL;
        }
    }

foreach(`api', `(var, var1, vara, vars, varm)', `PUTVAR(api, upcase(api))') dnl

    /* Count put size */
    if (!(reqMode & NC_REQ_ZERO)){
        err = getelementsize(nc4p, varid, &putsize);
        if (err != NC_NOERR){
            return err;
        }

        if (scount != NULL){
            for(i = 0; i < ndims; i++){
                putsize *= scount[i];
            }
        }
        else{
            if (apikind == NC4_API_KIND_VAR){
                err = getvarsize(nc4p, varid, ndims, &vsize);
                if (err != NC_NOERR){
                    return err;
                }

                putsize *= vsize;
            }
        }
        nc4p->putsize += putsize;
    }

    /* Free buffers if needed */
    if (ndims > 0) {
        if (sstart  != NULL) NCI_Free(sstart);
        if (scount  != NULL) NCI_Free(scount);
        if (sstride != NULL) NCI_Free(sstride);
        if (simap   != NULL) NCI_Free(simap);
    }

    return (status != NC_NOERR) ? status : err;
}
