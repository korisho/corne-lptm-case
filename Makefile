STL_DIR=stl
BUILD_DIR=.build

# match "module foobar() { // `make` me"
INCL=corne-lptm.scad case-shape.scad tent-shape.scad palmrest-shape.scad bento-shape.scad
BASE=$(shell sed '/^module [a-z0-9_-]*[(].*build=.*[)].*\/\/.*make.me.*$$/!d;s/module //;s/(.*).*//' ${INCL})
SRCS=$(BASE:%=${BUILD_DIR}/%.scad)
STLS=$(BASE:%=${STL_DIR}/%.stl)

all: ${STLS}

.PHONY: clean scad vars
vars:
	@echo "INCL=${INCL}"
	@echo "BASE=${BASE}"
	@echo "SRCS=${SRCS}"
	@echo "STLS=${STLS}"

# auto-generated .scad files with .deps make make re-build always. keeping the
# scad files solves this problem. (explanations are welcome.)
.SECONDARY: ${SRCS}

# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard ${BUILD_DIR}/*.deps)

${BUILD_DIR}/%.scad:
	@mkdir -p $(dir $@)
	@echo 'use <../$(shell grep -n "module $*[(].*build=.*[)]" ${INCL} | head -n 1 | sed "s/:.*//")>\n$*(build=true);' > $@
	@echo '=====[$@]====='
	@cat $@
	@echo ''

${STL_DIR}/%.stl: ${BUILD_DIR}/%.scad
	@mkdir -p $(dir $@)
	openscad -m make -o $@ -d ${BUILD_DIR}/$*.deps $<

scad : ${SRCS}

clean :
	-rm ${BUILD_DIR}/*.scad ${BUILD_DIR}/*.deps

# dependencies
bento.stl: case.stl
palmrest.stl: tent.stl case.stl
tent.stl: case.stl
case.stl: case_uncut.stl
case_uncut.stl: basic_shape_of_case.stl
