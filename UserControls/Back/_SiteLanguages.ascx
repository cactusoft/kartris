<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_SiteLanguages.ascx.vb" Inherits="UserControls_Back_SiteLanguages" %>
<%@ Register TagPrefix="_user" TagName="UploaderPopup" Src="~/UserControls/Back/_UploaderPopup.ascx" %>
<asp:UpdatePanel ID="updLanguages" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <div id="page_languages">
            <h1>
                <asp:Literal ID="litPageTitleLanguages" runat="server" Text="<%$ Resources:_Language, PageTitle_Languages %>" /></h1>
            <asp:Literal ID="litFullElemetsLanguageID" runat="server" Visible="false" Text="0" />
            <asp:Literal ID="litFullStringsLanguageID" runat="server" Visible="false" Text="0" />
            <asp:GridView CssClass="kartristable" ID="gvwLanguages" runat="server" AllowSorting="false"
                AutoGenerateColumns="False" AutoGenerateEditButton="False" GridLines="None" PagerSettings-PageButtonCount="10"
                SelectedIndex="0" DataKeyNames="LANG_ID">
                <Columns>
                    <asp:TemplateField>
                        <HeaderTemplate>
                        </HeaderTemplate>
                        <ItemStyle CssClass="recordnumberfield" />
                        <ItemTemplate>
                            <asp:Literal ID="litRecordNumber" runat="server" Text='<%# Container.DataItemIndex + 1 %>' />
                            <asp:Literal ID="litLANG_ID" runat="server" Text='<%# Eval("LANG_ID") %>' Visible="false" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <HeaderTemplate>
                        </HeaderTemplate>
                        <ItemStyle CssClass="flagfield" />
                        <ItemTemplate>
                            <asp:Literal ID="litImageName" runat="server" Visible="false" Text='<%# Eval("LANG_Culture") %>' />
                            <asp:PlaceHolder ID="phdImageExist" runat="server" Visible="false">
                                <asp:Image ID="imgLanguage" runat="server" />
                            </asp:PlaceHolder>
                            <asp:PlaceHolder ID="phdImageNotExist" runat="server" Visible="false"></asp:PlaceHolder>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <asp:Literal ID="litFormLabelBackName" runat="server" Text='<%$ Resources:_Kartris, FormLabel_BackName %>' />
                        </HeaderTemplate>
                        <ItemStyle CssClass="itemname" />
                        <ItemTemplate>
                            <asp:Literal ID="litLANG_BackName" runat="server" Text='<%# Eval("LANG_BackName") %>' />
                        </ItemTemplate>
                        <FooterTemplate>
                        </FooterTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <asp:Literal ID="litFormLabelLiveFront" runat="server" Text='<%$ Resources:_Kartris, ContentText_Live %>' />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:CheckBox ID="chkLive" runat="server" Checked='<%# Eval("LANG_LiveFront") %>'
                                Enabled="false" CssClass="checkbox" />
                        </ItemTemplate>
                        <FooterTemplate>
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <asp:Literal ID="litMissingElements" runat="server" Text="<%$ Resources:_Language, ContentText_MissingElements %>" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:Literal ID="litMissingElements" runat="server" Text='<%# Eval("MissingElements") %>' />
                            <asp:LinkButton ID="lnkFixElements" runat="server" Text="Fix Now" 
                            Visible='<%# Eval("NeedFixElements") AND Eval("LANG_LiveFront") %>' CssClass="linkbutton icon_edit" CommandName="FixElements" CommandArgument='<%# Eval("LANG_ID") %>' />
                        </ItemTemplate>
                        <FooterTemplate>
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <asp:Literal ID="litMissingStrings" runat="server" Text="<%$ Resources:_Language, ContentText_MissingStrings %>" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:Literal ID="litMissingStrings" runat="server" Text='<%# Eval("MissingStrings") %>' />
                            <asp:LinkButton ID="lnkFixStrings" runat="server" Text="Fix Now" 
                            Visible='<%# Eval("NeedFixStrings") AND Eval("LANG_LiveFront") %>' CssClass="linkbutton icon_edit" CommandName="FixStrings" CommandArgument='<%# Eval("LANG_ID") %>' />
                        </ItemTemplate>
                        <FooterTemplate>
                        </FooterTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField ItemStyle-CssClass="selectfield">
                        <HeaderTemplate>
                            <asp:LinkButton ID="btnNew" runat="server" Text='<%$ Resources:_Kartris, FormButton_New %>'
                                CommandName="CreateNewLanguage" CssClass="linkbutton icon_new floatright" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkBtnEditCurrency" runat="server" CommandName="select" CommandArgument='<%# Container.DataItemIndex %>'
                                Text="<%$ Resources: _Kartris, FormButton_Edit %>" CssClass="linkbutton icon_edit" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            
            <asp:Literal ID="litImageStatus" runat="server" Visible="false" Text="none" />
            <asp:Literal ID="litImageName" runat="server" Visible="false" Text="none" />
            
            <asp:Literal ID="Literal2" runat="server"></asp:Literal>
            <_user:UploaderPopup ID="_UC_UploaderPopup" runat="server" />
            <asp:UpdatePanel ID="updLanguage" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:Literal ID="litLanguageID" runat="server" Visible="false" />
                    <asp:CheckBox ID="chkIsDefault" runat="server" Visible="false" />
                    <asp:PlaceHolder ID="phdLanguageDetails" runat="server" Visible="false">
                        <div class="Kartris-DetailsView">
                            <div class="Kartris-DetailsView-Data">
                                <ul>
                                    <!-- Back Name -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblFormLabelBackName" runat="server" Text='<%$ Resources:_Kartris, FormLabel_BackName %>'
                                            AssociatedControlID="txtBackName" /></span><span class="Kartris-DetailsView-Value">
                                                <asp:TextBox ID="txtBackName" runat="server" MaxLength="50" />
                                                <asp:RequiredFieldValidator ID="valRequiredBackName" runat="server" CssClass="error"
                                                    ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                    ControlToValidate="txtBackName" ValidationGroup="SaveLanguage" Display="Dynamic" /></span></li>
                                    <!-- Front Name -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblFormLabelFrontName" runat="server" Text='<%$ Resources:_Kartris, FormLabel_FrontName %>' AssociatedControlID="txtFrontName" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtFrontName" runat="server" MaxLength="50" />
                                            <asp:RequiredFieldValidator ID="valRequiredFrontName" runat="server" CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" 
                                                ControlToValidate="txtFrontName" ValidationGroup="SaveLanguage" Display="Dynamic" /></span></li>
                                    <!-- Email Address (Orders) -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblContentTextEmailAddressOrders" runat="server" Text="<%$ Resources: _Kartris, ContentText_EmailAddressOrders %>" AssociatedControlID="txtEmailOrders" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtEmailOrders" runat="server" MaxLength="255" />
                                            <asp:RequiredFieldValidator ID="valRequiredEmailOrders" runat="server" CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" 
                                                ControlToValidate="txtEmailOrders" ValidationGroup="SaveLanguage" Display="Dynamic" />
                                            <asp:RegularExpressionValidator ID="valRegex1" runat="server" ErrorMessage="!"
                                                ControlToValidate="txtEmailOrders" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                                ValidationGroup="SaveLanguage" /></span></li>
                                    <!-- Email Address (Contact Form) -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblContentTextEmailAddressContact" runat="server" Text="<%$ Resources: _Kartris, ContentText_EmailAddressContact %>" AssociatedControlID="txtEmailContact" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtEmailContact" runat="server" MaxLength="255" />
                                            <asp:RequiredFieldValidator ID="valRequiredEmailContactFrom" runat="server" CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" 
                                                ControlToValidate="txtEmailContact" ValidationGroup="SaveLanguage" Display="Dynamic" />
                                            <asp:RegularExpressionValidator ID="valRegex2" runat="server" ErrorMessage="!"
                                                ControlToValidate="txtEmailContact" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                                ValidationGroup="SaveLanguage" /></span></li>
                                    <!-- 'Reply To' Email Address -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblContentTextEmailAddressReplyTo" runat="server" Text="<%$ Resources: _Kartris, ContentText_EmailAddressReplyTo %>" AssociatedControlID="txtReplayEmail" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtReplayEmail" runat="server" MaxLength="255" />
                                            <asp:RequiredFieldValidator ID="valRequiredReplayEmail" runat="server" CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" 
                                                ControlToValidate="txtReplayEmail" ValidationGroup="SaveLanguage" Display="Dynamic" />
                                            <asp:RegularExpressionValidator ID="valRegex3" runat="server" ErrorMessage="!"
                                                ControlToValidate="txtReplayEmail" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                                ValidationGroup="SaveLanguage" /></span></li>
                                    <!-- Date Format -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblContentTextDateFormat" runat="server" Text="<%$ Resources: _Kartris, ContentText_DateFormat %>" AssociatedControlID="txtDateFormat" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtDateFormat" runat="server" MaxLength="50" />
                                            <asp:RequiredFieldValidator ID="valRequiredDateFormat" runat="server" CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" 
                                                ControlToValidate="txtDateFormat" ValidationGroup="SaveLanguage" Display="Dynamic" /></span></li>
                                    <!-- Date & Time Format -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblContentTextDateTimeFormat" runat="server" Text="<%$ Resources: _Kartris, ContentText_DateTimeFormat %>" AssociatedControlID="txtDateTimeFormat" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtDateTimeFormat" runat="server" MaxLength="50" />
                                            <asp:RequiredFieldValidator ID="valRequiredDateTimeFormat" runat="server" CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" 
                                                ControlToValidate="txtDateTimeFormat" ValidationGroup="SaveLanguage" Display="Dynamic" /></span></li>
                                    <!-- Live on the backend? -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblContentTextLiveBack" runat="server" Text="<%$ Resources: _Kartris, FormLabel_LiveBack %>" AssociatedControlID="chkBackLive" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:CheckBox ID="chkBackLive" runat="server" CssClass="checkbox" /></span></li>
                                    <!-- Live on the frontend? -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblContentTextLive" runat="server" Text="<%$ Resources: _Kartris, ContentText_Live %>" AssociatedControlID="chkFrontLive" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:CheckBox ID="chkFrontLive" runat="server" CssClass="checkbox" /></span></li>
                                    <!-- Language Culture -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblContentTextLanguageCulture" runat="server" Text="<%$ Resources: _Language, FormLabel_LanguageCulture %>" AssociatedControlID="txtLanguageCulture" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtLanguageCulture" runat="server" CssClass="midtext" MaxLength="10" />
                                            <asp:RequiredFieldValidator ID="valRequiredLanguageCulture" runat="server" CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" 
                                                ControlToValidate="txtLanguageCulture" ValidationGroup="SaveLanguage" Display="Dynamic" /></span></li>
                                    <!-- Language UICulture -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblContentTextLanguageUICulture" runat="server" Text="<%$ Resources: _Language, FormLabel_LanguageUICulture %>" AssociatedControlID="txtLanguageUICulture" /></span><span
                                            class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtLanguageUICulture" runat="server" CssClass="midtext" MaxLength="10" />
                                            <asp:RequiredFieldValidator ID="valRequiredLanguageUICulture" runat="server" CssClass="error" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" 
                                                ControlToValidate="txtLanguageUICulture" ValidationGroup="SaveLanguage" Display="Dynamic" /></span></li>
                                    <% If KartSettingsManager.GetKartConfig("backend.expertmode") <> "n" Then%>
                                     <!-- Language Skin -->
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblFormLabelTheme" runat="server" Text="<%$ Resources: _Language, FormLabel_Theme %>"
                                            AssociatedControlID="txtTheme" /></span><span class="Kartris-DetailsView-Value">
                                                <asp:DropDownList ID="ddlTheme" runat="server" AutoPostBack="True">
                                                </asp:DropDownList>
                                                <asp:TextBox ID="txtTheme" runat="server" MaxLength="50" Visible="False" />
                                            </span></li>
                                    <!-- Language Master -->

                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblFormLabelMasterPage" runat="server" Text="<%$ Resources: _Language, FormLabel_MasterPage %>"
                                                AssociatedControlID="txtMaster" /></span><span class="Kartris-DetailsView-Value">
                                                    <asp:DropDownList ID="ddlMasterPage" runat="server">
                                                    </asp:DropDownList>
                                                    <asp:TextBox ID="txtMaster" runat="server" MaxLength="50" Visible="False" /></span>
                                            </span></li>
                                    <% End If%>
                                </ul>
                                <asp:UpdatePanel ID="updLanguageImages" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <ul>
                                            <!-- Image -->
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Literal ID="litContentTextNormalImage" Text='<%$ Resources: _Kartris, ContentText_NormalImage %>'
                                                    runat="server"></asp:Literal></span><span class="Kartris-DetailsView-Value">
                                                        <asp:Literal ID="litCulture" runat="server" Visible="false" />
                                                        <asp:PlaceHolder ID="phdImageExist" runat="server" Visible="false">
                                                            <asp:Image ID="imgLanguage" runat="server" />&nbsp;
                                                            <asp:LinkButton ID="lnkChangeImage" runat="server" Text='<%$ Resources: _Kartris, FormButton_Change %>'
                                                                CssClass="linkbutton icon_edit" />&nbsp;
                                                            <asp:LinkButton ID="lnkDeleteImage" runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>'
                                                                CssClass="linkbutton icon_delete" />
                                                        </asp:PlaceHolder>
                                                        <asp:PlaceHolder ID="phdImageNotExist" runat="server" Visible="false">
                                                            <asp:LinkButton ID="lnkSetImage" runat="server" Text='<%$ Resources: _Kartris, ContentText_Upload %>'
                                                                CssClass="linkbutton icon_new" />
                                                        </asp:PlaceHolder>
                                                    </span></li>
                                        </ul>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                        </div>
                        <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                            <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:LinkButton ID="lnkBtnSave" runat="server" ToolTip="<%$ Resources: _Kartris, FormButton_Save %>"
                                        CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                        ValidationGroup="SaveLanguage" />
                                    <asp:LinkButton ID="lnkBtnCancel" runat="server" CssClass="button cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                        ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                                    <span class="floatright">
                                        <asp:LinkButton ID="lnkBtnDelete" CssClass="button deletebutton"
                                            runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>' ToolTip='<%$ Resources: _Kartris, FormButton_Delete %>'
                                            Visible="false" /></span><asp:ValidationSummary ID="valSummary" ValidationGroup="SaveLanguage"
                                                runat="server" ForeColor="" CssClass="valsummary" DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                    </asp:PlaceHolder>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgMain" runat="server" AssociatedUpdatePanelID="updLanguages">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
<_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
