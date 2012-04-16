<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  version="1.0">
	
	<xsl:output indent="yes" method="html" />
	<xsl:variable name="LabelWidth" select="150" />	
	
	<xsl:template match="/">
		<xsl:element name="html">
			<xsl:element name="head">
				<xsl:element name="title">Ahoj svete</xsl:element>
			</xsl:element>
			<xsl:element name="body">
				<xsl:element name="table">
					<xsl:element name="tr">
						<xsl:element name="th"><xsl:text>ID</xsl:text></xsl:element>
						<xsl:element name="th"><xsl:text>Jmeno</xsl:text></xsl:element>
						<xsl:element name="th"><xsl:text>Email</xsl:text></xsl:element>
						<xsl:element name="th"><xsl:text>Identifikace</xsl:text></xsl:element>
						<xsl:element name="th"><xsl:text>Registrace</xsl:text></xsl:element>
						<xsl:element name="th"><xsl:text>Adresa</xsl:text></xsl:element>
					</xsl:element>
					<xsl:apply-templates select="//agents"/>
				</xsl:element>
				<xsl:for-each select="//agents/agent">
					<xsl:variable name="AgentId" select="./@id" />
					<!--Kotva -->
					<xsl:element name="a">
						<xsl:attribute name="name"><xsl:text>agent_datail_</xsl:text><xsl:value-of select="$AgentId" /></xsl:attribute>
					</xsl:element>
					<xsl:element name="h1"><xsl:value-of select="./name" /></xsl:element>
					<!--Seznam jeho klientu-->
					<xsl:call-template name="TClients" >
						<xsl:with-param name="ClientsNode" select="./clients" />
					</xsl:call-template>
					<!--Vypis dokumentu agenta, zajimave je, jak vypsat obsah nejakeho uzlu vcetne <>-->
					<xsl:for-each select="//document [@agentId = $AgentId]">
						<xsl:element name="p" >
							<!-- Jak escapovat? -->
							<xsl:copy-of select="node()"/>
						</xsl:element>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<!-- Vypise seznam agentu -->
	<xsl:template match="agent">
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:element name="a">
					<xsl:attribute name="href">
						<xsl:text>#agent_datail_</xsl:text><xsl:value-of select="./@id" />
					</xsl:attribute>
					<xsl:value-of select="./@id" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="td"><xsl:value-of select="./name" /></xsl:element>
			<xsl:element name="td"><xsl:value-of select="./email" /></xsl:element>
			<xsl:element name="td"><xsl:value-of select="./identification" /></xsl:element>
			<xsl:element name="td"><xsl:value-of select="./registration" /></xsl:element>
			<xsl:element name="td">
				<xsl:call-template name="TAddress" >
					<xsl:with-param name="AddressNode" select="./address" />
				</xsl:call-template> 
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<!-- 
		Vypise seznam klientu ze zadaneho clients nodu 
		ClientsNode node - Element clients
    -->
	<xsl:template name="TClients">
		<xsl:param name="ClientsNode" />
		<xsl:variable name="ClientsCount" select="count($ClientsNode/client)" />
		<xsl:element name="h2">
			<xsl:text>Seznam klientu (</xsl:text><xsl:value-of select="$ClientsCount" /><xsl:text>)</xsl:text>
		</xsl:element>
		<xsl:for-each select="$ClientsNode/client">
			<xsl:call-template name="TClient" />
		</xsl:for-each>
	</xsl:template>
  
	<!-- Vypis elementu client -->
  	<xsl:template name="TClient">
		<xsl:element name="fieldset">
			<xsl:element name="legend"><xsl:value-of select="./name"/></xsl:element>			
			<xsl:call-template name="TInfoRow">
				<xsl:with-param name="ValueNode" select="./name" />
				<xsl:with-param name="Label">Jmeno</xsl:with-param>
			</xsl:call-template>
			<!-- Informace o subjektu -->
			<xsl:apply-templates select="./subject" />
			<xsl:element name="div">		
				<xsl:call-template name="TLabel">
					<xsl:with-param name="Label">Adresa</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="TAddress" >
					<xsl:with-param name="AddressNode" select="./address" />
				</xsl:call-template> 
			</xsl:element>

		</xsl:element>
	</xsl:template>
	
	<!-- Vypis informace o subjektu -->
	<xsl:template match="subject">
		<xsl:element name="div">
			<xsl:choose>
				<!-- Je-li platce dph => vypis ho kurzivou pres mode -->
				<xsl:when test="@dph = 'true'">
					<xsl:apply-templates mode="platce_dph"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates />
				</xsl:otherwise>
			</xsl:choose>	
		</xsl:element>
		<!-- Je-li platce dph, pak pripis poznamku -->
		<xsl:if test="@dph = 'true'">
			<xsl:element name="div">
				<xsl:call-template name="TLabel">
					<xsl:with-param name="Label">Poznamka</xsl:with-param>
				</xsl:call-template>
				<xsl:text>Platce DPH</xsl:text>
			</xsl:element>
		</xsl:if>	
	</xsl:template>
	
	<!--
		Funkce pro zobrazeni popisky
		Label string - Popisek
		LabelWidth int - Globalni promena pro sirku popisku
	--> 
	<xsl:template name="TLabel">
			<xsl:param name="Label" />
			<xsl:element name="b">
				<xsl:attribute name="style"><xsl:text>width:</xsl:text><xsl:value-of select="$LabelWidth"/></xsl:attribute>
				<xsl:copy-of select="$Label"/>
			</xsl:element>	
	</xsl:template>
	
	<!--
		Funkce pro zobrazeni popisky a hodnoty
		Label string - Popisek
		ValueNode node - node na ktery lze aplikovat value-of
	--> 
	<xsl:template name="TInfoRow">
		<xsl:param name="Label" />
		<xsl:param name="ValueNode" />
		<xsl:element name="div">
			<xsl:call-template name="TLabel">
				<xsl:with-param name="Label"><xsl:copy-of select="$Label" /></xsl:with-param>
			</xsl:call-template>
			<xsl:value-of select="$ValueNode" />
		</xsl:element>
	</xsl:template>
	
	<!--
		Prevede uzel na citelnou adresu v normovanem zapisu
		AddressNode node - element obsahujuci adresu
	 -->
	<xsl:template name="TAddress">
		<xsl:param name="AddressNode" />
		<xsl:element name="address">
			<xsl:value-of select="$AddressNode/street" /><xsl:text>, </xsl:text><xsl:value-of select="$AddressNode/postal" /><xsl:text> </xsl:text><xsl:value-of select="$AddressNode/city" />
		</xsl:element>
	</xsl:template>
	
	<!-- Namatchovani unifikaci na ico, mohu pouzit if, ale toto se mi zda hezci :) + matchovani pomoci mode-->
	<xsl:template match="subject/ico" mode="platce_dph">
		<xsl:call-template name="TLabel">
			<xsl:with-param name="Label"><xsl:element name="i">ICO</xsl:element></xsl:with-param>
		</xsl:call-template>
		<xsl:copy-of select="./text()" />		
	</xsl:template>
	
	<!-- Namatchovani unifikaci na ico, mohu pouzit if, ale toto se mi zda hezci :) -->
	<xsl:template match="subject/ico">
		<xsl:call-template name="TLabel">
			<xsl:with-param name="Label">ICO</xsl:with-param>
		</xsl:call-template>
		<xsl:copy-of select="./text()" />		
	</xsl:template>
	
	<!-- Namatchovani unifikaci na datum narozeni, mohu pouzit if, ale toto se mi zda hezci :) -->
	<xsl:template match="subject/date">
		<xsl:call-template name="TLabel">
			<xsl:with-param name="Label">Datum narozeni</xsl:with-param>
		</xsl:call-template>
		<xsl:copy-of select="./text()" />	
	</xsl:template>
	
	<!-- Namatchovani unifikaci na datum narozeni, mohu pouzit if, ale toto se mi zda hezci :) + matchovani pomoci mode -->
	<xsl:template match="subject/date" mode="platce_dph">
		<xsl:call-template name="TLabel">
			<xsl:with-param name="Label"><xsl:element name="i">Datum narozeni</xsl:element></xsl:with-param>
		</xsl:call-template>
		<xsl:copy-of select="./text()" />	
	</xsl:template>
</xsl:stylesheet>
