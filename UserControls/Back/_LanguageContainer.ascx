<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_LanguageContainer.ascx.vb" Inherits="_LanguageContainer" %>
<%@ Register TagPrefix="_user" TagName="LanguageContent" Src="~/UserControls/Back/_LanguageContent.ascx" %>
<asp:UpdatePanel ID="updLanguageStrings" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <%-- // Dynamically the Tab Container will be added here // --%>
    </ContentTemplate>
</asp:UpdatePanel>
