#!/bin/sh
#SBATCH --nodes=8
#SBATCH --constraint=gpu
#SBATCH --time=01:00:00
#SBATCH --mail-type=ALL

root_dir="$PWD"

export LD_LIBRARY_PATH="$PWD"

if [[ ! -d tracing ]]; then mkdir tracing; fi
pushd tracing

for n in 8 4 2 1; do
  for r in 0 1 2 3 4; do
    echo "Running $n""x9_r$r""..."
    srun -n "$n" -N "$n" --cpu_bind none --ntasks-per-node 1 /lib64/ld-linux-x86-64.so.2 "$root_dir/pennant.spmd9" "$root_dir/pennant.tests/leblanc_long16x30/leblanc.pnt" -npieces $(( $n * 9 )) -numpcx 1 -numpcy $(( $n * 9 )) -seq_init 0 -par_init 1 -print_ts 1 -prune 10 -ll:cpu 9 -ll:io 1 -ll:util 3 -ll:dma 2 -ll:csize 40960 -ll:rsize 4096 -ll:gsize 0 -dm:memoize -lg:parallel_replay 3 -ll:ht_sharing 0 | tee out_"$n"x9_r"$r".log
  done
done

popd

if [[ ! -d notracing ]]; then mkdir notracing; fi
pushd notracing

for n in 8 4 2 1; do
  for r in 0 1 2 3 4; do
    echo "Running $n""x9_r$r""..."
    srun -n "$n" -N "$n" --cpu_bind none --ntasks-per-node 1 /lib64/ld-linux-x86-64.so.2 "$root_dir/pennant.spmd9" "$root_dir/pennant.tests/leblanc_long16x30/leblanc.pnt" -npieces $(( $n * 9 )) -numpcx 1 -numpcy $(( $n * 9 )) -seq_init 0 -par_init 1 -print_ts 1 -prune 10 -ll:cpu 9 -ll:io 1 -ll:util 3 -ll:dma 2 -ll:csize 40960 -ll:rsize 4096 -ll:gsize 0 -lg:no_tracing -ll:ht_sharing 0 | tee out_"$n"x9_r"$r".log
  done
done

popd
