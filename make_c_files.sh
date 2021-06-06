#!/bin/bash


# Process the path name down to a variable name
f1=$(basename $2)
file=${f1%.*}

full_path=$(dirname $2)
last_path=$(basename $full_path)

if [[ $last_path == $full_path ]] ; then
    name=$file
else
    name=${last_path}_${file}
fi


if [[ $1 == source ]] ; then
    echo  "const unsigned char ${name}_bytes[] = {" 
    cat $2 | xxd -i 
    echo "};"
    echo
else
    if [[ $1 == header ]] ; then
        echo "extern const unsigned char ${name}_bytes[];"
        size=`cat $2 | wc -c | tr -d ' '`
        echo "#define ${name}_size $size"
        echo
        echo
    else
        exit -1
    fi
fi

