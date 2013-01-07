<%@ Control Language="VB" AutoEventWireup="false" CodeFile="SampleCustomControl.ascx.vb"
    Inherits="SampleCustomControl" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <!-- Width Parameter -->
        <asp:Literal EnableViewState="false" ID="litWidth" runat="server" Text="Width" />
        <asp:DropDownList runat="server" ID="ddlWidth" AutoPostBack="true" >
            <asp:ListItem Text="1" />
            <asp:ListItem Text="2" />
            <asp:ListItem Text="3" />
        </asp:DropDownList>

        <!-- Length Parameter -->
        <asp:Literal EnableViewState="false" ID="litLength" runat="server" Text="Length" />
        <asp:DropDownList runat="server" ID="ddlLength" AutoPostBack="true" >
            <asp:ListItem Text="1" />
            <asp:ListItem Text="2" />
            <asp:ListItem Text="3" />
        </asp:DropDownList>

        <!-- Price Line -->
        <div class="boxinset line">
            <div class="addtobasket">
                <div class="prices">
                    <span class="price">
                        <asp:Literal EnableViewState="false" ID="lblCustomPrice" Visible ="false" runat="server" Text="<%$ Resources: Kartris, ContentText_Price %>" />
                        <span class="figure">
                            <asp:Literal ID="litCustomPrice" runat="server" Visible="false" EnableViewState="false" />
                        </span>
                    </span>
                </div>
            </div>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
