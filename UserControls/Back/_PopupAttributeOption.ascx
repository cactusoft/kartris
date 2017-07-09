<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_PopupAttributeOption.ascx.vb" Inherits="UserControls_Custom_Back_PopupAttributeOption" %>
<script type="text/javascript">
    function onYes() {
        var postBack = new Sys.WebForms.PostBackAction();
        postBack.set_target('lnkYes');
        postBack.set_eventArgument('');
        postBack.performAction();
    }
</script>
          <asp:Panel ID="pnlMessage" runat="server" Style="display: none" CssClass="popup">
              <asp:UpdatePanel ID="updAttributeOptions" runat="server" >
                        <ContentTemplate>
            <asp:MultiView ID="mvViews" runat="server" >
                <asp:View ID="viewAttributesForOption" runat="server">
                    <h2>Attribute Options Linked to Option Group Option</h2>
                    <h3>
                        <asp:Literal ID="litOptionDetails" runat="server"></asp:Literal></h3>
                   
                            <asp:GridView ID="gvAttributes" CssClass="kartristable" runat="server" AutoGenerateColumns="false" EmptyDataText="NO DATA"  >
                                <Columns>
                                    <asp:BoundField DataField="AttributeDetail" HeaderText="Attribute" ReadOnly="true" ShowHeader="true" />
                                    <asp:BoundField DataField="AttributeOptionDetail" HeaderText="Attribute Option" ReadOnly="true" ShowHeader="true" />
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkDelete" CommandArgument='<%# Eval("AttributeOptionId")%>' CommandName="delete" runat="server">Delete</asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <li><span class="Kartris-DetailsView-Name">Attribute</span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:DropDownList ID="ddlAttributes" runat="server" DataTextField="ATTRIB_Name" DataValueField="ATTRIB_ID" AutoPostBack="true"></asp:DropDownList>
                                    </span></li>
                                <li><span class="Kartris-DetailsView-Name">Option</span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:DropDownList ID="ddlAttributeOptions" runat="server" DataTextField="ATTRIBO_Name" DataValueField="ATTRIBO_ID"></asp:DropDownList>
                                    </span></li>
                                <li><span class="Kartris-DetailsView-Name"></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:Button ID="btnAddAttributeOption" CssClass="button" runat="server" Text="Add" Enabled="true" />
                                    </span></li></ul></div></div>
                            <asp:Label ID="lblError" runat="server" CssClass="error" Text=""></asp:Label>

                </asp:View>
                <asp:View ID="viewOptionsForAttribute" runat="server">
                    <h2>Option Group Options Linked to Attribute Option</h2>
                    <h3>
                        <asp:Literal ID="litAttributeDetails" runat="server"></asp:Literal></h3>
              
                            <asp:GridView ID="gvOptions" CssClass="kartristable" runat="server" AutoGenerateColumns="false" EmptyDataText="NO DATA">
                                <Columns>
                                     <asp:BoundField DataField="OptionGroupDetail" HeaderText="Option Group" ReadOnly="true" ShowHeader="true" />
                                    <asp:BoundField DataField="OptionDetail" HeaderText="Option Group Option" ReadOnly="true" ShowHeader="true" />
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkDelete" CommandArgument='<%# Eval("OptionId")%>' CommandName="delete" runat="server">Delete</asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                 <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <li><span class="Kartris-DetailsView-Name">Option Group</span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:DropDownList ID="ddlOptionGroups" runat="server" DataTextField="OPTG_BackendName" DataValueField="OPTG_ID" AutoPostBack="true"></asp:DropDownList>
                                    </span></li>
                                <li><span class="Kartris-DetailsView-Name">Option</span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:DropDownList ID="ddlOptionGroupOptions" runat="server" DataTextField="OPT_Name" DataValueField="OPT_ID"></asp:DropDownList>
                                    </span></li>
                                <li><span class="Kartris-DetailsView-Name"></span>
                                    <span class="Kartris-DetailsView-Value">
                                        <asp:Button ID="btnAddOptionGroupOption" CssClass="button" runat="server" Text="Add" Enabled="true" />
                                    </span></li></ul></div></div>
                            <asp:Label ID="lblOptionGroupError" runat="server" CssClass="error" Text=""></asp:Label>
                </asp:View>
            </asp:MultiView>
                      </ContentTemplate>
                    </asp:UpdatePanel>





            <asp:LinkButton ID="lnkExtenderCancel" runat="server" Text="" CssClass="closebutton" />
            <asp:LinkButton ID="lnkBtn" runat="server"></asp:LinkButton>
            <asp:PlaceHolder ID="phdContents" runat="server">
                <div>
                    <asp:PlaceHolder ID="phdImage" runat="server" Visible="false">
                        <div class="imageholder">
                            <asp:Image ID="imgToRemove" runat="server" Width="120px" Height="120px" />
                            <p>
                                <strong>
                                    <asp:Literal ID="litImageNameToRemove" runat="server"></asp:Literal></strong>
                            </p>
                        </div>
                    </asp:PlaceHolder>
                    <p>
                        <asp:Literal ID="litMessage" runat="server" /></p>

                    <asp:LinkButton ID="lnkExtenderOk" runat="server" Text="" CssClass="invisible" />
                    <p>
                        <asp:Button ID="lnkYes" OnClick="lnkYes_Click" runat="server" Text="<%$ Resources: _Kartris, ContentText_Yes %>" Visible="false" CssClass="button" />
                        &nbsp;<asp:Button ID="lnkNo" OnClick="lnkNo_Click" runat="server" Text="<%$ Resources: _Kartris, ContentText_No %>"
                            Visible="false" CssClass="button cancelbutton" />
                    </p>
                </div>
            </asp:PlaceHolder>

        </asp:Panel>
       <ajaxToolkit:ModalPopupExtender ID="popExtender" runat="server" TargetControlID="lnkBtn"
            PopupControlID="pnlMessage" OnOkScript="onYes()" BackgroundCssClass="popup_background"
            OkControlID="lnkExtenderOk" CancelControlID="lnkExtenderCancel" DropShadow="False"
            RepositionMode="None">
        </ajaxToolkit:ModalPopupExtender>

      
