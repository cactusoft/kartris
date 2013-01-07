<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_ProductReviews.ascx.vb"
    Inherits="_ProductReviews" %>
<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:PlaceHolder ID="phdReviewsList" runat="server">
            <asp:UpdatePanel ID="updReviewsList" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <div id="section_reviews">
                                            
                        <asp:GridView CssClass="kartristable" ID="gvwProductReviews" runat="server" AllowSorting="true"
                            AutoGenerateColumns="False" DataKeyNames="REV_ID" AutoGenerateEditButton="False"
                            GridLines="None" SelectedIndex="0" AllowPaging="true">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Literal ID="litFormLabelReviewTitle" runat="server" Text="<%$ Resources:_Reviews, FormLabel_ReviewTitle %>" />
                                    </HeaderTemplate>
                                    <HeaderStyle CssClass="itemname" />
                                    <ItemTemplate>
                                        <asp:Literal runat="server" ID="litReviewStatus" Text='<%# Eval("REV_Live") %>' Visible="false" />
                                        <asp:Literal runat="server" Mode="Encode" ID="litReviewTitle" Text='<%# Eval("REV_Title") %>' />
                                    </ItemTemplate>
                                    <ItemStyle CssClass="pad itemname" />
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Literal ID="litFormLabelReviewRating" runat="server" Text="<%$ Resources:_Reviews, FormLabel_ReviewRating %>" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Literal ID="litRating" runat="server" Text='<%# Eval("REV_Rating") %>' Visible="false" />
                                        <span class="nowrap">
                                            <asp:PlaceHolder ID="phdStars" runat="server"></asp:PlaceHolder>
                                        </span>
                                    </ItemTemplate>
                                    <ItemStyle CssClass="pad rating" />
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Literal ID="litFormLabelProductName" runat="server" Text="<%$ Resources:_Kartris, FormLabel_Title %>" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Literal runat="server" ID="litProductID" Text='<%# Eval("REV_ProductID") %>'
                                            Visible="false" />
                                        <asp:LinkButton runat="server" ID="lnkBtnProductName" />
                                    </ItemTemplate>
                                    <ItemStyle CssClass="pad" />
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Literal ID="litFormLabelLastUpdated" runat="server" Text="<%$ Resources:_Kartris, ContentText_LastUpdated %>" /></HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Literal ID="litDate" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("REV_DateLastUpdated"), "t", Session("_LANG")) %>'> </asp:Literal>
                                    </ItemTemplate>
                                    <ItemStyle CssClass="pad date" />
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkBtnEditVersion" runat="server" CommandName="EditReview" CommandArgument='<%# Eval("REV_ID") %>'
                                            CssClass="linkbutton icon_edit" runat="server" Text='<%$ Resources:_Kartris, FormButton_Edit %>' />
                                    </ItemTemplate>
                                    <ItemStyle CssClass="alignright selectfield" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <div class="spacer"></div>
                        <asp:Panel ID="pnlNoReview" runat="server" CssClass="noresults" Visible="false">
                            <asp:Literal ID="litNoReview" runat="server" Text="<%$ Resources: _Kartris, ContentText_NoItemsFound %>" /></asp:Panel>
                        <asp:Panel ID="pnlReviewColors" runat="server" CssClass="infomessage">
                            <asp:Literal ID="litReviewColors" runat="server" Text="<%$ Resources: _Reviews, ContentText_ReviewColors %>" />
                        </asp:Panel>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </asp:PlaceHolder>
        <asp:PlaceHolder ID="phdEditReview" runat="server" Visible="false">
            <asp:Literal ID="litReviewID" runat="server" Visible="false" />
            <asp:UpdatePanel ID="updEditReview" runat="server">
                <ContentTemplate>
                <asp:LinkButton ID="lnkBtnBack" runat="server" Text='<%$ Resources: _Kartris, ContentText_BackLink %>'
                            CssClass="linkbutton icon_back floatright"></asp:LinkButton>
                    <div class="Kartris-DetailsView">
                        <div class="Kartris-DetailsView-Data">
                            <ul>
                                <!-- Status -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelStatus" runat="server" Text="<%$ Resources:_Kartris, FormLabel_Status %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:DropDownList ID="ddlStatus" runat="server">
                                        <asp:ListItem Text="<%$ Resources:_Reviews, ContentText_RadioWaitingAuthorisation %>"
                                            Value="a"></asp:ListItem>
                                        <asp:ListItem Text="<%$ Resources:_Reviews, ContentText_RadioLive %>" Value="y"></asp:ListItem>
                                        <asp:ListItem Text="<%$ Resources:_Reviews, ContentText_RadioNotLive %>" Value="n"></asp:ListItem>
                                    </asp:DropDownList>
                                </span></li>
                                <!-- Product Name -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelProduct" runat="server" Text="<%$ Resources:_Kartris, FormLabel_Product %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:Literal ID="litProductName" runat="server" />
                                </span></li>
                                <!-- Language -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="litFormLabelLanguage" runat="server" Text="<%$ Resources:_Kartris, FormLabel_Language %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:DropDownList ID="ddlLanguages" runat="server">
                                    </asp:DropDownList>
                                </span></li>
                                <!-- Title -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="lblTitle" runat="server" Text="<%$ Resources:_Reviews, FormLabel_ReviewTitle %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtTitle" runat="server" MaxLength="60" />
                                    <asp:RequiredFieldValidator EnableClientScript="False" ID="valTitle" runat="server"
                                        ControlToValidate="txtTitle" ValidationGroup="ReviewForm" CssClass="error" />
                                </span></li>
                                <!-- Rating -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="lblRating" runat="server" Text="<%$ Resources:_Reviews, FormLabel_ReviewRating %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:DropDownList ID="ddlRating" runat="server">
                                        <asp:ListItem>0</asp:ListItem>
                                        <asp:ListItem>1</asp:ListItem>
                                        <asp:ListItem>2</asp:ListItem>
                                        <asp:ListItem>3</asp:ListItem>
                                        <asp:ListItem>4</asp:ListItem>
                                        <asp:ListItem>5</asp:ListItem>
                                    </asp:DropDownList>
                                </span></li>
                                <!-- Text -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="lblReviewText" runat="server" Text="<%$ Resources:_Reviews, FormLabel_ReviewText %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtReviewText" runat="server" TextMode="MultiLine" Width="500px"
                                        MaxLength="4000" />
                                    <asp:RequiredFieldValidator EnableClientScript="False" ID="valReviewText" runat="server"
                                        ControlToValidate="txtReviewText" ValidationGroup="ReviewForm" CssClass="error" />
                                </span></li>
                                <!-- Name -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="lblName" runat="server" Text="<%$ Resources:_Reviews, FormLabel_ReviewName %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtName" runat="server" MaxLength="30" />
                                    <asp:RequiredFieldValidator EnableClientScript="False" ID="valName" runat="server"
                                        ControlToValidate="txtName" ValidationGroup="ReviewForm" CssClass="error" />
                                </span></li>
                                <!-- Location -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="lblLocation" runat="server" Text="<%$ Resources:_Reviews, FormLabel_ReviewLocation %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtLocation" runat="server" MaxLength="30" />
                                    <asp:RequiredFieldValidator EnableClientScript="False" ID="valLocation" runat="server"
                                        ControlToValidate="txtLocation" ValidationGroup="ReviewForm" CssClass="error" />
                                </span></li>
                                <!-- Email -->
                                <li><span class="Kartris-DetailsView-Name">
                                    <asp:Literal ID="lblEmail" runat="server" Text="<%$ Resources:_Reviews, FormLabel_ReviewEmail %>" />
                                </span><span class="Kartris-DetailsView-Value">
                                    <asp:TextBox ID="txtEmail" runat="server" MaxLength="75" />
                                    <asp:RequiredFieldValidator ID="valEmail" runat="server" ControlToValidate="txtEmail"
                                        ValidationGroup="ReviewForm" CssClass="error" EnableClientScript="False"></asp:RequiredFieldValidator><asp:RegularExpressionValidator
                                            EnableClientScript="False" ID="valEmail2" runat="server" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                            ControlToValidate="txtEmail" CssClass="error" ValidationGroup="ReviewForm" />
                                </span></li>
                            </ul>
                        </div>
                    </div>
                    <%-- Save Button  --%>
                    <div id="updatebuttonbar" class="submitbuttons topsubmitbuttons">
                        <asp:UpdatePanel ID="updSaveChanges" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:LinkButton ID="btnSave" runat="server" CssClass="button savebutton" Text='<%$ Resources: _Kartris, FormButton_Save %>'
                                 ToolTip='<%$ Resources: _Kartris, FormButton_Save %>' />
                                <asp:LinkButton ID="btnCancel" runat="server" CssClass="button cancelbutton" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                                ToolTip='<%$ Resources: _Kartris, FormButton_Cancel %>' /><span
                                    class="floatright">
                                    <asp:LinkButton ID="lnkBtnDelete" CssClass="button deletebutton"
                                        runat="server" Text='<%$ Resources: _Kartris, FormButton_Delete %>' ToolTip='<%$ Resources: _Reviews, ContentText_DeleteThisReview %>' />
                                </span>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </asp:PlaceHolder>
        <_user:PopupMessage ID="_UC_DeleteConfirmation" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
