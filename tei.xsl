<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="1.0">
  <xsl:preserve-space elements="*"/>
  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes"/>

  <!--
    The primary language of the document we're rendering. Used to
    render Greek fonts if we need to.
  -->
  <xsl:param name="lang" select="'en'" />

  <xsl:template name="language-filter">
    <xsl:param name="lang" />
    <xsl:param name="default" select="''" />

    <xsl:choose>
      <xsl:when test="$lang='la'">
        <span class="la"><xsl:apply-templates /></span>
      </xsl:when>
      <xsl:when test="$lang='lat'">
        <span class="la"><xsl:apply-templates /></span>
      </xsl:when>
      <xsl:when test="$lang='latin'">
        <span class="la"><xsl:apply-templates /></span>
      </xsl:when>
      <xsl:when test="$lang='gk'">
        <span class="greek"><xsl:apply-templates /></span>
      </xsl:when>
      <xsl:when test="$lang='greek'">
        <span class="greek"><xsl:apply-templates /></span>
      </xsl:when>
      <xsl:when test="$lang='el'">
        <span class="greek"><xsl:apply-templates /></span>
      </xsl:when>
      <xsl:when test="$lang='it'">
        <span class="it"><xsl:apply-templates /></span>
      </xsl:when>
      <xsl:when test="$lang='ar'">
        <span class="ar"><xsl:apply-templates /></span>
      </xsl:when>
      <xsl:when test="$lang='en'">
        <span class="en"><xsl:apply-templates /></span>
      </xsl:when>
      <xsl:when test="$default != ''">
	<span class="{$default}"><xsl:apply-templates /></span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates /> 
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!--
	My main html structure with css included.
-->

<xsl:template match="/">
	<html><head>
		<title>Lewis and Short</title>
	<style type="text/css">
		body{font: 14px; font-family: Georgia,Times,serif;}
		
		div.lex_sense {
		    margin-top: 3px;
		    margin-bottom: 3px;
		}

		div.lex_sense1 {
		    margin: 10px auto;
		}
		div.lex_sense2 { margin-left: 15px; }
		div.lex_sense3 { margin-left: 30px; }
		div.lex_sense4,div.lex_sense5 { margin-left: 45px; }
		
		div.la, div.text_container span.la,
		div.en, div.text_container span.en,
		div.non, div.text_container span.non,
		div.ang, div.text_container span.ang {
		    font-family: Georgia,Times,serif;
		}
		
		a:link{
			font-weight: normal;
		}
	</style>
	</head>
	<body><xsl:apply-templates /></body>
	</html>
</xsl:template>

  <!--
    For lexicon entries, "sourcework" represents the document containing the
    word that we're looking up, in ABO format, "sourcesub" the subquery.
    This allows us to give special treatment to lexicon citations that point
    back to the work we came from, and perhaps even more special treatment
    to citations that point to the specific passage we came from.
  -->
  <xsl:param name="sourcework" select="''" />
  <xsl:param name="sourcesub" select="0" />

  <xsl:template match="sense[@level]">
    <div class="lex_sense lex_sense{@level}">
      <xsl:if test="not(@n='')">
        <b><xsl:value-of select="@n"/>. 
	    </b>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </div>
  </xsl:template>

  <xsl:template match="sense[@n=0]">
    <div class="lex_sense">
        <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="sense">
    <div class="lex_sense">
        <xsl:if test="not(@n='')">
           <b><xsl:value-of select="@n"/>. 
	    </b>
        </xsl:if>
        <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="orth|form/orth">
    <b><xsl:call-template name="language-filter">
      <xsl:with-param name="lang" select="@lang" />
    </xsl:call-template></b><xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="usg">
    <b><xsl:call-template name="language-filter">
      <xsl:with-param name="lang" select="@lang" />
    </xsl:call-template></b>
  </xsl:template>

