<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_SubSitesList.ascx.vb"
    Inherits="UserControls_Back_SubSiteList" %>
<%@ Register TagPrefix="_user" TagName="ItemPager" Src="~/UserControls/Back/_ItemPagerAjax.ascx" %>
<%@ Register TagPrefix="_user" TagName="DispatchLabels" Src="~/UserControls/Back/_DispatchLabels.ascx" %>
<div>
<%--    <div>
        <asp:PlaceHolder ID="phdPrintAllItems" Visible="true" runat="server">
            <div class="submitbuttons topsubmitbuttons">
                <asp:LinkButton ID="btnGetAllOrderInvoices" runat="server" Text="<%$Resources: _Orders, ContentText_PrintInvoices %>" CssClass="button printbutton" />
            </div>
        </asp:PlaceHolder>
        <_user:DispatchLabels ID="DispatchLabels" runat="server" Visible="false" />
    </div>--%>

    <div class="floatright">
        <asp:LinkButton ID="lnkNewLogin" PostBackUrl="~/Admin/_ModifySubSiteStatus.aspx"
            Text="<%$ Resources: _Kartris, FormButton_New %>" CssClass="linkbutton icon_new"
            runat="server" />
    </div>
    <asp:GridView CssClass="kartristable" ID="gvwSubSites" runat="server" AutoGenerateColumns="False"
        DataKeyNames="SUB_ID" GridLines="None" EnableViewState="true">
        <Columns>
            <asp:BoundField DataField="SUB_ID" HeaderText='<%$ Resources:_Kartris, ContentText_ID%>'
                ItemStyle-CssClass="idfield"></asp:BoundField>
            <asp:TemplateField ItemStyle-CssClass="" HeaderText='Name'>
                <ItemTemplate>
                    <asp:Literal ID="litNameValue" runat="server" Text='<%#Eval("SUB_Name") %>'> </asp:Literal>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-CssClass="" HeaderText='Domain'>
                <ItemTemplate>
                    <asp:Literal ID="litDomainValue" runat="server" Text='<%#Eval("SUB_Domain") %>'> </asp:Literal>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-CssClass="" HeaderText='Base Category'>
                <ItemTemplate>
                    <asp:Literal ID="litBaseCatIdValue" runat="server" Text='<%#Eval("CAT_Name") %>'> </asp:Literal>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-CssClass="" HeaderText='Skin'>
                <ItemTemplate>
                    <asp:Literal ID="litSkinValue" runat="server" Text='<%#Eval("SUB_Skin") %>'> </asp:Literal>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-CssClass="" HeaderText='Notes'>
                <ItemTemplate>
                    <asp:Literal ID="litNotesValue" runat="server" Text='<%#Eval("SUB_Notes") %>'> </asp:Literal>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-CssClass="" HeaderText='Live'>
                <ItemTemplate>
                    <asp:Literal ID="litLiveValue" runat="server" Text='<%#Eval("SUB_Live") %>'> </asp:Literal>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-CssClass="selectfield">
                <ItemTemplate>
                    <a class="linkbutton icon_edit" href="_ModifySubSiteStatus.aspx?SubSiteID=<%#Eval("SUB_ID") %>">
                        <asp:Literal ID="litOLIndicates" runat="server" EnableViewState="false" Text="<%$ Resources:_Kartris, FormButton_Select %>"></asp:Literal></a>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <div class="spacer">
    </div>
    <asp:PlaceHolder ID="phdIndicates" runat="server">
        <div class="infomessage">
            <asp:Literal ID="litOLIndicates" runat="server" Text=""></asp:Literal>
            <asp:Literal ID="litOLIndicatesComplete" runat="server" Text=""></asp:Literal>
        </div>
    </asp:PlaceHolder>
    <_user:ItemPager runat="server" ID="_UC_ItemPager" />
</div>
