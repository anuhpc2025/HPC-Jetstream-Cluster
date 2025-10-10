#!/bin/bash
#SBATCH --job-name=hpl-test       # Job name
#SBATCH --ntasks=192              # Total MPI tasks
#SBATCH --ntasks-per-node=64       # MPI tasks per node
#SBATCH --cpus-per-task=1         # CPU cores per MPI task
#SBATCH --time=00:10:00           # Time limit hh:mm:ss
#SBATCH --nodes=3                 # Number of nodes

source /etc/profile.d/openmpi.sh

# Ulimits
ulimit -l unlimited
ulimit -n 65536

# Run the MPI program
mpirun ./xhpl