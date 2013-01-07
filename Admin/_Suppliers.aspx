<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_suppliers.aspx.vb" Inherits="Admin_Suppliers"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_customergroupslist">
        <h1>
            <asp:Literal ID="litSuppliersTitle" runat="server" Text="<%$ Resources: _Suppliers, PageTitle_Suppliers %>" /></h1>
        <asp:UpdatePanel ID="updSupplierDetails" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:MultiView ID="mvwSuppliers" runat="server" ActiveViewIndex="0">
                    <asp:View ID="viwSuppliersData" runat="server">
                        <asp:LinkButton ID="lnkBtnNewSupplier" runat="server" Text='<%$ Resources: _Kartris, FormButton_New %>'
                            CssClass="linkbutton icon_new floatright " /><br />
                        <asp:MultiView ID="mvwSuppliersData" runat="server">
                            <asp:View ID="viwSuppliersList" runat="server">
                                <asp:GridView CssClass="kartristable" ID="gvwSuppliers" runat="server" AutoGenerateColumns="False" GridLines="None"
                                    AllowPaging="False" DataKeyNames="SUP_ID">
                                    <Columns>
                                        <asp:BoundField DataField="SUP_Name" HeaderText="<%$ Resources: _Suppliers, ContentText_SupplierName %>"
                                            SortExpression="SUP_Name" ItemStyle-CssClass="itemname" />
                                        <asp:TemplateField HeaderText="<%$ Resources: _Kartris, ContentText_Live %>" SortExpression="SUP_Live"
                                            HeaderStyle-CssClass="alignright">
                                            <ItemTemplate>
                                                <asp:CheckBox ID="chkSup_Live" CssClass="checkbox" runat="server" Checked='<%# Bind("SUP_Live") %>'
                                                    Enabled="false" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditSupplier" CommandArgument='<%# Container.DataItemIndex %>'
                                                    Text="<%$Resources: _Kartris, FormButton_Edit %>" CssClass="linkbutton icon_edit floatright" /><asp:LinkButton
                                                        ID="lnkProducts" runat="server" CommandName="viwLinkedProducts" CommandArgument='<%# Container.DataItemIndex %>'
                                                        Text="<%$Resources: _Suppliers, ContentText_LinkedProducts %>" CssClass="linkbutton icon_edit normalweight floatright" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </asp:View>
                            <asp:View ID="viwNoItems" runat="server">
                                <asp:Panel runat="server" ID="pnlNoSuppliers" CssClass="noresults">
                                    <asp:Literal ID="litNoSuppliers" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" />
                                </asp:Panel>
                            </asp:View>
                        </asp:MultiView>
                    </asp:View>
                    <asp:View ID="viwDetails" runat="server">
                        <asp:Literal ID="litSupplierID" runat="server" Text="0" Visible="false" />
                        <asp:Literal ID="litContentTextSupplierText" runat="server" Text="<%$ Resources: _Suppliers, ContentText_SupplierText %>" />
                        <div class="Kartris-DetailsView">
                            <div class="Kartris-DetailsView-Data">
                                <ul>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litName" runat="server" Text="<%$ Resources: _Suppliers, ContentText_SupplierName %>" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtSupplierName" runat="server" MaxLength="60"></asp:TextBox><asp:RequiredFieldValidator
                                                ID="valRequiredNewDesc" runat="server" CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                ControlToValidate="txtSupplierName" ValidationGroup="Supplier" SetFocusOnError="True" /></span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Literal ID="litLive" runat="server" Text="<%$ Resources: _Kartris, ContentText_Live %>" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:CheckBox ID="chkSupplierLive" runat="server" CssClass="checkbox" /></span></li>
                                </ul>
                            </div>
                        </div>
                        <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                            <asp:LinkButton ID="lnkBtnSave" runat="server" Text="<%$ Resources: _Kartris, FormButton_Save %>"
                            ToolTip="<%$ Resources: _Kartris, FormButton_Save %>"
                                CssClass="button savebutton" ValidationGroup="Supplier" />
                            <asp:LinkButton ID="lnkBtnCancel" runat="server" Text="<%$ Resources: _Kartris, FormButton_Cancel %>"
                            ToolTip="<%$ Resources: _Kartris, FormButton_Cancel %>"
                                CssClass="button cancelbutton" /><asp:ValidationSummary ID="valSummary" runat="server"
                                    ForeColor="" CssClass="valsummary" DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>"
                                    ValidationGroup="Supplier" />
                        </div>
                    </asp:View>
                    <asp:View ID="viwLinkedProducts" runat="server">
                        <h2>
                            <asp:Literal ID="litContentTextLinkedProducts" runat="server" Text="<%$ Resources: _Suppliers, ContentText_LinkedProducts %>" /></h2>
                        <asp:GridView CssClass="kartristable" ID="gvwLinkedProducts" runat="server" AutoGenerateColumns="False" GridLines="None"
                            PagerSettings-PageButtonCount="10" PageSize="10" AllowPaging="True" DataKeyNames="P_ID">
                            <Columns>
                                <asp:BoundField DataField="P_Name" HeaderText="<%$ Resources: _Kartris, ContentText_Product %>"
                                    SortExpression="SUP_Name" ItemStyle-CssClass="itemname" />
                                <asp:TemplateField HeaderText="">
                                    <ItemTemplate>
                                        <asp:Hyperlink ID="lnkEdit" runat="server" NavigateUrl='<%# "~/Admin/_ModifyProduct.aspx?ProductID=" & Eval("P_ID") %>'
                                            Text="<%$Resources: _Kartris, FormButton_Edit %>" CssClass="linkbutton icon_edit floatright" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <asp:LinkButton ID="lnkBtnHideLinkedProducts" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>'
                            CssClass="linkbutton icon_back" />
                        <asp:Panel ID="pnlNoLinkedProducts" runat="server" CssClass="noresults">
                            <asp:Literal ID="litNoLinkedProducts" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" />
                        </asp:Panel>
                    </asp:View>
                </asp:MultiView>
            </ContentTemplate>
        </asp:UpdatePanel>
        <asp:UpdateProgress ID="upgSupplierDetails" runat="server" AssociatedUpdatePanelID="updSupplierDetails">
            <ProgressTemplate>
                <div class="loadingimage">
                </div>
                <div class="updateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
    </div>
    <_user:popupmessage id="_UC_PopupMsg" runat="server" />
</asp:Content>
