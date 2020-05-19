<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_RelatedProducts.ascx.vb"
    Inherits="UserControls_Back_RelatedProducts" %>
<%@ Register TagPrefix="_user" TagName="AutoComplete" Src="~/UserControls/Back/_AutoCompleteInput.ascx" %>

<div id="section_relatedproducts">
    <asp:UpdatePanel ID="updRelatedProducts" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div>
                <asp:TextBox ID="txtProduct" runat="server" MaxLength="250" autocomplete="off" />
                <ajaxToolkit:AutoCompleteExtender runat="server" BehaviorID="bhvRelatedProducts" ID="autCompleteCtrl"
                    TargetControlID="txtProduct" ServicePath="~/Admin/kartrisServices.asmx" MinimumPrefixLength="1"
                    CompletionInterval="1000" ServiceMethod="GetProducts" EnableCaching="true" CompletionSetCount="10"
                    CompletionListCssClass="autocomplete_completionListElement" CompletionListItemCssClass="autocomplete_listItem"
                    CompletionListHighlightedItemCssClass="autocomplete_highlightedListItem" DelimiterCharacters=","
                    UseContextKey="true">
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
                                var behavior = $find('bhvRelatedProducts');
                                if (!behavior._height) {
                                    var target = behavior.get_completionList();
                                    behavior._height = target.offsetHeight - 2;
                                    target.style.height = '0px';
                                }" />
                            
                            <%-- Expand from 0px to the appropriate size while fading in --%>
                            <Parallel Duration=".4">
                                <FadeIn />
                                <Length PropertyKey="height" StartValue="0" EndValueScript="$find('bhvRelatedProducts')._height" />
                            </Parallel>
                        </Sequence>
                    </OnShow>
                    <OnHide>
                        <%-- Collapse down to 0px and fade out --%>
                        <Parallel Duration=".4">
                            <FadeOut />
                            <Length PropertyKey="height" StartValueScript="$find('bhvRelatedProducts')._height" EndValue="0" />
                        </Parallel>
                    </OnHide>
                    </Animations>
                </ajaxToolkit:AutoCompleteExtender>

                <script type="text/javascript">
                    // Work around browser behavior of "auto-submitting" simple forms
                    var frm = document.getElementById("aspnetForm");
                    if (frm) {
                        frm.onsubmit = function() { return false; };
                    }
                </script>

                <asp:Button ID="btnAdd" runat="server" CssClass="button" Text='<%$ Resources:_Kartris, ContentText_AddNew %>' />
                <asp:ListBox ID="lbxRelatedProducts" runat="server" Visible="false" />
                <asp:PlaceHolder ID="phdProductsList" runat="server" Visible="false">
                    <br />
                    <br />
                    <asp:Button ID="btnDeleteAll" runat="server" Text="<%$ Resources: _Kartris, ContentText_DeleteAll %>" Style="float: right;" class="button"/>
                    <h2>
                        <asp:Literal ID="litContentTextSelectedRelations" runat="server" Text="<%$ Resources: _Product, ContentText_SelectedRelations %>" /></h2>
                    <div class="minheight">
                        <asp:GridView CssClass="kartristable" ID="gvwRelatedProducts" runat="server" AllowSorting="true" AutoGenerateColumns="False"
                            DataKeyNames="ProductID" AutoGenerateEditButton="False" GridLines="None" PagerSettings-PageButtonCount="10"
                            SelectedIndex="0">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Literal ID="litFormLabelTitle" runat="server" Text='<%$ Resources:_Kartris, FormLabel_Title %>' />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkBtnEditProduct" runat="server" CommandName="EditRelatedProducts"
                                            CommandArgument='<%# Eval("ProductID") %>' Text='<%# Eval("ProductName") %>' />
                                    </ItemTemplate>
                                    <ItemStyle CssClass="itemname" />
                                </asp:TemplateField>
                                <asp:TemplateField ItemStyle-CssClass="selectfield">
                                    <HeaderTemplate>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkBtnEditVersion" runat="server" CommandName="RemoveProduct"
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
                <asp:LinkButton ID="btnSaveChanges" runat="server" CssClass="button savebutton" Text="<%$ Resources:_Kartris, FormButton_Save %>" ToolTip="<%$ Resources:_Kartris, FormButton_Save %>"/>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
<_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
