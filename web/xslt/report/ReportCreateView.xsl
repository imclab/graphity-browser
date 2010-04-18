<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE uridef[
	<!ENTITY owl "http://www.w3.org/2002/07/owl#">
	<!ENTITY rdf "http://www.w3.org/1999/02/22-rdf-syntax-ns#">
	<!ENTITY rdfs "http://www.w3.org/2000/01/rdf-schema#">
	<!ENTITY xsd "http://www.w3.org/2001/XMLSchema#">
	<!ENTITY geo "http://www.w3.org/2003/01/geo/wgs84_pos#">
	<!ENTITY sparql "http://www.w3.org/2005/sparql-results#">
        <!ENTITY rep "http://www.semantic-web.dk/ontologies/semantic-reports/">
        <!ENTITY vis "http://code.google.com/apis/visualization/">
        <!ENTITY dc "http://purl.org/dc/elements/1.1/">
        <!ENTITY spin "http://spinrdf.org/sp#">
]>
<xsl:stylesheet version="1.0"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:owl="&owl;"
xmlns:rdf="&rdf;"
xmlns:rdfs="&rdfs;"
xmlns:xsd="&xsd;"
xmlns:sparql="&sparql;"
xmlns:id="java:util.IDGenerator"
exclude-result-prefixes="#all">

	<xsl:import href="../sparql2google-wire.xsl"/>

	<xsl:include href="../FrontEndView.xsl"/>

	<xsl:param name="query-result"/>
	<xsl:param name="visualization-result"/>
	<xsl:param name="query-string" select="''"/>
	<!-- <xsl:param name="report-id"/> -->
	<xsl:param name="report-uri" select="concat($host-uri, 'reports/', id:generate())"/>
	<xsl:param name="query-uri" select="concat($host-uri, 'queries/', id:generate())"/>
	<xsl:param name="create-view" select="'frontend.view.report.ReportCreateView'"/>
	<xsl:param name="update-view" select="'frontend.view.report.ReportUpdateView'"/>

        <xsl:variable name="report" select="document('arg://report')"/> <!-- only set after $query-result -->
        <xsl:variable name="visualizations" select="document('arg://visualizations')"/> <!-- only set after $query-result -->
        <xsl:variable name="visualization-types" select="document('arg://visualization-types')"/>
        <xsl:variable name="binding-types" select="document('arg://binding-types')"/>

