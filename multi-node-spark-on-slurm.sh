#!/bin/bash
# Multiple nodes Spark Cluster on Slurm
# 1. Request Slurm resources
#SBATCH --nodes=4
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task=4
#SBATCH --ntasks-per-node=2
#SBATCH --output=sparkjob-%j.output

# 2. Spark environment
module load spark

export SPARK_ID_STRING=$SLURM_JOBID
export SPARK_WORKER_DIR=$HOME/.spark/worker
export SPARK_LOG_DIR=$HOME/.spark/logs
export SPARK_LOCAL_DIRS=/tmp/spark

echo SPARK_WORKER_DIR
echo $SPARK_WORKER_DIR

echo SPARK_LOG_DIR
echo $SPARK_LOG_DIR

echo SPARK_LOCAL_DIRS
echo $SPARK_LOCAL_DIRS
mkdir -p $SPARK_WORKER_DIR $SPARK_LOG_DIR $SPARK_LOCAL_DIRS

# 3. Start Spark Master
echo "start Spark master..."
$SPARK_HOME/sbin/start-master.sh
sleep 2
MASTER_URL=$(grep -oP '(?=spark://).*' $SPARK_LOG_DIR/spark-${SPARK_ID_STRING}-org.*master*.out)

echo MASTER_URL
echo $MASTER_URL

URL1=$(grep -oP 'http://\K[^ ]+' $SPARK_LOG_DIR/spark-${SPARK_ID_STRING}-org.*master*.out)
HOSTNAME1=$(echo URL1| cut -d. -f1)
IP1=$(scontrol show node $HOSTNAME1 | grep -oP 'NodeAddr=\K[^ ]+' )
PORT1=$(echo $URL1|cut -d: -f2)
echo "----------- Master webUI is : --------------"
echo "http://$IP1:PORT1"
echo "--------------------------------------------"

# 4. Start worker nodes
export SPARK_WORKER_CORES=${SLURM_CPUS_PER_TASK:-1}
export SPARK_MEM=$(( ${SLURM_MEM_PER_CPU:-4096} * ${SLURM_CPUS_PER_TASK:-1} ))M
export SPARK_DAEMON_MEMORY=$SPARK_MEM
export SPARK_WORKER_MEMORY=$SPARK_MEM
export SPARK_EXECUTOR_MEMORY=$SPARK_MEM

# start the workers on each node allocated to the job
export SPARK_NO_DAEMONIZE=1
srun  --output=$SPARK_LOG_DIR/spark-%j-workers.out --label start-slave.sh ${MASTER_URL} &

# 5. Submit a task to the Spark cluster
$SPARK_HOME/bin/spark-submit --master ${MASTER_URL} \
             --total-executor-cores $((SLURM_NTASKS * SLURM_CPUS_PER_TASK)) \
             $SPARK_HOME/examples/src/main/python/pi.py 1000
sleep 2			 

# 6. Clean up
# Stop Spark worker
scancel ${SLURM_JOBID}.0
sleep 2

# Stop Spark master
$SPARK_HOME/sbin/stop-master.sh

# to submit this script to SLURM
sbatch muli-nodes.sh
