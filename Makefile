# Documentation makefile
# WARNING: requires Pandoc, LaTeX (with pdf convertors and beamer) and xsltproc


targetDir=target
tocFile=src/book.xml
catTransFile=src/book-to-md.xsl
catFile=${targetDir}/catMd.sh
pdfFile=${targetDir}/doc.pdf

all:		pres-pdf book-pdf
targetdir:
		mkdir -p ${targetDir}

book-cat:	targetdir
		xsltproc ${catTransFile} ${tocFile} > ${catFile}
		chmod +x ${catFile}

book-pdf:	book-cat
		./${catFile} | pandoc  -f markdown+definition_lists+header_attributes -V papersize=a4paper -V urlcolor=black -V linkcolor=black -V links-as-notes=true --template=template.latex -V geometry:margin=1in --chapters --toc --number-sections -o ${pdfFile}

pres-pdf:	targetdir
		latexmk -pdf -jobname=${targetDir}/pres src/presentation/latex/pres.latex

clean:
		rm -f ${catFile}
		ls ${targetDir}/pres.* | grep -v "pres.pdf" | xargs -n1 rm -f

veryclean:
		rm -rf ${targetDir}
