<?xml version="1.0" encoding="utf-8" ?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 <xsl:import href="tools.xslt"/> 
 <xsl:output method="html" encoding="UTF-8"/>
 <xsl:decimal-format decimal-separator="," grouping-separator=" "/>
  <xsl:template match="*" >
   <xsl:variable name="this" select="."/>
   <xsl:variable name="config" select="document('commercialDocumentConfig.xml')/*/profile/configuration"/>
    <html >
      <head>
        <meta http-equiv="content-type" content="text/xhtml; charset=UTF-8"/>
      </head>
      <body>
      <div style="margin: 10px;width:21cm">
          
        <div style="float:right;width:50%">
            <div> <!--IssuePlace-->
				      <span style="float:left;text-align:right; width:45%; font-size:{$config/globalSettings/@font-size};font-family:{$config/globalSettings/@font-family};font-weight:{$config/globalSettings/@font-weight};color:{$config/globalSettings/@color}">
					      <xsl:value-of select="$config/labels/issuePlace"/>
	            </span>
				      <span style="float:right; width:45%;font-size:{$config/topLabelsSettings/@font-size}; font-weight:{$config/topLabelsSettings/@font-weight};color:{$config/topLabelsSettings/@color};font-style:{$config/topLabelsSettings/@font-style}">
					      <xsl:value-of select="issuePlaceId/@label"/>
				      </span>
			      </div>
            <div> <!--issue date-->
				      <span style="float:left;text-align:right; width:45%; font-size:{$config/globalSettings/@font-size};font-family:{$config/globalSettings/@font-family};font-weight:{$config/globalSettings/@font-weight};color:{$config/globalSettings/@color}">
				      	<xsl:value-of select="$config/labels/issueDate"/>
	            </span>
				      <span style="float:right; width:45%;font-size:{$config/topLabelsSettings/@font-size}; font-weight:{$config/topLabelsSettings/@font-weight};color:{$config/topLabelsSettings/@color};font-style:{$config/topLabelsSettings/@font-style}">
					      <xsl:call-template name="dataFormat">
						      <xsl:with-param name="data" select="issueDate"/>
						      <xsl:with-param name="form" select="'date'"/>
					      </xsl:call-template>
				      </span>
			      </div>
			      <div> <!--event date -->
				      <span style="float:left;text-align:right; width:45%; font-size:{$config/globalSettings/@font-size};font-family:{$config/globalSettings/@font-family};font-weight:{$config/globalSettings/@font-weight};color:{$config/globalSettings/@color}">
					      <xsl:value-of select="$config/labels/eventDate"/>
	            </span>
				      <span style="float:right; width:45%;font-size:{$config/topLabelsSettings/@font-size}; font-weight:{$config/topLabelsSettings/@font-weight};color:{$config/topLabelsSettings/@color};font-style:{$config/topLabelsSettings/@font-style}">
				        <xsl:call-template name="dataFormat">
					      <xsl:with-param name="data" select="eventDate"/>
					      <xsl:with-param name="form" select="'date'"/>
				        </xsl:call-template>
				      </span>
			       </div>
        </div>
		    <div style="float:left;width:50%">
				<xsl:if test="$config/header">
					<span style="color:{$config/headerSettings/@color}; font-weight:{$config/headerSettings/@font-weight}; font-size:{$config/headerSettings/@font-size}; font-style:{$config/headerSettings/@font-style};">
						<xsl:copy-of select="$config/header/*" />
					</span>
				</xsl:if>
			</div>

        <!--full Number-->
        <div style="width:100% ;text-align:center;float:left;font-size:{$config/fullNumberSettings/@font-size}; color:{$config/fullNumberSettings/@color}; font-weight:{$config/fullNumberSettings/@font-weight}; font-style:{$config/fullNumberSettings/@font-style}">
          <xsl:value-of select="documentTypeId/@label"/>&#160;<xsl:value-of select="number/fullNumber"/>
        </div>
        <br/>
        <br/>
        <!--issuer; contractor-->
		    <div style="width:100%">
			      <span style="float:left;width:45%; "> <!--issuer-->
				      <span style="float:left;text-align:right; width:45%;color:{$config/topLabelsSettings/@color}; font-weight:{$config/topLabelsSettings/@font-weight}; font-size:{$config/topLabelsSettings/@font-size}; font-style:{$config/topLabelsSettings/@font-style}">
					      <xsl:value-of select="$config/labels/issueContractor"/>
	            </span>
				      <span style="float:right; width:45%;color:{$config/topInformationSettings/@color}; font-weight:{$config/topInformationSettings/@font-weight}; font-size:{$config/topInformationSettings/@font-size}; font-style:{$config/topInformationSettings/@font-style}">
					      <xsl:value-of select="issuer/contractor/fullName"/><br/>
					      <xsl:value-of select="issuer/contractor/addresses/address[id = ../../../addressId]/address"/><br/>
					      <xsl:value-of select="issuer/contractor/addresses/address[id = ../../../addressId]/postCode"/>&#13;
					      <xsl:value-of select="issuer/contractor/addresses/address[id = ../../../addressId]/city"/><br/>
					      <xsl:if test="contractor/contractor/nip!=''">
						      <xsl:value-of select="$config/labels/nip"/>&#13;
						      <xsl:value-of select="issuer/contractor/nip"/><br/>
					      </xsl:if>
				      </span>
			      </span>
			      <span style="float:right;width:45%;"> <!--contractor-->
			        <xsl:if test="contractor">
				        <span style="float:left;text-align:right; width:45%;color:{$config/topLabelsSettings/@color}; font-weight:{$config/topLabelsSettings/@font-weight}; font-size:{$config/topLabelsSettings/@font-size}; font-style:{$config/topLabelsSettings/@font-style}">
					       <xsl:value-of select="$config/labels/contractor"/>
	              </span>
				        <span style="float:right; width:45%;color:{$config/topInformationSettings/@color}; font-weight:{$config/topInformationSettings/@font-weight}; font-size:{$config/topInformationSettings/@font-size}; font-style:{$config/topInformationSettings/@font-style}">
					        <xsl:value-of select="contractor/contractor/fullName"/><br/>
					        <xsl:value-of select="contractor/contractor/addresses/address[id = ../../../addressId]/address"/><br/>
					        <xsl:value-of select="contractor/contractor/addresses/address[id = ../../../addressId]/postCode"/>&#13;
					        <xsl:value-of select="contractor/contractor/addresses/address[id = ../../../addressId]/city"/><br/>
					        <xsl:if test="contractor/contractor/nip!=''">
						        <xsl:value-of select="$config/labels/nip"/>&#13;
						         <xsl:value-of select="contractor/contractor/nip"/>
					        </xsl:if>
			          </span>
			        </xsl:if>
			      </span>
		    </div>

		    <div style="width:100%;float:left;padding-top: 10pt;"> <!--table Item-->
          <table  style="border:{$config/linesTableColumns/@border};border-collapse:collapse" >
            <tr >
              <xsl:for-each select="$config/linesTableColumns/column">
                <td style="border:{../@border}; text-align:{@text-align-header}; font-weight:{@font-weight-header}; font-style:{@font-style-header}; color:{@color-header}">
                  <xsl:value-of select="@header"/>
                </td>
              </xsl:for-each>
            </tr>
            <xsl:for-each select="lines/line">
              <tr >
                <xsl:variable name="rowNumber">
                  <xsl:value-of select="position()"/>
                </xsl:variable>
                <xsl:for-each select="$config/linesTableColumns/column">
                  <xsl:variable name="node">
                    <xsl:value-of select="@node"/>
                  </xsl:variable>
                  <xsl:variable name="attribute">
                    <xsl:value-of select="@attribute"/>
                  </xsl:variable>
                  <xsl:variable name="data">
                    <xsl:choose>
                      <xsl:when test="boolean(@attribute)">
                        <xsl:value-of select="$this/lines/line[position() = $rowNumber]/*[name(.) = $node]/@*[name(.) = $attribute]"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="$this/lines/line[position() = $rowNumber]/*[name(.) = $node]"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <td  style="border:{../@border};text-align:{@text-align}; font-weight:{@font-weight};line-height:{../@line-height}; font-style:{@font-style}; color:{@color}">
                    <xsl:choose>
                      <xsl:when test="boolean(@dataFormat)">
                        <xsl:call-template name="dataFormat">
                          <xsl:with-param name="data" select="$data"/>
                          <xsl:with-param name="form" select="@dataFormat"/>
                        </xsl:call-template>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="$data"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </td>
                </xsl:for-each>
              </tr>
            </xsl:for-each>
          </table>		  
		  </div>
        
        
		  <div style="width:100%;float:left">  <!--table vat-->
       <br/>
       <br/>
		   <table style="border:{$config/vatTableColumns/@border};float:right;border-collapse:collapse" >
			    <tr>
			      <xsl:for-each select="$config/vatTableColumns/column">
			        <td style="border:{../@border}; text-align:{@text-align-header}; font-weight:{@font-weight-header}; font-style:{@font-style-header}; color:{@color-header}">
				        <xsl:value-of select="@header"/>
			        </td>
			      </xsl:for-each>
			    </tr>
			    <tr>
				    <xsl:variable name="rowNumber">
					     <xsl:value-of select="1"/>
				    </xsl:variable>
				    <xsl:for-each select="$config/vatTableColumns/column">
					    <xsl:variable name="node">
						    <xsl:value-of select="@node"/>
					    </xsl:variable>
					    <xsl:variable name="attribute">
						    <xsl:value-of select="@attribute"/>
					    </xsl:variable>
              <xsl:variable name="data">
                <xsl:choose>
                  <xsl:when test="boolean(@attribute)">
                    <xsl:value-of select="$this/vatTable/vtEntry[position() = $rowNumber]/*[name(.) = $node]/@*[name(.) = $attribute]"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$this/vatTable/vtEntry[position() = $rowNumber]/*[name(.) = $node]"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
					    <td style="border:{../@border}; text-align:{@text-align}; font-weight:{@font-weight}; line-height:{../@line-height}; font-style:{@font-style}; color:{@color}">
                <xsl:choose>
                  <xsl:when test="boolean(@dataFormat)">
                    <xsl:call-template name="dataFormat">
                      <xsl:with-param name="data" select="$data"/>
                      <xsl:with-param name="form" select="@dataFormat"/>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$data"/>
                  </xsl:otherwise>
                </xsl:choose>
					     </td>
					  </xsl:for-each>
				  </tr>	 
		   </table>
		  </div>
       
		  <div style="width:100%;float:left"> <!--payment-->
			  <span style="width:25%;color:{$config/grossValueLabelSettings/@color}; font-weight:{$config/grossValueLabelSettings/@font-weight}; font-size:{$config/grossValueLabelSettings/@font-size}; font-style:{$config/grossValueLabelSettings/@font-style}">
				  <xsl:value-of select="$config/labels/grossValue"/>
			  </span>
			  <span style="width:25%; color:{$config/grossValueInformationSettings/@color}; font-weight:{$config/grossValueInformationSettings/@font-weight}; font-size:{$config/grossValueInformationSettings/@font-size}; font-style:{$config/grossValueInformationSettings/@font-style}" >
			    <xsl:call-template name="dataFormat">
				  <xsl:with-param name="data" select="grossValue"/>
				  <xsl:with-param name="form" select="'money'"/>
			    </xsl:call-template>&#13;
			     <xsl:value-of select="payments/payment/paymentCurrencyId/@symbol"/>
			  </span>
		  </div>

        <!--payment wordValue-->
        <!--<div style="width:100%;float:left;">
			  <span  style="width:25%;color:{$config/labelsSettings/@color}; font-weight:{$config/labelsSettings/@font-weight}; font-size:{$config/labelsSettings/@font-size}; font-style:{$config/labelsSettings/@font-style}"  >
				 <xsl:value-of select="$config/labels/wordValue"/>
			  </span>
			  <span  style="width:25%;color:{$config/informationSettings/@color}; font-weight:{$config/informationSettings/@font-weight}; font-size:{$config/informationSettings/@font-size}; font-style:{$config/informationSettings/@font-style}"  >
				  <xsl:call-template name="WordValue">
					  <xsl:with-param name="value" select="grossValue"/>
					  <xsl:with-param name="majorUnit" select="payments/payment/paymentCurrencyId/@symbol"/>
					  <xsl:with-param name="minorUnit" select="concat(payments/payment/paymentCurrencyId/@symbol,'/100')"/>
			    </xsl:call-template>
			  </span>
		  </div>-->
		  <div style="width:45%;float:left;padding-top: 20pt;"> <!--payment form-->
			  <span style="width:45%;float:left;color:{$config/labelsSettings/@color}; font-weight:{$config/labelsSettings/@font-weight}; font-size:{$config/labelsSettings/@font-size};font-style:{$config/labelsSettings/@font-style}" > 
			    <xsl:value-of select="$config/labels/paymentMethod"/>
			  </span>
			  <span  style="width:45%;float:right;color:{$config/informationSettings/@color}; font-weight:{$config/informationSettings/@font-weight};font-size:{$config/informationSettings/@font-size}; font-style:{$config/informationSettings/@font-style}">
			    <xsl:value-of select="payments/payment/paymentMethodId/@label"/>
		  	</span>
		  </div>
		  <div style="width:45%;float:right;padding-top: 20pt;">
			  <span style="width:45%;float:left;color:{$config/labelsSettings/@color}; font-weight:{$config/labelsSettings/@font-weight}; font-size:{$config/labelsSettings/@font-size};font-style:{$config/labelsSettings/@font-style}" > 
			    <xsl:value-of select="$config/labels/dueDate"/>
			  </span>
			  <span  style="width:45%;float:right;color:{$config/informationSettings/@color}; font-weight:{$config/informationSettings/@font-weight};font-size:{$config/informationSettings/@font-size}; font-style:{$config/informationSettings/@font-style}">
			    <xsl:call-template name="dataFormat">
				    <xsl:with-param name="data" select="payments/payment/dueDate"/>
				    <xsl:with-param name="form" select="'date'"/>
				  </xsl:call-template>
			  </span>
		  </div>
		  <div style="width:45%;float:left;padding-top: 20pt;"> <!--paid-->
			  <span style="width:45%;float:left;color:{$config/labelsSettings/@color}; font-weight:{$config/labelsSettings/@font-weight}; font-size:{$config/labelsSettings/@font-size};font-style:{$config/labelsSettings/@font-style}" > 
			     <xsl:value-of select="$config/labels/paid"/>
			  </span>
			  <span  style="width:45%;float:right ;color:{$config/informationSettings/@color}; font-weight:{$config/informationSettings/@font-weight};font-size:{$config/informationSettings/@font-size}; font-style:{$config/informationSettings/@font-style}">
			    <xsl:call-template name="dataFormat">
				    <xsl:with-param name="data" select="sum(payments/payment/amount[../paymentMethodId/@isIncrementingDueAmount = 0])"/>
				    <xsl:with-param name="form" select="'money'"/>
			    </xsl:call-template> &#13;
			    <xsl:value-of select="payments/payment/paymentCurrencyId/@symbol"/>
			  </span>
		  </div>
		  <div style="width:45%;float:right;padding-top: 20pt;"> <!--topaid-->
        <span style="width:45%;float:left;color:{$config/labelsSettings/@color}; font-weight:{$config/labelsSettings/@font-weight}; font-size:{$config/labelsSettings/@font-size};font-style:{$config/labelsSettings/@font-style}" > 
			     <xsl:value-of select="$config/labels/toPay"/>
			  </span>
			  <span  style="width:45%;float:right;color:{$config/informationSettings/@color}; font-weight:{$config/informationSettings/@font-weight};font-size:{$config/informationSettings/@font-size}; font-style:{$config/informationSettings/@font-style}">
			    <xsl:call-template name="dataFormat">
				    <xsl:with-param name="data" select="sum(payments/payment/amount[../paymentMethodId/@isIncrementingDueAmount = 1])"/>
				    <xsl:with-param name="form" select="'money'"/>
			    </xsl:call-template>&#13;
			    <xsl:value-of select="payments/payment/paymentCurrencyId/@symbol"/>
			  </span>
		  </div>

		  <div style="width:45%;float:left;padding-top: 20pt;"> <!-- issuing person-->
			  <span style="width:45%;float:left;color:{$config/labelsSettings/@color}; font-weight:{$config/labelsSettings/@font-weight}; font-size:{$config/labelsSettings/@font-size};font-style:{$config/labelsSettings/@font-style}" > 
			     <xsl:value-of select="$config/labels/issuingPerson"/>
			  </span>
			  <span  style="width:45%;float:right;color:{$config/informationSettings/@color}; font-weight:{$config/informationSettings/@font-weight};font-size:{$config/informationSettings/@font-size}; font-style:{$config/informationSettings/@font-style}">
			    <xsl:value-of select="issuingPerson/contractor/fullName"/>
			  </span>
		  </div>
		  <div style="width:45%;float:right;padding-top: 20pt;">
			  <span style="width:45%;float:left;color:{$config/labelsSettings/@color}; font-weight:{$config/labelsSettings/@font-weight}; font-size:{$config/labelsSettings/@font-size};font-style:{$config/labelsSettings/@font-style}" > 
			    <xsl:value-of select="$config/labels/received"/>
			  </span>
			  <span  style="width:45%;float:right;color:{$config/informationSettings/@color}; font-weight:{$config/informationSettings/@font-weight};font-size:{$config/informationSettings/@font-size}; font-style:{$config/informationSettings/@font-style}">
				  <xsl:value-of select="receivingPerson/contractor/fullName"/>
			  </span>
		  </div>
        <div style="float:left;width:100%;padding-top: 20pt;">
		      <div style="width:45%;float:left;padding-top: 20pt; height:{$config/signaturesSettings/@line-height}; color:{$config/signaturesSettings/@color}; font-weight:{$config/signaturesSettings/@font-weight}; font-size:{$config/signaturesSettings/@font-size}; font-style:{$config/signaturesSettings/@font-style}"> <!-- signature-->
			        <xsl:value-of select="$config/labels/issuingPersonSignature"/>
		      </div>
		      <div style="width:45%;float:right;padding-top: 20pt; height:{$config/signaturesSettings/@line-height}; color:{$config/signaturesSettings/@color}; font-weight:{$config/signaturesSettings/@font-weight}; font-size:{$config/signaturesSettings/@font-size}; font-style:{$config/signaturesSettings/@font-style}">
			        <xsl:value-of select="$config/labels/recipientSignature"/>
		      </div>
       </div>
	   </div>
	   <div style="width:100%;float:right;padding-top: 30pt">
	         <xsl:if test="$config/footer">
              <span style="color:{$config/footerSettings/@color}; font-weight:{$config/footerSettings/@font-weight}; font-size:{$config/footerSettings/@font-size}; font-style:{$config/footerSettings/@font-style}">
                <xsl:copy-of select="$config/footer/*"/>
              </span>
            </xsl:if>
	   </div>
    </body>
    </html>
  </xsl:template>
</xsl:stylesheet>

