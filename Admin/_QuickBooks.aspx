<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_QuickBooks.aspx.vb" Inherits="Admin_QuickBooks"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_quickbooks">
        <asp:Literal ID="litMessage" runat="server" Visible="false" />
        <asp:PlaceHolder ID="phdMainContent" runat="server">
            <asp:UpdatePanel runat="server" ID="updQuickBooks" UpdateMode="Conditional">
                <ContentTemplate>
                    <h1>
                        <asp:Literal ID="litPageTitleQBIntegration" runat="server" Text="<%$ Resources:_QuickBooks, PageTitle_QBIntegration %>"></asp:Literal></h1>
                    <p>
                        <asp:Literal ID="litContentTextQBSeeManual" runat="server" Text="<%$ Resources:_QuickBooks, ContentText_QBSeeManual %>"></asp:Literal></p>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblFormLabelPassword" runat="server" AssociatedControlID="txtQBWCPassword"></asp:Label></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtQBWCPassword" TextMode="Password" EnableViewState="true" onclick="this.value = '';"
                                            runat="server"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="valQBWCPassword" runat="server" ControlToValidate="txtQBWCPassword"
                                            Enabled="true" CssClass="error" ForeColor="" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>" />
                                        <asp:Button CausesValidation="false" ID="btnUpdate" runat="server" Text="<%$ Resources:_Kartris, FormButton_Update %>"
                                            CssClass="button" /></span> </li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblFormLabelQBPollInterval" runat="server" Text="<%$ Resources:_QuickBooks, FormLabel_QBPollInterval %>"
                                        AssociatedControlID="txtInterval"></asp:Label></span> <span class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtInterval" Text="5" Width="40" runat="server"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="valInterval" runat="server" ControlToValidate="txtInterval"
                                                Enabled="true" CssClass="error" ForeColor="" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>" />
                                            <ajaxToolkit:FilteredTextBoxExtender ID="filInterval" runat="server" TargetControlID="txtInterval"
                                                FilterType="Numbers" />
                                        </span></li>
                            </ul>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
            <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                <asp:LinkButton ID="btnGenerate" CausesValidation="false" runat="server" Text="<%$ Resources:_QuickBooks, FormButton_QBCreateQWCFile %>"
                ToolTip="<%$ Resources:_QuickBooks, FormButton_QBCreateQWCFile %>"
                    CssClass="button exportbutton" /></div>
        </asp:PlaceHolder>
    </div>
</asp:Content>
