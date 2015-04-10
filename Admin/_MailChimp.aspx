<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_MailChimp.aspx.vb" Inherits="Admin_MailChimp"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">

    <div id="page_mailchimp">
        <h1>
            <asp:Literal ID="litPageTitle" runat="server" Text="MailChimp" /></h1>
        <%--Markup Prices--%>
        <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
            <ContentTemplate>

                <h2>
                    <asp:Literal ID="litConfigSettings" runat="server" Text='<%$ Resources:_Kartris, BackMenu_ConfigSettings %>'></asp:Literal>: MailChimp</h2>
                <p>
                    <asp:Literal ID="litStatus" runat="server"></asp:Literal>
                    <asp:HyperLink ID="lnkChange" CssClass="linkbutton icon_edit"
                        runat="server" Text="<%$ Resources: _Kartris, ContentText_ConfigChange2 %>"
                        NavigateUrl="_Config.aspx?name=general.mailchimp" />
                </p>
                <div class="Kartris-DetailsView section_languagestrings">
                    <div class="Kartris-DetailsView-Data">
                        <ul>
                            <li>
                                <span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litApiKey" runat="server" Text='general.mailchimp.apikey'></asp:Literal></span>
                                <span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtCFG_Value1" runat="server" Text='' MaxLength="255" Enabled="False" />

                                </span>
                            </li>
                            <li>
                                <span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litApiURL" runat="server" Text='general.mailchimp.apiurl'></asp:Literal></span>
                                <span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtCFG_Value2" runat="server" Text='' MaxLength="255" Enabled="False" /></span>
                            </li>
                            <li>
                                <span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litListID" runat="server" Text='general.mailchimp.listid'></asp:Literal></span>
                                <span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtCFG_Value3" runat="server" Text='' MaxLength="255" Enabled="False" /></span>
                            </li>
                            <li>
                                <span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litStoreID" runat="server" Text='general.mailchimp.storeid'></asp:Literal></span>
                                <span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtCFG_Value4" runat="server" Text='' MaxLength="255" Enabled="False" /></span>
                            </li>
                        </ul>
                    </div>
                    <asp:HyperLink ID="lnkChange2" CssClass="linkbutton icon_edit"
                        runat="server" Text="<%$ Resources: _Kartris, ContentText_ConfigChange2 %>"
                        NavigateUrl="_Config.aspx?name=general.mailchimp" />
                    <br />
                    <br />
                </div>
                <asp:PlaceHolder ID="phdMailChimpAPI" runat="server">
                    <h2>Create MailChimp Store</h2>
                    <div class="Kartris-DetailsView section_languagestrings">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <li>
                                    <span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litStoreName" runat="server" Text='Store Name'></asp:Literal></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtStoreName" runat="server" Text='' MaxLength="255" /></span>
                                </li>
                                <li>
                                    <span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litStoreDomain" runat="server" Text='Store Domain'></asp:Literal></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtStoreDomain" runat="server" Text='' MaxLength="255" /></span>
                                </li>
                                <li>
                                    <span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litStoreEmail" runat="server" Text='Store Email'></asp:Literal></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtStoreEmail" runat="server" Text='' MaxLength="255" /></span>
                                </li>
                                <li>
                                    <div class="submitbuttons">
                                        <asp:Button ID="lnkCreateStore" runat="server" Text='Create MailChimp Store' CssClass="button" CausesValidation="false"></asp:Button>
                                    </div>
                                </li>
                            </ul>
                        </div>


                    </div>
                </asp:PlaceHolder>
                <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
            </ContentTemplate>
        </asp:UpdatePanel>
        <asp:UpdateProgress ID="upgMain" runat="server" AssociatedUpdatePanelID="updMain">
            <ProgressTemplate>
                <div class="loadingimage">
                </div>
                <div class="updateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>

    </div>


</asp:Content>

