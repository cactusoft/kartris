<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_AdminErrorLogs.ascx.vb"
    Inherits="UserControls_Back_AdminErrorLogs" %>
<div id="section_errorlogs">
    <asp:UpdatePanel ID="updAdminLog" runat="server">
        <ContentTemplate>
            <ajaxToolkit:TabContainer ID="tabAdminErrorLog" runat="server" EnableTheming="False"
                CssClass=".tab" AutoPostBack="false">
                <ajaxToolkit:TabPanel ID="tabAdminErrorMessages" runat="server">
                    <HeaderTemplate>
                        <asp:Literal ID="litContentTextErrorLogMessages" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_ErrorLogMessages %>" />
                    </HeaderTemplate>
                    <ContentTemplate>
                        <div class="subtabsection">
                            <div class="searchboxrow">
                                <asp:PlaceHolder ID="phdError" runat="server" Visible="False">
                                    <div class="errormessage">
                                        <asp:Literal ID="litError" runat="server" />
                                    </div>
                                </asp:PlaceHolder>
                                <asp:Panel ID="pnlFind" runat="server" DefaultButton="btnSubmit">
                                    <asp:LinkButton ID="lnkBtnDeleteAllErrorLogs" runat="server" Text='<%$ Resources:_DBAdmin, ContentText_DeleteErrorLogs %>'
                                        CssClass="linkbutton icon_delete floatright" />
                                    <asp:DropDownList ID="ddlMonthYear" runat="server" CssClass="midtext">
                                    <asp:ListItem Text="&quot;&quot;&quot;&quot;" Value="&quot;&quot;&quot;&quot;" />
                                    </asp:DropDownList>
                                    <asp:Button ID="btnSubmit" runat="server" Text="<%$ Resources:_Kartris, FormButton_Submit %>"
                                        CssClass="button" />
                                </asp:Panel>
                            </div>
                            <div id="boxes">
                                <asp:ListBox ID="lbxFiles" runat="server" CssClass="leftlist" 
                                    AutoPostBack="True" />
                                <asp:TextBox ID="txtFileText" runat="server" ReadOnly="True" TextMode="MultiLine"
                                    CssClass="rightlist" />&nbsp;<asp:ImageButton ID="btnRefresh" 
                                    runat="server" ImageUrl="~/Skins/Admin/Images/button_refresh.png" 
                                    Visible="False" Height="32px" Width="32px" CssClass="hoverbutton" />
                            </div>

                            <div class="spacer">
                            </div>
                        </div>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <ajaxToolkit:TabPanel ID="tabAdminErrorSettings" runat="server">
                    <HeaderTemplate>
                        <asp:Literal ID="litContentTextErrorLogSettings" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_ErrorLogSettings %>" />
                    </HeaderTemplate>
                    <ContentTemplate>
                        <div class="subtabsection">
                            <div>
                                <asp:Literal ID="litContentTextErrorLogPath" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_ErrorLogPath %>" />
                                <strong>
                                    <asp:Literal ID="litErrorLogPath" runat="server" /></strong>
                                    <asp:Literal ID="litWebConfig" runat="server" Text=" -> web.config" />
                            </div>
                            <div>
                                <asp:Literal ID="litContentTextErrorLogStatus" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_ErrorLogStatus %>" />
                                <strong>
                                    <asp:Literal ID="litErrorLogStatus" runat="server" /></strong>
                                <asp:LinkButton ID="lnkChangeButton" runat="server" Text="<%$ Resources: _Kartris, FormButton_Change %>"
                                    PostBackUrl="~/Admin/_Config.aspx?name=general.errorlogs.enabled" CssClass="linkbutton icon_edit" />
                            </div>
                        </div>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
            </ajaxToolkit:TabContainer>
            <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
<asp:UpdateProgress ID="prgAdminLog" runat="server" AssociatedUpdatePanelID="updAdminLog">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
