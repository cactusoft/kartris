<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_LanguageContent.ascx.vb"
    Inherits="_LanguageContent" %>
<%@ Register TagPrefix="_user" TagName="HTMLEditor" Src="~/UserControls/Back/_HTMLEditor.ascx" %>
<asp:UpdatePanel ID="updPanel" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <div class="Kartris-DetailsView">
            <div class="Kartris-DetailsView-Data">
                <ul>
                    <asp:Repeater ID="rptLanguageControls" runat="server">
                        <ItemTemplate>
                            <li class="<%# Eval("LEFN_CssClass") %>"><span class="Kartris-DetailsView-Name">
                                <asp:Literal ID="litDisplayText" runat="server" Text='<%# Eval("LEFN_DisplayText") %>' />
                                <asp:Literal ID="litID" runat="server" Text='<%# Eval("LEFN_ID") %>' Visible="false" /></span>
                                <span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtValue" runat="server" CssClass='<%# Eval("LEFN_CssClass") %>'
                                        MaxLength="64000" />
                                    <asp:ImageButton ID="btnEdit" runat="server" AlternateText="HTML" CssClass="icon_html"
                                        Visible='<%# Eval("LEFN_UseHTMLEditor") %>' CommandName="ShowEditor" CommandArgument='<%# Eval("LEFN_ID") %>'
                                        ImageUrl="~/Skins/Admin/Images/icon_html.gif" Width="24px" Height="24px" ToolTip="HTML" />
                                    <asp:RequiredFieldValidator ID="valRequiredValue" runat="server" SetFocusOnError="true"
                                        CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                        ControlToValidate="txtValue" ValidationGroup='<%# Eval("LET_ID") %>' Enabled="False" Display="Dynamic" />
                                </span></li>
                            <asp:CheckBox ID="chkMultiLine" runat="server" Checked='<%# Eval("LEFN_IsMultiLine") %>'
                                Visible="false" CssClass="checkbox" />
                            <asp:CheckBox ID="chkMandatory" runat="server" Checked='<%# Eval("LEFN_IsMandatory") %>'
                                Visible="false" CssClass="checkbox" />
                            <asp:CheckBox ID="chkUseHTMLEditor" runat="server" Checked='<%# Eval("LEFN_UseHTMLEditor") %>'
                                Visible="false" CssClass="checkbox" />
                            <asp:CheckBox ID="chkSearchEngineInput" runat="server" Checked='<%# Eval("LEFN_SearchEngineInput") %>'
                                Visible="false" CssClass="checkbox" />
                            <asp:Literal ID="litFieldNameID" runat="server" Text='<%# Eval("LEFN_ID") %>' Visible="false" />
                        </ItemTemplate>
                    </asp:Repeater>
                </ul>
            </div>
        </div>
        <asp:PlaceHolder ID="phdShowHideSearchEngineInputs" runat="server" Visible="false">
            <asp:UpdatePanel ID="updSearchEngineControls" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:LinkButton CssClass="normalweight" ID="lnkShow" runat="server" />
                    <asp:LinkButton CssClass="normalweight" ID="lnkHide" runat="server" Visible="false"/>
                    <br /><br />
                </ContentTemplate>
            </asp:UpdatePanel>
        </asp:PlaceHolder>
        
        <_user:HTMLEditor ID="_UC_Editor" runat="server" Visible="true" />
    </ContentTemplate>
</asp:UpdatePanel>
