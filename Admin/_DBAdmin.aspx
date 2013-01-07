<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_dbadmin.aspx.vb" Inherits="Admin_DBAdmin"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<%@ Register TagPrefix="_user" TagName="AdminDataRemoval" Src="~/UserControls/Back/_AdminDataRemoval.ascx" %>
<%@ Register TagPrefix="_user" TagName="AdminLog" Src="~/UserControls/Back/_AdminLog.ascx" %>
<%@ Register TagPrefix="_user" TagName="AdminErrorLogs" Src="~/UserControls/Back/_AdminErrorLogs.ascx" %>
<%@ Register TagPrefix="_user" TagName="AdminExecuteQuery" Src="~/UserControls/Back/_AdminExecuteQuery.ascx" %>
<%@ Register TagPrefix="_user" TagName="AdminExportData" Src="~/UserControls/Back/_AdminExportData.ascx" %>
<%@ Register TagPrefix="_user" TagName="AdminDBTools" Src="~/UserControls/Back/_AdminDBTools.ascx" %>
<%@ Register TagPrefix="_user" TagName="AdminFTS" Src="~/UserControls/Back/_AdminFTS.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <h1>
        <asp:Literal ID="litBackMenuProducts" runat="server" Text="<%$ Resources: _Kartris, BackMenu_DBAdmin %>" /></h1>
    <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <ajaxToolkit:TabContainer ID="tabDBAdmin" runat="server" EnableTheming="False" CssClass=".tab"
                AutoPostBack="false">
                <%-- DB Admin Main Tab --%>
                <ajaxToolkit:TabPanel ID="tabMain" runat="server" HeaderText="<%$ Resources: _Kartris, BackMenu_Home %>">
                    <ContentTemplate>
                        <div class="subtabsection">
                            <div class="errormessage">
                                <asp:Literal ID="litContentTextDataBaseAdminWarning" runat="server" Text='<%$ Resources: _Kartris, ContentText_DataBaseAdminWarning %>' />
                            </div>
<%--                            <p>
                                <asp:LinkButton ID="btnRefresh" runat="server" Text='<%$ Resources: _Kartris, ContentText_RefreshKartrisCaches %>'
                                    CssClass="linkbutton icon_edit refreshbutton" />
                            </p>--%>
                            <p>
                                <asp:LinkButton ID="btnRestart" runat="server" Text='<%$ Resources: _Kartris, ContentText_RestartKartris %>'
                                    CssClass="linkbutton icon_edit refreshbutton" />
                            </p>
                            <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
                            <asp:UpdatePanel ID="updDeletedItems" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:PlaceHolder ID="phdDeletedItems" runat="server" Visible="false">
                                        <p>
                                            <asp:Literal ID="litContentTextDeletedItemsText" runat="server" Text='<%$ Resources: _DBAdmin, ContentText_DeletedItemsText %>' />
                                            <asp:LinkButton ID="lnkBtnDeleteFiles" runat="server" Text='<%$ Resources: _Kartris, ContentText_DeleteAll %>'
                                                CssClass="linkbutton icon_delete" CausesValidation="false" />
                                        </p>
                                    </asp:PlaceHolder>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                            <asp:UpdateProgress ID="prgDeletedItems" runat="server" AssociatedUpdatePanelID="updDeletedItems">
                                <ProgressTemplate>
                                    <div class="loadingimage">
                                    </div>
                                    <div class="updateprogress">
                                    </div>
                                </ProgressTemplate>
                            </asp:UpdateProgress>
                        </div>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <%-- DB Admin Log Tab --%>
                <ajaxToolkit:TabPanel ID="tabAdminLog" runat="server" HeaderText="<%$ Resources: _DBAdmin, ContentText_AdminLogs %>">
                    <ContentTemplate>
                        <div class="subtabsection">
                            <_user:AdminLog ID="_UC_AdminLog" runat="server" />
                        </div>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <%-- DB Admin Error Logs --%>
                <ajaxToolkit:TabPanel ID="tabErrorLogs" runat="server" HeaderText="<%$ Resources: _DBAdmin, ContentText_ErrorLogs %>" >
                    <ContentTemplate>
                        <_user:AdminErrorLogs ID="_UC_AdminErrorLogs" runat="server" />
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <%-- DB Admin Data Removal --%>
                <ajaxToolkit:TabPanel ID="tabDBRemoval" runat="server" HeaderText="<%$ Resources: _DBAdmin, ContentText_ClearData %>">
                    <ContentTemplate>
                        <div class="subtabsection">
                            <_user:AdminDataRemoval ID="_UC_AdminDataRemoval" runat="server" />
                        </div>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <%-- DB Admin Execute Query --%>
                <ajaxToolkit:TabPanel ID="tabExecuteQuery" runat="server" HeaderText="<%$ Resources: _DBAdmin, ContentText_ExecuteQuery %>">
                    <ContentTemplate>
                        <div class="subtabsection">
                            <_user:AdminExecuteQuery ID="_UC_AdminExecuteQuery" runat="server" />
                        </div>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <%-- DB Admin Export Data --%>
                <ajaxToolkit:TabPanel ID="tabExportData" runat="server" HeaderText="<%$ Resources: _Export, ContentText_DataExport %>">
                    <ContentTemplate>
                        <div class="subtabsection">
                            <_user:AdminExportData ID="_UC_AdminExportData" runat="server" />
                        </div>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <%-- DB Admin Tools --%>
                <ajaxToolkit:TabPanel ID="tabDBTools" runat="server" HeaderText="<%$ Resources: _DBAdmin, ContentText_DBTools %>">
                    <ContentTemplate>
                        <div class="subtabsection">
                            <_user:AdminDBTools ID="_UC_AdminDBTools" runat="server" />
                        </div>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <%-- FTS --%>
                <ajaxToolkit:TabPanel ID="tabFTS" runat="server" HeaderText="FTS">
                    <ContentTemplate>
                        <div class="subtabsection">
                            <_user:AdminFTS ID="_UC_AdminFTS" runat="server" />
                        </div>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
            </ajaxToolkit:TabContainer>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
