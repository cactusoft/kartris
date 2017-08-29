<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_attributes.aspx.vb" Inherits="Admin_Attributes"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<%@ Register TagPrefix="_user" TagName="_FileUploader" Src="~/UserControls/Back/_FileUploader.ascx" %>
<%@ Register Src="~/UserControls/Back/_PopupAttributeOption.ascx" TagPrefix="_user" TagName="_PopupAttributeOption" %>


<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div id="page_attributes">
                <h1>
                    <asp:Literal ID="litPageTitle" runat="server" Text='<%$ Resources:_Product, FormLabel_TabProductAttributes %>' /></h1>
                <div id="searchboxrow">
                    <div style="display:none;">
                        <asp:TextBox ID="txtSearch" runat="server" /><asp:Button ID="btnSearch" runat="server" Text="<%$ Resources:_Kartris, FormButton_Search %>"
                            CssClass="button" /><asp:Button ID="btnClear" runat="server" Text="<%$ Resources:_Kartris, ContentText_Clear %>"
                                CssClass="button cancelbutton" />
                    </div>
                </div>
                <br />
                <asp:UpdatePanel ID="updAttributes" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:MultiView ID="mvwAttributes" runat="server" ActiveViewIndex="0">
                            <asp:View ID="viwAttributeList" runat="server">
                                <asp:UpdatePanel ID="updAttributeList" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <span class="floatright">
                                            <asp:LinkButton ID="lnkBtnNewAttribute" runat="server" Text='<%$ Resources: _Kartris, FormButton_New %>'
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
                                                                <asp:Literal ID="litRecordNumber" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal>
                                                            </ItemTemplate>
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
                                                                <asp:LinkButton ID="lnkBtnAttributeValues" CssClass="linkbutton icon_edit normalweight"
                                                                    runat="server" Text='<%$ Resources: _Options, ContentText_OptionValues %>' CommandArgument='<%# Eval("ATTRIB_ID") %>'
                                                                    CommandName="EditValues" Visible="false" />
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
                            <asp:View ID="vwEditValues" runat="server">

                                <asp:UpdatePanel ID="updEditValues" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>

                                        <asp:Literal ID="litAttribID" runat="server" Visible="false"></asp:Literal>

                                        <asp:DataList CssClass="kartristable" ID="dtlOptions" runat="server" DataKeyField="ATTRIBO_ID">
                                            <AlternatingItemStyle CssClass="Kartris-GridView-Alternate" />
                                            <SelectedItemStyle CssClass="Kartris-DataList-SelectedItem" />
                                            <HeaderStyle CssClass="header" />
                                            <%-- Header --%>
                                            <HeaderTemplate>
                                                <div class="floatright">
                                                    <asp:LinkButton ID="lnkNewOption" CssClass="linkbutton icon_new" runat="server" Text="<%$ Resources: _Kartris, FormButton_New %>"
                                                        CommandName="new" />
                                                </div>
                                                <div class="column_optionname">
                                                    <asp:Literal ID="litContentTextName" runat="server" Text='<%$ Resources: _Kartris, ContentText_Name %>' />
                                                </div>
                                                <div class="column_misc">
                                                    <asp:Literal ID="litFormLabelOrderByValue" runat="server" Text='<%$ Resources: _Kartris, FormLabel_OrderByValue %>' />
                                                </div>
                                            </HeaderTemplate>
                                            <%-- Item --%>
                                            <ItemTemplate>
                                                <div class="floatright">
                                                    <asp:LinkButton ID="lnkBtnOptionValueEdit" CssClass="linkbutton icon_edit" runat="server"
                                                        Text='<%$ Resources: _Kartris, FormButton_Edit %>' CommandArgument='<%# Eval("ATTRIBO_ID")%>'
                                                        CommandName="edit" />
                                                </div>
                                                <div class="column_optionname">
                                                    <asp:Literal ID="litOptionID" runat="server" Text='<%# Eval("ATTRIBO_ID")%>' Visible="false" />
                                                    <asp:Literal ID="litOptionName" runat="server" Text='<%# Eval("ATTRIBO_Name") %>'></asp:Literal>
                                                </div>
                                                <div class="column_misc">
                                                    <asp:Literal ID="litOPT_DefOrderByValue" runat="server" Text='<%# CkartrisDataManipulation.FixNullFromDB(Eval("ATTRIBO_OrderBYValue"))%>' />
                                                </div>
                                            </ItemTemplate>
                                            <%-- Selected Item --%>
                                            <SelectedItemTemplate>
                                                <div class="Kartris-DetailsView">
                                                    <div class="Kartris-DetailsView-Data">
                                                        <ul>
                                                            <li><span class="Kartris-DetailsView-Name">
                                                                <asp:Literal ID="litContentTextName" runat="server" Text='<%$ Resources: _Kartris, ContentText_Name %>' /></span>
                                                                <span class="Kartris-DetailsView-Value">
                                                                    <asp:Literal ID="litOptionID" runat="server" Text='<%# Eval("ATTRIBO_ID")%>' Visible="false" /><asp:Literal
                                                                        ID="litOptionName" runat="server" Text='<%# Eval("ATTRIBO_Name")%>' /></span></li>

                                                            <li><span class="Kartris-DetailsView-Name">
                                                                <asp:Literal ID="litFormLabelOrderByValue" runat="server" Text='<%$ Resources: _Kartris, FormLabel_OrderByValue %>' /></span>
                                                                <span class="Kartris-DetailsView-Value">
                                                                    <asp:TextBox ID="txtOrderByValue" runat="server" Text='<%# CkartrisDataManipulation.FixNullFromDB(Eval("ATTRIBO_OrderBYValue"))%>'
                                                                        CssClass="shorttext" MaxLength="5" />
                                                                    <asp:RequiredFieldValidator ID="valRequiredOrderByValue" runat="server" CssClass="error"
                                                                        ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                                        Display="Dynamic" ControlToValidate="txtOrderByValue" SetFocusOnError="true"
                                                                        ValidationGroup="" />
                                                                    <asp:CompareValidator ID="valCompareOrderByValue" runat="server" ControlToValidate="txtOrderByValue"
                                                                        Display="Dynamic" ErrorMessage="0-32767!" CssClass="error" ForeColor="" Operator="LessThanEqual"
                                                                        SetFocusOnError="true" ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>"
                                                                        ValueToCompare="32767" Type="Integer" ValidationGroup="" />
                                                                    <ajaxToolkit:FilteredTextBoxExtender ID="filOrderByValue" runat="server" TargetControlID="txtOrderByValue"
                                                                        FilterType="Numbers" />
                                                                </span></li>
                                                            <li style="display:none;"><span class="Kartris-DetailsView-Name">
                                                                <!-- THIS SECTION SET AS display:none BECAUSE THIS FUNCTION IS NOT IMPLMENTED IN THE GLOBAL KARTRIS APPLICATION.
                                                                    I have left it in (but hidden) in case I want to move this functionality over into the general application from the 
                                                                    custom application it was written for - Craig Moore 20170708 -->
                                                                <asp:Literal ID="litAttributeOptionLink" runat="server" Text="Link Option Group Options"></asp:Literal>
                                                            </span>
                                                                <span class="Kartris-DetailsView-Value">
                                                                    <asp:Button ID="btnLinkOptionGroupOptions" runat="server" CssClass="button" Text="Show Links" CommandName="LinkOptionGroupOptions" CommandArgument='<%# Eval("ATTRIBO_ID")%>' />
                                                                </span></li>
                                                            <asp:PlaceHolder ID="phdNewSwatch" runat="server">
                                                                <li>
                                                                    <span class="Kartris-DetailsView-Name">
                                                                        <asp:Literal ID="litNewSwatchName" runat="server" Text='Swatch' /></span>
                                                                    <span class="Kartris-DetailsView-Value">
                                                                        <asp:Image ID="imgSwatch" runat="server" />
                                                                        <_user:_FileUploader runat="server" ID="UC_SwatchFileUploader" AllowMultiple="false" OneItemOnly="true" ImageType="enum_AttributeSwatch" ItemID='<%# Eval("ATTRIBO_ID")%>' ParentID='<%# Eval("ATTRIB_ID")%>' />
                                                                    </span>
                                                                </li>
                                                            </asp:PlaceHolder>
                                                        </ul>
                                                    </div>
                                                </div>
                                                <div class="spacer">
                                                </div>
                                                <div>
                                                    <asp:UpdatePanel ID="updLanguageElements" runat="server" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <_user:LanguageContainer ID="_UC_LangContainer_SelectedOption" runat="server" />
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                </div>
                                                <div class="spacer">
                                                </div>
                                                <div class="submitbuttons">
                                                    <asp:UpdatePanel ID="updSaveOptions" runat="server" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:Button ID="lnkDeleteOption" runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>'
                                                                CommandName="delete" CssClass="button floatright" />
                                                            <asp:Button ID="lnkSave" runat="server" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                                                CommandName="update" CommandArgument='<%# Eval("ATTRIBO_ID")%>'
                                                                CssClass="button" />
                                                            <asp:Button ID="lnkCancel" runat="server" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                                                CommandName="cancel" CssClass="button cancelbutton" /><asp:ValidationSummary ID="valSummary2"
                                                                    runat="server" ForeColor="" CssClass="valsummary" DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                </div>
                                            </SelectedItemTemplate>
                                            <%-- Footer --%>
                                            <FooterStyle CssClass="Kartris-DataList-SelectedItem" />
                                            <FooterTemplate>
                                                <asp:PlaceHolder ID="phdNewItem" runat="server" Visible="false">
                                                    <div class="Kartris-DetailsView">
                                                        <div class="Kartris-DetailsView-Data">
                                                            <ul>
                                                                <li><span class="Kartris-DetailsView-Name">
                                                                    <asp:Literal ID="litContentTextName" runat="server" Text='<%$ Resources: _Kartris, ContentText_Name %>' /></span>
                                                                    <span class="Kartris-DetailsView-Value">
                                                                        <asp:Literal ID="litNewOption" runat="server" Text="NewOption"></asp:Literal></span></li>
                                                                <li><span class="Kartris-DetailsView-Name">
                                                                    <asp:Literal ID="litContentTextLive" runat="server" Text='<%$ Resources: _Options, FormLabel_Selected %>' /></span>
                                                                    <span class="Kartris-DetailsView-Value">
                                                                        <asp:CheckBox ID="chkSelected" runat="server" CssClass="checkbox" /></span></li>

                                                                <li><span class="Kartris-DetailsView-Name">
                                                                    <asp:Literal ID="litFormLabelOrderByValue" runat="server" Text='<%$ Resources: _Kartris, FormLabel_OrderByValue %>' /></span>
                                                                    <span class="Kartris-DetailsView-Value">
                                                                        <asp:TextBox ID="txtOrderByValue" runat="server" Text="0" CssClass="shorttext" MaxLength="5" />
                                                                        <asp:RequiredFieldValidator ID="valRequiredOrderByValue" runat="server" CssClass="error"
                                                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                                            Display="Dynamic" ControlToValidate="txtOrderByValue" SetFocusOnError="true" />
                                                                        <asp:CompareValidator ID="valCompareOrderByValue" runat="server" ControlToValidate="txtOrderByValue"
                                                                            Display="Dynamic" ErrorMessage="0-32767!" CssClass="error" ForeColor="" Operator="LessThanEqual"
                                                                            SetFocusOnError="true" ToolTip="<%$ Resources: _Kartris, ContentText_MaxNoShort %>"
                                                                            ValueToCompare="32767" Type="Integer" />
                                                                        <ajaxToolkit:FilteredTextBoxExtender ID="filOrderByValue" runat="server" TargetControlID="txtOrderByValue"
                                                                            FilterType="Numbers" />
                                                                    </span></li>
                                                            </ul>
                                                        </div>
                                                    </div>
                                                    <div class="spacer">
                                                    </div>
                                                    <div>
                                                        <asp:UpdatePanel ID="updLanguagesNew" runat="server" UpdateMode="Conditional">
                                                            <ContentTemplate>
                                                                <_user:LanguageContainer ID="_UC_LangContainer_NewOption" runat="server" />
                                                            </ContentTemplate>
                                                        </asp:UpdatePanel>
                                                    </div>
                                                    <div class="spacer">
                                                    </div>
                                                    <div class="submitbuttons">
                                                        <asp:UpdatePanel ID="updSaveOptions" runat="server" UpdateMode="Conditional">
                                                            <ContentTemplate>
                                                                <asp:Button ID="lnkSaveNew" runat="server" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                                                    CommandName="save" CommandArgument='<%# Eval("ATTRIB_ID")%>'
                                                                    CssClass="button" />
                                                                <asp:Button ID="lnkCancelNew" runat="server" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                                                    CommandName="cancel" CssClass="button cancelbutton" /><asp:ValidationSummary ID="valSummary3"
                                                                        runat="server" ForeColor="" CssClass="valsummary" DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                                                            </ContentTemplate>
                                                        </asp:UpdatePanel>
                                                    </div>
                                                </asp:PlaceHolder>
                                                <asp:PlaceHolder ID="phdNoOption" runat="server" Visible="false">
                                                    <div id="noresults">
                                                        <asp:Literal ID="litContentTextNoItemsFound" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" />
                                                    </div>
                                                </asp:PlaceHolder>
                                            </FooterTemplate>
                                        </asp:DataList>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                                <asp:HyperLink ID="lnkBack" CssClass="linkbutton icon_back" runat="server" NavigateUrl="~/Admin/_Attributes.aspx"
                                    Text='<%$ Resources: _Kartris, FormButton_Back %>'></asp:HyperLink>
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
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    <_user:_PopupAttributeOption runat="server" ID="_UC_PopupAttributeOption" />
</asp:Content>
