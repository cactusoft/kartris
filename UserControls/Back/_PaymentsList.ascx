<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_PaymentsList.ascx.vb"
    Inherits="UserControls_Back_PaymentsList" %>
<%@ Register TagPrefix="_user" TagName="ItemPager" Src="~/UserControls/Back/_ItemPagerAjax.ascx" %>
<div>                
    <a class="linkbutton icon_new floatright" href="_ModifyPayment.aspx">
        <asp:Literal ID="lnkAddNewPayment" runat="server" EnableViewState="false" Text="<%$ Resources: _Kartris, FormButton_New %>"></asp:Literal></a>
    <br />
    <asp:PlaceHolder runat="server" ID="phdDateNavigation">
        <div class="breadcrumbtrail">
            <span><span>
                <asp:LinkButton runat="server" ID="btnYesterday" /></span></span> <span><span class="middle">
                    <asp:Literal ID="litToday" runat="server" Text=''></asp:Literal></span></span>
            <span><span>
                <asp:LinkButton runat="server" ID="btnTomorrow" /></span></span>
            <asp:Literal ID="litSelectedLongDate" runat="server" Text='' Visible="false"></asp:Literal></div>
    </asp:PlaceHolder>
    <asp:GridView CssClass="kartristable" ID="gvwPayments" runat="server" AutoGenerateColumns="False"
        DataKeyNames="Payment_ID" GridLines="None" EnableViewState="true">
        <Columns>
            <asp:BoundField DataField="Payment_ID" HeaderText='<%$ Resources:_Kartris, ContentText_ID%>'
                ItemStyle-CssClass="idfield"></asp:BoundField>
            <asp:TemplateField ItemStyle-CssClass="datefield" HeaderText='<%$ Resources:_Kartris, ContentText_Date %>'>
                <ItemTemplate>
                    <asp:Literal ID="litPaymentDate" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("Payment_Date"), "d", Session("_LANG")) %>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-CssClass="currencyfield" HeaderText='<%$ Resources:_Kartris, ContentText_Value %>'>
                <ItemTemplate>
                    <asp:Literal ID="litPaymentAmount" runat="server" Text='<%# Eval("Payment_Amount") %>'> </asp:Literal>
                    <asp:HiddenField runat="server" EnableViewState="false" ID="hidPaymentCurrencyID" Value='<%#Eval("Payment_CurrencyID")%>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText='<%$ Resources:_Kartris, ContentText_CustomerName %>'>
                <ItemTemplate>
                    <a class="linkbutton icon_user" href="_ModifyCustomerStatus.aspx?CustomerID=<%#Eval("Payment_CustomerID") %>">
                        <asp:Label ID="lblPaymentBillingName" runat="server" Text='<%# Eval("U_AccountHolderName") %>'></asp:Label></a>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-CssClass="selectfield">
                <ItemTemplate>
                    <a class="linkbutton icon_edit" href="_ModifyPayment.aspx?PaymentID=<%#Eval("Payment_ID") %>&amp;FromDate=<%# TagIfReturnToDate() %>&amp;Page=<%# CurrentPageNumber() %>">
                        <asp:Literal ID="litOLIndicates" runat="server" EnableViewState="false" Text="<%$ Resources:_Kartris, FormButton_Select %>"></asp:Literal></a>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <div class="spacer">
    </div>

    <_user:ItemPager runat="server" ID="_UC_ItemPager" />
</div>
