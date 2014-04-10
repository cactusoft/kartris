<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_CategoryFilters.ascx.vb" Inherits="UserControls_Back_CategoryFilters" %>

<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <div class="subtabsection">
            <asp:TextBox ID="txtXML" runat="server" TextMode="MultiLine" Height="200">
            </asp:TextBox>&nbsp;<asp:ImageButton ID="btnGenerate"
                runat="server" ImageUrl="~/Skins/Admin/Images/button_refresh.png"
                Visible="True" Height="32px" Width="32px" CssClass="hoverbutton"
                ToolTip="<%$ Resources: _Kartris, ContentText_Generate %>"
                AlternateText="<%$ Resources: _Kartris, ContentText_Generate %>" />
        </div>
        <%-- Save Button  --%>
        <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
            <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:LinkButton ID="lnkBtnSave" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                        ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
        <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgSaveChanges" runat="server" AssociatedUpdatePanelID="updMain">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
