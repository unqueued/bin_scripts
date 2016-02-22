#!/bin/sh

# @autogenerated_warning@
# @autogenerated_timestamp@
# @PACKAGE@ @VERSION@
# @PACKAGE_URL@

COPYRIGHT="
Copyright (C) 2012,2014 A. Gordon (assafgordon@gmail.com)
License: GPLv3+
"

##
## This script calculates how much disk space is used by each file type \
## (e.g. "txt", "fq")
##

die()
{
    BASE=$(basename -- "$0")
    echo "$BASE: error: $@" >&2
    exit 1
}

usage()
{
	BASE=$(basename $0)
	echo "
filetype_size_breakdown - Summarize disk-usage by file type.
Version: @VERSION@
$COPYRIGHT
See: @PACKAGE_URL@

Usage:
  $BASE
  $BASE [DIRECTORY]

Will print summary of disk usage by each file extension,
either in the current directory or in the specified directory.

Example:
 $BASE /tmp/
 txt	609.2K
 [no_extension]	179.3K
 pdf	53.8K
 png	4.0K
 ini	681
 log	379

"
    exit
}

SRC=$1
test -z "$SRC" && die "Missing directory name. See --help for details."
test "x$1" = "x-h" || test "x$1" = "x--help" && usage

test -d "$SRC" || die "'$SRC' is not a valid directory."

find -- "$SRC" -type f -printf "%f\t%s\n" |
	awk -v OFS="\t" -v FS="\t" '$1~/\./ { gsub(/.*\./,"",$1); print $1, $2 ; next }
	     { print "[no_extension]", $2 }' |
	sort -k1V,1 |
	groupBy -g 1 -o sum -c 2 |
	sort -k2nr,2 |
	human.py --div 1000 --col 2 |
	sed 's/  */\t/g'