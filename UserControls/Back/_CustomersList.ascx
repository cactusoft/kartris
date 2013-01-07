<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_CustomersList.ascx.vb"
    Inherits="UserControls_Back_CustomersList" %>
<%@ Register TagPrefix="_user" TagName="ItemPager" Src="~/UserControls/Back/_ItemPagerAjax.ascx" %>
<div class="floatright">
    <asp:LinkButton ID="lnkNewLogin" PostBackUrl="~/Admin/_ModifyCustomerStatus.aspx"
        Text="<%$ Resources: _Kartris, FormButton_New %>" CssClass="linkbutton icon_new"
        runat="server" />
</div>
<div>
        
    <asp:GridView CssClass="kartristable" ID="gvwCustomers" runat="server" AutoGenerateColumns="False"
        DataKeyNames="U_ID" GridLines="None" EnableViewState="false">
        <Columns>
            <asp:BoundField DataField="U_AccountHolderName" HeaderText='<%$ Resources:_Kartris, ContentText_CustomerName%>'
                ItemStyle-CssClass="itemname"></asp:BoundField>
            <asp:TemplateField HeaderText='<%$ Resources:_Kartris, ContentText_Email %>'>
                <ItemTemplate>
                    <a class="linkbutton icon_mail normalweight" href='mailto:<%# Eval("U_EmailAddress") %>'>
                        <asp:Literal ID="U_EmailAddress" runat="server" Text='<%# Eval("U_EmailAddress") %>'></asp:Literal></a>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText='<%$ Resources:_Users, ContentText_CustomerBalance%>'>
                <ItemTemplate>
                    <asp:Label ID="lblCustomerBalance" runat="server" Text='<%# CkartrisDataManipulation.FixNullFromDB(Eval("U_CustomerBalance")) %>'/>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:PlaceHolder ID="phdPayment" runat="server"><a class="linkbutton icon_orders normalweight"
                        href="_AffiliatePayRep.aspx?CustomerID=<%#Eval("U_ID") %>">
                        <asp:Literal ID="litPayment" runat="server" Text='<%$Resources: _Kartris, ContentText_Payments %>'></asp:Literal></a>
                    </asp:PlaceHolder>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <a class="linkbutton icon_orders normalweight" href="_OrdersList.aspx?CustomerID=<%#Eval("U_ID") %>&amp;callmode=customer">
                        <asp:Literal ID="litORD" runat="server" Text='<%$Resources: _Customers, ContentText_ListOrders %>'></asp:Literal></a>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-CssClass="selectfield">
                <ItemTemplate>
                    <a class="linkbutton icon_edit" runat="server" id="lnkCustomer" href="~/Admin/_ModifyCustomerStatus.aspx?CustomerID=">
                        <asp:Literal ID="litSelect" runat="server" Text="<%$ Resources:_Kartris, FormButton_Select %>"></asp:Literal></a>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <_user:ItemPager runat="server" ID="_UC_ItemPager" />
    <asp:Literal ID="litNoCustomersFound" runat="server" Text=""></asp:Literal>
    
</div>
