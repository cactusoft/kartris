<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_promotions.aspx.vb" Inherits="Admin_Promotions"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <div id="page_promotions">
        <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <h1>
                    <asp:Literal ID="litPageTitle" runat="server" Text='<%$ Resources:_Promotions, PageTitle_Promotions %>'
                        EnableViewState="False"></asp:Literal></h1>
                <asp:UpdatePanel ID="updViewPromotion" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:PlaceHolder ID="phdFeatureDisabled" runat="server" Visible="false">
                            <div class="warnmessage">
                                <asp:Literal ID="litFeatureDisabled" runat="server" />
                                <asp:HyperLink ID="lnkEnableFeature" runat="server" Text="<%$ Resources: _Kartris, ContentText_ConfigChange2 %>"
                                    NavigateUrl="~/Admin/_Config.aspx?name=frontend.promotions.enabled" CssClass="linkbutton icon_edit" />
                            </div>
                        </asp:PlaceHolder>
                        <asp:PlaceHolder ID="phdViewPromotions" runat="server" Visible="true"><span class="floatright">
                            <asp:LinkButton ID="lnkBtnNewPromotion" runat="server" Text='<%$ Resources: _Kartris, FormButton_New %>'
                                CssClass="linkbutton icon_new" /></span><br />
                            <asp:MultiView ID="mvwPromotions" runat="server" ActiveViewIndex="0">
                                <asp:View ID="viwPromotionList" runat="server">
                                    <asp:PlaceHolder ID="phdPromotionsSearch" runat="server" Visible="false">
                                        <div id="searchboxrow">
                                            <asp:Panel ID="pnlFind" runat="server" DefaultButton="btnFind">
                                                <asp:TextBox runat="server" ID="txtSearchStarting" MaxLength="20" />
                                                <asp:LinkButton ID="btnFind" runat="server" Text="<%$ Resources:_Kartris, FormButton_Search %>"
                                                    CssClass="linkbutton" />
                                                <asp:LinkButton ID="btnClear" runat="server" CssClass="linkbutton cancelbutton" Text='<%$ Resources:_Kartris, ContentText_Clear %>' />
                                                <asp:CheckBox ID="chkLiveOnly" runat="server" Text="Active Only" Checked="true" CssClass="checkbox" />
                                            </asp:Panel>
                                        </div>
                                    </asp:PlaceHolder>
                                    <asp:UpdatePanel ID="updPromotionsList" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <asp:GridView ID="gvwPromotions" CssClass="kartristable" runat="server" AllowPaging="True"
                                                AllowSorting="true" AutoGenerateColumns="False" DataKeyNames="PROM_ID" AutoGenerateEditButton="False"
                                                GridLines="None" PagerSettings-PageButtonCount="10" PageSize="10" SelectedIndex="0">
                                                <Columns>
                                                    <asp:TemplateField Visible="true" HeaderText='<%$ Resources: _Kartris, ContentText_ID %>'
                                                        ItemStyle-CssClass="column0">
                                                        <ItemTemplate>
                                                            <asp:Literal ID="litPromotionID" runat="server" Visible="true" Text='<%# Eval("PROM_ID") %>'
                                                                EnableViewState="False" />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField Visible="false">
                                                        <ItemTemplate>
                                                            <asp:Image ID="imgPromotion" runat="server" Width="45px" Height="45px" />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField ItemStyle-CssClass="column1">
                                                        <HeaderTemplate>
                                                            <asp:Literal ID="litFormLabelPromotionStartDate" runat="server" Text='<%$ Resources: _Promotions, FormLabel_PromotionStartDate %>'
                                                                EnableViewState="False" />
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <asp:Literal ID="litPROM_Start" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("PROM_Start"), "t",  Session("_LANG")) %>'></asp:Literal>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField ItemStyle-CssClass="column2">
                                                        <HeaderTemplate>
                                                            <asp:Literal ID="litFormLabelPromotionEndDate" runat="server" Text='<%$ Resources: _Promotions, FormLabel_PromotionEndDate %>'
                                                                EnableViewState="False" />
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <asp:Literal ID="litPROM_End" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("PROM_End"), "t",  Session("_LANG")) %>'></asp:Literal>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField ItemStyle-CssClass="column3">
                                                        <HeaderTemplate>
                                                            <asp:Literal ID="litFormLabelPromotionText" runat="server" Text='<%$ Resources: _Promotions, FormLabel_PromotionText %>'
                                                                EnableViewState="False" />
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <asp:Literal ID="litPromotionText" runat="server" Text='<%# Eval("PROM_Text") %>'
                                                                EnableViewState="False"></asp:Literal>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField ItemStyle-CssClass="column4">
                                                        <HeaderTemplate>
                                                            <asp:Literal ID="litFormLabelLive" runat="server" Text='<%$ Resources: _Kartris, FormLabel_Live %>'
                                                                EnableViewState="False" />
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <asp:CheckBox ID="chkPROM_Live" runat="server" Checked='<%# Eval("PROM_Live") %>'
                                                                CssClass="checkbox" Enabled="false" />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField ItemStyle-CssClass="selectfield">
                                                        <HeaderTemplate>
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <asp:LinkButton ID="lnkBtnEditVersion" runat="server" CommandName="EditPromotion"
                                                                CommandArgument='<%# Container.DataItemIndex %>' Text='<%$ Resources: _Kartris, FormButton_Edit %>'
                                                                CssClass="linkbutton icon_edit" />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </asp:View>
                                <asp:View ID="viwNoItems" runat="server">
                                    <asp:Panel ID="pnlNoItems" runat="server" CssClass="noresults">
                                        <asp:Literal ID="litNoItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                                        </asp:Literal>
                                    </asp:Panel>
                                </asp:View>
                            </asp:MultiView>
                        </asp:PlaceHolder>
                    </ContentTemplate>
                </asp:UpdatePanel>
                <asp:UpdatePanel ID="updEditPromotion" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:PlaceHolder ID="phdEditPromotion" runat="server" Visible="false">
                            <asp:LinkButton ID="lnkBtnBack" runat="server" Text='<%$ Resources: _Kartris, FormButton_Back %>'
                                CssClass="linkbutton icon_back floatright" />
                            <asp:Literal ID="litPromotionID" runat="server" Visible="false" />
                            <_user:EditPromotion ID="_UC_EditPromotion" runat="server" />
                            <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                                <asp:UpdatePanel ID="updConfirmation" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:LinkButton ID="lnkBtnSave" runat="server" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                            ToolTip="<%$ Resources: _Kartris, FormButton_Save %>" CssClass="button savebutton"
                                            ValidationGroup="EditPromotion" />
                                        <asp:LinkButton ID="lnkBtnCancel" runat="server" CssClass="button cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                            ToolTip="<%$ Resources: _Kartris, FormButton_Cancel %>" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                            <br />
                            <br />
                            <br />
                            <br />
                            <div class="line">
                            </div>
                        </asp:PlaceHolder>
                    </ContentTemplate>
                </asp:UpdatePanel>
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
    </div>
</asp:Content>
