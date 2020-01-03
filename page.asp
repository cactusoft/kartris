<%@ Language=VBScript %>
<%
'========================================================================
'Kartris - www.kartris.com
'Copyright 2020 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================

'This is just a simple script to redirect custom page links for 
'upgraded CactuShop sites to the new Kartris custom page URL

strID = request.querystring("id")
Response.Status="301 Moved Permanently"
Response.AddHeader "Location","t-" & request.querystring("id") & ".aspx"
%>
