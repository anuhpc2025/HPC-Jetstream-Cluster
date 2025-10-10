#!/bin/bash
#SBATCH --job-name=hpl-test       # Job name
#SBATCH --ntasks=192              # Total MPI tasks
#SBATCH --ntasks-per-node=64       # MPI tasks per node
#SBATCH --cpus-per-task=1         # CPU cores per MPI task
#SBATCH --time=00:10:00           # Time limit hh:mm:ss
#SBATCH --nodes=3                 # Number of nodes

# Pick the cluster interconnect only
export OMPI_MCA_btl=self,vader,tcp
export OMPI_MCA_btl_tcp_if_include=enp1s0


# keep environment consistent
export PATH=/opt/openmpi-4.1.6/bin:$PATH
export LD_LIBRARY_PATH=/opt/openmpi-4.1.6/lib:$LD_LIBRARY_PATH

# Optional: ensure SLURM launching is used cleanly
export OMPI_MCA_plm=slurm
export OMPI_MCA_orte_launch=slurm

# If using OpenMP threads inside HPL, uncomment and tune:
# export OMP_NUM_THREADS=1

# Ulimits
ulimit -l unlimited
ulimit -n 65536

# Run the MPI program
mpirun ./xhpl