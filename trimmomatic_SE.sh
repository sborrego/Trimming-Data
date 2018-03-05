#!/bin/bash

#$ -N sra_download          # name of the job
#$ -o /data/users/$USER/BioinformaticsSG/Trimming-Data/sra_download.out   # contains what would normally be printed to stdout (the$
#$ -e /data/users/$USER/BioinformaticsSG/Trimming-Data/sra_download.err   # file name to print standard error messages to. These m$
#$ -q free64,som,asom       # request cores from the free64, som, asom queues.
#$ -pe openmp 8-64          # request parallel environment. You can include a minimum and maximum core count.
#$ -m beas                  # send you email of job status (b)egin, (e)rror, (a)bort, (s)uspend
#$ -ckpt blcr               # (c)heckpoint: writes a snapshot of a process to disk, (r)estarts the process after the checkpoint is c$

module load blcr
module load fastqc/0.11.7

set -euxo pipefail

# Here we are assigning variables with paths
DIR=/data/users/$USER/BioinformaticsSG/Trimming-Data
SE_DIR=${DIR}/single_end_data
DATA_DIR_SE=${SE_DIR}/SE_fq_data

TRIM_DATA_SE=${SE_DIR}/SE_trim_data
TRIM_DATA_SE_QC=${SE_DIR}/SE_trim_data_QC
SE_QC_HTML=${TRIM_DATA_SE_QC}/SE_trim_data_QC_html

TRIMMOMATIC_DIR=/data/apps/trimmomatic/0.35/trimmomatic-0.35.jar 

# Here we are making two new directories, DATA_SRA is for our sra data and DATA_FQ is for the fastq file
mkdir -p ${TRIM_DATA_SE}
mkdir -p ${TRIM_DATA_SE_QC}
mkdir -p ${SE_QC_HTML}

RUNLOG=${TRIM_DATA_SE}/runlog.txt
echo "Run by `whoami` on `date`" > ${RUNLOG}

for SAMPLE in `find ${DATA_DIR_SE} -name \*.fastq\*`; do
	OUTPUT=${TRIM_DATA_SE}/trimmed_`basename ${SAMPLE}`

	TRIMMER="HEADCROP:13 LEADING:3 TRAILING:1 SLIDINGWINDOW:4:15 MINLEN:36"

	echo "*** Trimming: ${SAMPLE}"
	echo "`basename ${SAMPLE}` Summary" >> $RUNLOG

	java -jar ${TRIMMOMATIC_DIR} SE \
	-threads 8 \
	${SAMPLE} \
	${OUTPUT} \
	${TRIMMER} \
	2>> ${RUNLOG}

	fastqc ${OUTPUT} \
    --outdir ${TRIM_DATA_SE_QC}

    mv ${TRIM_DATA_SE_QC}/*.html ${SE_QC_HTML}
done

# Here we are compressing the HTML result file using the program tar
# -C flag prevents the parent directories from being included in the archive
# -csvf (c)reates archive, uses g(z)ip for compression, (v)erbosely shows the .tar file progress, (f)ilename appears next in the command
tar -C ${TRIM_DATA_SE_QC} -czvf ${SE_QC_HTML}.tar.gz ${SE_QC_HTML}


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