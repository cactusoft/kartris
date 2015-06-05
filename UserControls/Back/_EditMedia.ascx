<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_EditMedia.ascx.vb" Inherits="UserControls_Back_EditMedia" %>
<%@ Register TagPrefix="_user" TagName="UploaderPopup" Src="~/UserControls/Back/_UploaderPopup.ascx" %>

<script type="text/javascript" language="javascript">
    //<![CDATA[

    //Function to set URL for iframe of media popup, size it, and show it
    function ShowMediaPopup(ML_ID, MT_Extension, intParentID, strParentType, intWidth, intHeight) {
        //Set some variables we use later
        var objFrame = $find('phdMain__UC_EditMedia_UC_PopUpMedia_popMessage');
        var objMediaIframeBaseUrl = document.getElementById('media_iframe_base_url').value;
        var objPopupWindow = document.getElementById('phdMain__UC_EditMedia_UC_PopUpMedia_pnlMessage');
        var objMediaIframe = document.getElementById('media_iframe');
        //Set media ID
        objMediaIframe.src = objMediaIframeBaseUrl + "?ML_ID=" + ML_ID;
        //Set parent ID
        objMediaIframe.src = objMediaIframe.src + "&intParentID=" + intParentID;
        //Set parent type
        objMediaIframe.src = objMediaIframe.src + "&strParentType=" + strParentType;
        //Set file type
        objMediaIframe.src = objMediaIframe.src + "&MT_Extension=" + MT_Extension;
        //Size popup dynamically based on file type
        objPopupWindow.style.width = (intWidth*1 + 20) + "px";
        objPopupWindow.style.height = (intHeight * 1 + 15) + "px";
        //Show the popup
        objFrame.show();
    }
    //]]>
</script>

