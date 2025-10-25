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
export LD_LIBRARY_PATH=/opt/spack/opt/spack/linux-zen3/openmpi-5.0.8-6hi2ymzi7jy344ruvf5ew3kgoadai5v4/lib:$LD_LIBRARY_PATH

unset OMPI_MCA_osc

# MPI settings (Ethernet)
export OMPI_MCA_btl=self,vader,tcp
export OMPI_MCA_btl_tcp_if_include=eth0
export OMPI_MCA_oob_tcp_if_include=eth0
export OMPI_MCA_pml=ob1

# Collective tuning
export OMPI_MCA_coll_tuned_use_dynamic_rules=1
export OMPI_MCA_coll_tuned_bcast_algorithm=4
export OMPI_MCA_coll_tuned_allreduce_algorithm=6

# SLURM Integration
export OMPI_MCA_plm=slurm
export OMPI_MCA_orte_launch=slurm

# Thread binding and OpenMP
export OMP_NUM_THREADS=1
export OMP_PROC_BIND=close
export OMP_PLACES=cores

# amdblis (BLAS layer) optimizations
export BLIS_JC_NT=1  # (No outer loop parallelization)
export BLIS_IC_NT=$OMP_NUM_THREADS # (# of 2nd level threads – one per core in the shared L3 cache domain):
export BLIS_JR_NT=1 # (No 4th level threads)
export BLIS_IR_NT=1 # (No 5th level threads

export BLIS_NUM_THREADS=1

export OMPI_MCA_hwloc_base_binding_policy=core
export OMPI_MCA_hwloc_base_use_hwthreads_as_cpus=0

# Memory and file limits
ulimit -l unlimited
ulimit -n 65536

# Flush any pending writes
sync

# Run the MPI program
mpirun ./xhpl