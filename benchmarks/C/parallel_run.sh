#!/bin/sh
#
# Copyright (C) 2018, Northwestern University and Argonne National Laboratory
# See COPYRIGHT notice in top-level directory.
#

# Exit immediately if a command exits with a non-zero status.
set -e

VALIDATOR=../../src/utils/ncvalidator/ncvalidator
NCMPIDIFF=../../src/utils/ncmpidiff/ncmpidiff

# remove file system type prefix if there is any
OUTDIR=`echo "$TESTOUTDIR" | cut -d: -f2-`

MPIRUN=`echo ${TESTMPIRUN} | ${SED} -e "s/NP/$1/g"`
# echo "MPIRUN = ${MPIRUN}"
# echo "check_PROGRAMS=${check_PROGRAMS}"

# echo "PNETCDF_DEBUG = ${PNETCDF_DEBUG}"
if test ${PNETCDF_DEBUG} = 1 ; then
   safe_modes="0 1"
else
   safe_modes="0"
fi

for i in ${check_PROGRAMS} ; do
    for j in ${safe_modes} ; do
        if test "$j" = 1 ; then # test only in safe mode
           export PNETCDF_HINTS="nc_header_collective=true"
        fi
        export PNETCDF_SAFE_MODE=$j
        # echo "set PNETCDF_SAFE_MODE ${PNETCDF_SAFE_MODE}"

        OPTS=
        if test "$i" = "aggregation" ; then
           OPTS="-b -c -i -j"
        fi
        echo "${MPIRUN} ./$i -q ${OPTS} -l 10 ${TESTOUTDIR}/$i.nc"
        ${MPIRUN} ./$i -q ${OPTS} -l 10 ${TESTOUTDIR}/$i.nc
        if test $? = 0 ; then
           echo "PASS:  C  parallel run on $1 processes --------------- $i"
        fi

        # echo "--- validating file ${TESTOUTDIR}/$i.nc"
        ${TESTSEQRUN} ${VALIDATOR} -q ${TESTOUTDIR}/$i.nc
        # echo ""

        if test "x${ENABLE_BURST_BUFFER}" = x1 ; then
           # echo "test burst buffering feature"
           saved_PNETCDF_HINTS=${PNETCDF_HINTS}
           export PNETCDF_HINTS="${PNETCDF_HINTS};nc_burst_buf=enable;nc_burst_buf_dirname=${TESTOUTDIR};nc_burst_buf_overwrite=enable"
           ${MPIRUN} ./$i -q -l 10 ${TESTOUTDIR}/$i.bb.nc
           if test $? = 0 ; then
              echo "PASS:  C  parallel run on $1 processes --------------- $i"
           fi
           export PNETCDF_HINTS=${saved_PNETCDF_HINTS}

           # echo "--- validating file ${TESTOUTDIR}/$i.bb.nc"
           ${TESTSEQRUN} ${VALIDATOR} -q ${TESTOUTDIR}/$i.bb.nc

           # echo "--- ncmpidiff $i.nc $i.bb.nc ---"
           ${MPIRUN} ${NCMPIDIFF} -q ${TESTOUTDIR}/$i.nc ${TESTOUTDIR}/$i.bb.nc
        fi

       if test "x${ENABLE_NETCDF4}" = x1 ; then
          # echo "test netCDF-4 feature"
          ${MPIRUN} ./$i -q -l 10 ${TESTOUTDIR}/$i.nc4 4
          # Validator does not support nc4
       fi
    done
    rm -f ${OUTDIR}/$i.nc
    rm -f ${OUTDIR}/$i.bb.nc
    rm -f ${OUTDIR}/$i.nc4
done

