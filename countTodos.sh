#!/bin/bash
MD_DIR=src/book/markdown
TODO_MARK="TODO"

for x in `ls $MD_DIR`; do
	todoCnt="`cat $MD_DIR/$x | grep \"${TODO_MARK}\" | wc -l`"
	echo "- [${todoCnt}]	\`${x}\`"
done
