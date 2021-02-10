<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Install.aspx.vb" Inherits="Admin_Install"
    UICulture="auto:en-GB" Culture="auto:en-GB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server" enableviewstate="False">
    <link rel="icon" href="../favicon.ico" type="image/x-icon" />
    <link rel="shortcut icon" href="../favicon.ico" type="image/x-icon" />
    <link href='http://fonts.googleapis.com/css?family=Open+Sans:300' rel='stylesheet' type='text/css' />
    <link rel='stylesheet' type='text/css' href='https://tome.host/bundles/embed-css' />
    <title>
        <asp:Literal runat="server" ID="PageTitle" meta:resourcekey="PageTitle" /></title>

    <script language="javascript" type="text/javascript">
        /* Hide new database 'this will take some time' alert */
        function hideAlert() {
            document.getElementById('delaywarning').style.display = 'none';
        }
        /* Show new database 'this will take some time' alert */
        function showAlert() {
            document.getElementById('delaywarning').style.display = 'block';
        }
        /* Check URL is install.aspx, otherwise we redirect */
        /* This prevents CSS image issues due to path */
        var url = location.href.toLowerCase()
        if (url.indexOf("admin/install.aspx") != -1) {
            /* nothing */
        }
        else {
            /* redirect */
            location.replace("Admin/Install.aspx")
        }

    </script>

    <style type="text/css">
        html {
            height: 100%;
            background-color: #fff;
        }

        body {
            font-family: Segoe UI,Arial,Helvetica,Sans-Serif;
            font-size: 13px;
            font-weight: normal;
            color: #333;
            padding: 0;
            margin: 0;
            overflow: auto;
            height: 100%;
        }

        h2 {
            font-family: Segoe UI,Tahoma,Arial,Sans-Serif;
            font-weight: lighter;
            font-size: 210%;
            color: #000;
            margin: 20px 0 10px 0;
            display: inline-block;
        }

        #wizInstallation {
        }

        #container {
            background-image: url(../Skins/Admin/Images/kartris_square.png);
            background-position: 0 160px;
            background-repeat: no-repeat;
            display: block;
            margin: 0 auto;
            width: 500px;
            padding: 0 0 0 120px;
            height: auto;
            min-height: 100%;
        }

        form {
            width: 100%;
            min-height: 100%;

        }

        .summarydetails {
            background-color: #777;
            color: #fff;
            padding: 3px 10px 3px 10px;
        }

            .summarydetails div.formrow {
                padding: 0 0 10px 0
            }

        div.sidebar {
            display: block;
            z-index: 10;
            height: 32px;
            top: 80px;
            margin: 0px -33px 0px 0px;
            padding: 100px 30px 0 0;
            width: auto;
        }

        div.step {
            padding: 0;
            width: 500px;
        }

        #stepshield {
            height: 36px;
            display: block;
            width: 310px;
            margin: 97px 0 0 0;
            padding: 0;
            z-index: 1000;
            position: absolute;
            background-color: #000;
            z-index: 1000;
            filter: alpha(opacity=0);
            opacity: 0.0;
        }

        div.nav {
            margin: 0;
            padding: 30px 0 0 0;
            z-index: 2;
        }

            div.nav input,
            input.button {
                cursor: pointer;
                background-color: #eee;
                border: solid 1px #333;
                color: #000;
                padding: 2px 6px 2px 6px;
                font-weight: normal;
                font-size: 11px;
                margin: 1px 0px 1px 2px;
                width: auto;
                display: inline-block;
            }

                div.nav input:focus,
                input.button:focus {
                    background-color: #ccc;
                    color: #666;
                }

                div.nav input:hover {
                    background-color: #f6f6f6
                }

        .sidebar a {
            border: solid 1px #5d4;
            display: block;
            padding: 2px 8px 2px 8px;
            font-weight: normal;
            font-size: 13pt;
            color: #fff;
            background-color: #5d4;
            float: left;
            margin: 0 3px 0 0;
            text-decoration: none;
        }

        a.active {
            border: solid 1px #000;
            color: #000;
            background-color: #fff;
            font-weight: bold;
        }

        p {
            padding: 5px 0 15px 0;
            margin: 0;
        }

        label {
            font-size: 85%;
            text-transform: uppercase;
            font-weight: normal;
            color: #888;
            letter-spacing: 1px;
            width: 120px;
            display: inline-block;
        }

        span.checkbox input {
            margin-left: 120px
        }

        span.checkbox label {
            width: 300px
        }

        span.checkbox2 input {
            margin-left: 0px
        }

        span.checkbox2 label {
            width: 320px;
            padding: 0 0 5px 0;
        }

        span.checkbox input,
        span.radio input {
            border-style: none;
            background-color: transparent;
            display: inline;
            width: 20px;
            float: left;
            width: 20px;
            margin-right: 1px;
        }

        span.checkbox2 input {
            border-style: none;
            background-color: transparent;
            display: inline;
            width: 20px;
            float: left;
            width: 20px;
            margin-right: 1px;
        }

        div.formrow {
            padding: 2px 0 5px 0
        }

        div.spacer {
            clear: both
        }

        div.errormessage {
            background-color: #fcc;
            color: #d00;
            padding: 3px 10px 3px 10px;
            margin: 5px 0 10px 0;
            font-weight: normal;
        }

        div.warnmessage {
            border: solid 1px #f50;
            color: #f50;
            padding: 3px 10px 3px 10px;
            margin: 5px 0 10px 0;
            font-weight: normal;
            margin-left: 125px;
        }

        div.infomessage {
            background-color: #777;
            color: #fff;
            padding: 3px 10px 3px 10px;
            margin: 10px 0 10px 3px;
            font-weight: normal;
        }

        span.error {
            display: inline-block;
            color: #fff;
            font-weight: bold;
            padding: 1px 5px 1px 3px;
            text-decoration: blink;
            background-color: #c00;
            margin-left: 3px;
            border-radius: 3px;
        }

        select,
        input,
        textarea {
            font-weight: normal;
            font-size: inherit;
            color: #444;
            background-color: #f5f5f5;
            border: solid 1px #999;
            margin: 0 0 3px 0;
            width: 270px;
            padding: 1px;
        }

            select:focus,
            input:focus,
            textarea:focus {
                font-weight: normal;
                color: #000;
                background-color: #fff;
                border: solid 1px #c05;
                margin-bottom: 3px;
            }

        div.helplink {
        }

        a.tomeButtonLink {
            margin: -29px 0 0 0;
            float: right;
        }

        /*
==========================================
PROGRESS LOADING
==========================================
*/
        #loader {
            position: absolute;
            left: 50%;
            top: 30%;
            z-index: 995;
            width: 50px;
            height: 50px;
            margin: -25px 0 0 -25px;
            border: 5px solid #ddd;
            border-radius: 50%;
            border-top: 6px solid #000;
            -webkit-animation: spin 0.3s linear infinite;
            animation: spin 0.3s linear infinite;
        }

        #dimscreen {
            height: 100%;
            width: 100%;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            z-index: 990;
            background-color: rgba(255,255,255,0.8);
        }

        @-webkit-keyframes spin {
            0% {
                -webkit-transform: rotate(0deg);
            }

            100% {
                -webkit-transform: rotate(360deg);
            }
        }

        @keyframes spin {
            0% {
                transform: rotate(0deg);
            }

            100% {
                transform: rotate(360deg);
            }
        }
    </style>
