#!/bin/sh
#
# Copyright (C) 2018, Northwestern University and Argonne National Laboratory
# See COPYRIGHT notice in top-level directory.
#

# Exit immediately if a command exits with a non-zero status.
set -e

VALIDATOR=../../src/utils/ncvalidator/ncvalidator
NCMPIDIFF=../../src/utils/ncmpidiff/ncmpidiff

MPIRUN=`echo ${TESTMPIRUN} | ${SED} -e "s/NP/$1/g"`
# echo "MPIRUN = ${MPIRUN}"
# echo "check_PROGRAMS=${check_PROGRAMS}"

for i in ${check_PROGRAMS} ; do
    for j in 0 1 ; do
        export PNETCDF_SAFE_MODE=$j
        # echo "set PNETCDF_SAFE_MODE ${PNETCDF_SAFE_MODE}"

        ${MPIRUN} ./$i -q -l 10 ${TESTOUTDIR}/$i.nc
        if test $? = 0 ; then
           echo "PASS:  C  parallel run on $1 processes --------------- $i"
        fi

        # echo "--- validating file ${TESTOUTDIR}/$i.nc"
        ${TESTSEQRUN} ${VALIDATOR} -q ${TESTOUTDIR}/$i.nc
        # echo ""

        if test "x${TESTBB}" = x1 ; then
           # echo "test burst buffering feature"
           export PNETCDF_HINTS="nc_burst_buf=enable;nc_burst_buf_dirname=${TESTOUTDIR};nc_burst_buf_overwrite=enable"
           ${MPIRUN} ./$i -q -l 10 ${TESTOUTDIR}/$i.bb.nc
           if test $? = 0 ; then
              echo "PASS:  C  parallel run on $1 processes --------------- $i"
           fi
           unset PNETCDF_HINTS

           # echo "--- validating file ${TESTOUTDIR}/$i.bb.nc"
           ${TESTSEQRUN} ${VALIDATOR} -q ${TESTOUTDIR}/$i.bb.nc

           # echo "--- ncmpidiff $i.nc $i.bb.nc ---"
           ${MPIRUN} ${NCMPIDIFF} -q ${TESTOUTDIR}/$i.nc ${TESTOUTDIR}/$i.bb.nc
        fi
    done

    if test "x${TESTNETCDF4}" = x1 ; then
       # echo "test netCDF-4 feature"
       ${MPIRUN} ./$i -l 10 ${TESTOUTDIR}/$i.nc4 4
       # Validator does not support nc4
    fi
done
