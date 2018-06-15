<html>
<head>
	<title>Find Food</title>
</head>
<body>
<h3>FindFood</h3>
<cfset cName = "findfood">
<cfset priceRangeGap = 10>
<cfparam name="form.search" default="*:*" type="string">
<cfparam name="form.facets" default="" type="string">
<script type="text/javascript">
function addFacet(key, value){
if(value.indexOf(' ') >= 0){
    value = '"' + value + '"';
}
var store = document.getElementById("store").value;
if(store) {
	store +=" AND " + key + ":" + value;
} else
	store = key + ":" + value;
document.getElementById("store").value = store;
document.getElementById("form").submit();
}


function addRangeFacet(key, value, gap){
var query = key + ":[" + value + " TO " + (value + gap) + "]";
var store = document.getElementById("store").value;
if(store) {
	store +=" AND " + query;
} else
	store = query;
document.getElementById("store").value = store;
document.getElementById("form").submit();
}

function addOpenRangeFacet(key, value){
var query = key + ":[" + value + " TO *]";
var store = document.getElementById("store").value;
if(store) {
	store +=" AND " + query;
} else
	store = query;
document.getElementById("store").value = store;
document.getElementById("form").submit();
}
</script>
<form method="post" id="form">
<cfoutput>
<input name="search" id="search" type="text" size="100" value="#form.search#" placeholder="search for food">
<input type="hidden" id="store" name="facets" value='#form.facets#'>
</cfoutput>
</form>


<cfscript>
 facetsNames = {"name_s": "Brand", "state_s":"State", "type_s": "Type", "city_s": "City", "price_d": "Price"};
 query = form.search;
 if(len(form.facets) GT 0) {
	query = form.facets;
	if(!(form.search == "*:*")) {
		query = query & " AND " & "contents:" & form.search;
	}
 }
	
 facetURL = "http://localhost:8991/solr/" & cName & "/select?q=" & query & "&facet=true&facet.field=name_s&facet.field=state_s&facet.field=type_s&facet.range=price_d&facet.range.start=0&facet.range.gap=" & priceRangeGap &"&facet.range.end=40&facet.mincount=1&rows=0";
 writeoutput(facetURL);
 cfhttp(url=facetURL);
 response = deserializejson(cfhttp.fileContent);
 if(isdefined("response.facet_counts.facet_fields")) {
	facet_counts = response["facet_counts"]["facet_fields"];
	facets = structnew("Ordered");
	for(key in facet_counts) {
		if(arraylen(facet_counts[key]) GT 0){
			fieldFacet = structnew();
			for(i = 1; i<= arraylen(facet_counts[key]);i+=2) {
				fieldFacet[facet_counts[key][i]] = facet_counts[key][i+1];
			}
			facets[key] = fieldFacet;
		}		
	}
 }
 
 if(isdefined("response.facet_counts.facet_ranges")) {
	facet_ranges = response["facet_counts"]["facet_ranges"];
	facets_r = structnew("Ordered");
	for(key in facet_ranges) {
		if(structkeyExists(facet_ranges[key],"counts")){
			if(arraylen(facet_ranges[key]["counts"]) > 0) {
				fieldFacet = structnew();
				for(i = 1; i<= arraylen(facet_ranges[key]["counts"]);i+=2) {
					fieldFacet[facet_ranges[key]["counts"][i]] = facet_ranges[key]["counts"][i+1];
				}
				facets_r[key] = fieldFacet;
			}
		}		
	}
 }
 
 </cfscript>
<div style="width:800px;">
  <div style="width:300px; float:left;">
 <cfoutput>Facets: <br><br/>
 
<cfif isdefined("facets_r")>

<cfloop collection="#facets_r#" item="category" >
	<b>#facetsNames[category]#</b><br/><br/>
	<cfset count = structcount(facets_r[category])>
	<cfloop collection="#facets_r[category]#" item="value">
		<cfif i == count>
			<a href="javascript:addOpenRangeFacet('#category#', #value#)"><i>#value# - Above</i></a> <b>(#facets_r[category][value]#)</b><br/>
		<cfelse>
			<a href="javascript:addRangeFacet('#category#', #value#, #priceRangeGap#)"><i>#value# - #value + priceRangeGap#</i></a> <b>(#facets_r[category][value]#)</b><br/>
		</cfif>	
		<cfset count++>
	</cfloop><br/>
</cfloop>
</cfif> 
 
<cfif isdefined("facets")>

<cfloop collection="#facets#" item="category" >
	<b>#facetsNames[category]#</b><br/><br/>
	<cfloop collection="#facets[category]#" item="value">
		<a href="javascript:addFacet('#category#', '#value#')"><i>#value#</i></a> <b>(#facets[category][value]#)</b><br/>
	</cfloop><br/>	
</cfloop>
</cfif>
</cfoutput>
</div>

<div style="width:400px; float:right; margin-top:40px;">
<cfsearch
name = "result"
criteria='#query#'
collection = "#cName#"
startrow=1 
maxrows = "100"
suggestions="always"
type="standard"
status="info"> 
<cfoutput>
<cfif isdefined("info.SuggestedQuery") and len(info.SuggestedQuery) > 0>
<cfoutput>Did you mean to search for <h3>#info.SuggestedQuery#?</h3></strong><br></cfoutput>
</cfif>
<cfoutput> About #info.found# results (#info.time/1000# seconds)</cfoutput>
<cfloop query="#result#" >
	<div style="border:1px solid black;width:100%">
		Brand: #name_s#<br/>
		State: #state_s#<br/>
		City: #city_s#<br/>
		Type: #type_s#</br>
		Price: #price_d#<br/>
		Additional Info: "#tags_t#"<br/>
	</div><br/>
</cfloop>
</cfoutput>
</div>
</div>

</body>

</html>
