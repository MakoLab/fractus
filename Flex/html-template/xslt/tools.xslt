<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0">
  <xsl:template name="abs">
    <xsl:param name="n" />
    <xsl:choose>
      <xsl:when test="$n &gt;= 0">
        <xsl:value-of select="$n" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0 - $n" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="dataFormat">
    <xsl:param name="data" />
    <xsl:param name="form" />
    <xsl:choose>
      <xsl:when test="$form = 'decimal'">
        <xsl:value-of select="format-number($data, '0,##')" />
        <!--<xsl:value-of select="format-number($data, $decimal)"/>-->
      </xsl:when>
      <xsl:when test="$form = 'money'">
        <xsl:value-of select="format-number($data, '0,00')" />
        <!--<xsl:value-of select="format-number($data, $money)"/>-->
      </xsl:when>
      <xsl:when test="$form = 'percent'">
        <xsl:value-of select="format-number($data*0.01, '0,##%')" />
        <!--<xsl:value-of select="format-number($data, $percent)"/>-->
      </xsl:when>
      <xsl:when test="$form = 'date'">
        <xsl:value-of select="concat(substring($data,1,4), '-',substring($data,6,2), '-',substring($data,9,2))" />
      </xsl:when>
      <xsl:when test="$form = 'dateTime'">
        <xsl:value-of select="concat(substring($data,1,4), '-',substring($data,6,2), '-',substring($data,9,2), ' ',substring($data, 12,8))" />
      </xsl:when>
      <xsl:when test="$form = 'absMoney'">
        <xsl:variable name="absData">
          <xsl:call-template name="abs">
            <xsl:with-param name="n" select="$data" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="format-number($absData, '0,00')" />
        <!--<xsl:value-of select="format-number($data, $money)"/>-->
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="dataFormatDifferential">
    <xsl:param name="data" />
    <xsl:param name="form" />
    <xsl:choose>
      <xsl:when test="$form = 'decimal'">
        <xsl:choose>
          <xsl:when test="$data = 0">0</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="format-number($data, '+0,##;-0,##')" />
            <!--<xsl:value-of select="format-number($data, $decimal)"/>-->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$form = 'money'">
        <xsl:choose>
          <xsl:when test="$data = 0">0,00</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="format-number($data, '+0,00;-0,00')" />
            <!--<xsl:value-of select="format-number($data, $money)"/>-->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$form = 'percent'">
        <xsl:choose>
          <xsl:when test="$data = 0">0%</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="format-number($data, '+0,##%;-0,##%')" />
            <!--<xsl:value-of select="format-number($data, $percent)"/>-->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$form = 'date'">
        <xsl:value-of select="concat(substring($data,1,4), '-',substring($data,6,2), '-',substring($data,9,2))" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="WordValue">
    <xsl:param name="printSettings" select="/*" />
    <xsl:param name="value" />
    <xsl:param name="minorUnit" select="''" />
    <xsl:param name="majorUnit" select="''" />
    <xsl:param name="unit" select="$majorUnit" />
    <xsl:param name="pvalue" select="1" />
    <xsl:choose>
      <xsl:when test="$printSettings/wordValueConfig/@mode = 'simple'">
        <xsl:call-template name="SimpleWordValue">
          <xsl:with-param name="value" select="$value" />
          <xsl:with-param name="printSettings" select="$printSettings" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$value &lt; 0">
        <xsl:value-of select="$printSettings/wordValueConfig/word[@value = -1]/@tag" />
        <xsl:text> </xsl:text>
        <xsl:call-template name="WordValue">
          <xsl:with-param name="printSettings" select="$printSettings" />
          <xsl:with-param name="value" select="-$value" />
          <xsl:with-param name="majorUnit" select="$majorUnit" />
          <xsl:with-param name="minorUnit" select="$minorUnit" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$unit = $majorUnit and $majorUnit != ''">
        <xsl:call-template name="WordValue">
          <xsl:with-param name="printSettings" select="$printSettings" />
          <xsl:with-param name="value" select="floor($value)" />
          <xsl:with-param name="pvalue" select="$pvalue" />
          <xsl:with-param name="unit" select="$majorUnit" />
        </xsl:call-template>
        <xsl:call-template name="WordValue">
          <xsl:with-param name="printSettings" select="$printSettings" />
          <xsl:with-param name="value" select="round(100 * ($value - floor($value)))" />
          <xsl:with-param name="pvalue" select="$pvalue" />
          <xsl:with-param name="unit" select="$minorUnit" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$value = 0 and $pvalue = 1">
          <xsl:value-of select="$printSettings/wordValueConfig/word[@value = 0]/@tag" />
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="$value &gt; 0">
          <xsl:variable name="modvalue" select="$value mod 1000" />
          <xsl:call-template name="WordValue">
            <xsl:with-param name="printSettings" select="$printSettings" />
            <xsl:with-param name="value" select="floor($value div 1000)" />
            <xsl:with-param name="pvalue" select="$pvalue * 1000" />
          </xsl:call-template>
          <xsl:variable name="dnode" select="$printSettings/wordValueConfig/word[@value &lt;= $modvalue][last()]" />
          <xsl:if test="$dnode">
            <xsl:if test="$dnode/@value &gt; 0">
              <xsl:value-of select="$dnode/@tag" />
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:if>
          <xsl:call-template name="WordValue">
            <xsl:with-param name="printSettings" select="$printSettings" />
            <xsl:with-param name="value" select="$modvalue - $dnode/@value" />
            <xsl:with-param name="pvalue" select="0" />
          </xsl:call-template>
          <xsl:if test="$pvalue &gt; 1">
            <xsl:variable name="variant">
              <xsl:choose>
                <xsl:when test="$modvalue = 0" />
                <xsl:when test="$modvalue mod 100 &gt;= 5 and $modvalue mod 100 &lt;= 20">3</xsl:when>
                <xsl:when test="$modvalue mod 10 = 1 and $modvalue != 1">3</xsl:when>
                <xsl:when test="$modvalue mod 10 = 1">1</xsl:when>
                <xsl:when test="$modvalue mod 100 = 0">3</xsl:when>
                <xsl:when test="$modvalue mod 10 &lt;= 4">2</xsl:when>
                <xsl:otherwise>3</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="tag" select="$printSettings/wordValueConfig/word[@value = $pvalue and @variant = $variant]/@tag" />
            <xsl:if test="$tag">
              <xsl:value-of select="$tag" />
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:if>
        </xsl:if>
        <xsl:if test="$pvalue = 1 and $unit">
          <xsl:variable name="variant">
            <xsl:choose>
              <xsl:when test="$value = 0">3</xsl:when>
              <xsl:when test="$value mod 100 &gt;= 5 and $value mod 100 &lt;= 20">3</xsl:when>
              <xsl:when test="$value mod 10 = 1 and $value != 1">3</xsl:when>
              <xsl:when test="$value mod 10 = 1">1</xsl:when>
              <xsl:when test="$value mod 100 = 0">3</xsl:when>
              <xsl:when test="$value mod 10 &lt;= 4">2</xsl:when>
              <xsl:otherwise>3</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="unitTag" select="$printSettings/wordValueConfig/unit[@name = $unit and @variant = $variant]/@tag" />
          <xsl:if test="$unitTag and $pvalue=1">
            <xsl:value-of select="$unitTag" />
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:if test="not($unitTag) and $value &gt; 0">
            <xsl:value-of select="$unit" />
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="SimpleWordValue">
    <xsl:param name="value" />
    <xsl:param name="printSettings" select="/*" />
    <xsl:variable name="divValue" select="floor($value div 10)" />
    <xsl:variable name="modValue" select="floor($value mod 10)" />
    <xsl:choose>
      <xsl:when test="$value &lt; 0">
        <xsl:value-of select="$printSettings/wordValueConfig/word[@value=-1]/@tag" />
        <xsl:value-of select="$printSettings/wordValueConfig/@separator" />
        <xsl:call-template name="SimpleWordValue">
          <xsl:with-param name="value" select="-$value" />
          <xsl:with-param name="printSettings" select="$printSettings" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$divValue &gt; 0">
        <xsl:call-template name="SimpleWordValue">
          <xsl:with-param name="value" select="$divValue" />
          <xsl:with-param name="printSettings" select="$printSettings" />
        </xsl:call-template>
        <xsl:value-of select="$printSettings/wordValueConfig/@separator" />
      </xsl:when>
    </xsl:choose>
    <xsl:if test="not($value &lt; 0)">
      <xsl:value-of select="$printSettings/wordValueConfig/word[@value=$modValue]/@tag" />
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>