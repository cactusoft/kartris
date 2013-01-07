<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_LanguageStrings.ascx.vb"
    Inherits="_LanguageStrings" %>
<asp:UpdatePanel ID="updPanel" runat="server">
    <ContentTemplate>
        <div id="main">
            <div class="searchboxrow">
                <asp:Panel ID="pnlFind" runat="server" DefaultButton="btnFind">
                    <asp:LinkButton ID="btnNew" runat="server" Text='<%$ Resources:_Kartris, FormButton_New %>'
                        CssClass="linkbutton icon_new floatright" />
                    <asp:TextBox runat="server" ID="txtSearchStarting" MaxLength="100" />
                    <asp:Button ID="btnFind" runat="server" Text="<%$ Resources:_Kartris, FormButton_Search %>"
                        CssClass="button" />
                    <asp:Button ID="btnClear" runat="server" CssClass="button cancelbutton" Text='<%$ Resources:_Kartris, ContentText_Clear %>' />
                    <div>
                        <br />
                        <asp:Label ID="litLanguage" CssClass="nolabelwidth" runat="server" Text='<%$ Resources:_Kartris, FormLabel_Language %>'
                            AssociatedControlID="ddlLanguages" />
                        <asp:DropDownList CssClass="short" ID="ddlLanguages" runat="server" DataTextField="LANG_BackName"
                            DataValueField="LANG_ID" />
                        <asp:Label ID="litField" CssClass="nolabelwidth" runat="server" AssociatedControlID="ddlSearchBy"
                            Text='<%$ Resources:_Kartris, ContentText_Field %>' />
                        <asp:DropDownList CssClass="short" ID="ddlSearchBy" runat="server">
                            <asp:ListItem Text='<%$ Resources:_Kartris, BackMenu_SearchAll %>' Value="" Selected="Selected" />
                            <asp:ListItem Text='<%$ Resources:_Kartris, ContentText_Name %>' Value="Name" />
                            <asp:ListItem Text='<%$ Resources:_Kartris, ContentText_Value %>' Value="Value" />
                            <asp:ListItem Text='<%$ Resources:_Kartris, ContentText_ClassName %>' Value="ClassName" />
                        </asp:DropDownList>
                        <span class="checkbox nolabelwidth">
                            <asp:CheckBox ID="chkFront" runat="server" Text='<%$ Resources:_Kartris, ContentText_FrontEnd %>' />
                            <asp:CheckBox ID="chkBack" runat="server" Text='<%$ Resources:_Kartris, PageTitle_BackEnd %>' />
                        </span>
                    </div>
                </asp:Panel>
            </div>
            <asp:Panel ID="pnlNewSearch" runat="server" Visible="false">
                <asp:LinkButton ID="btnNewSearch" runat="server" CssClass="linkbutton icon_edit"
                    Text='<%$ Resources:_Search, ContentText_NewSearch %>' />
            </asp:Panel>
            <%--Update Error Message--%>
            <asp:PlaceHolder ID="phdMessageError" runat="server" Visible="false">
                <div class="errormessage">
                    <asp:Literal ID="litMessageError" runat="server" Text='<%$ Resources:_Kartris, ContentText_Error %>'></asp:Literal>
                </div>
            </asp:PlaceHolder>
            <asp:MultiView ID="mvwLS" runat="server">
                <asp:View ID="viwNoResult" runat="server">
                    <div id="noresults">
                        <asp:Literal ID="litNoResults" runat="server" Text='<%$ Resources:_Kartris, ContentText_NoResults %>'></asp:Literal>
                    </div>
                </asp:View>
                <asp:View ID="viwResult" runat="server">
                    <asp:GridView CssClass="kartristable" ID="gvwLS" runat="server" AllowPaging="True" AutoGenerateColumns="False"
                        DataKeyNames="LS_LANGID,LS_FrontBack,LS_Name" GridLines="None" AutoGenerateEditButton="False">
                        <Columns>
                            <asp:TemplateField ItemStyle-CssClass="hidecolumn" HeaderStyle-CssClass="hidecolumn" Visible="False">
                                <ItemTemplate>
                                    <asp:Literal ID="litLanguageID" runat="server" Text='<%# Eval("LS_LangID") %>' Visible="false" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="LS_FrontBack" HeaderText='' ItemStyle-CssClass="column1">
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:BoundField ItemStyle-CssClass="itemname column2" DataField="LS_Name" HeaderText='<%$ Resources:_Kartris, ContentText_Name %>'
                                HeaderStyle-CssClass="column2">
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:BoundField DataField="LS_Value" HeaderText='<%$ Resources:_Kartris, ContentText_Value %>'
                                ItemStyle-CssClass="column3">
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:BoundField DataField="LS_ClassName" HeaderText='<%$ Resources:_Kartris, ContentText_ClassName %>'
                                ItemStyle-CssClass="column4" NullDisplayText="-">
                                <HeaderStyle />
                            </asp:BoundField>
                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                <ItemTemplate>
                                    <asp:LinkButton ID="selectbutton" runat="server" CommandName="select" CssClass="linkbutton icon_edit"
                                        Text='<%$ Resources:_Kartris, FormButton_Edit %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </asp:View>
                <asp:View ID="viwEdit" runat="server">
                    <%-- Back Link --%>
                    <asp:PlaceHolder runat="server" ID="phdBackLink">
                        <asp:LinkButton ID="lnkBtnBack" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>'
                            CssClass="linkbutton icon_back floatright" Style='margin-top: 10px;'></asp:LinkButton>
                    </asp:PlaceHolder>
                    <div class="Kartris-DetailsView section_languagestrings">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <%--LS_FrontBack--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextFrontBack" runat="server" Text='<%$ Resources:_Kartris, ContentText_FrontOrBack %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:DropDownList ID="ddlLSFrontBack" runat="server" Enabled="false">
                                        <asp:ListItem>-</asp:ListItem>
                                        <asp:ListItem Text='<%$ Resources:_Kartris, ContentText_FrontEnd %>' Value="f" />
                                        <asp:ListItem Text='<%$ Resources:_Kartris, PageTitle_BackEnd %>' Value="b" />
                                    </asp:DropDownList>
                                    <asp:CompareValidator ID="valCompareFrontBack" runat="server" CssClass="error" ForeColor=""
                                        ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="ddlLSFrontBack"
                                        SetFocusOnError="True" ValidationGroup="LS_PK" ValueToCompare="-" Operator="NotEqual"></asp:CompareValidator>
                                </span></li>
                                <%--LS_Language--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litHLanguage" runat="server" Text='<%$ Resources:_Kartris, FormLabel_Language %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:DropDownList ID="ddlLSLanguage" runat="server" DataTextField="LANG_BackName"
                                        DataValueField="LANG_ID" Enabled="false" />
                                </span></li>
                                <%--LS_Name--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextName" runat="server" Text='<%$ Resources:_Kartris, ContentText_Name %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtLSName" runat="server" MaxLength="255" />
                                    <asp:RequiredFieldValidator ID="valRequiredLSName" runat="server" CssClass="error"
                                        ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                        ControlToValidate="txtLSName" ValidationGroup="LS_PK" SetFocusOnError="True">
                                    </asp:RequiredFieldValidator>
                                    <asp:PlaceHolder ID="phdCheckChange" runat="server" Visible="false">
                                        <asp:LinkButton ID="lnkBtnLSCheckName" runat="server" CausesValidation="true" ValidationGroup="LS_PK"
                                            Text='<%$ Resources:_Kartris, FormButton_Check %>' />
                                        <asp:LinkButton ID="lnkBtnLSChangeName" runat="server" CausesValidation="false" Visible="false"
                                            Text='<%$ Resources:_Kartris, FormButton_Change %>' /><br />
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder ID="phdNameAlreadyExists" Visible="false" runat="server">
                                        <asp:Literal ID="litNewNameMsg" runat="server" Text='<%$ Resources:_Kartris, ContentText_AlreadyInUse %>' />
                                        <asp:LinkButton ID="lnkBtnViewLSName" runat="server" Text='<%$ Resources:_Kartris, ContentText_ClickHere %>' />
                                    </asp:PlaceHolder>
                                    <asp:Literal ID="litPleaseEnterValue" runat="server" Visible="false" Text='<%$ Resources:_Kartris, ContentText_PleaseEnterValue %>' />
                                </span></li>
                                <%--LS_Value--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextValue" runat="server" Text='<%$ Resources:_Kartris, ContentText_Value %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtLSValue" runat="server" TextMode="MultiLine" Wrap="true" MaxLength="4000" />
                                </span></li>
                                
                                
                                <%--LS_DefaultValue--%>
                                <% If KartSettingsManager.GetKartConfig("backend.expertmode") <> "n" Then%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextDefaultValue" runat="server" Text='<%$ Resources: _Kartris, ContentText_DefaultValue %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtLSDefaultValue" runat="server" TextMode="MultiLine" Wrap="true"
                                        MaxLength="4000" />
                                </span></li>
                                <% end if %>
                                
                                <%--LS_Description--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextDesc" runat="server" Text='<%$ Resources:_Kartris, FormLabel_Description %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtLSDesc" runat="server" TextMode="MultiLine" Wrap="true" MaxLength="255" />
                                </span></li>
                                
                                <% If KartSettingsManager.GetKartConfig("backend.expertmode") <> "n" Then%>
                                <%--LS_VirtualPath--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextVirtualPath" runat="server" Text='<%$ Resources:_Kartris, ContentText_VirtualPath %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtLSVirtualPath" runat="server" MaxLength="50" />
                                </span></li>
                                <%--LS_ClassName--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litContentTextClassName" runat="server" Text='<%$ Resources:_Kartris, ContentText_ClassName %>'></asp:Literal>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtLSClassName" runat="server" MaxLength="50" />
                                </span></li>
                                <% end if %>
                                
                            </ul>
                        </div>
                    </div>
                    <div class="spacer">
                    </div>
                    <%-- Save Button  --%>
                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                        <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:LinkButton ID="btnSave" runat="server" CausesValidation="True" ValidationGroup="LS"
                                    Text='<%$ Resources: _Kartris, FormButton_Save %>' ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' CssClass="button savebutton"></asp:LinkButton>
                                <asp:LinkButton ID="btnCancel" runat="server" CausesValidation="False" CommandName="Cancel"
                                    ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                    Text='<%$ Resources: _Kartris, FormButton_Cancel %>' CssClass="button cancelbutton">
                                </asp:LinkButton>
                                <asp:ValidationSummary ID="valSummary" ValidationGroup="LS"
                                            runat="server" forecolor="" CssClass="valsummary" DisplayMode="BulletList"
                                            HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                </asp:View>
            </asp:MultiView>
        </div>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgLS" runat="server" AssociatedUpdatePanelID="updPanel">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
