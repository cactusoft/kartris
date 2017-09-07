<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_ItemSorter.ascx.vb"
    Inherits="_ItemSorter" %>

<asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <div id="column_sorter_left">
            <ajaxToolkit:ReorderList ID="ajxReorder" runat="server" PostBackOnReorder="true"
                CallbackCssStyle="callbackStyle" ItemInsertLocation="Beginning" SortOrderField="No"
                LayoutType="User">
                <ItemTemplate>
                    
                <div class="placeholder_sorter">
                    <asp:Literal ID="litNo" runat="server" Text='<%# Bind("No") %>' Visible="false"></asp:Literal>
                    
                    <asp:Literal ID="litImgName" runat="server" Text='<%# Bind("ImageName") %>' Visible="false"></asp:Literal>
                </div>
                </ItemTemplate>
            </ajaxToolkit:ReorderList>
        </div>
        <div id="column_sorter_right">
            <asp:Repeater ID="rptImages" runat="server">
                <ItemTemplate>
                    <div class="placeholder_sorter">
                        <div class="updownbuttons">
                                <asp:LinkButton ID="lnkBtnMoveUp" runat="server" CommandName="MoveUp" Text="+" CssClass="triggerswitch triggerswitch_on" />
                                <asp:LinkButton ID="lnkBtnMoveDown" runat="server" CommandName="MoveDown" Text="-"
                                CssClass="triggerswitch triggerswitch_off" />
                        </div>
                        <div class="sort_image_holder">
                            <asp:HyperLink runat="server" NavigateURL='<%# Bind("ImageURL") %>' ID="hlnkImage"><img src="../Image.ashx?strFullPath=<asp:Literal ID="litImgName2" runat="server"
                            Text='<%# Bind("ImageURL") %>' />&numMaxHeight=80&numMaxWidth=80&nocache=<% =Now.Hour & Now.Minute & Now.Second%>" /></asp:HyperLink>
                        </div>
                        <div class="sort_details_holder">
                            <asp:Literal ID="litNo" runat="server" Text='<%# Bind("No") %>' Visible="false"></asp:Literal>
                            <asp:Literal ID="litImgName" runat="server" Text='<%# Bind("ImageName") %>'></asp:Literal></br>
                            <asp:Literal ID="litImgModified" runat="server" Text='<%# CkartrisDisplayFunctions.FormatDate(Eval("LastModified"), "t", Session("_LANG")) %>'></asp:Literal></br>
                            <asp:Literal ID="litImgSize" runat="server" Text='<%# Bind("ImageSize") %>'></asp:Literal>
                        </div>
                        <div class="sort_remove_holder">
                            <asp:LinkButton ID="lnkRemove" runat="server"
                            CommandName="Remove" CssClass="linkbutton icon_delete" Text='<%$ Resources: _Kartris, FormButton_Delete %>' />
                        </div>
                        <asp:Literal ID="litImgURL" runat="server" Text='<%# Bind("ImageURL") %>' Visible="false"></asp:Literal>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <div class="spacer">
        </div>
        <asp:ListBox ID="lbxImagesOrder" runat="server" Visible="false"></asp:ListBox>                
    </ContentTemplate>
    <Triggers>
    </Triggers>
</asp:UpdatePanel>

<script type="text/javascript">
    function onYes() {
        var postBack = new Sys.WebForms.PostBackAction();
            postBack.set_target('lnkYes');
            postBack.set_eventArgument('');
            postBack.performAction();
        }
</script>
<asp:UpdatePanel ID="updConfirmationMessage" runat="server" UpdateMode="Conditional">
    <contenttemplate>
        <asp:Panel ID="pnlMessage" runat="server" Style="display: none" CssClass="popup">
            <asp:LinkButton ID="lnkExtenderCancel" runat="server" Text="" CssClass="closebutton" />
            <h2><asp:Literal ID="litTitle" runat="server" Text="Confirmation"/></h2>
            <asp:LinkButton ID="lnkBtn" runat="server"></asp:LinkButton>
            <asp:PlaceHolder ID="phdRemove" runat="server">
                <div>
                    <div class="imageholder">
                        <img src="../Image.ashx?strFullPath=<asp:Literal ID="litImgName3" runat="server"
                            Text='<%# Bind("ImageURL") %>' />&numMaxHeight=120&numMaxWidth=120" />
                        <asp:Image ID="imgToRemove" runat="server" Width="120px" Height="120px" AlternateText="" Visible="False" />
                        
                    <asp:Literal ID="litImageNameToRemove" runat="server" Visible="false"></asp:Literal>
                        
                    </div>
                    <div>
                        <asp:Literal ID="litAreYouSure" runat="server" Text="<%$ Resources: _Kartris, ContentText_ConfirmDeleteItemUnspecified %>" /></div>
                    <asp:LinkButton ID="lnkExtenderOk" runat="server" Text="" CssClass="invisible" />
                    
                    <br />
                    <div>
                        <asp:Button ID="lnkYes" OnClick="lnkYes_Click" runat="server" Text="<%$ Resources: _Kartris, ContentText_Yes %>"
                            CssClass="button" />
                    </div>
                </div>
            </asp:PlaceHolder>
        </asp:Panel>
        <ajaxToolkit:ModalPopUpExtender ID="popExtender" runat="server" TargetControlID="lnkBtn"
            PopupControlID="pnlMessage" OnOkScript="onYes()" BackgroundCssClass="popup_background"
            OkControlID="lnkExtenderOk" CancelControlID="lnkExtenderCancel" DropShadow="False"
            RepositionMode="None">
        </ajaxToolkit:ModalPopUpExtender>
    </contenttemplate>
</asp:UpdatePanel>
<_user:PopupMessage ID="_UC_PopupMsg" runat="server" />
