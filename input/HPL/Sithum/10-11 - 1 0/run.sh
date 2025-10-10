#!/bin/bash
#SBATCH --job-name=hpl-test       # Job name
#SBATCH --ntasks=192              # Total MPI tasks
#SBATCH --ntasks-per-node=64       # MPI tasks per node
#SBATCH --cpus-per-task=1         # CPU cores per MPI task
#SBATCH --time=01:00:00           # Time limit hh:mm:ss
#SBATCH --nodes=3                 # Number of nodes

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

# Run the MPI program
mpirun ./xhpl