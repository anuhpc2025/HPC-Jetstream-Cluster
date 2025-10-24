#!/bin/bash
#SBATCH --job-name=hpl-test       # Job name
#SBATCH --ntasks=256              # Total MPI tasks
#SBATCH --ntasks-per-node=64       # MPI tasks per node
#SBATCH --cpus-per-task=1         # CPU cores per MPI task
#SBATCH --time=24:00:00           # Time limit hh:mm:ss
#SBATCH --nodes=4                 # Number of nodes


# Load MPI module (adjust for your system)
# module load openmpi

unset OMPI_MCA_osc

export PATH=/opt/openmpi-4.1.6/bin:$PATH
export LD_LIBRARY_PATH=/opt/openmpi-4.1.6/lib:$LD_LIBRARY_PATH

# === AOCL BLIS ===
export AOCLROOT=/opt/AMD/aocl-5.1.0/5.1.0/gcc
export LD_LIBRARY_PATH=${AOCLROOT}/lib:$LD_LIBRARY_PATH

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

export OMP_NUM_THREADS=1
export OMP_PROC_BIND=true
export OMP_PLACES=cores
export BLIS_ENABLE_OPENMP=1
export BLIS_CPU_EXT=ZEN3        
export BLIS_DYNAMIC_SCHED=0

# OMPI / UCX tuning
export UCX_TLS=rc_x,sm,self
export UCX_IB_GPU_DIRECT_RDMA=y
export UCX_MEMTYPE_CACHE=y
export UCX_RNDV_SCHEME=put_zcopy
export UCX_IB_PCI_RELAXED_ORDERING=on 

# Ulimits
ulimit -l unlimited
ulimit -n 65536

# Run the MPI program
mpirun \
  --map-by ppr:32:node:PE=1 --rank-by core --bind-to core --report-bindings \
  -x LD_LIBRARY_PATH -x PATH \
  -x AOCLROOT -x OMP_NUM_THREADS -x OMP_PROC_BIND -x OMP_PLACES \
  -x BLIS_ENABLE_OPENMP -x BLIS_CPU_EXT -x BLIS_DYNAMIC_SCHED \
  -x OMPI_MCA_pml -x OMPI_MCA_osc -x OMPI_MCA_btl \
  -x UCX_TLS -x UCX_NET_DEVICES \
  ./xhpl
  