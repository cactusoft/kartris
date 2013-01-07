<%@ Control Language="VB" ClassName="html5video" %>
<video controls="controls" height="<%=Me.Attributes("Height") %>" width="<%=Me.Attributes("width")%>">
    <source src="<%=Me.Attributes("Source")%>" type="video/mp4" />
    <source src="<%=Me.Attributes("WebM")%>" type="video/webm" />
    <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0" width="<%=Me.Attributes("Width")%>" height="<%=Me.Attributes("Height")%>" id="<%=Me.Attributes("MovieName")%>">
        <param name="movie" value="<%=CkartrisBLL.WebShopURL%>UserControls/MediaTemplates/flvplayer.swf"/>
        <param name="quality" value="<%=Me.Attributes("Quality")%>"/>
        <param name="flashvars" value="file=<%=Me.Attributes("Source")%>&amp;height=<%=Me.Attributes("Height") %>&amp;width=<%=Me.Attributes("width")%>&amp;showstop=1&amp;showvolume=1&amp;showtime=1&amp;bgcolor1=189ca8&amp;bgcolor2=085c68&amp;playercolor=085c68" />
        <embed src="<%=CkartrisBLL.WebShopURL%>UserControls/MediaTemplates/flvplayer.swf" flashvars="file=<%=Me.Attributes("Source")%>&amp;height=<%=Me.Attributes("Height") %>&amp;width=<%=Me.Attributes("width")%>&amp;showstop=1&amp;showvolume=1&amp;showtime=1&amp;bgcolor1=189ca8&amp;bgcolor2=085c68&amp;playercolor=085c68" quality="<%=Me.Attributes("Quality") %>"
            name="<%=Me.Attributes("MovieName") %>" width="<%=Me.Attributes("Width")%>" height="<%=Me.Attributes("Height")%>" 
            wmode="transparent" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer"/></embed>
    </object>
</video> 
 