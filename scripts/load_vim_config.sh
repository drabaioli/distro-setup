#!/bin/bash

# Move to the dir where this script is
base_path=$( dirname $( readlink -f $0 ) )
cd $base_path

cp ../data/vimrc ~/.vimrc
