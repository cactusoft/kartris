<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_AdminExportData.ascx.vb"
    Inherits="UserControls_Back_AdminExportData" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <h2>
            <asp:Literal ID="litBackMenuProducts" runat="server" Text='<%$ Resources: _Export, ContentText_DataExport %>' />
            <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9806')">?</a>
        </h2>
        <p>
            <asp:Literal ID="litHeader" runat="server" Text='<%$ Resources: _Export, ContentText_DataExportHeader %>' /></p><br />
        <div>
            <ajaxToolkit:TabContainer ID="tabExport" runat="server" EnableTheming="False" CssClass=".tab"
                AutoPostBack="false">
                <ajaxToolkit:TabPanel ID="tabExportOrders" runat="server" HeaderText='<%$ Resources: _Export, ContentText_OrdersExport %>'>
                    <ContentTemplate>
                        <div class="subtabsection">
                            <div class="Kartris-DetailsView">
                                <div class="Kartris-DetailsView-Data">
                                    <ul>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Literal ID="litFormLabelStartDate" runat="server" Text='<%$ Resources: _Kartris, FormLabel_StartDate %>' /> / 
                                            <asp:Literal ID="litFormLabelStartID" runat="server" Text='<%$ Resources: _Kartris, ContentText_ID %>' /> </span><span
                                                class="Kartris-DetailsView-Value">
                                                <asp:UpdatePanel ID="updDates" runat="server" UpdateMode="Conditional">
                                                    <ContentTemplate>
                                                        <asp:ImageButton ID="imgBtnStart" runat="server" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                                                            Width="16" Height="16" CssClass="calendarbutton" /><asp:TextBox ID="txtStartDate"
                                                                runat="server" MaxLength="20" CssClass="midtext" />
                                                        <ajaxToolkit:CalendarExtender ID="calExtStartDate" runat="server" TargetControlID="txtStartDate"
                                                            PopupButtonID="imgBtnStart" Format="yyyy/MM/dd" CssClass="calendar" />
                                                        <asp:RequiredFieldValidator ID="valRequiredStartDate" runat="server" CssClass="error"
                                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                            ControlToValidate="txtStartDate" ValidationGroup="ExportOrders" SetFocusOnError="true" Display="Dynamic" />
                                                        <ajaxToolkit:FilteredTextBoxExtender ID="filStartDate" runat="server" TargetControlID="txtStartDate"
                                                            FilterType="Numbers, Custom" ValidChars="/" />
                                                        <asp:CustomValidator ID="valCustomStartDate" runat="server" CssClass="error"
                                                            ForeColor="" ErrorMessage='<%$ Resources: _Kartris, ContentText_InvalidValue %>' 
                                                            ControlToValidate="txtStartDate" ValidationGroup="ExportOrders" SetFocusOnError="true" Display="Dynamic" />
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>
                                            </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Literal ID="litFormLabelEndDate" runat="server" Text='<%$ Resources: _Kartris, FormLabel_EndDate %>' /> / 
                                            <asp:Literal ID="litFormLabelEndID" runat="server" Text='<%$ Resources: _Kartris, ContentText_ID %>' /> </span><span
                                                class="Kartris-DetailsView-Value">
                                                <asp:UpdatePanel ID="updDates2" runat="server" UpdateMode="Conditional">
                                                    <ContentTemplate>
                                                        <asp:ImageButton ID="imgBtnEnd" runat="server" ImageUrl="~/Skins/Admin/Images/icon_calendar.gif"
                                                            Width="16" Height="16" CssClass="calendarbutton" /><asp:TextBox ID="txtEndDate" runat="server"
                                                                MaxLength="20" CssClass="midtext" />
                                                        <ajaxToolkit:CalendarExtender ID="calExtEndDate" runat="server" TargetControlID="txtEndDate"
                                                            PopupButtonID="imgBtnEnd" Format="yyyy/MM/dd" CssClass="calendar" />
                                                        <asp:RequiredFieldValidator ID="valRequiredEndDate" runat="server" CssClass="error"
                                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                            ControlToValidate="txtEndDate" SetFocusOnError="true" ValidationGroup="ExportOrders" Display="Dynamic" />
                                                        <ajaxToolkit:FilteredTextBoxExtender ID="filEndDate" runat="server" TargetControlID="txtEndDate"
                                                            FilterType="Numbers, Custom" ValidChars="/" />
                                                       <asp:CustomValidator ID="valCustomEndDate" runat="server" CssClass="error"
                                                            ForeColor="" ErrorMessage='<%$ Resources: _Kartris, ContentText_InvalidValue %>' 
                                                            ControlToValidate="txtEndDate" ValidationGroup="ExportOrders" SetFocusOnError="true" Display="Dynamic" />
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>
                                            </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Literal ID="litContentTextExportFileName" runat="server" Text='<%$ Resources: _Export, ContentText_ExportFileName %>' />
                                        </span><span class="Kartris-DetailsView-Value">
                                            <asp:TextBox ID="txtFileName" runat="server" CssClass="midtext" MaxLength="50" />.csv
                                            <asp:RequiredFieldValidator ID="valRequiredFileName" runat="server" CssClass="error"
                                                ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                ControlToValidate="txtFileName" SetFocusOnError="true" ValidationGroup="ExportOrders" Display="Dynamic" />
                                        </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Literal ID="litContentTextFieldDelimiter" runat="server" Text='<%$ Resources: _Export, ContentText_FieldDelimiter %>' />
                                        </span><span class="Kartris-DetailsView-Value">
                                            <asp:DropDownList ID="ddlFieldDelimiter" runat="server" CssClass="midtext">
                                                <asp:ListItem Text="(,)" Value="44" />
                                                <asp:ListItem Text="<%$ Resources: _Export, ContentText_Tab %>" Value="9" />
                                                <asp:ListItem Text="(;)" Value="59" />
                                                <asp:ListItem Text="( )" Value="0" />
                                            </asp:DropDownList>
                                        </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Literal ID="litContentTextStringDelimiter" runat="server" Text='<%$ Resources: _Export, ContentText_StringDelimiter %>' />
                                        </span><span class="Kartris-DetailsView-Value">
                                            <asp:DropDownList ID="ddlStringDelimiter" runat="server" CssClass="midtext">
                                                <asp:ListItem Text="(')" Value="39" />
                                                <asp:ListItem Text="(&ldquo;)" Value="34" />
                                                <asp:ListItem Text="<%$ Resources: _Kartris, ContentText_Blank %>" Value="0" />
                                            </asp:DropDownList>
                                        </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Literal ID="litContentTextIncludeDetailsField" runat="server" Text='<%$ Resources: _Export, ContentText_IncludeDetailsField %>' />
                                        </span><span class="Kartris-DetailsView-Value">
                                            <asp:CheckBox ID="chkOrderDetails" runat="server" CssClass="checkbox" />
                                        </span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Literal ID="litContentTextIncludeIncompleteOrders" runat="server" Text='<%$ Resources: _Export, ContentText_IncludeIncompleteOrders %>' />
                                        </span><span class="Kartris-DetailsView-Value">
                                            <asp:CheckBox ID="chkIncompleteOrders" runat="server" CssClass="checkbox" />
                                        </span></li>
                                    </ul>
                                </div>
                            </div>
                            <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                                <asp:UpdatePanel ID="updExportButton" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:LinkButton ID="btnExportOrders" runat="server" CssClass="button exportbutton" Text='<%$ Resources: _Export, ContentText_Export %>'
                                            ToolTip='<%$ Resources: _Export, ContentText_Export %>' ValidationGroup="ExportOrders" />
                                        <asp:ValidationSummary ID="valSummary" runat="server" CssClass="valsummary" DisplayMode="BulletList"
                                            ForeColor="" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:PostBackTrigger ControlID="btnExportOrders" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </div>
                        </div>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <ajaxToolkit:TabPanel ID="tabCustomExport" runat="server" HeaderText='<%$ Resources: _Export, ContentText_CustomExport %>'>
                    <ContentTemplate>
                        <asp:UpdatePanel ID="updCustomExport" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <div class="subtabsection">
                                    <asp:Literal ID="litSavedExportID" runat="server" Visible="false" Text="0" />
                                    <asp:Literal ID="litSavedExportName" runat="server" Visible="false" Text="" />
                                    <div class="Kartris-DetailsView">
                                        <div class="Kartris-DetailsView-Data">
                                            <ul>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Literal ID="litContentTextExportName" runat="server" Text='<%$ Resources: _Export, ContentText_ExportName %>' /></span><span
                                                        class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="txtExportName" runat="server" CssClass="midtext" MaxLength="50" />
                                                        <asp:RequiredFieldValidator ID="valRequiredExportName" runat="server" CssClass="error"
                                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                            ControlToValidate="txtExportName" SetFocusOnError="true" ValidationGroup="CustomExport" Display="Dynamic" />
                                                    </span></li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Literal ID="litContentTextFieldDelimiter2" runat="server" Text='<%$ Resources: _Export, ContentText_FieldDelimiter %>' />
                                                </span><span class="Kartris-DetailsView-Value">
                                                    <asp:DropDownList ID="ddlCustomFieldDelimiter" runat="server" CssClass="midtext">
                                                        <asp:ListItem Text="(,)" Value="44" />
                                                        <asp:ListItem Text="<%$ Resources: _Export, ContentText_Tab %>" Value="9" />
                                                        <asp:ListItem Text="(;)" Value="59" />
                                                        <asp:ListItem Text="( )" Value="0" />
                                                    </asp:DropDownList>
                                                </span></li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Literal ID="litContentTextStringDelimiter2" runat="server" Text='<%$ Resources: _Export, ContentText_StringDelimiter %>' />
                                                </span><span class="Kartris-DetailsView-Value">
                                                    <asp:DropDownList ID="ddlCustomStringDelimiter" runat="server" CssClass="midtext">
                                                        <asp:ListItem Text="(')" Value="39" />
                                                        <asp:ListItem Text="(&ldquo;)" Value="34" />
                                                        <asp:ListItem Text="<%$ Resources: _Kartris, ContentText_Blank %>" Value="0" />
                                                    </asp:DropDownList>
                                                </span></li>
                                                <li><span class="Kartris-DetailsView-Name">
                                                    <asp:Literal ID="litContentTextExportQuery" runat="server" Text='<%$ Resources: _Export, ContentText_ExportQuery %>' /></span><span
                                                        class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="txtSqlQuery" runat="server" TextMode="MultiLine" />
                                                        <asp:RequiredFieldValidator ID="valReqiredQuery1" runat="server" CssClass="error"
                                                            Display="Dynamic" ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                            ControlToValidate="txtSqlQuery" SetFocusOnError="true" ValidationGroup="CustomExport" />
                                                    </span></li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                                <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                                    <asp:UpdatePanel ID="updCustomExportButtons" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <asp:LinkButton ID="btnSaveExport" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                                ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' ValidationGroup="CustomExport" /><asp:LinkButton
                                                    ID="btnCancel" runat="server" CssClass="button cancelbutton" Text="<%$ Resources: _Kartris, FormButton_Cancel %>"
                                                    ToolTip="<%$ Resources: _Kartris, FormButton_Cancel %>" Visible="false" />
                                            <asp:LinkButton ID="btnCustomExport" runat="server" CssClass="button exportbutton"
                                                Text='<%$ Resources: _Export, ContentText_Export %>' ToolTip='<%$ Resources: _Export, ContentText_Export %>'
                                                ValidationGroup="CustomExport" />
                                            <span class="floatright">
                                                <asp:LinkButton ID="lnkBtnDelete" runat="server" CommandName="cmdDelete" Visible="false"
                                                    CssClass="button deletebutton" Text='<%$ Resources: _Kartris, FormButton_Delete %>'
                                                    ToolTip='<%$ Resources: _Kartris, FormButton_Delete %>' /></span>
                                            <asp:ValidationSummary ID="valSummary2" runat="server" CssClass="valsummary" DisplayMode="BulletList"
                                                ForeColor="" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                                        </ContentTemplate>
                                        <Triggers>
                                            <asp:PostBackTrigger ControlID="btnCustomExport" />
                                        </Triggers>
                                    </asp:UpdatePanel>
                                </div>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <ajaxToolkit:TabPanel ID="tabSavedExports" runat="server" HeaderText="Saved Exports">
                    <ContentTemplate>
                        <div class="subtabsection">
                            <asp:UpdatePanel ID="updSavedExports" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:GridView CssClass="kartristable" ID="gvwSavedExports" runat="server" AllowPaging="False"
                                        AllowSorting="false" AutoGenerateColumns="False" DataKeyNames="Export_ID" AutoGenerateEditButton="False"
                                        GridLines="None" SelectedIndex="0">
                                        <Columns>
                                            <asp:BoundField DataField="Export_Name" HeaderText="<%$ Resources: _Export, ContentText_ExportName %>" HeaderStyle-CssClass="itemname" />
                                            <asp:TemplateField ItemStyle-CssClass="datefield">
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litContentTextDateCreated" runat="server" Text='<%$ Resources: _Kartris, ContentText_DateCreated %>'
                                                        EnableViewState="False" />
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <asp:Literal ID="litDateCreated" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("Export_DateCreated"), "d", Session("_LANG")) %>' />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-CssClass="datefield">
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litContentTextLastModified" runat="server" Text='<%$ Resources: _Kartris, ContentText_LastUpdated %>'
                                                        EnableViewState="False" />
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <asp:Literal ID="litLastModified" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("Export_LastModified"), "d", Session("_LANG")) %>' />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                                <HeaderTemplate>
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <asp:UpdatePanel ID="updExports" runat="server" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:LinkButton ID="lnkBtnExport" runat="server" CommandName="cmdExport" CommandArgument='<%# Eval("Export_ID") %>'
                                                                CssClass="linkbutton icon_upload" Text="Export" />
                                                            <asp:LinkButton ID="lnkBtnEdit" runat="server" CommandName="cmdEdit" CommandArgument='<%# Eval("Export_ID") %>'
                                                                CssClass="linkbutton icon_edit" Text='<%$ Resources: _Kartris, FormButton_Edit %>' />
                                                        </ContentTemplate>
                                                        <Triggers>
                                                            <asp:PostBackTrigger ControlID="lnkBtnExport" />
                                                        </Triggers>
                                                    </asp:UpdatePanel>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
            </ajaxToolkit:TabContainer>
        </div>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgMain" runat="server" AssociatedUpdatePanelID="updMain">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
