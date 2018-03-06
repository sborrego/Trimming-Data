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

# Here we are assigning variables with paths
DIR=/data/users/$USER/BioinformaticsSG/Trimming-Data
SE_DIR=${DIR}/single_end_data

DATA_DIR_SE=${SE_DIR}/SE_fq_data
SE_DATA_QC=${SE_DIR}/SE_data_QC
SE_QC_HTML=${SE_DATA_QC}/SE_data_QC_html

mkdir -p ${SE_DATA_QC}
mkdir -p ${SE_QC_HTML}


for SAMPLE in `find ${DATA_DIR_SE} -type f`; do
	fastqc ${SAMPLE} \
	--outdir ${DATA_SE_QC}

	mv ${SE_DATA_QC}/*.html ${SE_QC_HTML}
done

# Here we are compressing the HTML result file using the program tar
# -C flag prevents the parent directories from being included in the archive
# -csvf (c)reates archive, uses g(z)ip for compression, (v)erbosely shows the .tar file progress, (f)ilename appears next in the command
tar -C ${SE_DATA_QC} -czvf ${SE_QC_HTML}.tar.gz ${SE_QC_HTML}