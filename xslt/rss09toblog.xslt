<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"   version='1.0'
                xmlns:rss="http://my.netscape.com/rdf/simple/0.9/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns="http://ns.it.bond.edu.au/xsp/blogs/v1"
  >

  <!--

       simple transformer from RSS 0.9 to Blog 1.0 (Version 0.1)

       Mon Sep 30 11:27:00 EST 2002: \rho: first setup

  -->

  <xsl:output indent="yes"/>

  <xsl:template match="/">
     <xblog>
       <head>
         <title><xsl:value-of select="/rdf:RDF/rss:channel/rss:title"/></title>
         <url><xsl:value-of select="/rdf:RDF/rss:channel/rss:link"/></url>
         <description><xsl:value-of select="/rdf:RDF/rss:channel/rss:description"/></description>
      </head>
      <blog>
        <xsl:for-each select="/rdf:RDF/rss:item">
          <day>
            <entry>
              <xsl:attribute name="id">
                <xsl:choose > 
                  <xsl:when test = "./rss:pubDate" ><xsl:value-of select="./rss:pubDate"/></xsl:when> 
                  <xsl:when test = "./rss:link"><xsl:value-of select="./rss:link"/></xsl:when> 
                </xsl:choose> 
              </xsl:attribute>
              <title><xsl:value-of select="./rss:title"/></title>
              <url><xsl:value-of select="./rss:link"/></url>
              <content><xsl:value-of select="./rss:description"/></content>
            </entry>
          </day>
        </xsl:for-each> 
      </blog>
     </xblog>
  </xsl:template>


</xsl:stylesheet>