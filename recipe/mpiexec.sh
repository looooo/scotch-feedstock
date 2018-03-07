#!/bin/bash
set -e

if command -v mpichversion >/dev/null 2>&1; then
    export HYDRA_LAUNCHER=fork
elif command -v ompi_info >/dev/null 2>&1; then
    export OMPI_MCA_plm=isolated
    export OMPI_MCA_plm_rsh_agent=false
    export OMPI_MCA_rmaps_base_oversubscribe=yes
    export OMPI_MCA_btl_vader_single_copy_mechanism=none
    mpiexec_args=--allow-run-as-root
fi

# pipe stdout, stderr through cat to avoid O_NONBLOCK issues
mpiexec $mpiexec_args $@ 2>&1 </dev/null | cat
