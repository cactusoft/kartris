<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Admin/Template.master" AutoEventWireup="false"
    CodeFile="_MediaTypes.aspx.vb" Inherits="admin_MediaTypes" %>

<%@ Register TagPrefix="_user" TagName="UploaderPopup" Src="~/UserControls/Back/_UploaderPopup.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_mediatypes">
        <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <h1>
                    <asp:Literal ID="litPageTitle" runat="server" Text='<%$ Resources:_Media, PageTitle_MediaTypes %>' /></h1>
                <asp:UpdatePanel ID="updMediaTypes" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:MultiView ID="mvwMedia" runat="server" ActiveViewIndex="0">
                            <asp:View ID="vwTypeList" runat="server">
                                <asp:UpdatePanel ID="updTypeList" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <span class="floatright">
                                            <asp:LinkButton ID="lnkBtnNewType" runat="server" Text='<%$ Resources: _Kartris, FormButton_New %>'
                                                CssClass="linkbutton icon_new" /></span><br />
                                        <asp:GridView CssClass="kartristable" ID="gvwMediaTypes" runat="server" AllowPaging="True"
                                            AllowSorting="true" AutoGenerateColumns="False" DataKeyNames="MT_ID" AutoGenerateEditButton="False"
                                            GridLines="None" PagerSettings-PageButtonCount="10" PageSize="15" SelectedIndex="0">
                                            <FooterStyle />
                                            <RowStyle />
                                            <Columns>
                                                <asp:TemplateField>
                                                    <HeaderTemplate>
                                                    </HeaderTemplate>
                                                    <ItemStyle CssClass="recordnumberfield" />
                                                    <ItemTemplate>
                                                        <asp:Literal ID="litRecordNumber" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Literal></ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField DataField="MT_ID" HeaderText="ID" ItemStyle-CssClass="itemname" Visible="false">
                                                    <HeaderStyle />
                                                </asp:BoundField>
                                                <asp:BoundField DataField="MT_Extension" HeaderText='<%$ Resources:_Media, ContentText_MediaType %>'>
                                                    <HeaderStyle />
                                                </asp:BoundField>
                                                <asp:BoundField DataField="MT_DefaultHeight" HeaderText='<%$ Resources:_Media, ContentText_DefaultHeight %>'>
                                                    <HeaderStyle />
                                                </asp:BoundField>
                                                <asp:BoundField DataField="MT_DefaultWidth" HeaderText='<%$ Resources:_Media, ContentText_DefaultWidth %>'>
                                                    <HeaderStyle />
                                                </asp:BoundField>
                                                <asp:TemplateField>
                                                    <HeaderTemplate>
                                                        <asp:Literal ID="litFormLabelEmbed" runat="server" Text='<%$ Resources:_Media, ContentText_Embed %>' />
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <asp:CheckBox ID="chkEmbed" runat="server" Checked='<%# CkartrisDataManipulation.FixNullFromDB(Eval("MT_Embed")) %>' CssClass="checkbox"
                                                            Enabled="false" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField>
                                                    <HeaderTemplate>
                                                        <asp:Literal ID="litFormLabelInline" runat="server" Text='<%$ Resources:_Media, ContentText_Inline %>' />
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <asp:CheckBox ID="chkInline" runat="server" Checked='<%# CkartrisDataManipulation.FixNullFromDB(Eval("MT_Inline")) %>' CssClass="checkbox"
                                                            Enabled="false" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField ItemStyle-CssClass="selectfield">
                                                    <HeaderTemplate>
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <asp:LinkButton ID="lnkBtnEditMedia" runat="server" CommandName="EditMediaType" CommandArgument='<%# Eval("MT_ID") %>'
                                                            Text='<%$ Resources: _Kartris, FormButton_Edit %>' CssClass="linkbutton icon_edit" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                            <EmptyDataTemplate>
                                                <asp:Panel ID="pnlNoItems" runat="server" CssClass="noresults">
                                                    <asp:Literal ID="litNoItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                                                    </asp:Literal>
                                                </asp:Panel>
                                            </EmptyDataTemplate>
                                        </asp:GridView>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </asp:View>
                            <asp:View ID="vwEditType" runat="server">
                                <asp:UpdatePanel ID="updEditType" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <div class="Kartris-DetailsView">
                                            <div class="Kartris-DetailsView-Data">
                                                <ul>
                                                    <%--Upload Icon--%>
                                                    <li><span class="Kartris-DetailsView-Name">
                                                        <asp:Label ID="lblMediaIcon" runat="server" Text="<%$ Resources: _Media, ContentText_MediaIcon %>"
                                                            AssociatedControlID=""></asp:Label>
                                                    </span><span class="Kartris-DetailsView-Value">
                                                        <asp:UpdatePanel ID="updUploadIcon" runat="server" UpdateMode="Conditional">
                                                            <ContentTemplate>
                                                                <asp:Image ID="imgMediaIcon" runat="server" />
                                                                <asp:LinkButton ID="lnkUploadIcon" runat="server" CssClass="linkbutton icon_upload"
                                                                    Text="<%$ Resources:_Kartris, ContentText_Upload %>" />
                                                                <asp:LinkButton ID="lnkRemoveIcon" runat="server" CssClass="linkbutton icon_delete"
                                                                    Text="<%$ Resources:_Kartris, FormButton_Remove %>" />
                                                                <asp:Literal ID="litOriginalIconName" runat="server" Visible="false" />
                                                                <asp:Literal ID="litTempIconName" runat="server" Visible="false" />
                                                                <_user:UploaderPopup ID="_UC_IconUploaderPopup" runat="server" />
                                                                <asp:PlaceHolder ID="phdUploadError" runat="server" Visible="false">
                                                                    <span class="error">
                                                                        <asp:Literal ID="litUploadError" runat="server" />
                                                                    </span>
                                                                </asp:PlaceHolder>
                                                            </ContentTemplate>
                                                        </asp:UpdatePanel>
                                                        </span></li>
                                                    <%--Media Type--%>
                                                    <li><span class="Kartris-DetailsView-Name">
                                                        <asp:Label ID="litMediaTypeLabel" runat="server" Text="<%$ Resources: _Media, ContentText_MediaType %>"
                                                            AssociatedControlID="txtMediaType"></asp:Label>
                                                    </span><span class="Kartris-DetailsView-Value">
                                                        <asp:Literal ID="litMediaTypeID" runat="server" Visible="false" />
                                                        <asp:TextBox ID="txtMediaType" runat="server" CssClass="midtext" MaxLength="20" />
                                                        <asp:RequiredFieldValidator ID="rfvMediaType" runat="server" CssClass="error" ForeColor=""
                                                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="txtMediaType"
                                                            Display="Dynamic" SetFocusOnError="true" ValidationGroup="EditMediaType" />
                                                    </span></li>
                                                    <%--Media Default Height--%>
                                                    <li><span class="Kartris-DetailsView-Name">
                                                        <asp:Label ID="litDefaultHeight" runat="server" Text="<%$ Resources: _Media, ContentText_DefaultHeight %>"
                                                            AssociatedControlID="txtDefaultHeight"></asp:Label>
                                                    </span><span class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="txtDefaultHeight" runat="server" CssClass="shorttext" MaxLength="4" />
                                                        <asp:RequiredFieldValidator ID="valRequiredDefaultHeight" runat="server" ValidationGroup="EditMediaType"
                                                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" Display="Dynamic"
                                                            CssClass="error" ForeColor="" SetFocusOnError="true" ControlToValidate="txtDefaultHeight" />
                                                        <ajaxToolkit:FilteredTextBoxExtender ID="filDefaultHeight" runat="server"
                                                            TargetControlID="txtDefaultHeight" FilterType="Numbers" />
                                                        <%--FULL SCREEN--%>
                                                        <div style="display:inline-block;position: absolute; margin: 13px 0 0 40px;">
                                                            <asp:CheckBox ID="chkFullScreen" runat="server" CssClass="checkbox checkbox_label" Text="100%" AutoPostBack="True" />
                                                        </div>
                                                    </span></li>
                                                    <%--Media Default Width--%>
                                                    <li><span class="Kartris-DetailsView-Name">
                                                        <asp:Label ID="litDefaultWidth" runat="server" Text="<%$ Resources: _Media, ContentText_DefaultWidth %>"
                                                            AssociatedControlID="txtDefaultWidth"></asp:Label>
                                                    </span><span class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="txtDefaultWidth" runat="server" CssClass="shorttext" MaxLength="4" />
                                                        <asp:RequiredFieldValidator ID="valRequiredDefaultWidth" runat="server" ValidationGroup="EditMediaType"
                                                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" Display="Dynamic"
                                                            CssClass="error" ForeColor="" SetFocusOnError="true" ControlToValidate="txtDefaultWidth" />
                                                        <ajaxToolkit:FilteredTextBoxExtender ID="filDefaultWidth" runat="server"
                                                            TargetControlID="txtDefaultWidth" FilterType="Numbers" />
                                                    </span></li>
                                                    <%--Default Parameters--%>
                                                    <li><span class="Kartris-DetailsView-Name">
                                                        <asp:Label ID="lblDefaultParameters" runat="server" Text="<%$ Resources:_Media, ContentText_DefaultParameters %>"
                                                            AssociatedControlID="txtDefaultParameters"></asp:Label>
                                                    </span><span class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="txtDefaultParameters" runat="server" MaxLength="1000" />
                                                    </span></li>
                                                    <%--Downloadable --%>
                                                    <li><span class="Kartris-DetailsView-Name">
                                                        <asp:Label ID="lblDownloadable" runat="server" Text="<%$ Resources: _Media, ContentText_Downloadable %>"
                                                            AssociatedControlID="chkDownloadable"></asp:Label>
                                                    </span><span class="Kartris-DetailsView-Value">
                                                        <asp:CheckBox ID="chkDownloadable" runat="server" CssClass="checkbox" /></span>
                                                    </li>
                                                    <%--Embed--%>
                                                    <li><span class="Kartris-DetailsView-Name">
                                                        <asp:Label ID="lblEmbed" runat="server" Text="<%$ Resources: _Media, ContentText_Embed %>"
                                                            AssociatedControlID="chkEmbed"></asp:Label>
                                                    </span><span class="Kartris-DetailsView-Value">
                                                        <asp:CheckBox ID="chkEmbed" runat="server" CssClass="checkbox" /></span>
                                                    </li>
                                                    <%--Inline--%>
                                                    <li><span class="Kartris-DetailsView-Name">
                                                        <asp:Label ID="lblInline" runat="server" Text="<%$ Resources: _Media, ContentText_Inline %>"
                                                            AssociatedControlID="chkInline"></asp:Label>
                                                    </span><span class="Kartris-DetailsView-Value">
                                                        <asp:CheckBox ID="chkInline" runat="server" CssClass="checkbox" /></span>
                                                    </li>
                                                </ul>
                                            </div>
                                        </div>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                                <asp:UpdatePanel ID="updSubmitButtons" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                                            <asp:LinkButton ID="lnkBtnSave" runat="server" ToolTip='<%$ Resources: _Kartris, FormButton_Save %>'
                                                CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                                ValidationGroup="EditMediaType" />
                                            <asp:LinkButton ID="lnkBtnCancel" runat="server" CssClass="button cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                                ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                                            <asp:ValidationSummary ID="valSummary" runat="server" ForeColor="" CssClass="valsummary"
                                                DisplayMode="BulletList" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                                        </div>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </asp:View>
                        </asp:MultiView>
                        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
                    </ContentTemplate>
                </asp:UpdatePanel>
                <asp:UpdateProgress ID="prgMediaTypes" runat="server" AssociatedUpdatePanelID="updMediaTypes">
                    <ProgressTemplate>
                        <div class="loadingimage">
                        </div>
                        <div class="updateprogress">
                        </div>
                    </ProgressTemplate>
                </asp:UpdateProgress>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</asp:Content>
