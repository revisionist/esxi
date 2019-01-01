#!/bin/sh

sourcedir=$1
targetdir=$2

if [ "X${sourcedir}" = "X" ]; then
  echo "Please specify a source directory! Syntax $0 <source dir> <target parent dir>"
  exit 1
fi

if [ "X${targetdir}" = "X" ]; then
  echo "Please specify a target directory! Syntax $0 <source dir> <target parent dir>"
  exit 1
fi

if [ ! -d "$sourcedir" ]; then
  echo "Source is not a directory: $sourcedir"
  exit 1
fi

if [ ! -d "$targetdir" ]; then
  echo "Target is not a directory: $targetdir"
  exit 1
fi

if [ ! -w "$targetdir" ]; then
  echo "Target is not writeable: $targetdir"
  exit 1
fi

if [ `ls -1 ${sourcedir}/*.lck 2>/dev/null | wc -l ` -gt 0 ]; then
  echo "Source contains one or more lock files!"
  exit 1
fi

oldwd=${PWD}
cd ${sourcedir}

sourcedirname=${PWD##*/}
cd ${oldwd}
targetsubdir="${targetdir}/${sourcedirname}"

echo "Target subdir: ${targetsubdir}"

if [ -d "$targetsubdir" ]; then
  echo "Target subdir already exists - taking no action: $targetsubdir"
  exit 1
fi

if [ -f "$targetsubdir" ]; then
  echo "Target subdir is a file!  Taking no action: $targetsubdir"
  exit 1
fi

cd ${sourcedir}

mkdir ${targetsubdir}

for i in `ls *.vmdk | grep -v flat\.vmdk`
do
  echo "Processing $i ..."
  targetfile="${targetsubdir}/${i}"
  vmkfstools -i ${i} ${targetfile} -d thin
done

cp -a `ls | egrep -v '.vmdk$'` ${targetsubdir}/

cd ${oldwd}
