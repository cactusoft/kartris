<%@ Control Language="VB" AutoEventWireup="false" EnableViewState="true" CodeFile="LanguageDropdown.ascx.vb"
    Inherits="UserControls_Skin_LanguageDropdown" %>
<div id="languagemenu">
    <div class="box info">
        <div class="pad">
            <asp:DropDownList ID="selLanguage" DataSourceID="srcLanguage" AutoPostBack="true"
                runat="server" DataTextField="Name" DataValueField="Culture" />
            <asp:PlaceHolder ID="phdLanguageImages" runat="server">
                <div class="flagimages">
                    <asp:Repeater ID="rptLanguages" runat="server" DataSourceID="srcLanguage">
                        <ItemTemplate>
                            <span>
                                <asp:LinkButton ID="lnkImage" runat="server" CommandArgument='<%# Eval("Culture") %>'
                                    CommandName="ChangeLanguage" ToolTip='<%# Eval("Name") %>' CausesValidation="false">
                                    <asp:Image ID="imgLanguage" runat="server" AlternateText='<%# Eval("Name") %>' /></asp:LinkButton></span></ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:PlaceHolder>
        </div>
    </div>
</div>
<asp:ObjectDataSource ID="srcLanguage" TypeName="KartrisClasses+Language" SelectMethod="LoadLanguages"
    runat="server" />
