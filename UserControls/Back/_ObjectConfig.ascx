<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_ObjectConfig.ascx.vb"
    Inherits="UserControls_Back_ObjectConfig" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <div class="Kartris-DetailsView">
            <div class="Kartris-DetailsView-Data">
                <ul>

                    <asp:Repeater ID="rptObjectConfig" runat="server">
                        <ItemTemplate>

                            <asp:Literal ID="litConfigID" runat="server" Text='<%# Eval("OC_ID") %>' Visible="false" />
                            <asp:Literal ID="litConfigType" runat="server" Text='<%# Eval("OC_DataType") %>' Visible="false" />

                            <li><span class="Kartris-DetailsView-Name">
                                <asp:Literal ID="litConfigName" runat="server" Text='<%# Eval("OC_Name") %>' /></span>
                                <span class="Kartris-DetailsView-Value">
                                    <asp:CheckBox ID="chkSelected" runat="server" CssClass="checkbox" Visible='<%# Eval("OC_DataType") = "b" %>'
                                        Text="<%$ Resources: _Kartris, ContentText_Enabled %>" />
                                    <%-- if value type is "n" or "s", textbox will appear --%>
                                    <asp:CheckBox ID="chk_HiddenMultiline" runat="server" Visible="false" Checked='<%# Eval("OC_MultilineValue") %>' />
                                    <asp:TextBox ID="txtValue" runat="server" Visible='<%# Eval("OC_DataType") <> "b" %>'
                                        CssClass="midtext" MaxLength="200" />
                                    <asp:CompareValidator ID="cvNumberValue" runat="server" ErrorMessage="<%$ Resources: _Kartris, ContentText_InvalidValue %>"
                                        ControlToValidate="txtValue" Operator="DataTypeCheck" Type="Double" CssClass="error" ForeColor=""
                                        Enabled='<%# Eval("OC_DataType") = "n" %>' Display="Dynamic" />
                                    <ajaxToolkit:FilteredTextBoxExtender ID="filNumberValue" runat="server" TargetControlID="txtValue"
                                        FilterType="Numbers,Custom" ValidChars="." Enabled='<%# Eval("OC_DataType") = "n" %>' />
                                </span></li>

                            <li><span class="Kartris-DetailsView-Name"></span>
                                <span class="Kartris-DetailsView-Value">
                                    <asp:Literal ID="litOC_Description" runat="server" Text='<%# Eval("OC_Description") %>'></asp:Literal></span></li>
                            <li>
                                <br />
                                <div class="line"></div>
                            </li>
                        </ItemTemplate>
                    </asp:Repeater>

                </ul>
            </div>
        </div>
        <!-- Save Button  -->
        <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
            <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:LinkButton ID="btnSave" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                        ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                    <asp:LinkButton ID="btnCancel" runat="server" CssClass="button cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                        ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
