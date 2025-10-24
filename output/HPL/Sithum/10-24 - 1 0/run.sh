#!/bin/bash
#SBATCH --job-name=hpl-test       # Job name
#SBATCH --ntasks=256              # Total MPI tasks
#SBATCH --ntasks-per-node=64       # MPI tasks per node
#SBATCH --cpus-per-task=1         # CPU cores per MPI task
#SBATCH --time=24:00:00           # Time limit hh:mm:ss
#SBATCH --nodes=4                 # Number of nodes

export SPACK_ROOT=/opt/spack
source ${SPACK_ROOT}/share/spack/setup-env.sh

spack load openmpi
spack load hpl %aocc

unset OMPI_MCA_osc

export PATH=/opt/openmpi-4.1.6/bin:$PATH
export LD_LIBRARY_PATH=/opt/openmpi-4.1.6/lib:$LD_LIBRARY_PATH

# MPI settings (Ethernet)
export OMPI_MCA_btl=self,vader,tcp
export OMPI_MCA_btl_tcp_if_include=enp1s0
export OMPI_MCA_oob_tcp_if_include=enp1s0
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

# Memory and file limits
ulimit -l unlimited
ulimit -n 65536

# Flush any pending writes
sync

# Drop caches
echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null

# Forces memory compaction
echo 1 > /proc/sys/vm/compact_memory

# Run the MPI program
mpirun Xhpl