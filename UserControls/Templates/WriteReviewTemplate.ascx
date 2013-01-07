<%@ Control Language="VB" AutoEventWireup="false" CodeFile="WriteReviewTemplate.ascx.vb"
    Inherits="WriteReviewTemplate" ClientIDMode="Static" %>
<asp:UpdatePanel ID="updReviewMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:MultiView ID="mvwWriting" runat="server" ActiveViewIndex="0" >
            <asp:View ID="viwWritingForm" runat="server">
                <div class="addreview inputform">
                    <asp:UpdatePanel ID="updWritingForm" runat="server">
                        <ContentTemplate>
                            <div>
                                <asp:Literal ID="litAddRevew" runat="server" Text="<%$ Resources: Reviews, ContentText_AddReview %>"></asp:Literal>
                                <asp:Literal ID="litProductName" runat="server" Visible="false"></asp:Literal></div>
                            <br />
                            <div class="spacer">
                            </div>
                            <asp:Panel ID="pnlWriteReview" runat="server" DefaultButton="btnAddReview">
                                <div class="Kartris-DetailsView">
                                    <div class="Kartris-DetailsView-Data">
                                        <ul>
                                            <li>
                                                <h2>
                                                    <asp:Literal ID="litYourReview" runat="server" Text="<%$ Resources: Reviews, FormLabel_ReviewSectionReview %>"></asp:Literal></h2>
                                            </li>
                                            <!-- Title -->
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblTitle" runat="server" Text="<%$ Resources: Reviews, FormLabel_ReviewTitle %>"
                                                    AssociatedControlID="txtTitle" CssClass="requiredfield"></asp:Label></span><span
                                                        class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="txtTitle" runat="server" MaxLength="60" />
                                                        <asp:RequiredFieldValidator EnableClientScript="True" ID="valTitle" runat="server"
                                                            ControlToValidate="txtTitle" ValidationGroup="ReviewForm" CssClass="error" ForeColor=""
                                                            Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator></span></li>
                                            <!-- Rating -->
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblRating" runat="server" Text="<%$ Resources: Reviews, FormLabel_ReviewRating %>"
                                                    AssociatedControlID="ddlRating"></asp:Label></span><span class="Kartris-DetailsView-Value">
                                                        <asp:UpdatePanel ID="updRating" runat="server" UpdateMode="Conditional" RenderMode="Inline">
                                                            <ContentTemplate>
                                                                <asp:DropDownList ID="ddlRating" runat="server">
                                                                </asp:DropDownList>
                                                                <asp:RequiredFieldValidator Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                                            ID="valRating" runat="server" ControlToValidate="ddlRating" ValidationGroup="ReviewForm"
                                                            CssClass="error" ForeColor=""></asp:RequiredFieldValidator>
                                                            </ContentTemplate>
                                                        </asp:UpdatePanel>
                                                    </span></li>
                                            <!-- Text -->
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblReviewText" runat="server" Text="<%$ Resources: Reviews, FormLabel_ReviewText %>"
                                                    AssociatedControlID="txtReviewText" CssClass="requiredfield"></asp:Label></span><span
                                                        class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="txtReviewText" runat="server" TextMode="MultiLine" MaxLength="4000" />
                                                        <asp:RequiredFieldValidator Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                                            ID="valReviewText" runat="server" ControlToValidate="txtReviewText" ValidationGroup="ReviewForm"
                                                            CssClass="error" ForeColor=""></asp:RequiredFieldValidator></span></li>
                                            <li>
                                                <h2>
                                                    <asp:Literal ID="litContactSectionTitle" runat="server" Text="<%$ Resources: Reviews, FormLabel_ReviewSectionContact %>"></asp:Literal>
                                                </h2>
                                            </li>
                                            <!-- Name -->
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblName" runat="server" Text="<%$ Resources: Reviews, FormLabel_ReviewName %>"
                                                    AssociatedControlID="txtName" CssClass="requiredfield"></asp:Label></span><span class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="txtName" runat="server" MaxLength="30" />
                                                        <asp:RequiredFieldValidator Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                                            ID="valName" runat="server" ControlToValidate="txtName" ValidationGroup="ReviewForm"
                                                            CssClass="error" ForeColor=""></asp:RequiredFieldValidator></span></li>
                                            <!-- Location -->
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblLocation" runat="server" Text="<%$ Resources: Reviews, FormLabel_ReviewLocation %>"
                                                    AssociatedControlID="txtLocation" CssClass="requiredfield"></asp:Label></span><span
                                                        class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="txtLocation" runat="server" MaxLength="30" />
                                                        <asp:RequiredFieldValidator Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_RequiredField %>"
                                                            ID="valLocation" runat="server" ControlToValidate="txtLocation" ValidationGroup="ReviewForm"
                                                            CssClass="error" ForeColor=""></asp:RequiredFieldValidator></span></li>
                                            <!-- Email -->
                                            <li><span class="Kartris-DetailsView-Name">
                                                <asp:Label ID="lblEmail" runat="server" Text="<%$ Resources: Reviews, FormLabel_ReviewEmail %>"
                                                    AssociatedControlID="txtEmail" CssClass="requiredfield"></asp:Label></span><span
                                                        class="Kartris-DetailsView-Value">
                                                        <asp:TextBox ID="txtEmail" runat="server" MaxLength="75" />
                                                        <asp:RequiredFieldValidator ID="valEmail" runat="server" ControlToValidate="txtEmail"
                                                            ValidationGroup="ReviewForm" CssClass="error" ForeColor="" Display="Dynamic"
                                                            Text="<%$ Resources: Kartris, ContentText_RequiredField %>"></asp:RequiredFieldValidator><asp:RegularExpressionValidator
                                                                Display="Dynamic" Text="<%$ Resources: Kartris, ContentText_BadEmail %>" ID="valEmail2"
                                                                runat="server" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                                                ControlToValidate="txtEmail" CssClass="error" ForeColor="" ValidationGroup="ReviewForm"></asp:RegularExpressionValidator></span></li>
                                            <li><span class="Kartris-DetailsView-Name"></span><span class="Kartris-DetailsView-Value">
                                                <asp:UpdatePanel ID="updAddReview" runat="server" UpdateMode="Conditional" RenderMode="Inline">
                                                    <ContentTemplate>
                                                        <asp:Button ID="btnAddReview" runat="server" ValidationGroup="ReviewForm" CssClass="button"
                                                            Text="<%$ Resources:Kartris, FormButton_Submit %>" />
                                                        <ajaxToolkit:NoBot ID="ajaxNoBotReview" runat="server" 
                                                        ResponseMinimumDelaySeconds="2"
                                                        CutoffWindowSeconds="60"
                                                        CutoffMaximumInstances="5" />
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>
                                            </span></li>
                                        </ul>
                                    </div>
                                </div>
                            </asp:Panel>
                            <user:PopupMessage ID="popReviewErrors" runat="server" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </asp:View>
            <asp:View ID="viwWritingResult" runat="server">
                <div class="addreview inputform">
                    <asp:Literal ID="litResult" runat="server"></asp:Literal>
                    <asp:Button Visible="false" CssClass="button" classID="BtnBack" runat="server" Text="<%$ Resources:Kartris, ContentText_GoBack  %>"
                        OnClick="BtnBack_Click" />
                </div>
            </asp:View>
        </asp:MultiView>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="prgReviewMain" runat="server" AssociatedUpdatePanelID="updReviewMain">
    <ProgressTemplate>
        <div class="loadingimage">
        </div>
        <div class="updateprogress">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
