<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_SubSiteDetails.ascx.vb" Inherits="UserControls_Back_SubSiteDetails" %>
<%@ Register TagPrefix="_user" TagName="AutoComplete" Src="~/UserControls/Back/_AutoCompleteInput.ascx" %>
<%@ Register TagPrefix="_user" TagName="ObjectConfig" Src="~/UserControls/Back/_ObjectConfig.ascx" %>


<div class="floatright">
    <a class="linkbutton icon_back floatright" href='../Admin/_SubSitesList.aspx'>
        <asp:Literal ID="litContentTextBackLink" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>' /></a>
</div>

<asp:UpdatePanel ID="updMainInfo" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:FormView ID="fvwSubSiteDetails" runat="server" DefaultMode="Edit">
            <EditItemTemplate>
                <ajaxToolkit:TabContainer ID="tabContainerSubSite" runat="server" EnableTheming="False" CssClass=".tab" AutoPostBack="true" ActiveTabIndex="0" OnActiveTabChanged="tabContainerSubSite_ActiveTabChanged">
                    <ajaxToolkit:TabPanel ID="tabMainInfo" runat="server">
                        <HeaderTemplate>
                            <asp:Literal ID="litTabMainInfoHeader" runat="server" Text="Info" />
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
                                                    <asp:TextBox runat="server" ID="txtSubSiteName" Text='<%# CkartrisDataManipulation.FixNullFromDB(Eval("SUB_Name"))%>' /></span>
                                            <asp:RequiredFieldValidator ID="valRequiredSubSiteName" runat="server" CssClass="error"
                                                ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                ControlToValidate="txtSubSiteName" ValidationGroup="SaveSubSite" Display="Dynamic" />
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblSubSiteDomain" runat="server" Text="Domain"
                                                AssociatedControlID="txtSubSiteDomain" /></span> <span class="Kartris-DetailsView-Value">
                                                    <asp:TextBox runat="server" ID="txtSubSiteDomain" Text='<%# CkartrisDataManipulation.FixNullFromDB(Eval("SUB_Domain"))%>' /></span>
                                            <asp:RequiredFieldValidator ID="valRequiredSubSiteDomain" runat="server" CssClass="error"
                                                ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                ControlToValidate="txtSubSiteDomain" ValidationGroup="SaveSubSite" Display="Dynamic" />
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="litContentTextCategoryParent" runat="server" Text="Category"></asp:Label>
                                        </span>
                                            <span class="Kartris-DetailsView-Value">
                                                <asp:UpdatePanel ID="updCategory" runat="server" UpdateMode="Conditional">
                                                    <ContentTemplate>
                                                        <asp:ListBox ID="lbxCategory" runat="server"></asp:ListBox>
                                                        <asp:LinkButton ID="lnkBtnRemoveCategory" CssClass="linkbutton icon_delete" runat="server"
                                                            Text='<%$ Resources:_Kartris, ContentText_RemoveSelected %>' /><br />
                                                        <_user:AutoComplete ID="_UC_AutoComplete" runat="server" MethodName="GetCategories" />
                                                        <asp:LinkButton ID="lnkBtnAddCategory" CssClass="linkbutton icon_new" runat="server"
                                                            Text='Select' /><br />
                                                        <asp:RequiredFieldValidator ID="RequiredLbxCategory" runat="server" CssClass="error"
                                                            ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                            ControlToValidate="lbxCategory" ValidationGroup="SaveSubSite" Display="Dynamic" />
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>
                                            </span>
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblSubSiteCatSkin" runat="server" Text="Skin"
                                                AssociatedControlID="ddlistTheme" /></span> <span class="Kartris-DetailsView-Value">
                                                    <%--<asp:TextBox ReadOnly="true" runat="server" ID="txtSubSiteSkin" Text='<%#Eval("SUB_Skin")%>' />--%>
                                                    <asp:DropDownList ID="ddlistTheme" runat="server" AutoPostBack="False">
                                                        <asp:ListItem Text="-" Value="" />
                                                    </asp:DropDownList></span>
                                            <asp:TextBox ID="txtTheme" runat="server" MaxLength="50" Visible="False" />
                                            <asp:RequiredFieldValidator ID="RequiredtxtTheme" runat="server" CssClass="error"
                                                ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                ControlToValidate="ddlistTheme" ValidationGroup="SaveSubSite" Display="Dynamic" />
                                        </li>
                                        <li><span class="Kartris-DetailsView-Name">
                                            <asp:Label ID="lblSubSiteNotes" runat="server" Text="Notes"
                                                AssociatedControlID="txtSubSiteNotes" /></span> <span class="Kartris-DetailsView-Value">
                                                    <asp:TextBox runat="server" ID="txtSubSiteNotes" TextMode="MultiLine" Text='<%# CkartrisDataManipulation.FixNullFromDB(Eval("SUB_Notes"))%>' /></span></li>
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
                                        <div class="warnmessage">
                                            <asp:Literal ID="litCancelledMessage" runat="server"
                                                Text="<%$ Resources: _Orders, ContentText_OrderStatusCancelled %>" />
                                        </div>
                                    </asp:PlaceHolder>

                                </div>
                            </div>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <%-- Object Config Tab --%>
                    <ajaxToolkit:TabPanel runat="server" ID="tabObjectConfig">
                        <HeaderTemplate>
                            <asp:Literal ID="litTabMainObjConfigHeader" runat="server" Text="Object Config" />
                        </HeaderTemplate>
                        <ContentTemplate>
                            <div class="subtabsection">
                                <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9996')" style="margin-bottom: 20px;">?</a>
                                <_user:ObjectConfig ID="_UC_ObjectConfig" runat="server" ItemType="SubSite" />
                            </div>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                </ajaxToolkit:TabContainer>
            </EditItemTemplate>
        </asp:FormView>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
        <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
            <asp:LinkButton CausesValidation="True" CommandName="Update" CssClass="button savebutton" OnClick="lnkBtnUpdate_Click"
                runat="server" ID="lnkBtnUpdate" Text="<%$ Resources: _Kartris, FormButton_Save %>"
                ToolTip="<%$ Resources: _Kartris, FormButton_Save %>" />
            <asp:LinkButton ID="lnkBtnCancel" runat="server" CssClass="button cancelbutton"
                Text='<%$ Resources: _Kartris, FormButton_Cancel %>' />
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