<!-- There are a handful of these, but they are empty;
however, I'm not really sure that this does anything/is needed. -->
  <xsl:template match="figure">
	<xsl:apply-templates />
  </xsl:template>

  <xsl:template match="etym">
    <xsl:call-template name="language-filter">
      <xsl:with-param name="lang" select="@lang" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="hi[@rend='center']">
    <center><xsl:value-of select="."/></center>
  </xsl:template>

  <xsl:template match="hi[@rend='ital' or @rend='italics']">
    <xsl:if test="text() or child::*">
	<i><xsl:value-of select="."/></i> 
    </xsl:if>
  </xsl:template>

  <xsl:template match="tr|trans/tr">
    <i><xsl:value-of select="."/></i> 
  </xsl:template>

  <xsl:template match="p">
      <xsl:apply-templates /><p/>
  </xsl:template>

  <xsl:template match="bibl[parent::cit]">
    <xsl:text> </xsl:text>
    <xsl:call-template name="bibl-link"/>
  </xsl:template>

  <xsl:template match="bibl">
    <xsl:call-template name="bibl-link"/>
  </xsl:template>

  <xsl:template name="bibl-link">
    <xsl:choose>
        <xsl:when test="not(@n) and . = ''"></xsl:when>
	<xsl:when test="not(@valid)">
	    <i><xsl:call-template name="language-filter">
              <xsl:with-param name="lang" select="@lang" />
	      <xsl:with-param name="default" select="'en'" />
            </xsl:call-template></i>
	</xsl:when>
	<xsl:when test="@n=concat($sourcework,':',$sourcesub)">
	    <span style="font-size: x-large;"><a href="http://www.perseus.tufts.edu/hopper/text.jsp?doc={@n}&amp;lang=original"><xsl:call-template name="language-filter">
              <xsl:with-param name="lang" select="@lang" />
	      <xsl:with-param name="default" select="'en'" />
            </xsl:call-template></a></span>
	</xsl:when>
      <xsl:when test="@n and $sourcework != 'none' and starts-with(@n, $sourcework)">
	  <b><a href="http://www.perseus.tufts.edu/hopper/text.jsp?doc={@n}&amp;lang=original"><xsl:call-template name="language-filter">
            <xsl:with-param name="lang" select="@lang" />
	    <xsl:with-param name="default" select="'en'" />
          </xsl:call-template></a></b>
      </xsl:when>
      <xsl:when test="@n">
	  <a href="http://www.perseus.tufts.edu/hopper/text.jsp?doc={@n}&amp;lang=original">
	    <xsl:call-template name="language-filter">
            <xsl:with-param name="lang" select="@lang" />
	    <xsl:with-param name="default" select="'en'" />
          </xsl:call-template>
	  </a>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="language-filter">
          <xsl:with-param name="lang" select="@lang" />
	  <xsl:with-param name="default" select="'en'" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ref[@target!='']">
    <a href="http://www.perseus.tufts.edu/hopper/text.jsp?doc={$document_id}:id={@target}"><xsl:call-template name="language-filter">
      <xsl:with-param name="lang" select="@lang" />
    </xsl:call-template></a>
  </xsl:template>

  <xsl:template match="//ref[@lang!='']">
  	<xsl:call-template name="language-filter">
		<xsl:with-param name="lang" select="@lang"/>
	</xsl:call-template>	
  </xsl:template>

 <xsl:template match="quote|q">


   <xsl:choose>
     <xsl:when test="@rend[contains(.,'blockquote')]">
      <blockquote><xsl:call-template name="language-filter">
      <xsl:with-param name="lang" select="@lang" />
    </xsl:call-template></blockquote>
      </xsl:when>
     <xsl:otherwise>

       <xsl:choose>
	 <xsl:when test="parent::cit and ancestor::quote">
		<xsl:apply-templates />
	 </xsl:when>
	 <xsl:otherwise>

	   <xsl:choose>
	     <xsl:when test="self::quote">
	       <xsl:text>&#x201C;</xsl:text>
	     </xsl:when>
	     <xsl:otherwise>
	       <xsl:text>&#x2018;</xsl:text>
	     </xsl:otherwise>
	 </xsl:choose>


       <xsl:call-template name="language-filter">
         <xsl:with-param name="lang" select="@lang" />
       </xsl:call-template>
 
       <xsl:choose>
	 <xsl:when test="parent::cit and ancestor::quote">
	 </xsl:when>
	 <xsl:otherwise>
	   <xsl:choose>
	     <xsl:when test="self::quote">
	       <xsl:text>&#x201D;</xsl:text>
	     </xsl:when>
	     <xsl:otherwise>
	       <xsl:text>&#x2019;</xsl:text>
	     </xsl:otherwise>
	   </xsl:choose>


	 </xsl:otherwise>
       </xsl:choose>
  	 </xsl:otherwise>
       </xsl:choose>
    

       </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="foreign">
    <xsl:call-template name="language-filter">
      <xsl:with-param name="lang" select="@lang" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="itype">
    <xsl:call-template name="language-filter">
      <xsl:with-param name="lang" select="@lang" />
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
