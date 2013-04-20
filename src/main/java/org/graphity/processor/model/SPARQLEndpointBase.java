/*
 * Copyright (C) 2012 Martynas Jusevičius <martynas@graphity.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.graphity.processor.model;

import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.ResultSetRewindable;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.rdf.model.ResourceFactory;
import com.sun.jersey.api.core.ResourceConfig;
import javax.ws.rs.Path;
import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Request;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.ResponseBuilder;
import javax.ws.rs.core.UriInfo;
import org.graphity.client.util.DataManager;
import org.graphity.server.vocabulary.GS;
import org.graphity.server.vocabulary.VoID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * SPARQL endpoint resource, implementing ?query= access method
 * @author Martynas Jusevičius <martynas@graphity.org>
 */
@Path("/sparql")
public class SPARQLEndpointBase extends org.graphity.server.model.SPARQLEndpointBase
{
    private static final Logger log = LoggerFactory.getLogger(SPARQLEndpointBase.class);

    private final UriInfo uriInfo;

    public SPARQLEndpointBase(@Context UriInfo uriInfo, @Context Request request, @Context ResourceConfig resourceConfig,
	    @Context OntModel sitemap)
    {
	this(resourceConfig.getProperty(VoID.sparqlEndpoint.getURI()) == null ?
	    sitemap.createResource(uriInfo.getBaseUriBuilder().
		path(SPARQLEndpointBase.class).
		build().toString()) :
		ResourceFactory.createResource(resourceConfig.getProperty(VoID.sparqlEndpoint.getURI()).toString()),
		uriInfo, request, resourceConfig);
    }

    protected SPARQLEndpointBase(Resource endpoint, UriInfo uriInfo, Request request, ResourceConfig resourceConfig)
    {
	super(endpoint, request, resourceConfig);

	if (uriInfo == null) throw new IllegalArgumentException("UriInfo cannot be null");
	this.uriInfo = uriInfo;
	
	if (endpoint.equals(getOntModelEndpoint(uriInfo)) && !DataManager.get().hasServiceContext(endpoint))
	{
	    if (log.isDebugEnabled()) log.debug("Adding service Context for local SPARQL endpoint with URI: {}", endpoint.getURI());
	    DataManager.get().addServiceContext(endpoint);
	}
    }

    public Resource getOntModelEndpoint()
    {
	return getOntModelEndpoint(getUriInfo());
    }
    
    public final Resource getOntModelEndpoint(UriInfo uriInfo)
    {
	return ResourceFactory.createResource(uriInfo.
		getBaseUriBuilder().
		path(getClass()).
		build().toString());
    }
    
    @Override
    public Model loadModel(Resource endpoint, Query query)
    {
	if (endpoint.equals(getOntModelEndpoint()))
	{
	    if (log.isDebugEnabled()) log.debug("Loading Model from Model using Query: {}", query);
	    return DataManager.get().loadModel(getModel(), query);
	}
	else
	{
	    if (log.isDebugEnabled()) log.debug("Loading Model from SPARQL endpoint: {} using Query: {}", endpoint, query);
	    return DataManager.get().loadModel(endpoint.getURI(), query);
	}
    }

    @Override
    public ResultSetRewindable loadResultSetRewindable(Resource endpoint, Query query)
    {
	if (endpoint.equals(getOntModelEndpoint()))
	{
	    if (log.isDebugEnabled()) log.debug("Loading ResultSet from Model using Query: {}", query);
	    return DataManager.get().loadResultSet(getModel(), query);
	}
	else
	{
	    if (log.isDebugEnabled()) log.debug("Loading ResultSet from SPARQL endpoint: {} using Query: {}", endpoint.getURI(), query);
	    return DataManager.get().loadResultSet(endpoint.getURI(), query);
	}
    }

    public ResponseBuilder getResponseBuilder(Query queryParam, Model model)
    {
	if (queryParam == null) throw new WebApplicationException(Response.Status.BAD_REQUEST);

	if (queryParam.isSelectType())
	{
	    if (log.isDebugEnabled()) log.debug("SPARQL endpoint executing SELECT query: {}", queryParam);
	    if (getResourceConfig().getProperty(GS.resultLimit.getURI()) != null)
		queryParam.setLimit(Long.parseLong(getResourceConfig().
			getProperty(GS.resultLimit.getURI()).toString()));

	    if (log.isDebugEnabled()) log.debug("Loading ResultSet from Model: {} using Query: {}", model, queryParam);
	    return getResponseBuilder(DataManager.get().loadResultSet(model, queryParam));
	}

	if (queryParam.isConstructType() || queryParam.isDescribeType())
	{
	    if (log.isDebugEnabled()) log.debug("Loading Model from Model: {} using Query: {}", model, queryParam);
	    return getResponseBuilder(DataManager.get().loadModel(model, queryParam));
	}

	if (log.isWarnEnabled()) log.warn("SPARQL endpoint received unknown type of query: {}", queryParam);
	throw new WebApplicationException(Response.Status.BAD_REQUEST);
    }

    public UriInfo getUriInfo()
    {
	return uriInfo;
    }

}