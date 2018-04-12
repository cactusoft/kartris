<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_AdminExecuteQuery.ascx.vb"
    Inherits="UserControls_Back_AdminExecuteQuery" %>
<div id="section_executequery">
    <asp:UpdatePanel ID="updExecuteQuery" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:MultiView ID="mvwQuery" runat="server" ActiveViewIndex="0">
                <asp:View ID="viwExecuteQuery" runat="server">
                    <h2>
                        <asp:Literal ID="litContentTextLogQuery" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_LogQuery %>" />
                        <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9805')">?</a>
                    </h2>
                    <p>
                        <asp:Literal ID="litContentTextExecuteQueryText" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_ExecuteQueryText %>" />
                    </p>
                    <div>
                        <asp:TextBox ID="txtSqlQuery" runat="server" TextMode="MultiLine" /></div>
                    <div>
                        <asp:Button ID="btnExecuteQuery" runat="server" Text="<%$ Resources: _DBAdmin, FormButton_ExecuteQuery %>"
                            CssClass="button" />
                    </div>
                </asp:View>
                <asp:View ID="viwQuerySucceeded" runat="server">
                    <asp:LinkButton ID="lnkBtnBackSucceeded" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>'
                        CssClass="linkbutton icon_back floatright" />
                    <h2>
                        <asp:Literal ID="litContentTextQueryExecuted" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_LogQuery %>" /></h2>

                    <pre><asp:Literal ID="litQueryExecutedSucceeded" runat="server" /></pre>
                    <br />
                    <asp:MultiView ID="mvwQueryType" runat="server" ActiveViewIndex="0">
                        <asp:View ID="viwNonProcedure" runat="server">
                            <p>
                                <asp:Literal ID="litContentTextRecordsAffected" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_RecordsAffected %>" />
                                <asp:Literal ID="litRecordsAffected" runat="server" /></p>
                            <p>
                                <asp:Literal ID="litContentTextRecordsReturned" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_RecordsReturned %>" />
                                <asp:Literal ID="litRecordsReturned" runat="server" /></p>
                        </asp:View>
                        <asp:View ID="viwProcedure" runat="server">
                            <asp:Literal ID="litCommandCompleted" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_CommandCompleted %>" />
                        </asp:View>
                    </asp:MultiView>
                    <br />
                    <br />
                    <asp:MultiView ID="mvwResult" runat="server">
                        <asp:View ID="viwResultData" runat="server">
                            <asp:Panel ID="pnlResult" runat="server" ScrollBars="Auto">
                                <asp:GridView ID="gvwReturnedRecords" runat="server" AutoGenerateColumns="true">
                                </asp:GridView>
                            </asp:Panel>
                        </asp:View>
                        <asp:View ID="viwNoResults" runat="server">
                            <asp:Panel ID="pnlNoItems" runat="server" CssClass="noresults">
                                <asp:Literal ID="litNoItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>">
                                </asp:Literal>
                            </asp:Panel>
                        </asp:View>
                    </asp:MultiView>
                </asp:View>
                <asp:View ID="viwQueryFailed" runat="server">
                    <asp:LinkButton ID="lnkBtnBackFailed" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>'
                        CssClass="linkbutton icon_back floatright" /><h2>
                            <asp:Literal ID="litContentTextLogQuery2" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_LogQuery %>" /></h2>

                    <pre><asp:Literal ID="litQueryExecutedFailed" runat="server" /></pre>
                    <br />
                    <asp:Literal ID="litContentText_QueryFailed" runat="server" Text="<%$ Resources: _DBAdmin, ContentText_QueryFailed %>" />
                    <div class="errormessage">
                        <asp:Literal ID="litQueryFailedError" runat="server" />
                    </div>
                </asp:View>
            </asp:MultiView>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
