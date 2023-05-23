#!/bin/bash
# Display Slurm running status

echo "Slurm running status: "
echo "Running jobgs: " `squeue -h | wc -l`
echo "Active nodes: " `sinfo -h -t alloc | awk '{Total=Total+$4} END{print $Total}'`
echo "Idle nodes: " `sinfo -h -t idle | awk '{print $4}'`
echo "Number of CPUs in use: " `squeue -h -o "%C" | {Total=Total+$1} END{print $Total}'`
