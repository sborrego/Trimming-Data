
DATA_DIR=/data/users/$USER/BioinformaticsSG/griffith_data/reads

for SAMPLE in `find ${DATA_DIR} -name \*`; do
	echo $SAMPLE
done

for SAMPLE in `find ${DATA_DIR} -name \*gz`; do
	echo $SAMPLE
done

for SAMPLE in `find ${DATA_DIR} -name \*gz`; do
	BASENAME=`basename $SAMPLE`
	echo $BASENAME
done

for SAMPLE in `find ${DATA_DIR} -name \*gz`; do
	BASENAME=`basename $SAMPLE`
	PREFIX=${BASENAME%%.*}
	echo $PREFIX
done



