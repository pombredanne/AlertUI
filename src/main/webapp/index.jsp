<%@page import="com.jsi.alert.utils.UserAuthenticator"%>
<% UserAuthenticator authenticator = UserAuthenticator.getInstance(); %>
<!DOCTYPE html>
<html>
<head>
	<title>Alert</title>
	<meta http-equiv="content-type" content="application/xhtml+xml; charset=UTF-8" />
	<meta name="description" content="Active support and reaL-time coordination based on Event pRocessing in FLOSS developmenT" />
	<meta name="keywords" content="keywords, goes, here" />
	<meta name="robots" content="index, follow, noarchive" />
	<meta name="googlebot" content="noarchive" />
	<link type="text/css" rel="stylesheet" href="css/layout-default-latest.css" />
	<link type="text/css" rel="stylesheet" href="css/flick/jquery-ui-1.8.17.custom.css" />
	<link type="text/css" rel="stylesheet" href="css/autoSuggest.css" />
	<link type="text/css" rel="stylesheet" href="css/jqcloud.css" />
	<link type="text/css" rel="stylesheet" href="css/tabber.css" />
	<link type="text/css" rel="stylesheet" href="css/headings.css" />
	<link type="text/css" rel="stylesheet" href="css/tables.css" />
	<link type="text/css" rel="stylesheet" href="css/main.css" media="screen" />
	<link type="text/css" rel="stylesheet" href="css/tooltip.css" media="screen" />
	
	<script type="application/javascript" src="js/jquery-1.7.1.js"></script>
	<script type="application/javascript" src="js/jquery.layout-latest.js"></script>
	<script type="application/javascript" src="js/jquery-ui-1.8.17.custom.min.js"></script>
	<script type="application/javascript" src="js/jquery.ba-bbq.min.js"></script>
	<script type="application/javascript" src="js/jquery.autoSuggest.js"></script>
	<script type="application/javascript" src="js/jquery.bpopup-0.7.0.min.js"></script>
	<script type="application/javascript" src="js/arbor.js"></script>
	<script type="application/javascript" src="js/kinetic-v3.10.0.js"></script>
	<script type="application/javascript" src="js/graphics.js"></script>
	<script type="application/javascript" src="js/jqcloud-1.0.0.js"></script>		
	<script type="application/javascript" src="js/highcharts.js"></script>
	<script type="application/javascript" src="js/dynamicgraph.js"></script>
	<script type="application/javascript" src="js/alertviz.js"></script>
	<script type="application/javascript" src="js/tabber.js"></script>
	<script type="application/javascript" src="js/popbox.js"></script>	
	<script type="application/javascript" src="js/sliding.form.js"></script>
	<script type="application/javascript" src="js/date.format.js"></script>
	<script type="application/javascript" src="js/tooltip.js"></script>
	<script type="application/javascript">
		var viz;
		$(document).ready(function(){														
			viz = AlertViz();
			loadState();
		});
	</script>
	<script type="text/javascript" charset="utf-8">
  	  $(document).ready(function(){
 	     $('.popbox').popbox();
 	   });
	</script>
	<style type="text/css">.tabber{visibility: hidden;}</style>
</head>
<body>
	<div id="header-wrap">
		<div id="header" class="container_wide">
			<div id="nav">
				<ul>
				     <li><img src="img/logo.png" style="float:left;width:60px;hight:60px;margin-right:10px;"></img></li>
					 <li id="current"><a href="index.html">Browse</a></li>
					 <li><a href="subscribe.html">Subscribe</a></li>
					 <li><a href="overview.html">Project overview</a></li>
					 <%
					 if (authenticator.isAdmin(session)) {
					 %>
					 <li><a href="admin.html">Administration</a></li>
					 <%
					 }
					 if (authenticator.isLoggedIn(session)) {
					 %>
					 <li><div class='popbox'>
				  		 <a class="open" href="#"><% out.write(authenticator.getUserEmail(session)); %></a>
					 		<div class='collapse'>
 					 			<div class='box'>
   					 				<div class='arrow'></div>
     		 		 				<div class='arrow-border'></div>
        			 				<form method="post" id="subForm">
        				 				<p>
<a href="#" style="float:right;text-transform:normalcase;">Logout</a>
<script type="text/javascript" src="http://output21.rssinclude.com/output?type=js&amp;id=526079&amp;hash=ee25e8943dc9de3f8d68f5bf9e0b5c5c"></script>
		 								</p>
     			    				</form>
     			     			</div>
     			     		</div>
     			     	</div>
     			     </li>
     			     <%
					 }
     			     %>
     			 </ul>
     		</div>
    	</div>
    </div>
