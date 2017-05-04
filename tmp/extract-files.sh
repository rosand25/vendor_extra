#!/bin/bash

set -e

SCRIPT_DIR=$(dirname $0)
VENDOR=xiaomi
DEVICE=aries

if [ $# -eq 3 ]; then
	SRC_ARIES=$1
	SRC_MAKO=$2
	SRC_OTHERS=$3
else
echo "$0: bad number of arguments"
	echo ""
	echo "usage: $0 [ARIES] [MAKO] [OTHERS]"
	echo ""
	echo "If PATH_TO_EXPANDED_ROM is not specified, blobs will be extracted from"
	echo "the device using adb pull."
	exit 1
fi

BASE=../../../vendor/$VENDOR/$DEVICE/proprietary
rm -rf $BASE/*

fetch_file() {
	SRC="$1"
	FILE="$2"

	OLDIFS=$IFS IFS=":" PARSING_ARRAY=($FILE) IFS=$OLDIFS
	FILE=`echo ${PARSING_ARRAY[0]} | sed -e "s/^-//g"`
	DEST=${PARSING_ARRAY[1]}
	if [ -z $DEST ] ; then
		DEST=$FILE
	fi

	DIR=`dirname $DEST`
	if [ ! -d $BASE/$DIR ]; then
		mkdir -p $BASE/$DIR
	fi

	cp $SRC/$FILE $BASE/$DEST
	echo $DEST >> proprietary-blobs.txt.tmp
}

rm -f proprietary-blobs.txt.tmp
touch proprietary-blobs.txt.tmp

while read FILE; do
    FILE=`echo $FILE | sed -e "s/^-//g" | cut -d\# -f1`
    if [ -z "$FILE" ]; then
        continue;
    fi
    
    fetch_file "$SRC_ARIES" "$FILE"
done < "$SCRIPT_DIR/proprietary-blobs-aries.txt"

while read FILE; do
    FILE=`echo $FILE | sed -e "s/^-//g" | cut -d\# -f1`
    if [ -z "$FILE" ]; then
        continue;
    fi
    
    fetch_file "$SRC_MAKO" "$FILE"
done < "$SCRIPT_DIR/proprietary-blobs-mako.txt"

while read FILE; do
    FILE=`echo $FILE | sed -e "s/^-//g" | cut -d\# -f1`
    if [ -z "$FILE" ]; then
        continue;
    fi
    
    fetch_file "$SRC_OTHERS" "$FILE"
done < "$SCRIPT_DIR/proprietary-blobs-others.txt"

cat proprietary-blobs.txt.tmp | sort > proprietary-blobs.txt
rm proprietary-blobs.txt.tmp

# patch libqc-opt.so
perl -pi -e 's/utext_openUChars_48/utext_openUChars_53/g' $BASE/vendor/lib/libqc-opt.so
perl -pi -e 's/utext_close_48/utext_close_53/g' $BASE/vendor/lib/libqc-opt.so
perl -pi -e 's/u_errorName_48/u_errorName_53/g' $BASE/vendor/lib/libqc-opt.so
perl -pi -e 's/u_digit_48/u_digit_53/g' $BASE/vendor/lib/libqc-opt.so

./setup-makefiles.sh
