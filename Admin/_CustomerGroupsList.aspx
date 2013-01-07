<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_CustomerGroupsList.aspx.vb"
    Inherits="Admin_CustomerGroupsList" MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_customergroupslist">
        <h1>
            <asp:Literal ID="litCustomersListTitle" runat="server" Text="<%$ Resources: PageTitle_CustomerGroups %>"></asp:Literal></h1>
        <div>
            <a class="linkbutton icon_mail" href="_CustomersList.aspx?mode=ml">
                <asp:Literal ID="litBackMenuMailingList" runat="server" Text="<%$ Resources: _Kartris, BackMenu_MailingList %>"></asp:Literal></a>
            <a class="linkbutton icon_edit" href="_CustomersList.aspx?mode=af">
                <asp:Literal ID="litBackMenuAffiliates" runat="server" Text="<%$ Resources: _Kartris, BackMenu_Affiliates %>"></asp:Literal></a></div>
        <asp:UpdatePanel ID="updCGDetails" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:MultiView ID="mvwCustomerGroups" runat="server" ActiveViewIndex="0">
                    <asp:View ID="viwMain" runat="server">
                        <asp:LinkButton ID="lnkBtnNewCG" runat="server" Text='<%$ Resources: _Kartris, FormButton_New %>'
                            CssClass="linkbutton icon_new floatright " /><br />
                        <asp:MultiView ID="mvwCustomerGroupList" runat="server" ActiveViewIndex="0">
                            <asp:View ID="viwCGData" runat="server">
                                <asp:GridView ID="gvwCustomers" CssClass="kartristable" runat="server" AutoGenerateColumns="False" GridLines="None"
                                    AllowPaging="False" DataKeyNames="CG_ID">
                                    <Columns>
                                        <asp:BoundField DataField="CG_Name" SortExpression="CG_Name" ItemStyle-CssClass="itemname" />
                                        <asp:BoundField DataField="CG_Discount" HeaderText="<%$ Resources: _Kartris, FormLabel_Discount %>"
                                            SortExpression="CG_Discount" ItemStyle-CssClass="alignright" HeaderStyle-CssClass="alignright" />
                                        <asp:TemplateField HeaderText="<%$ Resources: _Kartris, ContentText_Live %>" SortExpression="CG_Live"
                                            HeaderStyle-CssClass="alignright">
                                            <ItemTemplate>
                                                <asp:CheckBox ID="chkCG_Live" CssClass="checkbox" runat="server" Checked='<%# Bind("CG_Live") %>'
                                                    Enabled="false" />
                                            </ItemTemplate>
                                            <ItemStyle CssClass="alignright" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditCustomerGroup" CommandArgument='<%# Container.DataItemIndex %>'
                                                    Text="<%$Resources: _Kartris, FormButton_Edit %>" CssClass="linkbutton icon_edit floatright" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="CG_ID" HeaderText="CG_ID" SortExpression="CG_ID" Visible="False" />
                                    </Columns>
                                </asp:GridView>
                            </asp:View>
                            <asp:View ID="viwCGNoItems" runat="server">
                                <asp:Panel ID="pnlNoItems" runat="server" CssClass="noresults">
                                    <asp:Literal ID="litNoItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                                    </asp:Literal>
                                </asp:Panel>
                            </asp:View>
                        </asp:MultiView>
                    </asp:View>
                    <asp:View ID="viwDetails" runat="server">
                        <asp:Literal ID="litCustomerGroupID" runat="server" Text="0" Visible="false" />
                        <br />
                        <%-- LanguageElements --%>
                        <div>
                            <asp:UpdatePanel ID="updLanguageContainer" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:PlaceHolder ID="phdLanguageContainer" runat="server">
                                        <_user:LanguageContainer ID="_UC_LangContainer" runat="server" />
                                    </asp:PlaceHolder>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                        <div class="line">
                        </div>
                        <div class="Kartris-DetailsView">
                            <div class="Kartris-DetailsView-Data">
                                <ul>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblCGLive" runat="server" Text="<%$ Resources: _Kartris, ContentText_Live %>" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:CheckBox runat="server" ID="chkCGLive" CssClass="checkbox" /></span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblCGDiscount" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Discount %>" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtDiscount" runat="server" CssClass="shorttext" MaxLength="8" />
                                            <asp:RequiredFieldValidator ID="valRequiredDiscount" runat="server" CssClass="error"
                                                ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                ControlToValidate="txtDiscount" SetFocusOnError="true" Display="Dynamic" />
                                            <asp:RegularExpressionValidator ID="valRegexDiscount" runat="server" Display="Dynamic"
                                                SetFocusOnError="true" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                                                CssClass="error" ForeColor="" ControlToValidate="txtDiscount" ValidationExpression="<%$ AppSettings:DecimalRegex %>" />
                                            <ajaxToolkit:FilteredTextBoxExtender ID="filPriceIncTax" runat="server" TargetControlID="txtDiscount"
                                                FilterType="Numbers,Custom" ValidChars=".," />
                                        </span></li>
                                </ul>
                            </div>
                        </div>
                        <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                            <asp:LinkButton ID="lnkBtnSave" runat="server" Text="<%$ Resources: _Kartris, FormButton_Save %>"
                                ToolTip="<%$ Resources: _Kartris, FormButton_Save %>" CssClass="button savebutton" />
                            <asp:LinkButton ID="lnkBtnCancel" runat="server" Text="<%$ Resources: _Kartris, FormButton_Cancel %>"
                                ToolTip="<%$ Resources: _Kartris, FormButton_Cancel %>" CssClass="button cancelbutton" /><asp:ValidationSummary
                                    ID="valSummary" runat="server" ForeColor="" CssClass="valsummary" DisplayMode="BulletList"
                                    HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                        </div>
                    </asp:View>
                </asp:MultiView>
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
