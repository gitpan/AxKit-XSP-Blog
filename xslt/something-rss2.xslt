<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
  version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rss="http://purl.org/rss/1.0/"
  xmlns:rss2="http://backend.userland.com/rss2"
  exclude-result-prefixes="xsl rdf rss rss2">

  <xsl:output method="html"/>

  <xsl:template match="rssfeed">
    <xsl:apply-templates select="subscriptions/rss" mode="rssfeed"/>
  </xsl:template>

  <xsl:template match="rss" mode="rssfeed">
    <div class="news">
      <xsl:apply-templates select="document(@href)/*">
        <xsl:with-param name="rssfeed-name" select="@name"/>
        <xsl:with-param name="rssfeed-url" select="@href"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>

  <!-- ============================================================== -->
  <!-- RSS 2.0 handling                                               -->
  <!-- ============================================================== -->

  <xsl:template match="rss2:rss">
    <xsl:apply-templates select="rss2:channel"/>
  </xsl:template>

  <xsl:template match="rss2:channel">
    <span class="newstitle">
      <img src="/images/box.gif"/>&#160;&#160;<a href="{rss2:link}"><xsl:value-of select="rss2:title"/></a>
    </span>
    <xsl:if test="count(rss2:item[rss2:title]) != 0">
      <ul class="newsitem">
        <xsl:apply-templates select="rss2:item"/>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template match="rss2:item">
    <xsl:choose>
      <xsl:when test="rss2:title">
        <li class="newsitem">
          <a href="{rss2:link}"><xsl:value-of select="rss2:title"/></a>
        </li>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- ============================================================== -->
  <!-- RSS 1.0 handling                                               -->
  <!-- ============================================================== -->

  <xsl:template match="rdf:RDF">
    <xsl:apply-templates select="rss:channel"/>
  </xsl:template>

  <xsl:template match="rss:channel">
    <div class="newstitle">
      <a href="{@rdf:about}"><xsl:value-of select="rss:title"/></a>
      <xsl:if test="string(description) != ''">
        - <xsl:value-of select="description"/>
      </xsl:if>
    </div>
    <xsl:if test="count(rss:items/rdf:Seq/rdf:li) != 0">
      <ul class="newsitem">
        <xsl:apply-templates select="rss:items/rdf:Seq/rdf:li"/>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template match="rdf:li">
    <xsl:variable name="resource" select="@rdf:resource"/>
    <li class="newsitem">
      <xsl:apply-templates select="/rdf:RDF/rss:item[@rdf:about = $resource]"/>
    </li>
  </xsl:template>

  <xsl:template match="rss:item">
    <a href="{@rdf:about}"><xsl:value-of select="rss:title"/></a>
  </xsl:template>

  <!-- ============================================================== -->
  <!-- RSS 0.92 handling                                              -->
  <!-- ============================================================== -->

  <xsl:template match="rss">
    <xsl:apply-templates select="channel"/>
  </xsl:template>

  <xsl:template match="channel">
    <span class="newstitle">
      <img src="/images/box.gif"/>&#160;&#160;<a href="{link}"><xsl:value-of select="title"/></a>
    </span>
    <xsl:if test="count(item[title]) != 0">
      <ul class="newsitem">
        <xsl:apply-templates select="item"/>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template match="item">
    <xsl:choose>
      <xsl:when test="title">
        <li class="newsitem">
          <a href="{link}"><xsl:value-of select="title"/></a>
        </li>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- ============================================================== -->
  <!-- Backslash (slashdot.org)                                       -->
  <!-- ============================================================== -->

  <xsl:template match="backslash">
    <xsl:param name="rssfeed-name"/>
    <div class="newstitle"><xsl:value-of select="$rssfeed-name"/></div>
    <!--
    <xsl:if test="$rssfeed/@id"><xsl:value-of select="$rssfeed/@id"/></xsl:if>
-->
    <ul class="newsitem">
      <xsl:apply-templates select="story"/>
    </ul>
  </xsl:template>

  <xsl:template match="story">
    <li class="newsitem">
      <a href="{url}"><xsl:value-of select="title"/></a>
    </li>
  </xsl:template>

  <!-- ============================================================== -->
  <!-- Everything else                                                -->
  <!-- ============================================================== -->

  <xsl:template match="@*|*|text()|processing-instruction()">
    <xsl:param name="rssfeed-name"/>
    <xsl:param name="rssfeed-url"/>

    <!-- Catch all template. This template is reached when we don't
    know how to handle a particular RSS feed. Just place the a link to
    the RSS feed using the name of the person here. -->
    <span class="newstitle">
      <img src="/images/box.gif"/>&#160;&#160;<a href="{$rssfeed-url}"><xsl:value-of select="$rssfeed-name"/></a>
    </span>

  </xsl:template>

</xsl:stylesheet>