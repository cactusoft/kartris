<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_ProductAttributes.ascx.vb"
    Inherits="UserControls_Back_ProductAttributes" %>
<%@ Register TagPrefix="_user" TagName="LanguageContainer" Src="~/UserControls/Back/_LanguageContainer.ascx" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:MultiView ID="mvwAttributes" runat="server">
            <asp:View ID="viwNoAttributes" runat="server">
                <br />
                <asp:Panel ID="pnlNoReview" runat="server" CssClass="noresults">
                    <asp:Literal ID="litNoAttributes" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" />
                </asp:Panel>
            </asp:View>
            <asp:View ID="viwAttributes" runat="server">
                <div id="section_attributes">
                    <asp:PlaceHolder ID="phdOptionsAllSelected" runat="server">
                        <div id="optionfilters">
                            <asp:LinkButton ID="lnkShowAll" runat="server"
                                Text="All" />&nbsp;
                            <asp:LinkButton ID="lnkJustSelected" runat="server"
                                Text="Selected" />
                            <asp:PlaceHolder ID="phdFilterBox" runat="server">&nbsp;&nbsp;
                                <asp:TextBox ID="txtFilterText" runat="server" CssClass="mediumfield"></asp:TextBox>
                                <asp:Button ID="btnFilterSubmit" runat="server" CssClass="button" Text="<%$ Resources: _Kartris, ContentText_AddNew %>" /></asp:PlaceHolder>
                        </div>
                    </asp:PlaceHolder>
                    <table class="kartristable">
                        <asp:HiddenField ID="hidNumberOfAttributes" runat="server"></asp:HiddenField>
                        
                        <asp:Repeater ID="rptAttributes" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td class="itemname">
                                        <asp:Literal ID="litAttributeID" runat="server" Text='<%# Eval("ATTRIB_ID") %>' Visible="False" />
                                         <asp:Literal ID="litAttributeType" runat="server" Text='<%# Eval("ATTRIB_Type")%>' Visible="False" />
                                        <asp:UpdatePanel ID="updSelection" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:CheckBox ID="chkAttribute" runat="server" AutoPostBack="true" CssClass="checkbox" OnCheckedChanged="chkAttribute_CheckedChanged" CommandArgument='<%# Eval("ATTRIB_ID") %>' />
                                                <asp:LinkButton ID="lnkBtnAttributeName" runat="server" Text='<%# Eval("ATTRIB_Name") %>'
                                                    CommandName="select" />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                    <td>
                                        <asp:MultiView ID="mvAttributeData" runat="server" ActiveViewIndex="0">
                                            <asp:View ID="vwLanguage" runat="server">
                                                <asp:UpdatePanel ID="updLanguageStrings" runat="server" UpdateMode="Conditional">
                                                    <ContentTemplate>
                                                        <asp:PlaceHolder ID="phdLanguageStrings" runat="server" Visible="false">
                                                            <asp:UpdatePanel ID="updLanguageContainer" runat="server" UpdateMode="Conditional">
                                                                <ContentTemplate>
                                                                    <asp:PlaceHolder ID="phdLangContainer" runat="server">
                                                                        <_user:LanguageContainer ID="_UC_LangContainer" runat="server" />
                                                                    </asp:PlaceHolder>
                                                                </ContentTemplate>
                                                            </asp:UpdatePanel>
                                                        </asp:PlaceHolder>
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>
                                            </asp:View>
                                            <asp:View runat="server" ID="vwYesNo">
                                                <!-- I have hidden the autopopulate button because I have not implemented the changes to the Option Groups to allow this function to work.
                                                    I will make it visible if I even implement that part of things. Craig Moore 20170709 -->
                                                <asp:Button ID="btnAutoPopulate" runat="server" Text="Auto Populate" CssClass="button" CommandName="AutoPopulate" CommandArgument='<%# Eval("ATTRIB_ID") %>' Visible="false" />
                                                <asp:Repeater ID="rptYesNoOptions" runat="server">
                                                    <HeaderTemplate>
                                                        
                                                        <div class="Kartris-DetailsView">
                                                            <div class="Kartris-DetailsView-Data">
                                                                <ul>
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <li>
                                                            <span class="checkbox">
                                                                <asp:CheckBox ID="chkAttributeOption" runat="server" Checked='<%# Eval("checked")%>' /></span>
                                                            <span class="Kartris-DetailsView-Value">
                                                                <asp:Literal ID="litOptionID" runat="server" Text='<%# Eval("ATTRIBO_ID")%>' Visible="false" />
                                                                <asp:Label ID="lblOptionName" runat="server" AssociatedControlID="chkAttributeOption" Text='<%# Eval("ATTRIBO_Name")%>'></asp:Label>

                                                        </li>
                                                    </ItemTemplate>
                                                    <FooterTemplate>
                                                        </ul>
                                                             </div>
                                                        </div>
                                                    </FooterTemplate>
                                                </asp:Repeater>
                                            </asp:View>
                                        </asp:MultiView>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </table>

                </div>
                <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                    <asp:UpdatePanel ID="updConfirmation" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:LinkButton ID="btnSave" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                            <asp:LinkButton ID="btnCancel" runat="server" CssClass="button cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                            <asp:ValidationSummary ID="valSummary" runat="server" CssClass="valsummary" DisplayMode="BulletList"
                                ForeColor="" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </asp:View>
        </asp:MultiView>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>

