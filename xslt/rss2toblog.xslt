<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"   version='1.0'
                xmlns:rss="http://backend.userland.com/rss2"
                xmlns="http://ns.it.bond.edu.au/xsp/blogs/v1"
  >

  <!--

       simple transformer from RSS 2.0 to Blog 1.0 (Version 0.1)

       Mon Sep 30 11:27:00 EST 2002: \rho: first setup

  -->

  <xsl:output indent="yes"/>

  <xsl:template match="/">
     <xblog>
       <head>
         <title><xsl:value-of select="/rss:rss/rss:channel/rss:title"/></title>
         <url><xsl:value-of select="/rss:rss/rss:channel/rss:link"/></url>
         <description><xsl:value-of select="/rss:rss/rss:channel/rss:description"/></description>
      </head>
      <blog>
        <xsl:for-each select="/rss:rss/rss:channel/rss:item">
          <day>
            <entry>
              <xsl:attribute name="date"><xsl:value-of select="./rss:pubDate"/></xsl:attribute> 
              <postDate><xsl:value-of select="./rss:pubDate"/></postDate>
              <authorName>
                <xsl:choose > 
                  <xsl:when test = "./author_name"><xsl:value-of select="./author_name"/></xsl:when> 
                  <xsl:when test = "$author_name"><xsl:value-of select="$author_name"/></xsl:when> 
                </xsl:choose> 
              </authorName>
              <authorEmail>
                <xsl:choose > 
                  <xsl:when test = "./author_email"><xsl:value-of select="./author_email"/></xsl:when> 
                  <xsl:when test = "$author_email"><xsl:value-of select="$author_email"/></xsl:when> 
                </xsl:choose> 
              </authorEmail>
              <title><xsl:value-of select="./rss:title"/></title>
              <url><xsl:value-of select="./rss:guid"/></url>
              <content><xsl:value-of select="./rss:description"/></content>
            </entry>
          </day>
        </xsl:for-each> 
      </blog>
     </xblog>
  </xsl:template>


</xsl:stylesheet>