</head>
<body>

        <form id="frmInstallation" runat="server">
            <div id="container">
            <asp:UpdatePanel ID="updTotal" runat="server">
                <ContentTemplate>
                    <ajaxToolkit:ToolkitScriptManager ID="scrManager" runat="server" ScriptMode="Release"
                        EnableHistory="true" EnableSecureHistoryState="false" EnablePageMethods="True"
                        CombineScripts="true" EnableViewState="True">
                        <Scripts>
                        </Scripts>
                    </ajaxToolkit:ToolkitScriptManager>


                    <asp:DropDownList ID="ddlLanguage" runat="server" OnSelectedIndexChanged="ddlLanguage_SelectedIndexChanged"
                        AutoPostBack="True" Visible="false">
                    </asp:DropDownList>
                    <div id="stepshield">&nbsp;</div>
                    <asp:Wizard ID="wizInstallation" runat="server" ActiveStepIndex="0">
                        <WizardSteps>
                            <asp:WizardStep ID="ws1_Welcome" runat="server" Title="1" StepType="Start">
                                <!-- -------- STEP 1 - WELCOME TO KARTRIS  -------- -->
                                <h2>
                                    <asp:Literal runat="server" ID="Step1_Header" meta:resourcekey="Step1_Header" /></h2>

                                <p>
                                    <asp:Literal ID="Step1_WelcomeMessage" runat="server" meta:resourcekey="Step1_WelcomeMessage"></asp:Literal>
                                </p>
                                <p>
                                    <asp:Literal ID="Step1_IntroMessage" runat="server" meta:resourcekey="Step1_IntroMessage"></asp:Literal>
                                </p>

                                <!-- -------- // STEP 1 - WELCOME TO KARTRIS -------- -->
                            </asp:WizardStep>
                            <asp:WizardStep ID="ws2_HashandMachineKey" runat="server" Title="2" StepType="Step">
                                <!-- -------- STEP 2 - HASH SALT KEY CHECK -------- -->
                                <div class="helplink">
                                    <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=14149')">?</a>
                                </div>
                                <h2>
                                    <asp:Literal runat="server" ID="Step2_Header" meta:resourcekey="Step2_Header" /></h2>
                                <p>
                                    <asp:Literal ID="litHashDesc" runat="server" Text="<%$ Resources: Step2_litHashDesc_Text %>" />
                                </p>
                                <asp:TextBox ID="txtHashKey" runat="server"></asp:TextBox>
                                <!-- -------- // STEP 2 - HASH SALT KEY CHECK -------- -->
                            </asp:WizardStep>
                            <asp:WizardStep ID="ws3_ConnectionString" runat="server" Title="3" StepType="Step">
                                <!-- -------- STEP 3 - CONNECTION STRING CHECK -------- -->
                                <div class="helplink">
                                    <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=14150')">?</a>
                                </div>
                                <h2>
                                    <asp:Literal runat="server" ID="Step3_Header" meta:resourcekey="Step3_Header" /></h2>
                                <asp:PlaceHolder ID="phdConnectionChecking" runat="server">
                                    <h4>
                                        <asp:Literal runat="server" ID="Step3_CheckingConnection" meta:resourcekey="Step3_CheckingConnection" /></h4>
                                    <p>
                                        <asp:Literal runat="server" ID="Step3_ConnectionString" meta:resourcekey="Step3_ConnectionStringFound" />
                                        <div class="summarydetails">
                                            <asp:Literal runat="server" ID="litConnectionString" />
                                        </div>
                                        <p>
                                            <asp:Button ID="btnUseSavedConnection" runat="server" meta:resourcekey="Step3_UseThisConnection"
                                                CausesValidation="false" CssClass="button" Visible="false" />
                                        </p>
                                    </p>
                                </asp:PlaceHolder>
                                <asp:MultiView ID="mvwConnectionString" runat="server">
                                    <asp:View ID="viwSuccess" runat="server">
                                        <p>
                                            <asp:Literal runat="server" ID="Step3_Success" meta:resourcekey="Step3_Success" />
                                        </p>
                                    </asp:View>
                                    <asp:View ID="viwCannotConnect" runat="server">
                                        <asp:PlaceHolder ID="phdRetryCheckButton" runat="server">
                                            <p>
                                                <asp:Button ID="btnRetryCheck" runat="server" meta:resourcekey="Retry" CausesValidation="false"
                                                    CssClass="button" />
                                            </p>
                                        </asp:PlaceHolder>
                                        <h4>
                                            <asp:Literal runat="server" ID="Step3_EnterDetails" meta:resourcekey="Step3_EnterDetails" /></h4>

                                        <p>
                                            <asp:Literal runat="server" ID="Step3_Help" meta:resourcekey="Step3_Help" />
                                        </p>
                                        <div class="formrow">
                                            <asp:Label ID="Step3_ServerName" runat="server" meta:resourcekey="Step3_ServerName"
                                                AssociatedControlID="txtServerName"></asp:Label>
                                            <asp:TextBox ID="txtServerName" runat="server"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="valServerName" ForeColor="" CssClass="error" runat="server"
                                                ControlToValidate="txtServerName" ErrorMessage="<%$ Resources: Error_RequiredField %>"></asp:RequiredFieldValidator>
                                        </div>
                                        <div class="spacer">
                                        </div>
                                        <div class="formrow">
                                            <span class="checkbox">
                                                <asp:CheckBox ID="chkUseWindowsAuthentication" runat="server" AutoPostBack="True"
                                                    Text="<%$ Resources: Step3_UseWindowsAuthentication%>" />
                                            </span>
                                        </div>
                                        <div class="spacer">
                                        </div>
                                        <div class="formrow">
                                            <asp:Label ID="Step3_Username" runat="server" meta:resourcekey="Username" AssociatedControlID="txtUsername"></asp:Label>
                                            <asp:TextBox ID="txtUsername" runat="server"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="valUsername" ForeColor="" CssClass="error" runat="server"
                                                ControlToValidate="txtUsername" ErrorMessage="<%$ Resources: Error_RequiredField %>"></asp:RequiredFieldValidator>
                                        </div>
                                        <div class="spacer">
                                        </div>
                                        <div class="formrow">
                                            <asp:Label ID="Step3_Password" runat="server" meta:resourcekey="Password" AssociatedControlID="txtPassword"></asp:Label>
                                            <asp:TextBox ID="txtPassword" runat="server"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="valPassword" ForeColor="" CssClass="error" runat="server"
                                                ControlToValidate="txtPassword" ErrorMessage="<%$ Resources: Error_RequiredField %>"></asp:RequiredFieldValidator>
                                        </div>
                                        <div class="spacer">
                                        </div>
                                        <div class="formrow">
                                            <span class="checkbox">
                                                <asp:RadioButton ID="rbnUseExistingDB" onClick="hideAlert()" runat="server" meta:resourcekey="Step3_UseExistingDB"
                                                    GroupName="database_status" Checked="true" />
                                            </span>
                                        </div>
                                        <div class="spacer">
                                        </div>
                                        <div class="formrow">
                                            <span class="checkbox">
                                                <asp:RadioButton ID="rbnCreateDB" onClick="showAlert()" runat="server" meta:resourcekey="Step3_CreateNewDB"
                                                    GroupName="database_status" />
                                            </span>
                                        </div>
                                        <div class="spacer">
                                        </div>
                                        <div class="warnmessage" style="display: none;" id="delaywarning">
                                            <asp:Literal runat="server" ID="litTimeDelayWarning" meta:resourcekey="Step3_TimeDelay" />
                                        </div>
                                        <div class="spacer">
                                        </div>
                                        <div class="formrow">
                                            <asp:Label ID="Step3_DatabaseName" runat="server" meta:resourcekey="Step3_DatabaseName"
                                                AssociatedControlID="txtDatabaseName"></asp:Label>
                                            <asp:TextBox ID="txtDatabaseName" runat="server"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="valDatabaseName" ForeColor="" CssClass="error" runat="server"
                                                ControlToValidate="txtDatabaseName" ErrorMessage="<%$ Resources: Error_RequiredField %>"></asp:RequiredFieldValidator>
                                        </div>
                                        <div class="spacer">
                                        </div>
                                        <div class="spacer">
                                        </div>
                                    </asp:View>
                                </asp:MultiView>
                                <div class="formrow">
                                    <span class="checkbox">
                                        <asp:CheckBox ID="chkCreateSampleData" runat="server" meta:resourcekey="Step3_CreateSampleData" />
                                    </span>
                                </div>
                                <!-- -------- // STEP 3 - CONNECTION STRING CHECK -------- -->
                            </asp:WizardStep>
                            <asp:WizardStep runat="server" Title="4" ID="ws4_SetUpDatabase">
                                <!-- -------- STEP 4 - DATABASE STRUCTURE CHECK -------- -->
                                <div class="helplink">
                                    <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=14155')">?</a>
                                </div>
                                <h2>
                                    <asp:Literal runat="server" ID="Step4_Header" meta:resourcekey="Step4_Header" /></h2>
                                <h4>
                                    <asp:Literal runat="server" ID="Step4_ConnectionSuccessful" meta:resourcekey="Step4_ConnectionSuccessful" /></h4>
                                <asp:MultiView ID="mvwSetUpDatabase" runat="server">
                                    <asp:View ID="viwDatabaseAlreadySetUp" runat="server">
                                        <p>
                                            <asp:Literal runat="server" ID="Step4_DatabaseAlreadyContains" meta:resourcekey="Step4_DatabaseAlreadyContains" />
                                        </p>
                                    </asp:View>
                                    <asp:View ID="viwBlankDatabase" runat="server">
                                        <p>
                                            <asp:Literal runat="server" ID="Step4_DatabaseSetupSuccess" meta:resourcekey="Step4_DatabaseSetupSuccess" />
                                        </p>
                                        <p>
                                            <asp:Literal runat="server" ID="Step4_DatabaseNowReady" meta:resourcekey="Step4_DatabaseNowReady" />
                                        </p>
                                    </asp:View>
                                    <asp:View ID="viwDatabaseCreationFailure" runat="server">
                                    </asp:View>
                                </asp:MultiView>
                                <p>
                                    <asp:Literal runat="server" ID="Step4_AccountGenerated" meta:resourcekey="Step4_AccountGenerated" />
                                </p>
                                <div class="formrow">
                                    <asp:Label ID="Step4_Username" runat="server" meta:resourcekey="Username" AssociatedControlID="Username"></asp:Label>
                                    <strong>
                                        <asp:Literal runat="server" ID="Username" Text="Admin" /></strong>
                                </div>
                                <div class="formrow">
                                    <asp:Label ID="Step4_Password" runat="server" meta:resourcekey="Password" AssociatedControlID="litBackendPassword"></asp:Label>
                                    <strong>
                                        <asp:Literal runat="server" ID="litBackendPassword" /></strong>
                                </div>
                                <!-- -------- // STEP 4 - DATABASE STRUCTURE CHECK -------- -->
                            </asp:WizardStep>
                            <asp:WizardStep ID="ws5_ConfigSettings" runat="server" Title="5">
                                <!-- -------- STEP 5 - IMPORTANT CONFIG SETTINGS -------- -->
                                <div class="helplink">
                                    <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=14156')">?</a>
                                </div>
                                <h2>
                                    <asp:Literal runat="server" ID="Step5_Header" meta:resourcekey="Step5_Header" /></h2>
                                <asp:PlaceHolder runat="server" ID="phdConfigSettings"></asp:PlaceHolder>

                                <p>
                                    <asp:Label runat="server" ID="lblTaxRegime" Text="<%$ Resources: Step5_TaxRegime_Text %>" Font-Bold="true" />
                                    <asp:DropDownList runat="server" ID="ddlTaxRegime" Width="200">
                                        <asp:ListItem Text="-" Value="" Selected="True" />
                                        <asp:ListItem Value="European Union" />
                                        <asp:ListItem Value="VAT (non EU)" />
                                        <asp:ListItem Value="US" />
                                        <asp:ListItem Value="Canada" />                                
                                        <asp:ListItem Value="Other" />
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="valTaxRegime" ForeColor="" CssClass="error" runat="server"
                                        ControlToValidate="ddlTaxRegime"
                                        ErrorMessage="<%$ Resources: Error_RequiredField %>"></asp:RequiredFieldValidator>
                                    <br />
                                    <asp:Literal ID="litTaxRegimeDesc" runat="server" Text="<%$ Resources: Step5_litTaxRegimeDesc_Text %>" />
                                </p>

                                <p>
                                    <asp:Label runat="server" ID="lblDefaultCurrency" Text="<%$ Resources: Step5_DefaultCurrency_Text %>" Font-Bold="true" />
                                    <asp:DropDownList runat="server" ID="ddlDefaultCurrency" Width="200">
                                        <asp:ListItem Text="-" Value="" Selected="True" />
                                        <asp:ListItem Text="Australian Dollar ($)" Value="6" />
                                        <asp:ListItem Text="Bitcoin (฿)" Value="15" />
                                        <asp:ListItem Text="Brazilian Real (R$)" Value="13" />
                                        <asp:ListItem Text="British Pounds (£)" Value="1" />
                                        <asp:ListItem Text="Canadian Dollar ($)" Value="7" />
                                        <asp:ListItem Text="Euros (€)" Value="3" />
                                        <asp:ListItem Text="Hong Kong Dollar ($)" Value="10" />
                                        <asp:ListItem Text="Indian Rupee (Rs)" Value="11" />
                                        <asp:ListItem Text="Japanese Yen (¥)" Value="4" />
                                        <asp:ListItem Text="Russian Rouble (py6)" Value="12" />
                                        <asp:ListItem Text="Singapore Dollar ($)" Value="14" />
                                        <asp:ListItem Text="Swiss Franc (SFr)" Value="5" />
                                        <asp:ListItem Text="US Dollars ($)" Value="2" />
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="valDefaultCurrency" ForeColor="" CssClass="error" runat="server"
                                        ControlToValidate="ddlDefaultCurrency"
                                        ErrorMessage="<%$ Resources: Error_RequiredField %>"></asp:RequiredFieldValidator>
                                    <br />
                                    <asp:Literal ID="litDefaultCurrencyDesc" runat="server" Text="<%$ Resources: Step5_litDefaultCurrencyDesc_Text %>" />
                                </p>

                                <!-- -------- // STEP 5 - IMPORTANT CONFIG SETTINGS -------- -->
                            </asp:WizardStep>
                            <asp:WizardStep ID="ws6_FolderPermissions" runat="server" Title="6">
                                <!-- -------- STEP 6 - FOLDER PERMISSIONS CHECK-------- -->
                                <div class="helplink">
                                    <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=14163')">?</a>
                                </div>
                                <h2>
                                    <asp:Literal runat="server" ID="Step6_Header" meta:resourcekey="Step6_Header" /></h2>
                                <p>
                                    <asp:Literal runat="server" ID="Step6_TestingImages" meta:resourcekey="Step6_TestingImages" />
                                    <asp:Literal runat="server" ID="litImagesStatus"></asp:Literal>
                                </p>
                                <p>
                                    <asp:Literal runat="server" ID="Step6_TestingUploads" meta:resourcekey="Step6_TestingUploads" />
                                    <asp:Literal runat="server" ID="litUploadsStatus"></asp:Literal>
                                </p>
                                <p>
                                    <asp:Literal runat="server" ID="Step7_TestingPayment" meta:resourcekey="Step6_TestingPayment" />
                                    <asp:Literal runat="server" ID="litPaymentStatus"></asp:Literal>
                                </p>
                                <asp:Button ID="btnRetryTests" runat="server" CssClass="button" Text="<%$ Resources: Step6_RetryTests %>" />
                                <!-- -------- // STEP 6 - FOLDER PERMISSIONS CHECK-------- -->
                            </asp:WizardStep>
                            <asp:WizardStep ID="ws7_ReviewSettings" runat="server" StepType="Finish" Title="7">
                                <!-- -------- STEP 7 - REVIEW SETTINGS -------- -->
                                <div class="helplink">
                                    <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=14164')">?</a>
                                </div>
                                <h2>
                                    <asp:Literal runat="server" ID="Step7_Header" meta:resourcekey="Step7_Header" /></h2>
                                <p>
                                    <asp:Literal ID="litReviewSettingsDesc" runat="server" Text="<%$ Resources: Step7_ReviewSettingsDesc %>"></asp:Literal>
                                </p>
                                <br />
                                <div class="summarydetails">
                                    <asp:PlaceHolder runat="server" ID="phdConnectionString">
                                        <div class="formrow">
                                            <asp:Literal runat="server" ID="Step7_ConnectionString" meta:resourcekey="ConnectionString" />
                                            <asp:Literal ID="litReviewConnectionString" runat="server" Mode="Encode"></asp:Literal>
                                        </div>
                                        <div class="spacer">
                                        </div>
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder runat="server" ID="phdHashSaltKey">
                                        <div class="formrow">
                                            <asp:Literal runat="server" ID="Step7_HashSaltKey" meta:resourcekey="Step7_HashSaltKey" />
                                            <asp:Literal ID="litReviewHashSaltKey" runat="server" Mode="Encode"></asp:Literal>
                                        </div>
                                        <div class="spacer">
                                        </div>
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder runat="server" ID="phdTaxRegime">
                                        <div class="formrow">
                                            <asp:Literal runat="server" ID="Step7_TaxRegime" meta:resourcekey="Step7_TaxRegime" />
                                            <asp:Literal ID="litReviewTaxRegime" runat="server" Mode="Encode"></asp:Literal>
                                        </div>
                                        <div class="spacer">
                                        </div>
                                    </asp:PlaceHolder>
                                </div>
                                <asp:Literal ID="litReason" runat="server"></asp:Literal>
                                <!-- -------- // STEP 7 - REVIEW SETTINGS -------- -->
                            </asp:WizardStep>
                            <asp:WizardStep ID="ws7_SetupComplete" runat="server" StepType="Complete" Title="8">
                                <!-- -------- STEP 8 - SETUP COMPLETE -------- -->
                                <div class="helplink">
                                    <a class="tomeButtonLink" onclick="launchTomeHelp('https://kartris.tome.host/Content/Print/0?headId=14165')">?</a>
                                </div>
                                <h2>
                                    <asp:Literal runat="server" ID="Step8_Header" meta:resourcekey="Step8_Header" /></h2>
                                <h4>
                                    <asp:Literal runat="server" ID="Step8_Congratulations" meta:resourcekey="Step8_Congratulations" /></h4>
                                <p>
                                    <asp:Literal ID="litReminder" runat="server" Text="<%$ Resources: Step8_ReminderToUploadNewWebConfig %>"></asp:Literal>
                                </p>
                                <p>
                                    <a href="_TaxSetupWizard.aspx" target="_new">
                                        <asp:Literal runat="server" ID="Step8_YouCanLoginBackend" meta:resourcekey="Step8_YouCanLoginBackend" /></a>
                                </p>
                                <p>
                                    <a href="../Default.aspx" target="_new">
                                        <asp:Literal runat="server" ID="Step8_ViewFrontEnd" meta:resourcekey="Step8_ViewFrontEnd" /></a>
                                </p>
                                <iframe src="http://www.kartris.com/MailChimpForm_Install.html"
                                    style="width: 100%; height: 200px; border: none; border-top: solid 3px #ccc; margin-top: 20px;"></iframe>

                                <!-- -------- // STEP 8 - SETUP COMPLETE -------- -->
                            </asp:WizardStep>
                        </WizardSteps>
                        <SideBarStyle Width="200px" />
                    </asp:Wizard>
                    <asp:PlaceHolder ID="phdError" runat="server" Visible="false">
                        <div class="errormessage">
                            <strong>Error:</strong>
                            <asp:Literal ID="litError" runat="server" Text=""></asp:Literal>
                        </div>
                    </asp:PlaceHolder>
                    <br />
                    <asp:Button runat="server" Text="<%$ Resources: Step8_DownloadWebConfigButtonText %>"
                        ID="btnSaveCopy" Visible="false" CssClass="button"></asp:Button>
                    <asp:PlaceHolder ID="phdNote" runat="server">
                        <div class="infomessage">
                            <asp:Label ID="lblNote" runat="server" Text="<%$ Resources: CannotUpdateWebConfigNote %>"></asp:Label>
                        </div>
                    </asp:PlaceHolder>


                </ContentTemplate>
            </asp:UpdatePanel></div>
        <asp:UpdateProgress ID="updProgress" runat="server">
            <ProgressTemplate>
                <div id="dimscreen">
                </div>
                <div id="loader"></div>
            </ProgressTemplate>
        </asp:UpdateProgress>

        </form>


    <script type="text/javascript" async src='https://tome.host/bundles/embed-js'></script>
</body>
</html>
