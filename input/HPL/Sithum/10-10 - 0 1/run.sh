#!/bin/bash
#SBATCH --job-name=hpl-test       # Job name
#SBATCH --ntasks=192              # Total MPI tasks
#SBATCH --ntasks-per-node=64       # MPI tasks per node
#SBATCH --cpus-per-task=1         # CPU cores per MPI task
#SBATCH --time=00:10:00           # Time limit hh:mm:ss
#SBATCH --nodes=3                 # Number of nodes

hostname
which srun
which mpirun
echo "PATH is: $PATH"
ls -l /bin/srun
env | grep -E "SLURM|PATH"

echo "TESTTESTTEST"
export PATH=/opt/slurm/bin:/usr/bin:/bin:/opt/openmpi-4.1.6/bin:$PATH
export LD_LIBRARY_PATH=/opt/openmpi-4.1.6/lib:$LD_LIBRARY_PATH

hostname
which srun
which mpirun
echo "PATH is: $PATH"
ls -l /bin/srun
env | grep -E "SLURM|PATH"

# Ulimits
ulimit -l unlimited
ulimit -n 65536

# Run the MPI program
mpirun ./xhpl