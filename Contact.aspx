<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Kartris/Template.master"
    AutoEventWireup="false" CodeFile="contact.aspx.vb" Inherits="contact" %>

<asp:Content ID="cntMain" ContentPlaceHolderID="cntMain" runat="Server">
    <div id="contact">
        <h1>
            <asp:Literal ID="litPageTitleContactUs" runat="server" Text="<%$ Resources: Kartris, PageTitle_ContactUs %>" /></h1>
        <!-- ALTERNATIVE POSITION FOR CONTACT TEXT -->
        <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:MultiView ID="mvwWriting" runat="server" ActiveViewIndex="0">
                    <asp:View ID="viwWritingForm" runat="server">
                        <div class="inputform">
                            <asp:UpdatePanel ID="updWritingForm" runat="server">
                                <ContentTemplate>
                                    <asp:Panel ID="pnlContactForm" runat="server" DefaultButton="btnSendMessage">
                                        <div class="Kartris-DetailsView">
                                            <div class="Kartris-DetailsView-Data">
                                                <ul>
                                                    <!-- Name -->
                                                    <li><span class="Kartris-DetailsView-Name">
                                                        <asp:Label ID="lblName" runat="server" Text="<%$ Resources:ContactUs, ContentText_YourName %>"
                                                            AssociatedControlID="txtName" CssClass="requiredfield"></asp:Label></span><span class="Kartris-DetailsView-Value">
                                                                <asp:TextBox ID="txtName" runat="server" MaxLength="30" /></span>
                                                                <asp:RequiredFieldValidator EnableClientScript="True" ID="valName" runat="server"
                                                                    ControlToValidate="txtName" ValidationGroup="ContactForm" CssClass="error" ForeColor=""
                                                                    Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator></li>
                                                    <!-- Email -->
                                                    <li><span class="Kartris-DetailsView-Name">
                                                        <asp:Label ID="lblEmail" runat="server" Text="<%$ Resources:ContactUs, ContentText_YourEmail %>"
                                                            AssociatedControlID="txtEmail" CssClass="requiredfield"></asp:Label></span><span
                                                                class="Kartris-DetailsView-Value">
                                                                <asp:TextBox ID="txtEmail" runat="server" MaxLength="75" /></span>
                                                                <asp:RequiredFieldValidator ID="valEmail" runat="server" ControlToValidate="txtEmail"
                                                                    ValidationGroup="ContactForm" CssClass="error" ForeColor="" Display="Dynamic"
                                                                    Text="<%$ Resources: Kartris, ContentText_RequiredField %>" EnableClientScript="True"></asp:RequiredFieldValidator><asp:RegularExpressionValidator
                                                                        EnableClientScript="True" ID="valEmail2" runat="server" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                                                        ControlToValidate="txtEmail" CssClass="error" ForeColor="" Display="Dynamic"
                                                                        Text="<%$ Resources: Kartris, ContentText_BadEmail %>" ValidationGroup="ContactForm"></asp:RegularExpressionValidator></li>
                                                    <!-- Message -->
                                                    <li><span class="Kartris-DetailsView-Name">
                                                        <asp:Label ID="lblMessage" runat="server" Text="<%$ Resources:ContactUs, ContentText_YourMessageComments %>"
                                                            AssociatedControlID="txtMessage" CssClass="requiredfield"></asp:Label></span><span
                                                                class="Kartris-DetailsView-Value">
                                                                <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine" MaxLength="4000" /></span>
                                                                <asp:RequiredFieldValidator EnableClientScript="True" ID="valMessage" runat="server"
                                                                    ControlToValidate="txtMessage" ValidationGroup="ContactForm" CssClass="error"
                                                                    ForeColor="" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator></li>
                                                    <li><span class="Kartris-DetailsView-Name"></span><span class="Kartris-DetailsView-Value">
                                                        <asp:UpdatePanel ID="updIncludeItems" runat="server" UpdateMode="Conditional" RenderMode="Inline">
                                                            <ContentTemplate>
                                                                <asp:CheckBox ID="chkIncludeItems" Checked="true" runat="server" Text="<%$ Resources:ContactUs, ContentText_IncludeBasketInEmail %>"
                                                                    CssClass="checkbox" />
                                                            </ContentTemplate>
                                                        </asp:UpdatePanel>
                                                    </span></li>
                                                </ul>
                                            </div>
                                        </div>
                                    </asp:Panel>
                                    <user:PopupMessage ID="popErrors" runat="server" />
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                        <div class="spacer">
                        </div>
                        <div class="submitbuttons">
                            <asp:Button ID="btnSendMessage" runat="server" ValidationGroup="ContactForm" CssClass="button"
                                Text="<%$ Resources:Kartris, FormButton_Submit %>" />
                            <asp:ValidationSummary ValidationGroup="ContactForm" ID="valSummary" runat="server"
                                CssClass="valsummary" DisplayMode="BulletList" ForeColor="" HeaderText="<%$ Resources: Kartris, ContentText_Errors %>" />
                            <ajaxToolkit:NoBot ID="ajaxNoBotContact" runat="server" 
                                ResponseMinimumDelaySeconds="2"
                                CutoffWindowSeconds="60"
                                CutoffMaximumInstances="5" />
                        </div>
                        <!--
                        CONTACT ADDRESS & PHONE
                        You can move this section if necessary to the
                        'alternative position' marked above.
                        -->
                        <div>
                            <p>
                                <asp:Literal ID="litContentTextAddressAndPhoneContact" runat="server" Text="<%$ Resources: ContactUs, ContentText_AddressAndPhoneContact %>" /></p>
                        </div>
                        <!-- END OF SECTION -->
                    </asp:View>
                    <asp:View ID="viwWritingResult" runat="server">
                        <div class="contact inputform">
                            <p>
                                <asp:Literal ID="litResult" runat="server" /></p>
                        </div>
                    </asp:View>
                </asp:MultiView>
            </ContentTemplate>
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
