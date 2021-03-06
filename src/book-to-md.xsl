<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
	<xsl:output method="text" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="chapter">
		echo
		echo "# <xsl:value-of select="title"/>"
		echo
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="section">
		echo
		cat src/book/markdown/<xsl:value-of select="id"/>.md
		echo
	</xsl:template>

	<xsl:template match="book">
		cat src/book/markdown/_info.md
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="chapters">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="sections">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="id"/>
	<xsl:template match="title"/>
	<xsl:template match="author"/>

</xsl:stylesheet>
