<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_LoginsList.aspx.vb" Inherits="Admin_LoginsList"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<%@ Register TagPrefix="_user" TagName="AnimatedText" Src="~/UserControls/General/AnimatedText.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div id="page_logins">
                <div class="floatright">
                    <asp:LinkButton ID="lnkNewLogin" Text="<%$ Resources: _Kartris, FormButton_New %>"
                        CssClass="linkbutton icon_new" runat="server" />
                </div>
                <h1>
                    <asp:Literal ID="litLoginsListTitle" runat="server" Text="<%$ Resources: PageTitle_Logins %>"></asp:Literal></h1>
                <asp:GridView ID="gvwLogins" CssClass="kartristable" runat="server" AutoGenerateColumns="False"
                    GridLines="None" AllowPaging="False" DataSourceID="objLogins">
                    <Columns>
                        <asp:BoundField DataField="LOGIN_Username" HeaderText='<%$ Resources: _Kartris, FormLabel_Username %>'
                            SortExpression="LOGIN_Username" ItemStyle-CssClass="itemname" />
                        <asp:BoundField DataField="LOGIN_EmailAddress" HeaderText='<%$ Resources: _Kartris, ContentText_Email %>'
                            SortExpression="LOGIN_EmailAddress" ItemStyle-CssClass="itemname" />
                        <asp:BoundField DataField="LOGIN_Password" HeaderText="<%$ Resources: _Kartris, FormLabel_Password %>"
                            Visible="false" />
                        <asp:TemplateField HeaderText="<%$Resources: _Logins, ContentText_Permissions %>">
                            <ItemTemplate>
                                <span class="checkbox">
                                    <asp:CheckBox ID="chkLoginConfig" runat="server" Checked='<%# Bind("LOGIN_Config") %>'
                                        Enabled="false" ToolTip="<%$ Resources: _Logins, ImageLabel_PermConfig %>" />
                                    <asp:CheckBox ID="chkLoginProducts" runat="server" Checked='<%# Bind("LOGIN_Products") %>'
                                        Enabled="false" ToolTip="<%$ Resources: _Logins, ImageLabel_PermProducts %>" />
                                    <asp:CheckBox ID="chkLoginOrders" runat="server" Checked='<%# Bind("LOGIN_Orders") %>'
                                        Enabled="false" ToolTip="<%$ Resources: _Logins, ImageLabel_PermOrders %>" />
                                    <asp:CheckBox ID="chkLoginTickets" runat="server" Checked='<%# Bind("LOGIN_Tickets") %>'
                                        Enabled="false" ToolTip="<%$ Resources: _Logins, ImageLabel_PermSupport %>" /></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$Resources: _Kartris, ContentText_Live%>" SortExpression="LOGIN_Live">
                            <ItemTemplate>
                                <span class="checkbox">
                                    <asp:CheckBox ID="chkLoginLive" runat="server" Checked='<%# Bind("LOGIN_Live") %>'
                                        Enabled="false" /></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderStyle-CssClass="invisible" ItemStyle-CssClass="invisible">
                            <ItemTemplate>
                                <asp:HiddenField ID="hidLoginID" runat="server" Value='<%# Bind("LOGIN_ID") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderStyle-CssClass="invisible" ItemStyle-CssClass="invisible">
                            <ItemTemplate>
                                <asp:HiddenField ID="hidLoginProtected" runat="server" Value='<%# Bind("LOGIN_Protected") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderStyle-CssClass="invisible" ItemStyle-CssClass="invisible">
                            <ItemTemplate>
                                <asp:HiddenField ID="hidLoginLanguageID" runat="server" Value='<%# Bind("LOGIN_LanguageID") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:ButtonField Text="<%$ Resources: _Kartris, FormButton_Delete %>" CommandName="DeleteLogins"
                            HeaderStyle-CssClass="invisible" ItemStyle-CssClass="invisible" />
                        <asp:ButtonField Text="<%$ Resources: _Kartris, FormButton_Edit %>" CommandName="EditLogins"
                            ItemStyle-CssClass="linkbuttonfield alignright selectfield" />
                    </Columns>
                </asp:GridView>
                <asp:ObjectDataSource ID="objLogins" runat="server" OldValuesParameterFormatString="original_{0}"
                    SelectMethod="_GetList" TypeName="kartrisLoginDataTableAdapters.LoginsTblAdptr">
                </asp:ObjectDataSource>
                <asp:Panel ID="pnlEdit" runat="server" Visible="false">
                    <asp:HiddenField ID="hidLoginID" runat="server" Value=''></asp:HiddenField>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblLoginUsername" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Username %>"
                                        AssociatedControlID="txtUsername" /></span> <span class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtUsername" runat="server"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="valRequiredUserName" runat="server" ControlToValidate="txtUsername"
                                                Enabled="true" CssClass="error" ForeColor="" ValidationGroup="UserDetails" Display="Dynamic"
                                                Text="<%$ Resources: Kartris, ContentText_RequiredField %>" />
                                        </span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblLoginEmailAddress" runat="server" Text="<%$ Resources: _Kartris, ContentText_Email %>"
                                        AssociatedControlID="txtEmailAddress" /></span> <span class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtEmailAddress" runat="server"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="valRequiredEmailAddress" runat="server" ControlToValidate="txtEmailAddress"
                                                Enabled="true" CssClass="error" ForeColor="" ValidationGroup="UserDetails" Display="Dynamic"
                                                Text="<%$ Resources: Kartris, ContentText_RequiredField %>" />
                                            <asp:RegularExpressionValidator ID="valEmailAddress" runat="server" ControlToValidate="txtEmailAddress"
                                                Enabled="true" CssClass="error" ValidationGroup="UserDetails" ForeColor="" Display="Dynamic"
                                                ErrorMessage="<%$ Resources: _Kartris, ContentText_BadEmail %>" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" /></span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblLoginPassword" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Password %>" /></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:Label ID="lblPassword" runat="server" Text="<%$ Resources: _Kartris, ContentText_Encrypted %>"
                                            AssociatedControlID="txtPassword" />
                                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" Visible="false" />
                                        <asp:LinkButton ID="btnChangePassword" OnClick="btnChangePassword_Click" Text="<%$ Resources: _Kartris, ContentText_ConfigChange2 %>"
                                            runat="server" />
                                        <asp:RequiredFieldValidator CssClass="error" ForeColor="" ID="valRequiredUserPassword"
                                            runat="server" ControlToValidate="txtPassword" Enabled="false" ValidationGroup="UserDetails"
                                            Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>" />
                                    </span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblLoginLive" runat="server" Text="<%$ Resources: _Kartris, ContentText_Live %>" />
                                </span><span class="Kartris-DetailsView-Value radio">
                                    <asp:RadioButton ID="radYes" runat="server" Text="<%$ Resources: _Kartris, ContentText_Yes %>"
                                        GroupName="Login_Live" /><asp:RadioButton ID="radNo" runat="server" Text="<%$ Resources: _Kartris, ContentText_No %>"
                                            GroupName="Login_Live" />
                                </span></li>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblLanguage" runat="server" Text="<%$ Resources: _Kartris, FormLabel_Language %>"
                                        AssociatedControlID="ddlLanguages" /></span> <span class="Kartris-DetailsView-Value">
                                            <asp:DropDownList ID="ddlLanguages" runat="server" DataSourceID="objLanguages" DataTextField="Lang_BackName"
                                                DataValueField="Lang_ID" />
                                        </span></li>
                                <li><span class="Kartris-DetailsView-Name"></span><span class="Kartris-DetailsView-Value">
                                    <table cssclass="kartristable">
                                        <tr>
                                            <td>
                                                <span class="checkbox">
                                                    <asp:CheckBox ID="chkLoginEditConfig" runat="server" />
                                                    <asp:Label ID="lblAllowConfig" runat="server" Text="<%$Resources: ContentText_AllowConfig%>" />
                                                </span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <span class="checkbox">
                                                    <asp:CheckBox ID="chkLoginEditProducts" runat="server" />
                                                    <asp:Label ID="lblAllowProducts" runat="server" Text="<%$Resources: ContentText_AllowProducts%>" />
                                                </span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <span class="checkbox">
                                                    <asp:CheckBox ID="chkLoginEditOrders" runat="server" />
                                                    <asp:Label ID="lblAllowOrders" runat="server" Text="<%$Resources: ContentText_AllowOrders%>" />
                                                </span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <span class="checkbox">
                                                    <asp:CheckBox ID="chkLoginEditTickets" runat="server" />
                                                    <asp:Label ID="lblAllowTickets" runat="server" Text="<%$Resources: ContentText_AllowTickets%>" />
                                                </span>
                                            </td>
                                        </tr>
                                    </table>
                                </span></li>
                            </ul>
                        </div>
                    </div>
                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                        <asp:LinkButton ID="btnUpdate" ValidationGroup="UserDetails" runat="server" ToolTip='<%$ Resources: _Kartris, FormButton_Save %>'
                            CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>' />
                        <asp:LinkButton ID="btnCancel" runat="server" CssClass="button cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                            ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                        <asp:ValidationSummary ValidationGroup="UserDetails" ID="valSummary" runat="server"
                            CssClass="valsummary" DisplayMode="BulletList" ForeColor="" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                    </div>
                    <asp:ObjectDataSource ID="objLanguages" runat="server" OldValuesParameterFormatString="original_{0}"
                        SelectMethod="_GetData" TypeName="kartrisLanguageDataTableAdapters.LanguagesTblAdptr">
                    </asp:ObjectDataSource>
                </asp:Panel>
            </div>
            <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