<div id="container_main" class="container_main">
	<div id="container" class="container_wide">
		<div id="advanced_div">
			<div id="tabscontent">
				<div id="tabswrapper">
					<div id="navigation" style="display: none;">
						<ul>
							<li class="selected"><a href="#">General search</a></li>
							<li><a href="#">Duplicate issue detection</a></li>
							<li><a href="#">Issues related to my code</a></li>
							<li><a href="#">Suggest issues for a developer</a></li>
						</ul>
					</div>
					<div id="steps">
						<form id="formElem" action="" method="post">
							<fieldset class="step">
								<table>
									<tbody>
										<tr>
											<td colspan="7"><input type="text" class="text" id="keyword_text" name="keywords" /></td>
										</tr>
										<tr>
											<td  colspan="7"><input type="text" class="text" id="other_text" name="other"/></td>
										</tr>
										<tr>
											<td class="cells"><label for="from_text">Between:</label>
												<input type="text" id="from_text" class="text_date" onchange="updateUrl();" style="width:100px;"/>
												<label for="to_text">and</label>
												<input type="text" id="to_text" class="text_date" onchange="updateUrl();" style="width:100px;"/></td>
											<td class="cells"><input class="check" type="checkbox" id="issues_check" checked="checked" onchange="updateUrl();"/><label> Issues</label></td>
											<td class="cells"><input class="check" type="checkbox" id="commits_check" checked="checked" onchange="updateUrl();"/><label> Commits</label></td>
											<td class="cells"><input class="check" type="checkbox" id="forums_check" checked="checked" onchange="updateUrl();"/><label> Forums</label></td>
											<td class="cells"><input class="check" type="checkbox" id="mailing_check" checked="checked" onchange="updateUrl();"/><label> Mailing lists</label></td>
											<td class="cells"><input class="check" type="checkbox" id="wikis_check" checked="checked" onchange="updateUrl();"/><label> Wiki</label></td>
											<td class="cells"><button onclick="return viz.searchGeneral();">Search</button></td>
										</tr>
									</tbody>
								</table>
							</fieldset>
							<fieldset class="step">
								<table>
									<tbody>
										<tr>
											<td colspan="10"><input type="text" id="issue_id_text" class="text_issue"/></td>
										</tr>
										<tr>
											<td class="cells"><input class="check" type="checkbox" id="dup_unconfirmed_check" checked="checked" onchange="updateUrl();" /><label> Uncomfirmed</label></td>
											<td class="cells"><input class="check" type="checkbox" id="dup_new_check" checked="checked" onchange="updateUrl();" /><label> New</label></td>
											<td class="cells"><input class="check" type="checkbox" id="dup_assigned_check" checked="checked" onchange="updateUrl();" /><label> Assigned</label></td>
											<td class="cells"><input class="check" type="checkbox" id="dup_resolved_check" checked="checked" onchange="updateUrl();" /><label> Resolved</label></td>
											<td class="cells"><input class="check" type="checkbox" id="dup_invalid_check" checked="checked" onchange="updateUrl();" /><label> Invalid</label></td>
											<td class="cells"><input class="check" type="checkbox" id="dup_works_check" checked="checked" onchange="updateUrl();" /><label> Works for me</label></td>
											<td class="cells"><input class="check" type="checkbox" id="dup_fixed_check" checked="checked" onchange="updateUrl();" /><label> Fixed</label></td>
											<td class="cells"><input class="check" type="checkbox" id="dup_wond_check" checked="checked" onchange="updateUrl();" /><label> Wond for</label></td>
											<td class="cells"><input class="check" type="checkbox" id="dup_duplicate_check" checked="checked" onchange="updateUrl();" /><label> Duplicate</label></td>
											<td class="cells"><button id="issue_search" onclick="return viz.searchIssueId();">Search</button></td>
										</tr>
									</tbody>
								</table>
							</fieldset>
							<fieldset class="step">
								<table>
									<tbody>
										<tr>
											<td class="cells"><input class="check" type="checkbox" id="my_unconfirmed_check" checked="checked" onchange="updateUrl();" /><label> Uncomfirmed</label></td>
											<td class="cells"><input class="check" type="checkbox" id="my_new_check" checked="checked" onchange="updateUrl();" /><label> New</label></td>
											<td class="cells"><input class="check" type="checkbox" id="my_assigned_check" checked="checked" onchange="updateUrl();" /><label> Assigned</label></td>
											<td class="cells"><input class="check" type="checkbox" id="my_resolved_check" checked="checked" onchange="updateUrl();" /><label> Resolved</label></td>	
											<td class="cells"><input class="check" type="checkbox" id="my_invalid_check" checked="checked" onchange="updateUrl();" /><label> Invalid</label></td>
											<td class="cells"><input class="check" type="checkbox" id="my_works_check" checked="checked" onchange="updateUrl();" /><label> Works for me</label></td>
											<td class="cells"><input class="check" type="checkbox" id="my_fixed_check" checked="checked" onchange="updateUrl();" /><label> Fixed</label></td>
											<td class="cells"><input class="check" type="checkbox" id="my_wond_check" checked="checked" onchange="updateUrl();" /><label> Wond for</label></td>
											<td class="cells"><input class="check" type="checkbox" id="my_duplicate_check" checked="checked" onchange="updateUrl();" /><label> Duplicate</label></td>
											<td class="cells"><button onclick="return viz.searchRelated();">Search</button></td>
										</tr>
									</tbody>
								</table>
							</fieldset>
							<fieldset class="step">
								<table>
									<tbody>
										<tr style="line-hight:12px;">
											<td style="width:100%;"><input id="person_text" name="other"/></td>
											<td><button onclick="return viz.search();">Search</button></td>
										</tr>
									</tbody>
								</table>
							</fieldset>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>
