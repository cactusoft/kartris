<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_attributes.aspx.vb" Inherits="Admin_Attributes"
MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <h1>
                <asp:Literal ID="litPageTitle" runat="server" Text='<%$ Resources:_Product, FormLabel_TabProductAttributes %>' /></h1>
            <asp:UpdatePanel ID="updAttributes" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:MultiView ID="mvwAttributes" runat="server" ActiveViewIndex="0">
                        <asp:View ID="viwAttributeList" runat="server">
                            <asp:UpdatePanel ID="updAttributeList" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <span class="floatright"><asp:LinkButton ID="lnkBtnNewAttribute" runat="server" Text='<%$ Resources: _Kartris, FormButton_New %>'
                                        CssClass="linkbutton icon_new" /></span><br />
                                    <asp:MultiView ID="mvwAttributeData" runat="server" ActiveViewIndex="0">
                                        <asp:View ID="vwAttributeList" runat="server">
                                            <asp:GridView CssClass="kartristable" ID="gvwAttributes" runat="server" AllowPaging="True" AllowSorting="true"
                                                AutoGenerateColumns="False" DataKeyNames="ATTRIB_ID" AutoGenerateEditButton="False"
                                                GridLines="None" PagerSettings-PageButtonCount="10" PageSize="15" SelectedIndex="0">
                                                <FooterStyle />
                                                <RowStyle />
                                                <Columns>
                                                    <asp:TemplateField>
                                                        <HeaderTemplate>
                                                        </HeaderTemplate>
                                                        <ItemStyle CssClass="recordnumberfield" />
                                                        <ItemTemplate>
                                                            <asp:Literal ID="litRecordNumber" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal></ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:BoundField DataField="ATTRIB_ID" HeaderText="ID" ItemStyle-CssClass="itemname"
                                                        Visible="false">
                                                        <HeaderStyle />
                                                    </asp:BoundField>
                                                    <asp:BoundField DataField="ATTRIB_Name" HeaderText='<%$ Resources:_Attributes, FormLabel_AttributeName %>'>
                                                        <HeaderStyle />
                                                    </asp:BoundField>
                                                    <asp:BoundField DataField="ATTRIB_TypeModified" HeaderText='<%$ Resources:_Attributes, FormLabel_AttributeType %>'>
                                                        <HeaderStyle />
                                                    </asp:BoundField>
                                                    <asp:BoundField DataField="ATTRIB_CompareModified" HeaderText='<%$ Resources:_Attributes, FormLabel_Compare %>'>
                                                        <HeaderStyle />
                                                    </asp:BoundField>
                                                    <asp:TemplateField>
                                                        <HeaderTemplate>
                                                            <asp:Literal ID="litFormLabelSpecialUse" runat="server" Text='<%$ Resources: _Attributes, FormLabel_SpecialUse %>' />
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <asp:CheckBox ID="chkATTRIB_Special" runat="server" Checked='<%# Eval("ATTRIB_Special") %>'
                                                                CssClass="checkbox" Enabled="false" />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField>
                                                        <HeaderTemplate>
                                                            <asp:Literal ID="litFormLabelLive" runat="server" Text='<%$ Resources:_Kartris, FormLabel_Live %>' />
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <asp:CheckBox ID="chkATTRIB_Live" runat="server" Checked='<%# Eval("ATTRIB_Live") %>'
                                                                CssClass="checkbox" Enabled="false" />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField ItemStyle-CssClass="selectfield">
                                                        <HeaderTemplate>
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <asp:LinkButton ID="lnkBtnEditAttribute" runat="server" CommandName="EditAttribute"
                                                                CommandArgument='<%# Container.DataItemIndex %>' Text='<%$ Resources: _Kartris, FormButton_Edit %>'
                                                                CssClass="linkbutton icon_edit" />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </asp:View>
                                        <asp:View ID="vwNoItems" runat="server">
                                            <asp:Panel ID="pnlNoItems" runat="server" CssClass="noresults">
                                                <asp:Literal ID="litNoItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                                                </asp:Literal>
                                            </asp:Panel>
                                        </asp:View>
                                    </asp:MultiView>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </asp:View>
                        <asp:View ID="vwEditAttribute" runat="server">
                            <asp:UpdatePanel ID="updEditAttribute" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <_user:EditAttribute ID="_UC_EditAttribute" runat="server" />
                                </ContentTemplate>
                            </asp:UpdatePanel>
                            <asp:UpdatePanel ID="updEditAttributeAndConfirm" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                                        <asp:LinkButton ID="lnkBtnSave" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                            ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                                        <asp:LinkButton ID="lnkBtnCancel" runat="server" CssClass="button cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                            ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                                        <span class="floatright">
                                            <asp:LinkButton ID="lnkBtnDelete" CssClass="button deletebutton"
                                                runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>' ToolTip='<%$ Resources: _Kartris, FormButton_Delete %>' /></span>
                                        <asp:ValidationSummary ID="valSummary" runat="server" ForeColor="" CssClass="valsummary"
                                            DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                                    </div>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </asp:View>
                    </asp:MultiView>
                </ContentTemplate>
            </asp:UpdatePanel>
            <asp:UpdateProgress ID="prgAttributes" runat="server" AssociatedUpdatePanelID="updAttributes">
                <ProgressTemplate>
                    <div class="loadingimage">
                    </div>
                    <div class="updateprogress">
                    </div>
                </ProgressTemplate>
            </asp:UpdateProgress>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>