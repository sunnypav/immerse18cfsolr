<!-----------------------------------------------------------
Filename:	cfsearch-context-attrib.cfm 	
Author:		pnayak
Created:	16 Dec 2014

Feature: 	validate the cfsearch output with respect to the context attribute.
Description: bug #3824890: CFSEARCH tag ignores contextBytes parameter.
-------------------------------------------------------------
Modification History:

Date		Name		Modifications
----		----		-------------
------------------------------------------------------------->


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
	<head>
	    <title>cfloop-query-nested-group-attrib</title>
	</head>

	<body>
		

			<cfset path_separator = IIF((server.os.name contains "windows"), DE("\"), DE("/"))>
			<cfset col_name = "bookclub">
			<cfset col_fls_loc = "#expandpath(".")#" & path_separator & "col">

			<cfcollection action="list" name="lst_col" engine="solr">
			<cfset col_lst = ValueList(lst_col.NAME, ",")>

			<cfif ListContains(col_lst, "#col_name#") EQ 0>
			    <cfcollection  
			    	action = "create"
		            collection = "#col_name#"
		            categories = "true"> 
			</cfif>

			<cfset filename = "#Expandpath(".")#" & path_separator & "search-Docs">
			                <cfindex action="purge" collection="#col_name#">

			<cfindex 
				action = 'update'
				collection = '#col_name#' 
				type = 'path' 
				key = '#filename#' 
				extensions = ".txt"
				urlpath = "#CGI.http_referer#">

			<cfset sleep(500)>
			<cfsearch 
				name="srch_rslt"
				collection="#col_name#"
				criteria= "golden"
			    ContextHighlightBegin="<b><font color='red'>"
			    ContextHighlightEnd="</font></b>"
			    ContextPassages="1"
			    ContextBytes="150"
			    > <!--- the search output seems to include the chars in the formatting text in the count as well. --->

			<cfloop query="srch_rslt">
				<b>context:</b><br>
				<cfoutput>#srch_rslt.context#</cfoutput><br>
				No of Chars in context: <cfoutput>#Len(srch_rslt.context)#</cfoutput><br>
				Chars in summary: <cfoutput>#Len(srch_rslt.summary)#</cfoutput><br>
				<hr>
			</cfloop>
							<cfdump var="#srch_rslt#">

			<!--- post-test clean up. --->
			<cfif ListContains(col_lst, "#col_name#") NEQ 0>
				<cftry>
				    <cfcollection  action = "delete" collection = "#col_name#">
					<cfdirectory action="delete" directory="#col_fls_loc#" recurse="true">
					
					<cfcatch type="any">
						<!--- ignore and carry on. --->
					</cfcatch>
				</cftry>
			</cfif>



	</body>
</html>
