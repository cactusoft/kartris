<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_PromotionStringBuilder.ascx.vb"
    Inherits="UserControls_Back_PromotionStringBuilder" %>
<%@ Register TagPrefix="_user" TagName="UC_AutoComplete" Src="~/UserControls/Back/_AutoCompleteInput.ascx" %>

<div class="promotion_part">
    <h2>
        <asp:Literal ID="litContentTextPromotionPart" runat="server" Text='<%$ Resources: _Promotion, ContentText_PromotionPart %>'
            EnableViewState="False" />
        <asp:Literal ID="litPartLetter" runat="server" EnableViewState="False" /></h2>
        
    <asp:UpdatePanel ID="updPromotionStrings" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:DropDownList ID="ddlPromotionString" runat="server" AutoPostBack="true" AppendDataBoundItems="true">
                <asp:ListItem Text='<%$ Resources: _Kartris, ContentText_DropDownSelect %>' Value="0" />
            </asp:DropDownList>
        </ContentTemplate>
    </asp:UpdatePanel>
    <asp:UpdatePanel ID="updPromotionForm" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div class="stringbuilder">
                <asp:PlaceHolder ID="phdForm" runat="server" Visible="true"></asp:PlaceHolder>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    <asp:UpdatePanel ID="updButtons" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:PlaceHolder ID="phdButtons" runat="server" Visible="false">
                <asp:LinkButton ID="lnkAdd" runat="server" Text='<%$ Resources: _Kartris, FormButton_Add %>'
                    CssClass="linkbutton icon_new" Visible="true" ValidationGroup="updatestring" />
                <asp:LinkButton ID="lnkOk" runat="server" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                    CssClass="linkbutton icon_edit" Visible="false" ValidationGroup="updatestring" />
                <asp:LinkButton ID="lnkRemove" runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>'
                    CssClass="linkbutton icon_delete" Visible="false" />
                <asp:LinkButton ID="lnkCancel" runat="server" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                    CssClass="linkbutton icon_back" Visible="false" />
            </asp:PlaceHolder>
        </ContentTemplate>
    </asp:UpdatePanel>
    <br />
    <asp:UpdatePanel ID="updStringList" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:PlaceHolder ID="phdStringLinks" runat="server"></asp:PlaceHolder>
            <br />
            <asp:PlaceHolder ID="phdList" runat="server" Visible="false">
                <asp:ListBox ID="lbxStrings" runat="server"></asp:ListBox>
                <asp:ListBox ID="lbxStringID" runat="server"></asp:ListBox>
                <asp:ListBox ID="lbxStringValue" runat="server"></asp:ListBox>
                <asp:ListBox ID="lbxStringItem" runat="server"></asp:ListBox>
            </asp:PlaceHolder>
            <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
        </ContentTemplate>
    </asp:UpdatePanel>

</div>
