<%@ Language=VBScript %>
<%
'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================

'This is just a simple script to redirect product page links for 
'upgraded CactuShop sites to the new Kartris product page URL.
'Note that friendly style CactuShop links are handled in 04.aspx.vb
'instead

strID = request.querystring("P_ID")
strAF_ID = request.querystring("af")

Response.Status="301 Moved Permanently"
Response.AddHeader "Location","Product.aspx?ProductID=" & strID & "&af=" & strAF_ID
%>
