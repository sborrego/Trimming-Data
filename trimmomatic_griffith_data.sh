
#!/bin/bash


#$ -pe openmp 8-64

module load blcr

set -euxo pipefail

TRIMMOMATIC_DIR=/data/apps/trimmomatic/0.35/trimmomatic-0.35.jar 
TRIM_DATA_DIR=/data/users/$USER/BioinformaticsSG/griffith_data_trimmed
DATA_DIR=/data/users/$USER/BioinformaticsSG/griffith_data/reads

mkdir -p ${TRIM_DATA_DIR}

# TRIMMOMATIC for paired end samples

RUNLOG=${TRIM_DATA_DIR}/runlog.txt
echo "Run by `whoami` on `date`" > $RUNLOG

for SAMPLE in HBR UHR;
do
    for REPLICATE in 1 2 3;
    do
        # Build the name of the files.
        R1=${DATA_DIR}/${SAMPLE}_${REPLICATE}_R1.fq.gz
        R2=${DATA_DIR}/${SAMPLE}_${REPLICATE}_R2.fq.gz
        TRIM_FILE=${TRIM_DATA_DIR}/${SAMPLE}_${REPLICATE}.fq.gz

        TRIMMER="HEADCROP:13 LEADING:3 TRAILING:1 SLIDINGWINDOW:4:15 MINLEN:36"

        echo "*** Trimming: $TRIM_FILE"
        echo "`basename $TRIM_FILE` Summary" >> $RUNLOG

        java -jar ${TRIMMOMATIC_DIR} PE \
        -threads 8 \
        ${R1} ${R2} \
        -baseout ${TRIM_FILE} \
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






