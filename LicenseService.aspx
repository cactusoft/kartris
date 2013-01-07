<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Kartris/Template.master" AutoEventWireup="false" CodeFile="LicenseService.aspx.vb" Inherits="LicenseService" %>

<asp:Content ID="Content1" ContentPlaceHolderID="cntMain" Runat="Server">
    <div id="contact">
    <%--<div class="breadcrumbtrail">
            <asp:SiteMapPath ID="smpTrail2" PathSeparator="<% $Resources: Kartris, ContentText_BreadcrumbSeparator %>" runat="server" SiteMapProvider="BreadCrumbSiteMap" />
        </div>--%>
        <h1>License Service</h1>
    <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
    <asp:MultiView ID="mvwMain" runat="server" ActiveViewIndex="0">
        <asp:View ID="viwKartrisSite" runat="server">
        
            <div class="Kartris-DetailsView">
                <div class="Kartris-DetailsView-Data">
                    <ul>
                        <li><span class="Kartris-DetailsView-Name">
                            <asp:Label ID="lblName" runat="server" Text="Domain Name" AssociatedControlID="txtDomain"
                                CssClass="requiredfield"></asp:Label></span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtDomain" runat="server" MaxLength="30" />
                                    <asp:RegularExpressionValidator ID="revDomain" runat="server" Text="incorrect domain!"
                                        ForeColor="" Display="Dynamic" ValidationExpression="http(s)?://([\w-]+\.)+[\w-]+(/[\w- ./?%&amp;=]*)?"
                                        CssClass="error" ValidationGroup="LicenseService" ControlToValidate="txtDomain" />
                                    <asp:RequiredFieldValidator EnableClientScript="True" ID="valName" runat="server"
                                        ControlToValidate="txtDomain" ValidationGroup="LicenseService" CssClass="error"
                                        ForeColor="" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator>
                                        <br />
                                    <p> example: http://www.mydomain.com </p>
                                        </span></li>
                    </ul>
                </div>
            </div>
            <div class="submitbuttons">
                <asp:Button ID="btnSubmit" runat="server" ValidationGroup="LicenseService" CssClass="button"
                    Text="<%$ Resources:Kartris, FormButton_Submit %>" />
            </div>
        </asp:View>
        <asp:View ID="viwDomainExist" runat="server">
            <asp:LinkButton ID="lnkBtnBack1" runat="server" Text="<%$ Resources: Kartris, ContentText_GoBack %>" CssClass="link2 floatright" />
            <asp:Literal ID="litDomainExist" runat="server" />
            <br /><br />
            <asp:HyperLink ID="HyperLink1" runat="server" CssClass="link2" Text="contact us" NavigateUrl="~/Contact.aspx" />
        </asp:View>
        <asp:View ID="viwError" runat="server">
        <asp:LinkButton ID="lnkBtnBack2" runat="server" Text="<%$ Resources: Kartris, ContentText_GoBack %>" CssClass="link2 floatright" />
            <asp:Literal ID="Literal1" runat="server" Text="An Error has been occured." />
            <br /><br />
            <asp:HyperLink ID="HyperLink2" runat="server" CssClass="link2" Text="contact us" NavigateUrl="~/Contact.aspx" />
        </asp:View>
        <asp:View ID="viwNotExist" runat="server">
            <p>
                <asp:Literal ID="litContentTextNotAvailable" runat="server" Text="<%$ Resources: Kartris, ContentText_ContentNotAvailable %>" /></p>
        </asp:View>
    </asp:MultiView>
    </ContentTemplate>
    <Triggers>
        <asp:PostBackTrigger ControlID="btnSubmit" />
    </Triggers>
    </asp:UpdatePanel>
    <asp:UpdateProgress ID="prgMain" runat="server" AssociatedUpdatePanelID="updMain">
            <ProgressTemplate>
                <div class="loadingimage">
                </div>
                <div class="updateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
        </div>
</asp:Content>

