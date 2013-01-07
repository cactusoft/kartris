<%@ Control Language="VB" ClassName="mp3" %>

<embed src="<%=CkartrisBLL.WebShopURL%>UserControls/MediaTemplates/dewplayer-mini.swf" 
        flashvars="mp3=<%=Me.Attributes("Source")%>&amp;autostart=<%=Me.Attributes("autostart")%>&amp;autoreplay=<%=Me.Attributes("autoreplay")%>&amp;showtime=<%=Me.Attributes("showtime")%>&amp;randomplay=<%=Me.Attributes("randomplay")%>&amp;nopointer=<%=Me.Attributes("nopointer")%>"
        wmode="transparent"
        width="<%=Me.Attributes("Width")%>" 
        height="<%=Me.Attributes("Height")%>"
        pluginspage="http://www.macromedia.com/go/getflashplayer">
</embed>
