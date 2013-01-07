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
                    <table class="kartristable">
                        <asp:Repeater ID="rptAttributes" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td class="itemname">
                                        <asp:Literal ID="litAttributeID" runat="server" Text='<%# Eval("ATTRIB_ID") %>' Visible="false" />
                                        <asp:UpdatePanel ID="updSelection" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:CheckBox ID="chkAttribute" runat="server" AutoPostBack="true" CssClass="checkbox" OnCheckedChanged="RefreshCategoryMenu" />
                                                <asp:LinkButton ID="lnkBtnAttributeName" runat="server" Text='<%# Eval("ATTRIB_Name") %>'
                                                    CommandName="select" />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                    <td>
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

