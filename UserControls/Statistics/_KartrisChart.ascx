<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_KartrisChart.ascx.vb"
    Inherits="UserControls_Back_KartrisChart" %>
<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>
<asp:UpdatePanel ID="updKartChartMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:MultiView ID="mvwCharting" runat="server" ActiveViewIndex="0">
            <asp:View ID="viwChart" runat="server">
                <asp:UpdatePanel ID="updOptions" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:LinkButton ID="btnOptions" runat="server" Text="Options" CssClass="linkbutton icon_edit floatright" />
                    </ContentTemplate>
                </asp:UpdatePanel>
                <div class="chartcontrol">
                    <asp:UpdatePanel ID="updKartChart" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:Chart ID="kartChart" runat="server"
                                EnableViewState="true"
                                BackColor="#EEEEEE">
                                <Series>
                                    <asp:Series Name="chtSeries" ChartArea="chtArea" Font="Tahoma, 7.5pt"
                                    Color="#33BB11" BorderColor="#ffffff" BackGradientStyle="None" LabelBackColor="#CC0077" LabelForeColor="White" LabelBorderColor="#880044">
                                    </asp:Series>
                                </Series>
                                <Legends></Legends>
                                <ChartAreas>
                                    <asp:ChartArea Name="chtArea"
                                        BackGradientStyle="DiagonalRight"
                                        BackColor="#845DEA"
                                        BackSecondaryColor="#CCCFFF" BorderDashStyle="Solid" Area3DStyle-IsRightAngleAxes="True" Area3DStyle-LightStyle="Simplistic">
                                        <AxisY LineColor="#000000" LabelAutoFitMaxFontSize="7" LabelAutoFitMinFontSize="7">
                                            <LabelStyle Font="Tahoma, 7.5pt" ForeColor="#000000" />
                                            <MajorGrid LineColor="#FFFFFF" LineDashStyle="Dot" />
                                            
                                        </AxisY>
                                        <AxisX LineColor="#000000" LabelAutoFitStyle="None" LabelAutoFitMaxFontSize="7" LabelAutoFitMinFontSize="7" TitleFont="Tahoma, 8pt">
                                            <LabelStyle Font="Tahoma, 7.5pt" ForeColor="#000000" Angle="-90" />
                                            <MajorGrid LineColor="#FFFFFF" LineDashStyle="Dot" />
                                        </AxisX>
                                    </asp:ChartArea>
                                </ChartAreas>
                                <Annotations>
                                    <asp:RectangleAnnotation Name="NoDataAnnotation" Text="No data is available" X="25"
                                        Y="15" Width="50" Height="15" Font="Tahoma, 8pt">
                                    </asp:RectangleAnnotation>
                                </Annotations>
                            </asp:Chart>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </asp:View>
            <asp:View ID="viwNoData" runat="server">
                
            </asp:View>
        </asp:MultiView>
        <asp:UpdatePanel ID="updConfirmationMessage" runat="server">
            <ContentTemplate>
                <asp:Panel ID="pnlMessage" runat="server" Style="display: none" CssClass="popup">
                    <h2>
                        <asp:Literal ID="litTitle" runat="server" Text='<%$ Resources: _Kartris, ContentText_Options %>' /></h2>
                    <asp:LinkButton ID="lnkExtenderCancel" runat="server" Text="" CssClass="closebutton linkbutton2" />
                    <asp:LinkButton ID="lnkBtn" runat="server"></asp:LinkButton>
            <asp:PlaceHolder ID="phdContents" runat="server">
                
                <div class="Kartris-DetailsView">
                    <div class="Kartris-DetailsView-Data">
                        <ul>
                            <li><span class="Kartris-DetailsView-Value"><span class="Kartris-DetailsView-Name">
                                <asp:Literal ID="Literal1" runat="server" Text="Chart Type" />
                            </span>
                                <asp:DropDownList ID="ddlChartType" runat="server" CssClass="midtext">
                                </asp:DropDownList>
                            </span></li>
                            <li><span class="Kartris-DetailsView-Value"><span class="Kartris-DetailsView-Name">
                                <asp:Literal ID="Literal2" runat="server" Text="Chart Style" />
                            </span>
                                <asp:DropDownList ID="ddlChartStyle" runat="server" CssClass="midtext">
                                </asp:DropDownList>
                            </span></li>
                            <li><span class="Kartris-DetailsView-Value"><span class="Kartris-DetailsView-Name">
                                <asp:Literal ID="Literal3" runat="server" Text="3D View" />
                            </span>
                                <asp:CheckBox ID="chkEnable3D" runat="server" CssClass="checkbox" /></span></li>
                            <li><span class="Kartris-DetailsView-Value"><span class="Kartris-DetailsView-Name">
                                <asp:Literal ID="Literal4" runat="server" Text="Show Label" />
                            </span>
                                <asp:CheckBox ID="chkShowLabel" runat="server" CssClass="checkbox" /></span></li>
                        </ul>
                    </div>
                </div>
                <asp:LinkButton ID="lnkExtenderOk" runat="server" Text="" CssClass="invisible" />
                <div class="submitbuttons">
                        <asp:Button ID="lnkOk" OnClick="lnkOk_Click" runat="server" Text='<%$ Resources: _Kartris, FormButton_Save %>' CssClass="button" />
                        &nbsp;<asp:Button ID="lnkCancel" runat="server" Text='<%$ Resources: _Kartris, FormButton_Cancel %>'
                            CssClass="button cancelbutton" />
                </div></asp:PlaceHolder>
        </asp:Panel>
        <ajaxToolkit:ModalPopupExtender ID="popExtender" runat="server" TargetControlID="lnkBtn"
            PopupControlID="pnlMessage" OnOkScript="onOk()" BackgroundCssClass="popup_background"
            OkControlID="lnkExtenderOk" CancelControlID="lnkExtenderCancel" DropShadow="False"
            RepositionMode="None">
        </ajaxToolkit:ModalPopupExtender>
    </ContentTemplate>
</asp:UpdatePanel>
    </ContentTemplate>
</asp:UpdatePanel>

<script type="text/javascript">
    function onOk() {
        var postBack = new Sys.WebForms.PostBackAction();
        postBack.set_target('lnkOk');
        postBack.set_eventArgument('');
        postBack.performAction();
    }
</script>

