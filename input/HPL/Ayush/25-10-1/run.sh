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

# --- MPI transports (Ethernet) ---
export OMPI_MCA_btl=self,vader,tcp
NETDEV=$(ip route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="dev") {print $(i+1); exit}}')
export OMPI_MCA_btl_tcp_if_include="$NETDEV"
export OMPI_MCA_oob_tcp_if_include="$NETDEV"
export OMPI_MCA_pml=ob1         

# --- Open MPI tuned collectives ---
export OMPI_MCA_coll_tuned_use_dynamic_rules=1
export OMPI_MCA_coll_tuned_bcast_algorithm=1   
unset  OMPI_MCA_coll_tuned_allreduce_algorithm 

# --- Slurm integration ---
export OMPI_MCA_plm=slurm
unset OMPI_MCA_orte_launch

# Thread binding and OpenMP
export OMP_NUM_THREADS=1
export OMP_PROC_BIND=close
export OMP_PLACES=cores

# --- OpenMP / AOCL-BLIS (single-threaded BLAS) ---
export OMP_NUM_THREADS=1
export OMP_PROC_BIND=close
export OMP_PLACES=cores
export OMP_MAX_ACTIVE_LEVELS=1


export BLIS_ARCH_TYPE=zen3        
export BLIS_ARCH_DEBUG=1          
export BLIS_NUM_THREADS=1        
unset  BLIS_JC_NT BLIS_IC_NT BLIS_JR_NT BLIS_IR_NT  

export OMPI_MCA_hwloc_base_binding_policy=core
export OMPI_MCA_hwloc_base_use_hwthreads_as_cpus=0

# Memory and file limits
ulimit -l unlimited
ulimit -n 65536

# Flush any pending writes
sync

# Run the MPI program
mpirun --bind-to core --map-by ppr:64:node:pe=1 --report-bindings \
  $(spack location -i hpl)/bin/xhpl