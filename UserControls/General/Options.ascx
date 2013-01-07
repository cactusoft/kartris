<%@ Control Language="VB" AutoEventWireup="false" CodeFile="Options.ascx.vb" Inherits="Options" %>
<asp:UpdatePanel ID="updOptions" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <div class="boxinset">
            <div class="option">
                <label class="optiontitle">
                    <asp:Label ID="lblOptionGroupName" runat="server"></asp:Label>
                    <asp:PlaceHolder ID="phdOptionGroupDescription" runat="server" Visible="false">
                        <%--Need a span rather than div for the description, beacuse its inside an HTML <label></label> tags--%>
                        <span class="optiondesc">
                            <asp:Literal ID="litOptionDescription" runat="server"></asp:Literal>
                        </span>
                    </asp:PlaceHolder>
                </label>
                <div>
                    <asp:UpdatePanel ID="updOption" runat="server">
                        <ContentTemplate>
                            <asp:PlaceHolder ID="phdOption" runat="server"></asp:PlaceHolder>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>
            <asp:Label ID="lblCurrencyID" runat="server" Visible="False"></asp:Label>
            
        </div>
    </ContentTemplate>
</asp:UpdatePanel>
