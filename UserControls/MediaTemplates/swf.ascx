<%@ Control Language="VB" ClassName="swf" %>
 <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0" width="<%=Me.Attributes("Width")%>" height="<%=Me.Attributes("Height")%>" id="<%=Me.Attributes("MovieName")%>">
    <param name="movie" value="<%=Me.Attributes("Source")%>"/>
    <param name="quality" value="<%=Me.Attributes("Quality")%>"/>
    <param name="bgcolor" value="<%=Me.Attributes("BGColor")%>"/>
    <embed src="<%=Me.Attributes("Source")%>" quality="<%=Me.Attributes("Quality") %>" bgcolor="<%=Me.Attributes("BGColor")%>" 
        width="<%=Me.Attributes("Width")%>" height="<%=Me.Attributes("Height") %>" name="<%=Me.Attributes("MovieName") %>" align="" 
        type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer"></embed>
</object>