<div id="container" class="container_wide">
	<div id="container" class="item_left">
		<div>
			<div class="items"><div class="items-div" id="items-div"></div></div>
			<div class="pages" id="item_nav">
				<table class="pages_table">
					<tbody>
						<tr>
							<td class="pages" id="page_td"><a href="#"></a> page 1 of 100 <a href="#"></a></td>
							<td class="pages"><a href="#">Sort by relevance</a></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
	</div>
	<div id="separator" onselectstart="return false;"></div>
	<div id="container" class="item_right">
	<div class="tabber">
 	<div class="tabbertab">
	 <h2>Item details</h2>
	  	<div id="item-div">
	  		<div id="details_wrapper" class="layer1"></div>
		</div>
     </div>
     <div class="tabbertab">
	  <h2>Social graph</h2>
		<div id="graph-controls-div">
			<button class="zoom_btns" id="btnShowMore">+</button>
			<button class="zoom_btns" id="btnShowLess">-</button>
		</div>
			<div id="graph-div" onselectstart="return false;"></div>
    	</div>
     <div class="tabbertab">
	  <h2>Word cloud</h2>
		<div id="wordcloud-div">
		</div>
     </div>
</div>
</div>

<div id="container" class="container_wide">
	<div id="container" class="timeline">
		<div id="chart-div">
		</div>
	</div>
</div>
<div id="footer-wrapper">
	<div id="footer-content">
Copyleft...
	</div>
</div>
</div>
</div>


</body>
</html>
