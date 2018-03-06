#!/bin/bash

#$ -N trim_PE               # name of the job
#$ -o /data/users/$USER/BioinformaticsSG/Trimming-Data/trim_PE.out   # contains what would normally be printed to stdout (the$
#$ -e /data/users/$USER/BioinformaticsSG/Trimming-Data/trim_PE.err   # file name to print standard error messages to. These m$
#$ -q free64,som,asom       # request cores from the free64, som, asom queues.
#$ -pe openmp 8-64          # request parallel environment. You can include a minimum and maximum core count.
#$ -m beas                  # send you email of job status (b)egin, (e)rror, (a)bort, (s)uspend
#$ -ckpt blcr               # (c)heckpoint: writes a snapshot of a process to disk, (r)estarts the process after the checkpoint is c$

module load blcr

set -euxo pipefail

DATA_DIR=/data/users/sborrego/BioinformaticsSG/griffith_data/reads

DIR=/data/users/$USER/BioinformaticsSG/Trimming-Data

PE_DIR=${DIR}/paired_end_data

TRIM_DATA_PE=${PE_DIR}/PE_trim_data

TRIMMOMATIC_DIR=/data/apps/trimmomatic/0.35/trimmomatic-0.35.jar 

mkdir -p ${PE_DIR}

mkdir -p ${TRIM_DATA_PE}

# TRIMMOMATIC for paired end samples

RUNLOG=${TRIM_DATA_PE}/runlog.txt
echo "Run by `whoami` on `date`" > $RUNLOG

for SAMPLE in HBR UHR;
do
    for REPLICATE in 1 2 3;
    do
        # Build the name of the files.
        R1=${DATA_DIR}/${SAMPLE}_${REPLICATE}_R1.fq.gz
        R2=${DATA_DIR}/${SAMPLE}_${REPLICATE}_R2.fq.gz
        OUTPUT=${TRIM_DATA_PE}/${SAMPLE}_${REPLICATE}.fq.gz

        TRIMMER="HEADCROP:13 LEADING:3 TRAILING:1 SLIDINGWINDOW:4:15 MINLEN:36"

        echo "*** Trimming: ${SAMPLE}_${REPLICATE}"
        echo "${SAMPLE}_${REPLICATE} Summary" >> $RUNLOG

        java -jar ${TRIMMOMATIC_DIR} \
        PE \
        -threads 8 \
        ${R1} ${R2} \
        -baseout ${OUTPUT} \
        ${TRIMMER} \
        2>> $RUNLOG
     done
done


# Some notes on the trimmer setting:

# quality: Specifies the minimum quality required to keep a base.

# LEADING:<quality>
# Removes leading low quality or N bases (below quality 3)

# TRAILING:<quality>
# Remove trailing low quality or N bases (below quality 1)

# SLIDINGWINDOW:<windowSize>:<requiredQuality>
# Scan the read with a 4-base wide sliding window (windowSize), cutting when the average quality per base drops below 15 (requiredQuality)

# MINLEN:<length>
# Drop reads which are less than 36 bases long after these steps






