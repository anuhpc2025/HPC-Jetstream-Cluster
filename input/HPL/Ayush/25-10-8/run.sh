#!/bin/bash
#SBATCH --job-name=hpl-test       # Job name
#SBATCH --ntasks=256              # Total MPI tasks
#SBATCH --ntasks-per-node=64       # MPI tasks per node
#SBATCH --cpus-per-task=1         # CPU cores per MPI task
#SBATCH --time=24:00:00           # Time limit hh:mm:ss
#SBATCH --nodes=4                 # Number of nodes

export SPACK_USER_CONFIG_PATH=/tmp/spack-config
export SPACK_USER_CACHE_PATH=/tmp/spack-cache

export SPACK_ROOT=/opt/spack
source ${SPACK_ROOT}/share/spack/setup-env.sh

# Load OpenMPI explicitly by hash
spack load /buou2hh
spack load hpl %aocc

unset OMPI_MCA_osc

# MPI over Ethernet (auto-detect primary NIC)
unset OMPI_MCA_osc
NETDEV=$(ip route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}')
export OMPI_MCA_btl=self,vader,tcp
export OMPI_MCA_btl_tcp_if_include="$NETDEV"
export OMPI_MCA_oob_tcp_if_include="$NETDEV"
export OMPI_MCA_pml=ob1       

# Avoid forcing coll algorithms; let HPL's BCAST do its thing
unset OMPI_MCA_coll_tuned_bcast_algorithm
unset OMPI_MCA_coll_tuned_allreduce_algorithm

# --- Slurm integration ---
export OMPI_MCA_plm=slurm
unset OMPI_MCA_orte_launch

# Thread binding and OpenMP
export OMP_NUM_THREADS=1
export OMP_PROC_BIND=true
export OMP_PLACES=cores

# --- OpenMP / AOCL-BLIS (single-threaded BLAS) ---
export BLIS_NUM_THREADS=1  
export OMP_NUM_THREADS=1      
unset BLIS_JC_NT BLIS_IC_NT BLIS_JR_NT

# Memory and file limits
ulimit -l unlimited
ulimit -n 65536

# Flush any pending writes
sync

# Run the MPI program
mpirun --bind-to core --map-by ppr:64:node:pe=1 --report-bindings \
  $(spack location -i hpl)/bin/xhpl