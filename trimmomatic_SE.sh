#!/bin/bash

#$ -N sra_download          # name of the job
#$ -o /data/users/$USER/BioinformaticsSG/Trimming-Data/sra_download.out   # contains what would normally be printed to stdout (the$
#$ -e /data/users/$USER/BioinformaticsSG/Trimming-Data/sra_download.err   # file name to print standard error messages to. These m$
#$ -q free64,som,asom       # request cores from the free64, som, asom queues.
#$ -pe openmp 8-64          # request parallel environment. You can include a minimum and maximum core count.
#$ -m beas                  # send you email of job status (b)egin, (e)rror, (a)bort, (s)uspend
#$ -ckpt blcr               # (c)heckpoint: writes a snapshot of a process to disk, (r)estarts the process after the checkpoint is c$

module load blcr

# Here we are assigning variables with paths
DIR=/data/users/$USER/BioinformaticsSG/Trimming-Data
SE_DIR=${DIR}/single_end_data
DATA_DIR_SE=${SE_DIR}/SE_fq_data

TRIM_DATA_SE=${SE_DIR}/SE_trim_data
TRIM_DATA_SE_QC=${SE_DIR}/SE_trim_data_QC

TRIMMOMATIC_DIR=/data/apps/trimmomatic/0.35/trimmomatic-0.35.jar 

# Here we are making two new directories, DATA_SRA is for our sra data and DATA_FQ is for the fastq file
mkdir ${TRIM_DATA_SE}
mkdir ${TRIM_DATA_SE_QC}

RUNLOG=${TRIM_DATA_SE}/runlog.txt
echo "Run by `whoami` on `date`" > ${RUNLOG}

for SAMPLE in `find ${DATA_SE} -name \*.fastq`; do
	INPUT=${TRIM_DATA_SE}/${SAMPLE}.fq.gz
	OUTPUT=${TRIM_DATA_SE}/${SAMPLE}.fq.gz

	TRIMMER="HEADCROP:13 LEADING:3 TRAILING:1 SLIDINGWINDOW:4:15 MINLEN:36"

	echo "*** Trimming: ${SAMPLE}"
	echo "`basename ${SAMPLE}` Summary" >> $RUNLOG

	java -jar ${TRIMMOMATIC_DIR} SE \
	-threads 8 \
	${INPUT} \
	-baseout ${OUTPUT} \
	${TRIMMER} \
	2>> ${RUNLOG}
    
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