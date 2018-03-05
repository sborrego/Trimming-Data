#!/bin/bash

#$ -N sra_download          # name of the job
#$ -o /data/users/$USER/BioinformaticsSG/Trimming-Data/sra_download.out   # contains what would normally be printed to stdout (the$
#$ -e /data/users/$USER/BioinformaticsSG/Trimming-Data/sra_download.err   # file name to print standard error messages to. These m$
#$ -q free64,som,asom       # request cores from the free64, som, asom queues.
#$ -pe openmp 8-64          # request parallel environment. You can include a minimum and maximum core count.
#$ -m beas                  # send you email of job status (b)egin, (e)rror, (a)bort, (s)uspend
#$ -ckpt blcr               # (c)heckpoint: writes a snapshot of a process to disk, (r)estarts the process after the checkpoint is c$

module load blcr
module load SRAToolKit

# Here we are assigning variables with paths
DIR=/data/users/$USER/BioinformaticsSG/Trimming-Data
DATA_SE_SRA=${DIR}/SE_data
DATA_SE=${DIR}/SE_fastq

# Here we are making two new directories, DATA_SRA is for our sra data and DATA_FQ is for the fastq file
mkdir ${DATA_SRA}
mkdir ${DATA_FQ}

# Here we are changing our current directory to the DATA directory
cd ${DATA_SRA}

# Here you have to manually write out the PREFIX (first three characters of experiment names), BASE (first six characters), 
# and the range of numbers after the BASE
# We are using the data file located here: https://www.ncbi.nlm.nih.gov/sra/?term=SRR3744667
PREFIX="SRR"
BASE="SRR374" 
nstart_seq="4667"
nstop_seq="4667"

for ID in `seq ${nstart_seq} ${nstop_seq}`; do
        SRA_FILE=${BASE}${ID}
        echo $USER is downloading ${SRA_FILE}
        wget ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/${PREFIX}/${BASE}/${SRA_FILE}/${SRA_FILE}.sra
        fastq-dump --outdir ${DATA_FQ} -X 1000 ${DATA_SRA}/${SRA_FILE}.sra
done