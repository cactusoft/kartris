<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_VersionView.ascx.vb"
    Inherits="_VersionView" %>
<%@ Register TagPrefix="_user" TagName="FileUploader" Src="~/UserControls/Back/_FileUploader.ascx" %>
<%@ Register TagPrefix="_user" TagName="EditVersion" Src="~/UserControls/Back/_EditVersion.ascx" %>
<%@ Register TagPrefix="_user" TagName="EditMedia" Src="~/UserControls/Back/_EditMedia.ascx" %>
<%@ Register TagPrefix="_user" TagName="QuantityDiscount" Src="~/UserControls/Back/_QuantityDiscount.ascx" %>
<%@ Register TagPrefix="_user" TagName="CustomerGroupPrices" Src="~/UserControls/Back/_CustomerGroupPrices.ascx" %>
<%@ Register TagPrefix="_user" TagName="ObjectConfig" Src="~/UserControls/Back/_ObjectConfig.ascx" %>
<div id="section_versions">
    <asp:UpdatePanel ID="updVersionsMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Literal ID="litProductID" runat="server" Visible="false"></asp:Literal>
            <asp:UpdatePanel ID="updVersions" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:MultiView ID="mvwVersions" runat="server" ActiveViewIndex="0">
                        <asp:View ID="viwVersionList" runat="server">
                            <div>
                            <asp:UpdatePanel ID="updVersionsList" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                    <asp:Button Visible="false" Text="Update Preference" runat="server" ID="btnUpdatePreference" />

                                    <asp:HiddenField ID="currentPreference"  value='' runat="server" />
                                    <asp:GridView CssClass="kartristable" ID="gvwViewVersions" runat="server" AllowPaging="False" 
                                        AllowSorting="true" AutoGenerateColumns="False" DataKeyNames="V_ID" AutoGenerateEditButton="False"
                                        GridLines="None" SelectedIndex="-1">
                                        <Columns>
                                            <asp:TemplateField HeaderText='<%$ Resources:_Product, FormLabel_VersionName %>'
                                                ItemStyle-CssClass="itemname">
                                                <HeaderStyle />
                                                <ItemTemplate>
                                                    <asp:PlaceHolder ID="phdVersionSort" runat="server" Visible='<%# Eval("SortByValue") %>'>
                                                        <div class="updownbuttons">
                                                            <asp:LinkButton ID="lnkBtnMoveUp" runat="server" CommandName="MoveUp" CommandArgument='<%# Eval("V_ID") %>'
                                                                Text="+" CssClass="triggerswitch triggerswitch_on" />
                                                            <asp:LinkButton ID="lnkBtnMoveDown" runat="server" CommandName="MoveDown" CommandArgument='<%# Eval("V_ID") %>'
                                                                Text="-" CssClass="triggerswitch triggerswitch_off" />
                                                        </div>
                                                    </asp:PlaceHolder>
                                                    <input type="hidden" name="V_ID" value='<%# Eval("V_ID") %>' />
                                                    <asp:Literal ID="V_Name" runat="server" Text='<%# Eval("V_Name") %>' />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField DataField="V_CodeNumber" HeaderText='<%$ Resources:_Version, FormLabel_CodeNumer %>'>
                                                <HeaderStyle />
                                            </asp:BoundField>
                                            <asp:TemplateField ItemStyle-CssClass="alignright">
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litFormLabelStockQuantity" runat="server" Text='<%$ Resources:_Version, FormLabel_StockQuantity %>' />
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <asp:Literal ID="litQuantity" runat="server" Text='<%# Eval("V_Quantity") & " (" & Eval("V_QuantityWarnLevel") & ")" %>' />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField ItemStyle-CssClass="alignright" DataField="V_Price" HeaderText='<%$ Resources:_Kartris, ContentText_Price %>'>
                                                <HeaderStyle />
                                            </asp:BoundField>
                                            <asp:TemplateField ItemStyle-CssClass="alignright">
                                                <HeaderTemplate>
                                                    <asp:LinkButton ID="lnkBtnRefreshVersions" runat="server" CommandName="Refresh" Text="refresh" CssClass="invisible btnRefreshVersions"/>
                                                    <asp:Literal ID="litContentTextTax" runat="server" Text='<%$ Resources:_Version, ContentText_Tax %>' />
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                <%  If TaxRegime.VTax_Type = "boolean" Then %>
                                                        <span class="checkbox"><asp:CheckBox ID="chkTax" runat="server" Checked='<%# CkartrisDataManipulation.FixNullFromDB(Eval("T_TaxRate")) <> 0 %>' Enabled="False"></asp:CheckBox></span>
                                                        <% Else%>
                                                        <asp:Literal ID="T_TaxRate" runat="server" Text='<%# CkartrisDisplayFunctions.FixDecimal(CkartrisDataManipulation.FixNullFromDB(Eval("T_TaxRate"))) & "%"%>' />
                                                <% End If%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-CssClass="selectfield alignright nowrap">
                                                <HeaderTemplate>
                                                    <asp:LinkButton ID="lnkNewVersion" runat="server" CssClass="linkbutton icon_new"
                                                        CommandName="NewVersion" Text="<%$ Resources: _Kartris, FormButton_New %>" />
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <asp:PlaceHolder ID="phdCloneLink" runat="server"><a class="linkbutton icon_new"
                                                        href="_ModifyProduct.aspx?ProductID=<%# Eval("V_ProductID") %>&CategoryID=<% =Request.QueryString("CategoryID") %>&VersionID=<%# Eval("V_ID") %>&strParent=<% =Request.Querystring("strParent") %>&strTab=versions&strClone=yes">
                                                        <asp:Literal ID="litFormButtonClone" Text='<%$ Resources:_Kartris, FormButton_Clone %>'
                                                            runat="server"></asp:Literal></a></asp:PlaceHolder>
                                                    <a class="linkbutton icon_edit" href="_ModifyProduct.aspx?ProductID=<%# Eval("V_ProductID") %>&CategoryID=<% =Request.QueryString("CategoryID") %>&VersionID=<%# Eval("V_ID") %>&strParent=<% =Request.Querystring("strParent") %>&strTab=versions">
                                                        <asp:Literal ID="litRelatedProductsLink" Text='<%$ Resources:_Kartris, FormButton_Edit %>'
                                                            runat="server"></asp:Literal></a>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                            </div>
                        </asp:View>
                        <asp:View ID="viwVersionDetails" runat="server">
                            <asp:Literal ID="litVersionID" runat="server" Visible="false" />
                            <asp:Literal ID="litVersionName" runat="server" Visible="false" />
                            <asp:LinkButton ID="lnkBtnShowVersionsList" runat="server" CssClass="linkbutton icon_back floatright"
                                Text='<%$ Resources: _Kartris, ContentText_BackLink %>' />
                            <asp:Panel class="mvw__tab_default" runat="server" ID="pnlTabStrip">
                                <asp:LinkButton ID="lnkMainInfo" runat="server" Text="<%$ Resources:_Version, FormLabel_TabVersionInformation %>" /><asp:LinkButton
                                    ID="lnkImages" runat="server" Text="<%$ Resources:_Version, FormLabel_TabVersionImages %>" /><asp:LinkButton
                                        ID="lnkMedia" runat="server" Text="<%$ Resources:_Product, FormLabel_TabProductMedia %>" /><asp:LinkButton ID="lnkQtyDiscount"
                                            runat="server" Text="<%$ Resources:_Version, FormLabel_TabQuantityDiscount %>" /><asp:LinkButton
                                                ID="lnkCustomerGroupPrices" runat="server" Text="<%$ Resources:_Kartris, ContentText_CustomerGroupPrices %>" /><asp:LinkButton
                                                    ID="lnkObjectConfig" runat="server" Text="<%$ Resources:_Kartris, ContentText_ObjectConfig %>" />
                            </asp:Panel>
                            <asp:MultiView ID="mvwVersionsDetails" runat="server" ActiveViewIndex="0">
                                <asp:View ID="viwMainInfo" runat="server">
                                    <asp:UpdatePanel ID="updEditVersion" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <_user:EditVersion ID="_UC_EditVersion" runat="server" />
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                    <%-- Save Button  --%>
                                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                                        <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:LinkButton ID="lnkBtnSave" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                                    ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                                                <asp:LinkButton ID="lnkBtnCancel" runat="server" CssClass="button cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                                    ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' />
                                                <span class="floatright">
                                                    <asp:LinkButton ID="lnkBtnDelete" CssClass="button deletebutton"
                                                        runat="server" Visible="false" Text='<%$ Resources: _Kartris, FormButton_Delete %>'
                                                        ToolTip='<%$ Resources: _Product, ContentText_DeleteThisProduct %>' /></span><asp:ValidationSummary
                                                            ID="valSummary2" runat="server" ForeColor="" CssClass="valsummary" DisplayMode="BulletList"
                                                            HeaderText="<%$ Resources: _Kartris, ContentText_Errors %>" />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                </asp:View>
                                <asp:View ID="viwVersionImages" runat="server">
                                    <div class="subtabsection">
                                        <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=10160')" style="margin-bottom: 20px;">?</a>
                                        <_user:FileUploader ID="_UC_Uploader" runat="server" />
                                    </div>
                                </asp:View>
                                <asp:View runat="server" ID="viwVersionMedia">
                                    <div class="subtabsection">
                                        <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9838')" style="margin-bottom: 20px;">?</a>
                                        <_user:EditMedia ID="_UC_EditMedia" runat="server" />
                                    </div>
                                </asp:View>
                                <asp:View ID="viwQuantityDiscount" runat="server">
                                    <div class="subtabsection">
                                        <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9927')">?</a>
                                        <_user:QuantityDiscount ID="_UC_QtyDiscount" runat="server" />
                                    </div>
                                </asp:View>
                                <asp:View ID="viwCustomerGroupPrices" runat="server">
                                    <div class="subtabsection">
                                        <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=9889')">?</a>
                                        <_user:CustomerGroupPrices ID="_UC_CustomerGroupPrices" runat="server" />
                                    </div>
                                </asp:View>
                                <asp:View runat="server" ID="tabObjectConfig">
                                    <div class="subtabsection">
                                        <_user:ObjectConfig ID="_UC_ObjectConfig" runat="server" ItemType="Version" />
                                    </div>
                                </asp:View>
                            </asp:MultiView>
                        </asp:View>
                        <asp:View ID="viwNoVersions" runat="server">
                            <div class="noresults">
                                <asp:Literal ID="litContentTextNoItemsFound" runat="server" Text='<%$ Resources:_Kartris, ContentText_NoItemsFound %>' />
                            </div>
                            <p>
                                <asp:LinkButton ID="lnkBtnCreateNewVersion" runat="server" class="linkbutton icon_new"
                                    Text='<%$ Resources: _Version, PageTitle_NewVersion %>' /></p>
                        </asp:View>
                    </asp:MultiView>
                </ContentTemplate>
            </asp:UpdatePanel>
        </ContentTemplate>
    </asp:UpdatePanel>
    <script type="text/javascript">
            function dndEvents() {
                $("[id*=phdMain__UC_VersionView_gvwViewVersions]").sortable({
                    items: 'tr',
                    cursor: 'pointer',
                    axis: 'y',
                    dropOnEmpty: false,
                    start: function (e, ui) {
                        ui.item.addClass("selected");
                        $(ui.item).find(".floatright").hide();
                    },
                    stop: function (e, ui) {
                        console.log("stop");
                        console.log(document.forms[0]);
                        ui.item.removeClass("selected");
                        var versionIds = document.forms[0].elements["V_ID"];
                        var versionIdsStr = "";
                        for (var i = 0; i < versionIds.length; i++) {
                            if (versionIdsStr == "") {
                                versionIdsStr = versionIds[i].value;
                            } else {
                                versionIdsStr = versionIdsStr + "," + versionIds[i].value;
                            }

                        }
                        $(ui.item).find(".floatright").show();
                        if (versionIdsStr != $("#phdMain__UC_VersionView_currentPreference").val()) {
                            console.log("click");
                            $(".btnRefreshVersions")[0].click();
                            //__doPostBack('ctl00$phdMain$_UC_VersionView$btnUpdatePreference', 'OnClick');
                        }
                    },
                    receive: function (e, ui) {
                        $(this).find("tbody").append(ui.item);
                    }
                });
            }

        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_endRequest(function (s, e) {
            dndEvents();
        });

        $(function () {
            dndEvents();
        });
</script>
</div>
<_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
