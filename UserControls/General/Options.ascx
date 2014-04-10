<%@ Control Language="VB" AutoEventWireup="false" CodeFile="Options.ascx.vb" Inherits="Options" %>
<asp:UpdatePanel ID="updOptions" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <div class="boxinset">
            <div class="option">
                <div class="row">
                    <div class="small-12 large-4 columns">
                        <label class="optiontitle">
                            <asp:Label ID="lblOptionGroupName" runat="server"></asp:Label>
                            <asp:PlaceHolder ID="phdOptionGroupDescription" runat="server" Visible="false">
                                <span class="optiondesc">
                                    <asp:Literal ID="litOptionDescription" runat="server"></asp:Literal>
                                </span>
                            </asp:PlaceHolder>
                    
                        </label>
                    </div>
                    <div class="small-12 large-8 columns">
                        <asp:UpdatePanel ID="updOption" runat="server">
                            <ContentTemplate>
                                <asp:PlaceHolder ID="phdOption" runat="server"></asp:PlaceHolder>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                </div>
            </div>
            <asp:Label ID="lblCurrencyID" runat="server" Visible="False"></asp:Label>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
