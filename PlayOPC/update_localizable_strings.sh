#!/bin/sh
#
# update_localizable_strings.sh - automatically extract translatable strings from source code and update strings files
# 

if [ ! `which python3` ]; then
    echo "python3 is not installed."
    exit 1
fi

stringsFile="Localizable.strings"
stringsExt=".strings"
oldStringsExt=".strings.old"
workDir="/tmp/update_localizable_string"

oldIFS=$IFS
IFS=$'\n'

echo "Extracting strings from source code"
mkdir -p $workDir
genstrings -u -q -o $workDir *.m
oldStringsFile=$(echo "$stringsFile" | sed "s/$stringsExt/$oldStringsExt/")
mv $workDir/$stringsFile $workDir/$oldStringsFile
iconv -f UTF-16 -t UTF-8 $workDir/$oldStringsFile > $workDir/$stringsFile

for stringPath in `find . -name "$stringsFile" -print`
do
    echo "Update $stringPath"
    oldStringsPath=$(echo "$stringPath" | sed "s/$stringsExt/$oldStringsExt/")
    mv $stringPath $oldStringsPath
    python3 update_localizable_strings.py $workDir/$stringsFile $oldStringsPath > $stringPath
    rm $oldStringsPath
done

rm -fr $workDir

IFS=$oldIFS