<xsl:key name="binding-type-by-vis-type" match="sparql:result" use="sparql:binding[@name = 'visType']/sparql:uri"/>

	<xsl:template name="title">
            <xsl:choose>
                <xsl:when test="$view = $update-view"> <!-- ReportUpdateView -->
                    Edit report
                </xsl:when>
                <xsl:otherwise> <!-- ReportCreateView -->
                    Create report
                </xsl:otherwise>
            </xsl:choose>
	</xsl:template>

	<xsl:template name="body-onload">
            <xsl:variable name="used-vis-types">
                <xsl:choose>
                    <xsl:when test="$view = $update-view"> <!-- ReportUpdateView -->
                        <xsl:copy-of select="$visualization-types//sparql:result[sparql:binding[@name = 'type']/sparql:uri = $visualizations//sparql:binding[@name = 'type']/sparql:uri]"/>
                    </xsl:when>
                    <xsl:otherwise> <!-- ReportCreateView -->
                        <xsl:copy-of select="$visualization-types//sparql:result"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:text>countColumns(data); </xsl:text>
            <xsl:for-each select="$visualization-types//sparql:result">
                <xsl:text>initWithControlsAndDraw(document.getElementById('</xsl:text>
                <xsl:value-of select="generate-id()"/>
                <xsl:text>-visualization'), '</xsl:text>
                <xsl:value-of select="sparql:binding[@name = 'type']/sparql:uri"/>
                <xsl:text>', [</xsl:text>
                <xsl:for-each select="key('binding-type-by-vis-type', sparql:binding[@name = 'type']/sparql:uri, $binding-types)">
                    <xsl:text>{ 'element' :</xsl:text>
                    <xsl:text>document.getElementById('</xsl:text><xsl:value-of select="generate-id()"/><xsl:text>-binding')</xsl:text>
                    <xsl:text>, 'bindingType' : '</xsl:text>
                    <xsl:value-of select="sparql:binding[@name = 'type']/sparql:uri"/>
                    <xsl:text>' }</xsl:text>
                    <xsl:if test="position() != last()">,</xsl:if>
                </xsl:for-each>
                <xsl:text>], [</xsl:text>
                <xsl:for-each select="key('binding-type-by-vis-type', sparql:binding[@name = 'type']/sparql:uri, $binding-types)">
                    <xsl:text>'</xsl:text>
                    <xsl:value-of select="sparql:binding[@name = 'type']/sparql:uri"/>
                    <xsl:text>'</xsl:text>
                    <xsl:if test="position() != last()">,</xsl:if>
                </xsl:for-each>
                <xsl:text>], [</xsl:text>
                <xsl:for-each select="key('binding-type-by-vis-type', sparql:binding[@name = 'type']/sparql:uri, $binding-types)">
                    <xsl:text>{ 'columns' : </xsl:text>
                    <xsl:if test="exists(index-of(('&vis;LineChartLabelBinding', '&vis;MapLabelBinding', '&vis;PieChartLabelBinding'), sparql:binding[@name = 'type']/sparql:uri))">typeColumns.string</xsl:if>
                    <xsl:if test="exists(index-of(('&vis;LineChartValueBinding', '&vis;PieChartValueBinding', '&vis;ScatterChartXBinding', '&vis;ScatterChartYBinding'), sparql:binding[@name = 'type']/sparql:uri))">typeColumns.number</xsl:if>
                    <xsl:if test="exists(index-of(('&vis;MapLatBinding'), sparql:binding[@name = 'type']/sparql:uri))">typeColumns.lat</xsl:if>
                    <xsl:if test="exists(index-of(('&vis;MapLngBinding'), sparql:binding[@name = 'type']/sparql:uri))">typeColumns.lng</xsl:if>
                    <xsl:text>, 'bindingType' : '</xsl:text>
                    <xsl:value-of select="sparql:binding[@name = 'type']/sparql:uri"/>
                    <xsl:text>' }</xsl:text>
                    <xsl:if test="position() != last()">,</xsl:if>
                </xsl:for-each>
                <xsl:text>]);</xsl:text>
            </xsl:for-each>
            <xsl:text> </xsl:text>
            <!-- switch of Visualizations not included in the Report -->
            <xsl:for-each select="$visualization-types//sparql:result[not(sparql:binding[@name = 'type']/sparql:uri = $visualizations//sparql:binding[@name = 'type']/sparql:uri)]">
                <xsl:text>toggleVisualization(document.getElementById('</xsl:text>
                <xsl:value-of select="generate-id()"/>
                <xsl:text>-visualization'), document.getElementById('</xsl:text>
                <xsl:value-of select="generate-id()"/>
                <xsl:text>-controls'), false); </xsl:text>
            </xsl:for-each>
        </xsl:template>

	<xsl:template name="content">
		<div id="main">
			<h2>
                            <xsl:call-template name="title"/>
                        </h2>

                        <!--
                        <xsl:copy-of select="document('arg://visualization-types')"/>
			<xsl:copy-of select="document('arg://report')"/>
                        -->
                        <xsl:copy-of select="$visualization-types//sparql:result[sparql:binding[@name = 'type']/sparql:uri = $visualizations//sparql:binding[@name = 'type']/sparql:uri]"/>

			<form action="{$resource//sparql:binding[@name = 'resource']/sparql:uri}" method="post" accept-charset="UTF-8">
				<p>
					<input type="hidden" name="view" value="create"/>
                                        <input type="hidden" name="report-uri" value="{$report-uri}"/>
<input type="hidden" name="rdf"/>
<input type="hidden" name="v" value="&vis;"/>
<input type="hidden" name="n" value="rdf"/>
<input type="hidden" name="v" value="&rdf;"/>
<input type="hidden" name="n" value="rep"/>
<input type="hidden" name="v" value="&rep;"/>
<input type="hidden" name="n" value="dc"/>
<input type="hidden" name="v" value="&dc;"/>
<input type="hidden" name="n" value="spin"/>
<input type="hidden" name="v" value="&spin;"/>

<input type="hidden" name="su" value="{$report-uri}"/>
<input type="hidden" name="pu" value="&rdf;type"/>
<input type="hidden" name="on" value="rep"/>
<input type="hidden" name="ov" value="Report"/>
<input type="hidden" name="pu" value="&rep;query"/>
<!-- <input type="hidden" name="ob" value="query"/> -->
<input type="hidden" name="ou" value="{$query-uri}"/>

<!-- <input type="hidden" name="sb" value="query"/> -->
<input type="hidden" name="su" value="{$query-uri}"/>
<input type="hidden" name="pu" value="&rdf;type"/>
<input type="hidden" name="on" value="spin"/>
<input type="hidden" name="ov" value="Select"/>

					<label for="query-string">Query</label>
					<br/>
<input type="hidden" name="pn" value="spin"/>
<input type="hidden" name="pv" value="text"/>
<input type="hidden" name="lt" value="&xsd;string"/>

					<textarea cols="80" rows="20" id="query-string" name="ol">
						<xsl:if test="$query-result">
							<xsl:value-of select="$report//sparql:binding[@name = 'queryString']/sparql:literal"/>
						</xsl:if>
					</textarea>
					<br/>
<input type="hidden" name="su" value="{$report-uri}"/>
<input type="hidden" name="pn" value="dc"/>
<input type="hidden" name="pv" value="title"/>
<input type="hidden" name="lt" value="&xsd;string"/>

					<label for="title">Title</label>
					<input type="text" id="title" name="ol" value="whatever!!">
                                            <xsl:attribute name="value">
						<xsl:if test="$query-result">
							<xsl:value-of select="$report//sparql:binding[@name = 'title']/sparql:literal"/>
						</xsl:if>
                                            </xsl:attribute>
                                        </input>
					<br/>
<!-- <input type="hidden" name="sb" value="query"/> -->
<input type="hidden" name="su" value="{$query-uri}"/>
<input type="hidden" name="pn" value="spin"/>
<input type="hidden" name="pv" value="from"/>

					<label for="endpoint">Endpoint</label>
                                        <!-- <xsl:value-of select="$query-result"/> -->
					<input type="text" id="endpoint" name="ou">
                                            <xsl:attribute name="value">
                                                <xsl:choose>
                                                    <xsl:when test="$query-result">
                                                            <xsl:value-of select="$report//sparql:binding[@name = 'endpoint']/sparql:uri"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>http://dbpedia.org/sparql</xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:attribute>
                                        </input>
					<br/>
					<button type="submit" name="action" value="query">Query</button>
                                        <xsl:if test="$view = $create-view and $query-result = 'success'">
                                            <button type="submit" name="action" value="save">Save</button>
                                        </xsl:if>
                                        <xsl:if test="$view = $update-view">
                                            <button type="submit" name="action" value="update">Save</button>
                                        </xsl:if>
                                </p>

                                <xsl:if test="$query-result = 'failure'">
                                    <ul>
                                        <xsl:for-each select="document('arg://query-errors')//sparql:binding">
                                            <li>
                                                <xsl:value-of select="."/>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:if>

                                <xsl:if test="$query-result = 'success'">
                                    <fieldset>
                                            <legend>Visualizations</legend>
<input type="hidden" name="su" value="{$report-uri}"/>
<input type="hidden" name="pu" value="&rep;visualizedBy"/>
                                            <ul>
                                                    <xsl:apply-templates select="$visualization-types" mode="vis-type-item"/>
                                            </ul>
                                    </fieldset>

                                    <xsl:apply-templates select="$visualization-types" mode="vis-type-fieldset"/>
                                </xsl:if>
			</form>
		</div>
	</xsl:template>

	<xsl:template match="sparql:result[sparql:binding[@name = 'type']]" mode="vis-type-item">
                <!-- visualization of this type (might be non-existing) -->
                <xsl:variable name="visualization" select="$visualizations//sparql:result[sparql:binding[@name = 'type']/sparql:uri = current()/sparql:binding[@name = 'type']/sparql:uri]"/>
                <!-- reuse existing visualization URI or generate a new one -->
                <xsl:variable name="visualization-uri">
                    <xsl:choose>
                        <xsl:when test="$view = $update-view and $visualization"> <!-- ReportUpdateView -->
                            <xsl:value-of select="$visualization/sparql:binding[@name = 'visualization']/sparql:uri"/>
                        </xsl:when>
                        <xsl:otherwise> <!-- ReportCreateView -->
                            <xsl:value-of select="concat($host-uri, 'visualizations/', generate-id())"/> <!-- QUIRK - because visualization IDs must be stable across all templates -->
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <li>
<!-- $report rep:visualizedBy ou -->
<input type="checkbox" name="ou" value="{$visualization-uri}" id="{generate-id()}-toggle" onchange="toggleVisualization(document.getElementById('{generate-id()}-visualization'), document.getElementById('{generate-id()}-controls'), this.checked);">
    <xsl:choose>
        <xsl:when test="$view = $update-view"> <!-- ReportUpdateView -->
            <xsl:if test="$visualization">
                <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
        </xsl:when>
        <xsl:otherwise> <!-- ReportCreateView -->
            <xsl:attribute name="checked">checked</xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>
</input>

                        <!-- <input type="checkbox" id="{generate-id()}-toggle" name="visualization" value="{sparql:binding[@name = 'type']/sparql:uri}" checked="checked" onchange="toggleVisualization(document.getElementById('{generate-id()}-visualization'), document.getElementById('{generate-id()}-controls'), this.checked);"/> -->
			<label for="{generate-id()}-toggle">
				<xsl:value-of select="sparql:binding[@name = 'label']/sparql:literal"/>
			</label>
		</li>
	</xsl:template>

        <xsl:template match="sparql:result[sparql:binding[@name = 'type']]" mode="vis-type-fieldset">
                <!-- visualization of this type (might be non-existing) -->
                <xsl:variable name="visualization" select="$visualizations//sparql:result[sparql:binding[@name = 'type']/sparql:uri = current()/sparql:binding[@name = 'type']/sparql:uri]"/>
                <!-- reuse existing visualization URI or generate a new one -->
                <xsl:variable name="visualization-uri">
                    <xsl:choose>
                        <xsl:when test="$view = $update-view and $visualization"> <!-- ReportUpdateView -->
                            <xsl:value-of select="$visualization/sparql:binding[@name = 'visualization']/sparql:uri"/>
                        </xsl:when>
                        <xsl:otherwise> <!-- ReportCreateView -->
                            <xsl:value-of select="concat($host-uri, 'visualizations/', generate-id())"/> <!-- QUIRK - because visualization IDs must be stable across all templates -->
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <fieldset id="{generate-id()}-controls">
                        <legend>
                            <xsl:value-of select="sparql:binding[@name = 'label']/sparql:literal"/>
                        </legend>
                        <p>
<input type="hidden" name="su" value="{$visualization-uri}"/>
<input type="hidden" name="pu" value="&rdf;type"/>
<input type="hidden" name="ou" value="{sparql:binding[@name = 'type']/sparql:uri}"/>

    <xsl:apply-templates select="key('binding-type-by-vis-type', sparql:binding[@name = 'type']/sparql:uri, $binding-types)"  mode="binding-type-select">
        <xsl:with-param name="visualization-uri" select="$visualization-uri"/>
        <xsl:with-param name="visualization" select="."/>
    </xsl:apply-templates>

                        </p>
                </fieldset>

        <div id="{generate-id()}-visualization" style="width: 800px; height: 400px;"></div>
    </xsl:template>

    <xsl:template match="sparql:result[sparql:binding[@name = 'type']]" mode="binding-type-select">
        <xsl:param name="visualization"/>
        <xsl:param name="visualization-uri"/>
        <xsl:param name="binding-uri" select="concat($host-uri, 'bindings/', id:generate())"/>

        <input type="hidden" name="su" value="{$binding-uri}"/>
        <input type="hidden" name="pu" value="&rdf;type"/>
        <input type="hidden" name="ou" value="{sparql:binding[@name = 'type']/sparql:uri}"/>

        <input type="hidden" name="su" value="{$visualization-uri}"/>
        <input type="hidden" name="pv" value="binding"/>
        <input type="hidden" name="ou" value="{$binding-uri}"/>

        <input type="hidden" name="su" value="{$binding-uri}"/>
        <input type="hidden" name="pv" value="variableName"/>
        <input type="hidden" name="lt" value="&xsd;string"/>

        <label for="{generate-id()}-binding">
            <xsl:value-of select="sparql:binding[@name = 'label']/sparql:literal"/>
        </label>
        <select id="{generate-id()}-binding" name="ol" multiple="multiple">
            <xsl:attribute name="onchange">
                <xsl:for-each select="$visualization">
                    <xsl:text>draw(visualizations['</xsl:text>
                    <xsl:value-of select="sparql:binding[@name = 'type']/sparql:uri"/>
                    <xsl:text>'], '</xsl:text>
                    <xsl:value-of select="sparql:binding[@name = 'type']/sparql:uri"/>
                    <xsl:text>', [</xsl:text>
                    <xsl:for-each select="key('binding-type-by-vis-type', sparql:binding[@name = 'type']/sparql:uri, $binding-types)">
                        <xsl:text>'</xsl:text>
                        <xsl:value-of select="sparql:binding[@name = 'type']/sparql:uri"/>
                        <xsl:text>'</xsl:text>
                        <xsl:if test="position() != last()">,</xsl:if>
                    </xsl:for-each>
                    <xsl:text>], [</xsl:text>
                    <xsl:for-each select="key('binding-type-by-vis-type', sparql:binding[@name = 'type']/sparql:uri, $binding-types)">
                        <xsl:text>{ 'columns' : getSelectedValues(document.getElementById('</xsl:text><xsl:value-of select="generate-id()"/><xsl:text>-binding'))</xsl:text>
                        <xsl:text>, 'bindingType' : '</xsl:text>
                        <xsl:value-of select="sparql:binding[@name = 'type']/sparql:uri"/>
                        <xsl:text>' }</xsl:text>
                        <xsl:if test="position() != last()">,</xsl:if>
                    </xsl:for-each>
                    <xsl:text>]);</xsl:text>
                </xsl:for-each>
            </xsl:attribute>
            <!--
                <xsl:text>draw(document.getElementById('</xsl:text><xsl:value-of select="generate-id()"/><xsl:text>-visualization'), '</xsl:text>
                <xsl:value-of select="sparql:binding[@name = 'type']/sparql:uri"/>
                <xsl:text>', [</xsl:text>
                <xsl:for-each select="key('binding-type-by-vis-type', sparql:binding[@name = 'type']/sparql:uri, $binding-types)">
                    <xsl:text>'</xsl:text>
                    <xsl:value-of select="sparql:binding[@name = 'type']/sparql:uri"/>
                    <xsl:text>'</xsl:text>
                    <xsl:if test="position() != last()">,</xsl:if>
                </xsl:for-each>
                <xsl:text>], [</xsl:text>
                <xsl:for-each select="key('binding-type-by-vis-type', sparql:binding[@name = 'type']/sparql:uri, $binding-types)">
                    <xsl:text>{ 'columns' : </xsl:text>
                    <xsl:if test="exists(index-of(('&vis;LineChartLabelBinding', '&vis;MapLabelBinding', '&vis;PieChartLabelBinding'), sparql:binding[@name = 'type']/sparql:uri))">typeColumns.string</xsl:if>
                    <xsl:if test="exists(index-of(('&vis;LineChartValueBinding', '&vis;PieChartValueBinding', '&vis;ScatterChartXBinding', '&vis;ScatterChartYBinding'), sparql:binding[@name = 'type']/sparql:uri))">typeColumns.number</xsl:if>
                    <xsl:if test="exists(index-of(('&vis;MapLatBinding'), sparql:binding[@name = 'type']/sparql:uri))">typeColumns.lat</xsl:if>
                    <xsl:if test="exists(index-of(('&vis;MapLngBinding'), sparql:binding[@name = 'type']/sparql:uri))">typeColumns.lng</xsl:if>
                    <xsl:text>, 'bindingType' : '</xsl:text>
                    <xsl:value-of select="sparql:binding[@name = 'type']/sparql:uri"/>
                    <xsl:text>' }</xsl:text>
                    <xsl:if test="position() != last()">,</xsl:if>
                </xsl:for-each>
                <xsl:text>]);</xsl:text>

                -->
        </select>
    </xsl:template>

</xsl:stylesheet>