<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:Literal ID="litParentType" runat="server" Visible="false" />
        <asp:Literal ID="litParentID" runat="server" Visible="false" />
        <user:PopupMessage ID="UC_PopUpMedia" runat="server" />
        <asp:MultiView ID="mvwMedia" runat="server" ActiveViewIndex="0">
            <asp:View ID="viwMediaList" runat="server">
                <div id="fileuploader">
                    <asp:Button ID="btnNewMedia" runat="server" runat="server" Text="<%$ Resources: _Kartris, ContentText_AddNew %>"
                        CssClass="button" />
                </div>
                <asp:Repeater ID="rptMediaLinks" runat="server">
                    <ItemTemplate>
                        <div class="placeholder_sorter" <%# IIf(Eval("ML_Live"), "", "style=""background-color: #eee;border-color:#fff;""")%>>
                            <div class="updownbuttons">
                                <asp:LinkButton ID="lnkBtnMoveUp" runat="server" CommandName="MoveUp" Text="+" CssClass="triggerswitch triggerswitch_on"
                                    CommandArgument='<%# Eval("ML_ID") %>' /><asp:LinkButton ID="lnkBtnMoveDown" runat="server" CommandName="MoveDown" Text="-"
                                    CssClass="triggerswitch triggerswitch_off" CommandArgument='<%# Eval("ML_ID") %>' />
                            </div>
                            <div class="sort_image_holder">
                                <asp:Literal ID="litMediaLink" runat="server"></asp:Literal>
                            </div>
                            <div class="sort_details_holder">
                                <asp:Literal ID="litMediaID" runat="server" Text='<%# Bind("ML_ID") %>' Visible="false"></asp:Literal>                         
                                <strong><asp:Literal ID="litItemName" runat="server" Text='<%# Bind("ML_Parameters")%>'></asp:Literal></strong><br />   
                                <asp:Literal ID="litImgName" runat="server" Text='<%# Bind("MT_Extension") %>'></asp:Literal>           
                            </div>
                            <div class="sort_remove_holder">
                                <asp:LinkButton ID="lnkEdit" runat="server"
                                    CommandName="EditMedia" CssClass="linkbutton icon_edit" Text='<%$ Resources: _Kartris, FormButton_Edit %>'
                                    CommandArgument='<%# Eval("ML_ID") %>' />
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <br />
            </asp:View>
            <asp:View ID="viwEditMedia" runat="server">
                <asp:Literal ID="litMediaLinkID" runat="server" Visible="false"/>
                <asp:CheckBox ID="chkEmbed" runat="server" Visible = "false" />
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <%--Media Type--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="litMediaTypeLabel" runat="server" Text="<%$ Resources: _Media, ContentText_MediaType %>" AssociatedControlID="ddlMediaType"></asp:Label>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:DropDownList ID="ddlMediaType" runat="server" AppendDataBoundItems="true" CssClass="midtext" AutoPostBack="true">
                                        <asp:ListItem Text='<%$ Resources: _Kartris, ContentText_DropDownSelect %>' Value="0" />
                                    </asp:DropDownList>
                                    <asp:CompareValidator ID="valCompareMediaType" runat="server" CssClass="error" ForeColor=""
                                        ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" ControlToValidate="ddlMediaType"
                                        Operator="NotEqual" ValueToCompare="0" Display="Dynamic" SetFocusOnError="true"
                                        ValidationGroup="EditMedia" />
                                </span></li>
                                <asp:PlaceHolder ID="phdMediaDetails" runat="server" Visible="false">
                                <%--Upload Thumb--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblMediaThumb" runat="server" Text="<%$ Resources: _Media, ContentText_MediaThumb %>" AssociatedControlID=""></asp:Label>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:UpdatePanel ID="updUploadThumb" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <asp:Image ID="imgMediaThumb" runat="server" visible="False" />
                                            <img src="../Image.aspx?strFullPath=<asp:Literal ID="litImgName" runat="server"/>&numMaxHeight=<asp:Literal Text="80" ID="litImgHeight" runat="server"/>&numMaxWidth=<asp:Literal Text="80" ID="litImgWidth" runat="server"/>" />
                                            <asp:LinkButton ID="lnkUploadThumb" runat="server" CssClass="linkbutton icon_upload"
                                                Text="<%$ Resources:_Kartris, ContentText_Upload %>" />

                                            <asp:LinkButton ID="lnkRemoveThumb" runat="server" CssClass="linkbutton icon_delete"
                                                Text="<%$ Resources:_Kartris, FormButton_Remove %>" />
                                            <asp:Literal ID="litOriginalThumbName" runat="server" Visible="false" />
                                            <asp:Literal ID="litTempThumbName" runat="server" Visible="false" />
                                            <_user:UploaderPopup ID="_UC_ThumbUploaderPopup" runat="server" />
                                            <asp:PlaceHolder ID="phdThumbUploadError" runat="server" Visible="false"><span class="error">
                                                <asp:Literal ID="litThumbUploadError" runat="server" />
                                            </span></asp:PlaceHolder>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </span></li>
                                <%--Media Embed Source--%>
                                <asp:PlaceHolder ID="phdEmbed" runat="server" Visible="true">
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="litMediaSource" runat="server" Text="<%$ Resources: _Media, ContentText_EmbedSource %>" AssociatedControlID="txtEmbedSource"></asp:Label>
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtEmbedSource" runat="server" TextMode="MultiLine" Width="400"
                                            Height="120" />
                                        <asp:RequiredFieldValidator ID="valRequiredEmbedSource" runat="server" ValidationGroup="EditMedia"
                                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" Display="Dynamic"
                                            CssClass="error" ForeColor="" SetFocusOnError="true" ControlToValidate="txtEmbedSource"
                                            Enabled="false" />
                                    </span></li>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblParameters2" runat="server" Text="<%$ Resources:_Category, ContentText_TextProdTypeDisplay %>" AssociatedControlID="txtParameters"></asp:Label>
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtParameters2" runat="server" MaxLength="200" />
                                        <asp:RequiredFieldValidator ID="valRequiredParameters2" runat="server" ValidationGroup="EditMedia"
                                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" Display="Dynamic"
                                            CssClass="error" ForeColor="" SetFocusOnError="true" ControlToValidate="txtParameters2"
                                            Enabled="false" />
                                    </span></li>
                                </asp:PlaceHolder>
                                <asp:PlaceHolder ID="phdNonEmbedControls" runat="server" Visible="true">
                                    <%--Upload File--%>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblUploadFile" runat="server" Text="<%$ Resources: _Media, ContentText_MediaFile %>" AssociatedControlID=""></asp:Label>
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litMediaFileName" runat="server" Visible="false" />
                                        <asp:UpdatePanel ID="updUploadFile" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:LinkButton ID="lnkUploadFile" runat="server" CssClass="linkbutton icon_upload"
                                                    Text="<%$ Resources:_Kartris, ContentText_Upload %>" />
                                                <asp:LinkButton ID="lnkRemoveFile" runat="server" CssClass="linkbutton icon_delete"
                                                    Text="<%$ Resources:_Kartris, FormButton_Remove %>" />
                                                <asp:CustomValidator ID="cvMediaFile" runat="server" ValidationGroup="EditMedia"
                                                    ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" Display="Dynamic"
                                                    CssClass="error" ForeColor="" SetFocusOnError="true" Enabled="true"
                                                    OnServerValidate="ValidateMediaFile" />
                                                <asp:Literal ID="litOriginalFileName" runat="server" Visible="false" />
                                                <asp:Literal ID="litTempFileName" runat="server" Visible="false" />
                                                <_user:UploaderPopup ID="_UC_FileUploaderPopup" runat="server" />
                                                <asp:PlaceHolder ID="phdFileUploadError" runat="server" Visible="false"><span class="error">
                                                    <asp:Literal ID="litFileUploadError" runat="server" />
                                                </span></asp:PlaceHolder>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </span></li>
                                    <%--Upload File 2--%>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblUploadFile2" runat="server" Text="<%$ Resources: _Media, ContentText_MediaFile %>" AssociatedControlID=""></asp:Label>
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:Literal ID="litMediaFileName2" runat="server" Visible="false" />
                                        <asp:UpdatePanel ID="updUploadFile2" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:LinkButton ID="lnkUploadFile2" runat="server" CssClass="linkbutton icon_upload"
                                                    Text="<%$ Resources:_Kartris, ContentText_Upload %>" />
                                                <asp:LinkButton ID="lnkRemoveFile2" runat="server" CssClass="linkbutton icon_delete"
                                                    Text="<%$ Resources:_Kartris, FormButton_Remove %>" />
                                                <asp:CustomValidator ID="cvMediaFile2" runat="server" ValidationGroup="EditMedia"
                                                    ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" Display="Dynamic"
                                                    CssClass="error" ForeColor="" SetFocusOnError="true" Enabled="true"
                                                    OnServerValidate="ValidateMediaFile2" />
                                                <asp:Literal ID="litOriginalFileName2" runat="server" Visible="false" />
                                                <asp:Literal ID="litTempFileName2" runat="server" Visible="false" />
                                                <_user:UploaderPopup ID="_UC_FileUploaderPopup2" runat="server" />
                                                <asp:PlaceHolder ID="phdFileUploadError2" runat="server" Visible="false"><span class="error">
                                                    <asp:Literal ID="litFileUploadError2" runat="server" />
                                                </span></asp:PlaceHolder>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </span></li>
                                    <%--Parameters--%>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblParameters" runat="server" Text="<%$ Resources:_Category, ContentText_TextProdTypeDisplay %>" AssociatedControlID="txtParameters"></asp:Label>
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtParameters" runat="server" MaxLength="200" />
                                        <asp:RequiredFieldValidator ID="valRequiredParameters" runat="server" ValidationGroup="EditMedia"
                                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" Display="Dynamic"
                                            CssClass="error" ForeColor="" SetFocusOnError="true" ControlToValidate="txtParameters"
                                            Enabled="false" />
                                        <asp:Literal ID="litDefaultParameter" runat="server" Visible="false" />
                                    </span></li>
                                    <%--Downloadable --%>
                                    <li style="display:none;"><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblDownloadable" runat="server" Text="<%$ Resources: _Media, ContentText_Downloadable %>" AssociatedControlID="chkDownloadable"></asp:Label>
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:CheckBox ID="chkDownloadable" runat="server" CssClass="checkbox" /></span>
                                    </li>
                                </asp:PlaceHolder>
                                <%--Media Height--%>
                                <asp:PlaceHolder ID="phdHeightWidth" runat="server">
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblMediaHeight" runat="server" Text="<%$ Resources:_Media, ContentText_MediaHeight %>" AssociatedControlID="txtHeight"></asp:Label>
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtHeight" runat="server" CssClass="shorttext" MaxLength="4" />
                                        <asp:RequiredFieldValidator ID="valRequiredHeight" runat="server" ValidationGroup="EditMedia"
                                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" Display="Dynamic"
                                            CssClass="error" ForeColor="" SetFocusOnError="true" ControlToValidate="txtHeight"
                                            Enabled="false" />
                                        <asp:CheckBox ID="chkDefaultHeight" runat="server" Text="<%$ Resources:_Kartris, ContentText_DefaultValue %>" Checked="false"
                                            AutoPostBack="true" CssClass="checkbox" />
                                        <asp:Literal ID="litDefaultHeight" runat="server" Visible="false" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filHeight" runat="server"
                                            TargetControlID="txtHeight" FilterType="Numbers" />
                                    </span></li>
                                    <%--Media Width--%>
                                    <li><span class="Kartris-DetailsView-Name">
                                        <asp:Label ID="lblMediaWidth" runat="server" Text="<%$ Resources:_Media, ContentText_MediaWidth %>" AssociatedControlID="txtWidth"></asp:Label>
                                    </span><span class="Kartris-DetailsView-Value">
                                        <asp:TextBox ID="txtWidth" runat="server" CssClass="shorttext" MaxLength="4" />
                                        <asp:RequiredFieldValidator ID="valRequiredWidth" runat="server" ValidationGroup="EditMedia"
                                            ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>" Display="Dynamic"
                                            CssClass="error" ForeColor="" SetFocusOnError="true" ControlToValidate="txtWidth"
                                            Enabled="false" />
                                        <asp:CheckBox ID="chkDefaultWidth" runat="server" Text="<%$ Resources:_Kartris, ContentText_DefaultValue %>" Checked="false"
                                            AutoPostBack="true" CssClass="checkbox" />
                                        <asp:Literal ID="litDefaultWidth" runat="server" Visible="false" />
                                        <ajaxToolkit:FilteredTextBoxExtender ID="filWidth" runat="server"
                                            TargetControlID="txtWidth" FilterType="Numbers" />
                                    </span></li>
                                </asp:PlaceHolder>
                                <%--Live--%>
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Label ID="lblLive" runat="server" Text="<%$ Resources: _Kartris, ContentText_Live %>"
                                        AssociatedControlID="chkLive"></asp:Label>
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:CheckBox ID="chkLive" runat="server" CssClass="checkbox" /></span>
                                </li>
                            </asp:PlaceHolder>
                        </ul>
                    </div>
                </div>
                <!-- Save Button  -->
                <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                    <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:LinkButton ID="btnSave" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' ValidationGroup="EditMedia" />
                            <asp:LinkButton ID="btnCancel" runat="server" CssClass="button cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                            <asp:Literal ID="litPreview" runat="server"></asp:Literal>
                            <span class="floatright">
                                <asp:LinkButton ID="lnkBtnDelete" CssClass="button deletebutton"
                                    runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>' ToolTip='<%$ Resources: _Product, ContentText_DeleteThisProduct %>' /></span><asp:ValidationSummary
                                        ID="valSummary" runat="server" CssClass="valsummary" DisplayMode="BulletList"
                                        ForeColor="" HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </asp:View>
        </asp:MultiView>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
        <div style='display: none'>
            <asp:PlaceHolder ID="phdInline" runat="server" />
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
