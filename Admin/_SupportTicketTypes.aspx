<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Admin/Template.master" AutoEventWireup="false" CodeFile="_SupportTicketTypes.aspx.vb" Inherits="Admin_SupportTicketTypes" %>

<asp:Content ID="Content1" ContentPlaceHolderID="phdHead" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="phdMain" Runat="Server">
<div id="page_supporttickets">
        <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <h1>
                    <asp:Literal ID="litPageTitleSupportTickets" runat="server" Text="<%$ Resources: _Tickets, PageTitle_SupportTicketTypes %>" /></h1>
                    <asp:PlaceHolder ID="phdFeatureDisabled" runat="server" Visible="false">
            <div class="warnmessage">
                <asp:Literal ID="litFeatureDisabled" runat="server" />
                <asp:HyperLink ID="lnkEnableFeature" runat="server" Text="<%$ Resources: _Kartris, ContentText_ConfigChange2 %>"
                    NavigateUrl="~/Admin/_Config.aspx?name=frontend.supporttickets.enabled" CssClass="linkbutton icon_edit" />
            </div>
        </asp:PlaceHolder>
                <asp:MultiView ID="mvwTypes" runat="server" ActiveViewIndex="0">
                    <asp:View ID="viwTypes" runat="server">
                        <asp:UpdatePanel ID="updTypes" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:LinkButton ID="lnkBtnNewType" runat="server" Text='<%$ Resources: _Kartris, FormButton_New %>'
                                CssClass="linkbutton icon_new floatright" />
                                <asp:GridView CssClass="kartristable" ID="gvwTicketTypes" runat="server" AllowPaging="True"
                                    AutoGenerateColumns="False" DataKeyNames="STT_ID" AutoGenerateEditButton="False"
                                    GridLines="None" PagerSettings-PageButtonCount="10" PageSize="15">
                                    <Columns>
                                        <asp:BoundField DataField="STT_Name" HeaderText="<%$ Resources: _Kartris, ContentText_Type %>" ItemStyle-CssClass="itemname">
                                            <HeaderStyle />
                                        </asp:BoundField>
                                        <asp:TemplateField>
                                            <HeaderTemplate>
                                                <asp:Literal ID="litContentTextSupportLevel" runat="server" Text="<%$ Resources: _Tickets, ContentText_SupportLevel %>" />
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <asp:Literal ID="litSupportLevel" runat="server" Text='<%# Eval("STT_Level") %>' Visible="false"  />
                                                <asp:Literal ID="litStandardSupport" runat="server" Text="<%$ Resources: _Tickets, ContentText_StandardSupport %>" Visible='<%# Eval("STT_Level") = "s" %>' />
                                                <asp:Literal ID="litPremiumSupport" runat="server" Text="<%$ Resources: _Tickets, ContentText_PremiumSupport %>" Visible='<%# Eval("STT_Level") = "p" %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField ItemStyle-CssClass="selectfield">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="selectbutton" runat="server" CommandName="edit_type" CommandArgument='<%# Eval("STT_ID") %>'
                                                    CssClass="linkbutton icon_edit" Text='<%$ Resources: _Kartris, FormButton_Edit %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <div class="noresults">
                                            <asp:Literal ID="litNoTypes" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" /></div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                                <asp:Panel ID="pnlNoTypes" runat="server" CssClass="noresults" Visible="false">
                                    <asp:Literal ID="litNoTypes" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" /></asp:Panel>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </asp:View>
                    <asp:View ID="viwEditType" runat="server">
                        <asp:UpdatePanel ID="updBack" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:LinkButton ID="lnkBtnShowTypesList" runat="server" CssClass="linkbutton icon_back floatright"
                                    Text='<%$ Resources: _Kartris, ContentText_BackLink %>' />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                        <div class="spacer">
                        </div>
                        <asp:UpdatePanel ID="updTypeDetails" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:Literal ID="litTypeID" runat="server" Visible="false" />
                                <div class="Kartris-DetailsView">
                                    <div class="Kartris-DetailsView-Data">
                                        <ul>
                                            <!-- Ticket Subject -->
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Literal ID="litEditSupportType" runat="server" Text="<%$ Resources:_Tickets, ContentText_SupportType %>" />
                                            </span><span class="Kartris-DetailsView-Value">
                                                <asp:Literal ID="litSupportType" runat="server" Visible="false" />
                                                <asp:TextBox ID="txtSupportType" runat="server" MaxLength="50"></asp:TextBox>
                                                <asp:RequiredFieldValidator EnableClientScript="True" ID="valType" runat="server"
                                                    ControlToValidate="txtSupportType" ValidationGroup="TypeForm" CssClass="error"
                                                    ForeColor="" Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>" />
                                            </span></li>
                                            <!-- Assigned To -->
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Literal ID="litEditSupportLevel" runat="server" Text="<%$ Resources:_Tickets, ContentText_SupportLevel %>" />
                                            </span><span class="Kartris-DetailsView-Value">
                                                <asp:DropDownList ID="ddlSupportLevel" runat="server">
                                                    <asp:ListItem Text="<%$ Resources: _Kartris, ContentText_DropDownSelect %>" Value="0"></asp:ListItem>
                                                    <asp:ListItem Text="<%$ Resources: _Tickets, ContentText_PremiumSupport %>" Value="p"></asp:ListItem>
                                                    <asp:ListItem Text="<%$ Resources: _Tickets, ContentText_StandardSupport %>" Value="s"></asp:ListItem>
                                                </asp:DropDownList>
                                                <asp:CompareValidator ID="valCompareSupportLevel" runat="server" CssClass="error"
                                                    ForeColor="" ErrorMessage="<%$ Resources: _Kartris, ContentText_RequiredField %>"
                                                    ControlToValidate="ddlSupportLevel" Operator="NotEqual" ValueToCompare="0" Display="Dynamic"
                                                    SetFocusOnError="true" ValidationGroup="TypeForm" />
                                            </span></li>
                                        </ul>
                                    </div>
                                </div>
                                <!-- Save Button  -->
                                <div class="submitbuttons topsubmitbuttons">
                                    <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <asp:LinkButton ID="btnSave" runat="server" CssClass="savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                                ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' ValidationGroup="TypeForm" />
                                            <asp:LinkButton ID="btnCancel" runat="server" CssClass="cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                                ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                                            <asp:PlaceHolder ID="phdDelete" runat="server" Visible="false"><span class="floatright">
                                                <span class="reassign">
                                                    <asp:Literal ID="litContentTextMoveTicketsMessage" runat="server" Text="<%$ Resources: _Tickets, ContentText_MoveTicketsMessage %>" />
                                                    <asp:DropDownList ID="ddlTicketType" runat="server" CssClass="midtext">
                                                    </asp:DropDownList>
                                                </span>
                                                <asp:LinkButton ID="lnkBtnDelete" CssClass="deletebutton" runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>' /></span>
                                            </asp:PlaceHolder>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </asp:View>
                </asp:MultiView>
                <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
            </ContentTemplate>
        </asp:UpdatePanel>
        <asp:UpdateProgress ID="prgTypes" runat="server" AssociatedUpdatePanelID="updTypes">
            <ProgressTemplate>
                <div class="loadingimage">
                </div>
                <div class="updateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
        <asp:UpdateProgress ID="upgBack" runat="server" AssociatedUpdatePanelID="updBack">
            <ProgressTemplate>
                <div class="loadingimage">
                </div>
                <div class="updateprogress">
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
    </div>
</asp:Content>

