#!/bin/bash

set -e

pushd lib 
sed -ne '/^\s/{s/\s*//;s/\s*\\$//;p}' < Makefile.am | sort > .installed
find * -type f -o -type l | grep -v Makefile | sort > .present
if cmp .present .installed; then
	exit 0
fi
diff -U 0 .present .installed | grep -v "^@@"
exit 1
