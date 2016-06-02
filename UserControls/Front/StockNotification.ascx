<%@ Control Language="VB" AutoEventWireup="false" CodeFile="StockNotification.ascx.vb" Inherits="UserControls_Front_StockNotification" %>
<!--
===============================
STOCK NOTIFICATION
===============================
-->
<asp:UpdatePanel ID="updPnlStockNotification" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Panel ID="pnlStockNotification" DefaultButton="btnSave" runat="server" CssClass="popup popup_customization" Visible="true">
            <h2>
                <asp:Literal ID="litContentStockNotifications" runat="server" Text='<%$ Resources: StockNotification, ContentText_NotifyMe %>'
                    EnableViewState="false" /></h2>
            <asp:LinkButton ID="lnkClose" runat="server" Text="×" CssClass="closebutton" />

            <asp:Literal ID="litDetails" runat="server"></asp:Literal>

            <br /><br />

            <asp:Label ID="lblEmail" runat="server" AssociatedControlID="txtEmail" Text='<%$ Resources: ContactUs, ContentText_YourEmail %>'></asp:Label>
            <br />
            <!-- Customization Text Box & Validator -->
            <asp:TextBox ID="txtEmail" runat="server" TextMode="SingleLine" CssClass="longtext" ValidationGroup="<%# UniqueValidationGroup %>"></asp:TextBox>
            <asp:RequiredFieldValidator EnableClientScript="True" ID="valEmail" runat="server"
                ControlToValidate="txtEmail" CssClass="error"
                ForeColor="" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>" ValidationGroup="<%# UniqueValidationGroup %>"></asp:RequiredFieldValidator>
            <asp:RegularExpressionValidator
                EnableClientScript="True" ID="valEmail2" runat="server" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                ControlToValidate="txtEmail" CssClass="error" ForeColor="" Display="Dynamic"
                Text="<%$ Resources: Kartris, ContentText_BadEmail %>" ValidationGroup="<%# UniqueValidationGroup %>"></asp:RegularExpressionValidator>
            <!-- Save Button -->
            <div class="submitbuttons">
                <asp:Button ID="btnSave" runat="server" CssClass="button"
                    Text='<%$ Resources: Kartris, FormLabel_Save %>' UseSubmitBehavior="True" ValidationGroup="<%# UniqueValidationGroup %>" />
                <ajaxToolkit:NoBot ID="ajaxNoBotContact" runat="server"
                    ResponseMinimumDelaySeconds="2"
                    CutoffWindowSeconds="60"
                    CutoffMaximumInstances="5" />


                <!-- Store info in hidden fields -->
                <asp:HiddenField ID="hidVersionID" runat="server" />
                <asp:HiddenField ID="hidPageLink" runat="server" />
                <asp:HiddenField ID="hidVersionName" runat="server" />
                <asp:HiddenField ID="hidProductName" runat="server" />
                <asp:HiddenField ID="hidLanguageID" runat="server" />
            </div>
        </asp:Panel>
        <ajaxToolkit:ModalPopupExtender ID="popStockNotification" runat="server" TargetControlID="lnkClose"
            PopupControlID="pnlStockNotification" BackgroundCssClass="popup_background" OkControlID="lnkClose"
            CancelControlID="lnkClose" DropShadow="False">
        </ajaxToolkit:ModalPopupExtender>
    </ContentTemplate>
</asp:UpdatePanel>
