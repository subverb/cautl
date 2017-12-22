#!/bin/bash

cd $(dirname $0)

. ../../lib/template.sh

parse_template < tmpltest
