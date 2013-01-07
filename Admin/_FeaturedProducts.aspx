<%@ Page Title="" Language="VB" MasterPageFile="~/Skins/Admin/Template.master" AutoEventWireup="false"
    CodeFile="_FeaturedProducts.aspx.vb" Inherits="Admin_FeaturedProducts" %>
 
<%@ Register TagPrefix="_user" TagName="AutoComplete" Src="~/UserControls/Back/_AutoCompleteInput.ascx" %>
<asp:Content ID="cntHead" ContentPlaceHolderID="phdHead" runat="Server">
</asp:Content>
<asp:Content ID="cntMain" ContentPlaceHolderID="phdMain" runat="Server">
    <h1>
        <asp:Literal ID="litPageTitleFeaturedProducts" runat="server" Text="<%$ Resources: _Kartris, PageTitle_FeaturedProducts %>" /></h1>
    <div id="section_featuredproducts">
        <asp:UpdatePanel ID="updFeaturedProducts" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <div>
                    <asp:TextBox ID="txtProduct" runat="server" MaxLength="250" />
                    <ajaxToolkit:AutoCompleteExtender runat="server" BehaviorID="bhvFeaturedProducts"
                        ID="autCompleteFeaturedProducts" TargetControlID="txtProduct" ServicePath="~/Admin/kartrisServices.asmx"
                        MinimumPrefixLength="1" CompletionInterval="1000" ServiceMethod="GetProducts"
                        EnableCaching="true" CompletionSetCount="10" CompletionListCssClass="autocomplete_completionListElement"
                        CompletionListItemCssClass="autocomplete_listItem" CompletionListHighlightedItemCssClass="autocomplete_highlightedListItem"
                        DelimiterCharacters="," UseContextKey="true">
                        <Animations>
                    <OnShow>
                        <Sequence>
                            <%-- Make the completion list transparent and then show it --%>
                            <OpacityAction Opacity="0" />
                            <HideAction Visible="true" />
                            
                            <%--Cache the original size of the completion list the first time
                                the animation is played and then set it to zero --%>
                            <ScriptAction Script="
                                // Cache the size and setup the initial size
                                var behavior = $find('bhvFeaturedProducts');
                                if (!behavior._height) {
                                    var target = behavior.get_completionList();
                                    behavior._height = target.offsetHeight - 2;
                                    target.style.height = '0px';
                                }" />
                            
                            <%-- Expand from 0px to the appropriate size while fading in --%>
                            <Parallel Duration=".4">
                                <FadeIn />
                                <Length PropertyKey="height" StartValue="0" EndValueScript="$find('bhvFeaturedProducts')._height" />
                            </Parallel>
                        </Sequence>
                    </OnShow>
                    <OnHide>
                        <%-- Collapse down to 0px and fade out --%>
                        <Parallel Duration=".4">
                            <FadeOut />
                            <Length PropertyKey="height" StartValueScript="$find('bhvFeaturedProducts')._height" EndValue="0" />
                        </Parallel>
                    </OnHide>
                        </Animations>
                    </ajaxToolkit:AutoCompleteExtender>
                    <asp:Literal ID="litContentTextFeatured" runat="server" Text='<%$ Resources:_Kartris, ContentText_Featured %>' />
                    <asp:TextBox ID="txtFeaturedLevel" runat="server" Text='<%# Eval("ProductPriority") %>'
                                                        CssClass="shorttext" MaxLength="3" />
                    

                    <script type="text/javascript">
                        // Work around browser behavior of "auto-submitting" simple forms
                        var frm = document.getElementById("aspnetForm");
                        if (frm) {
                            frm.onsubmit = function() { return false; };
                        }
                    </script>

                    <asp:Button ID="btnAdd" runat="server" CssClass="button" Text='<%$ Resources:_Kartris, ContentText_AddNew %>'
                        ValidationGroup="addFeatured" />
                </div>
                <asp:MultiView ID="mvwFeaturedProducts" runat="server" ActiveViewIndex="0">
                    <asp:View ID="viwProductList" runat="server">
                        <div>
                            <asp:ListBox ID="lbxFeaturedProducts" runat="server" Visible="false" />
                            <asp:ListBox ID="lbxFeaturedPriorities" runat="server" Visible="false" />
                            <asp:PlaceHolder ID="phdProductsList" runat="server">
                                <br />
                                <br />
                                <div class="minheight">
                                    <asp:GridView CssClass="kartristable" ID="gvwFeaturedProducts" runat="server" AllowSorting="true" AutoGenerateColumns="False"
                                        DataKeyNames="ProductID" AutoGenerateEditButton="False" GridLines="None" PagerSettings-PageButtonCount="10"
                                        SelectedIndex="0">
                                        <Columns>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litFormLabelTitle" runat="server" Text='<%$ Resources:_Kartris, FormLabel_Title %>' />
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="lnkBtnEditProduct" runat="server" CommandName="EditFeaturedProducts"
                                                        CommandArgument='<%# Eval("ProductID") %>' Text='<%# Eval("ProductName") %>' />
                                                </ItemTemplate>
                                                <ItemStyle CssClass="itemname" />
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <HeaderTemplate>
                                                    <asp:Literal ID="litFormLabelFeatured" runat="server" Text='<%$ Resources:_Kartris, ContentText_Featured %>' />
                                                </HeaderTemplate>
                                                <ItemTemplate><span style="white-space:nowrap;">
                                                    <asp:TextBox ID="txtPriority" runat="server" Text='<%# Eval("ProductPriority") %>'
                                                        CssClass="shorttext" MaxLength="3" />
                                                    <ajaxToolkit:FilteredTextBoxExtender ID="filPriority" runat="server" TargetControlID="txtPriority"
                                                        FilterType="Numbers" />
                                                    <asp:LinkButton ID="lnkBtnEditPriority" runat="server" CommandName="ChangePriority"
                                                        CommandArgument='<%# Container.DataItemIndex %>' Text="<%$ Resources: _Kartris, FormButton_Change %>"
                                                        CssClass="linkbutton icon_edit" /></span>
                                                </ItemTemplate>
                                                <ItemStyle />
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-CssClass="selectfield">
                                                <HeaderTemplate>
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="lnkBtnDeleteProduct" runat="server" CommandName="RemoveProduct"
                                                        CssClass="linkbutton icon_delete" CommandArgument='<%# Eval("ProductID") %>'
                                                        Text="<%$ Resources:_Kartris, FormButton_Delete %>" ToolTip='<%$ Resources:_Product, ImageLabel_RemoveRelatedProduct %>' />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </div>
                            </asp:PlaceHolder>
                        </div>
                        <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                            <asp:LinkButton ID="btnSaveChanges" runat="server" CssClass="button savebutton" Text="<%$ Resources:_Kartris, FormButton_Save %>"
                            ToolTip="<%$ Resources:_Kartris, FormButton_Save %>" />
                        </div>
                    </asp:View>
                    <asp:View ID="viwNoItems" runat="server">
                        <asp:Panel ID="pnlNoItems" runat="server" CssClass="noresults">
                            <asp:Literal ID="litNoItems" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" />
                        </asp:Panel>
                    </asp:View>
                </asp:MultiView>
                <div>
                    <div class="infomessage">
                        <asp:Literal ID="litContentTextFeaturedText" runat="server" Text="<%$ Resources: _Kartris, ContentText_FeaturedText %>" /></div>
                    <br />
                    <p>
                        <asp:Literal ID="litContentTextMaximumFeaturedProductsToDisplay" runat="server" Text="<%$ Resources: _Kartris, ContentText_MaximumFeaturedProductsToDisplay %>" />
                        <strong>
                            <asp:Literal ID="litMaxNumberToDisplay" runat="server" /></strong>
                        <asp:LinkButton ID="lnkChange" runat="server" Text="<%$ Resources: _Kartris, FormButton_Change %>"
                            PostBackUrl="~/Admin/_Config.aspx?name=frontend.featuredproducts.display.max"
                            CssClass="linkbutton icon_edit" /></p>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
    <_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
    <asp:UpdateProgress ID="prgMain" runat="server" AssociatedUpdatePanelID="updFeaturedProducts">
        <ProgressTemplate>
            <div class="loadingimage">
            </div>
            <div class="updateprogress">
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>
</asp:Content>

