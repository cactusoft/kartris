<%@ Control Language="VB" ClassName="mp3" %>

<audio controls>
  <source src="<%=Me.Attributes("Source")%>" type="audio/mpeg">
Your browser does not support the audio element.
</audio>
