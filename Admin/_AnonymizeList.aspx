<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_AnonymizeList.aspx.vb"
    Inherits="Admin_WholesaleApplicationsList" MasterPageFile="~/Skins/Admin/Template.master" %>
<%@ Register TagPrefix="user" TagName="AddressDetails" Src="~/UserControls/General/AddressDetails.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_customergroupslist">
        <h1>
            <asp:Literal ID="litCustomersListTitle" runat="server" Text='Anonymization List'></asp:Literal></h1>
        <asp:UpdatePanel ID="updCGDetails" runat="server" UpdateMode="Conditional">
            <ContentTemplate>

                <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                    <asp:LinkButton CausesValidation="True" CssClass="button anonymizebutton" runat="server" OnClick="btnAnonymize_Click"
                        ID="btnAnonymize" Text="Anonymize" ToolTip="Anonymize" />
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
                        <asp:TemplateField HeaderText='Order Last Modified Date'>
                            <ItemTemplate>
                                    <asp:Literal ID="O_LastModified" runat="server" Text='<%# Eval("O_LastModified") %>'></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText='Order Cancelled'>
                            <ItemTemplate>
                                    <asp:Literal ID="O_Cancelled" runat="server" Text='<%# Eval("O_Cancelled") %>'></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText='Order Shipped'>
                            <ItemTemplate>
                                    <asp:Literal ID="O_Shipped" runat="server" Text='<%# Eval("O_Shipped") %>'></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText='Order Paid'>
                            <ItemTemplate>
                                    <asp:Literal ID="O_Paid" runat="server" Text='<%# Eval("O_Paid") %>'></asp:Literal>
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
