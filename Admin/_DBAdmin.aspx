<%@ Page Language="VB" AutoEventWireup="false" CodeFile="_DBAdmin.aspx.vb" Inherits="Admin_DBAdmin"
    MasterPageFile="~/Skins/Admin/Template.master" %>

<%@ Register TagPrefix="_user" TagName="AdminDataRemoval" Src="~/UserControls/Back/_AdminDataRemoval.ascx" %>
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


                        </div>
                    </ContentTemplate>
                </ajaxToolkit:TabPanel>
                <%-- DB Admin Data Removal --%>
                <ajaxToolkit:TabPanel ID="tabDBRemoval" runat="server" HeaderText="<%$ Resources: _DBAdmin, ContentText_ClearData %>">
                    <ContentTemplate>
                        <div class="subtabsection">
                            <_user:AdminDataRemoval ID="_UC_AdminDataRemoval" runat="server" />
                        </div>
                        
                            <asp:UpdatePanel ID="updDeletedItems" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:PlaceHolder ID="phdDeletedItems" runat="server" Visible="false"><hr />
                                        <p>
                                            <asp:Literal ID="litContentTextDeletedItemsText" runat="server"
                                                Text='<%$ Resources: _DBAdmin, ContentText_DeletedItemsText %>' /><br />
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
