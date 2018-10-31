<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_AnonymizeList.aspx.vb"
    Inherits="Admin_WholesaleApplicationsList" MasterPageFile="~/Skins/Admin/Template.master" %>
<%@ Register TagPrefix="user" TagName="AddressDetails" Src="~/UserControls/General/AddressDetails.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_anonymize">
        <h1>
            <asp:Literal ID="litCustomersListTitle" runat="server" Text='<%$ Resources:_GDPR, BackMenu_AnonymizationList %>'></asp:Literal></h1>
        <asp:UpdatePanel ID="updCGDetails" runat="server" UpdateMode="Conditional">
            <ContentTemplate>

                <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                    <asp:LinkButton CausesValidation="True" CssClass="button anonymizebutton" runat="server" OnClick="btnAnonymize_Click"
                        ID="btnAnonymize" Text='<%$ Resources:_GDPR, FormButton_Anonymize %>' ToolTip='<%$ Resources:_GDPR, FormButton_Anonymize %>' />
                </div>
                <asp:GridView ID="gvwCustomers" CssClass="kartristable" runat="server" AutoGenerateColumns="False" GridLines="None"
                    AllowPaging="false" DataKeyNames="U_ID">
                    <Columns>
                         <asp:TemplateField HeaderText='<%$ Resources:_Kartris, ContentText_Email %>'>
                            <ItemTemplate>
                                <a class="linkbutton icon_mail normalweight" href='mailto:<%# Eval("U_EmailAddress") %>'>
                                    <asp:Literal ID="U_EmailAddress" runat="server" Text='<%# Eval("U_EmailAddress") %>'></asp:Literal></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText='<%$ Resources:_Orders, ContentText_LastUpdate %>'>
                            <ItemTemplate>
                                    <asp:Literal ID="O_LastModified" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("O_LastModified"), "t", Session("_LANG")) %>'></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:CheckBox ID="chkCancelled" runat="server" Text='<%$ Resources:_Orders, ContentText_OrderStatusCancelled %>' Enabled="false" Checked='<%# Eval("O_Cancelled") %>'/><br />
                                <asp:CheckBox ID="chkShipped" runat="server" Text='<%$ Resources:_Orders, ContentText_OrderStatusShipped %>' Enabled="false" Checked='<%# Eval("O_Shipped") %>'/><br />
                                <asp:CheckBox ID="chkPaid" runat="server" Text='<%$ Resources:_Orders, ContentText_OrderStatusPaid %>' Enabled="false" Checked='<%# Eval("O_Paid") %>'/>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="U_ID" HeaderText="U_ID" SortExpression="U_ID" Visible="False" />
                    </Columns>
                </asp:GridView>

            </ContentTemplate>
        </asp:UpdatePanel>
        
                        
        <asp:UpdateProgress ID="upgCGDetails" runat="server" AssociatedUpdatePanelID="updCGDetails">
            <ProgressTemplate>
                <div class="loadingimage">
                </div>
                <div class="updateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
    </div>
    <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
</asp:Content>
