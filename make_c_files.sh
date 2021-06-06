#!/bin/bash

# This takes an indicator to produce either source or header and the
# name of file containing encoded CBOR and outputs a C static variable
# for the contents of the file


# The first argument is the operation type, either "source" or "header"
operation_type=$1

# The second argument is the file with encoded CBOR that is the input
cbor_input_file=$2


# Process the path name down to a variable name. If there is a
# directory name in the path, then that is prepended to the name. If
# not, then it is not prepended.

# Prefix all test with this
prefix="eat_test_"

f1=$(basename $cbor_input_file)
file=${f1%.*}

full_path=$(dirname $cbor_input_file)
last_path=$(basename $full_path)

if [[ $last_path == $full_path ]] ; then
    name=${prefix}$file
else
    name=${prefix}${last_path}_${file}
fi


if [[ $operation_type == source ]] ; then
    # Being asked to produce the source file, the one with the
    # contents of the CBOR file in a const variable. xxd does all the
    # work. It is necessary to pipe the file into xxd so this can
    # control the variable name.
    echo  "const unsigned char ${name}[] = {" 
    cat $cbor_input_file | xxd -i 
    echo "};"
    echo
else
    if [[ $operation_type == header ]] ; then
        # Being asked to produce the header file, the empty definition
        # of the variable. The size is included so the sizeof operator
        # works on it. Must pipe into wc so the file name is not in
        # the wc output
        size=`cat $cbor_input_file | wc -c | tr -d ' '`
        echo "extern const unsigned char ${name}[${size}];"
        echo
        echo
    else
	# Caller gave a bad operation_type
        exit -1
    fi
fi

