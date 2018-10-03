<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_SubSiteDetails.ascx.vb" Inherits="UserControls_Back_SubSiteDetails" %>
<%@ Register TagPrefix="_user" TagName="AutoComplete" Src="~/UserControls/Back/_AutoCompleteInput.ascx" %>


<div class="floatright">
    <a class="linkbutton icon_back floatright" href='../Admin/_SubSitesList.aspx'>
                        <asp:Literal ID="litContentTextBackLink" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>' /></a>
</div>

<asp:UpdatePanel ID="updMainInfo" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:FormView ID="fvwSubSiteDetails" runat="server" DefaultMode="Edit">
            <EditItemTemplate>
                <ajaxToolkit:TabContainer ID="tabContaineSubSite" runat="server" EnableTheming="False"
                    CssClass=".tab" AutoPostBack="false">
                    <ajaxToolkit:TabPanel ID="tabMainInfo" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litTabMainInfo2" runat="server" Text="Info" />
                        </HeaderTemplate>
                        <ContentTemplate>
                            <div class="Kartris-DetailsView">
                                <div class="Kartris-DetailsView-Data">
                                    <ul>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblSubSiteID" runat="server" Text="SubSite ID" /></span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:Literal ID="litSubSiteID" runat="server" Text='<%#Eval("SUB_ID") %>'></asp:Literal></span>
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblSubSiteName" runat="server" Text="Name"
                                                AssociatedControlID="txtSubSiteName" /></span> <span class="Kartris-DetailsView-Value">
                                                    <asp:TextBox runat="server" ID="txtSubSiteName" Text='<%#Eval("SUB_Name")%>' /></span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblSubSiteDomain" runat="server" Text="Domain"
                                                AssociatedControlID="txtSubSiteDomain" /></span> <span class="Kartris-DetailsView-Value">
                                                    <asp:TextBox runat="server" ID="txtSubSiteDomain" Text='<%#Eval("SUB_Domain")%>' /></span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="litContentTextCategoryParent" runat="server" Text="Category"></asp:Label>
                                        </span>
                                        <span class="Kartris-DetailsView-Value">
                                            <asp:UpdatePanel ID="updCategory" runat="server" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:ListBox ID="lbxCategory" runat="server"></asp:ListBox>
                                                    <asp:LinkButton ID="lnkBtnRemoveCategory" Cssclass="linkbutton icon_delete" runat="server"
                                                        Text='<%$ Resources:_Kartris, ContentText_RemoveSelected %>' /><br />
                                                    <_user:AutoComplete ID="_UC_AutoComplete" runat="server" MethodName="GetCategories" />
                                                    <asp:LinkButton ID="lnkBtnAddCategory" Cssclass="linkbutton icon_new" runat="server"
                                                        Text='Select' /><br />
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </span>
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblSubSiteCatSkin" runat="server" Text="Skin"
                                                AssociatedControlID="txtSubSiteSkin" /></span> <span class="Kartris-DetailsView-Value">
                                                    <%--<asp:TextBox ReadOnly="true" runat="server" ID="txtSubSiteSkin" Text='<%#Eval("SUB_Skin")%>' />--%><asp:DropDownList ID="ddlistTheme" runat="server" AutoPostBack="False">
                                                            </asp:DropDownList></span>
                                                            <asp:TextBox ID="txtTheme" runat="server" MaxLength="50" Visible="False" /></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblSubSiteNotes" runat="server" Text="Notes"
                                                AssociatedControlID="txtSubSiteNotes" /></span> <span class="Kartris-DetailsView-Value">
                                                    <asp:TextBox runat="server" ID="txtSubSiteNotes" TextMode="MultiLine" Text='<%#Eval("SUB_Notes")%>' /></span></li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblOrderStatus" runat="server" Text="Status" /></span>
                                                
                                            <span class="Kartris-DetailsView-Value"><span class="checkbox">
                                                <asp:CheckBox runat="server" ID="chkSubSiteLive" Checked='<%#Bind("SUB_Live")%>' /></span>
                                                <asp:Label CssClass="checkbox_label" ID="lblSubSiteLive" runat="server" Text="Live"
                                                    AssociatedControlID="chkSubSiteLive" /><asp:HiddenField runat="server" ID="hidOrigSubSiteLive"
                                                        Value='<%#Eval("SUB_Live")%>' />
                                                <br />
                                            </span></li>
                                    </ul>
                                        <asp:PlaceHolder runat="server" ID="phdCancelledMessage" Visible="false">
                                            <div class="warnmessage"><asp:Literal ID="litCancelledMessage" runat="server"
                                            Text="<%$ Resources: _Orders, ContentText_OrderStatusCancelled %>" /></div>
                                        </asp:PlaceHolder>
                                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                                        <asp:LinkButton CausesValidation="True" CommandName="Update" CssClass="button savebutton" OnClick="lnkBtnUpdate_Click"
                                            runat="server" ID="lnkBtnUpdate" Text="<%$ Resources: _Kartris, FormButton_Save %>"
                                            ToolTip="<%$ Resources: _Kartris, FormButton_Save %>" />
                                    </div>
                                </div>
                            </div>
                            </ContentTemplate>
                        </ajaxToolkit:TabPanel>
                </ajaxToolkit:TabContainer>
            </EditItemTemplate>
        </asp:FormView>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>