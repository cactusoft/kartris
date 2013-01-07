Imports System.Web.UI
Imports System.Web.UI.WebControls

'All due credit and kudos to Andrew Tokeley http://andrewtokeley.net/
'for this excellent piece of code

Namespace Kartris
    ''' <summary>
    ''' The wizard adpater will render the standard wizard control using div's rather than tables.
    ''' </summary>
    Public Class WizardAdapter
        Inherits System.Web.UI.WebControls.Adapters.WebControlAdapter
#Region "Member Variables"
        Private _extender As WebControlAdapterExtender = Nothing
        '-- CSS class names for the div's
        Private Const CSS_WIZARD As String = "wizard"
        Private Const CSS_STEP As String = "step"
        Private Const CSS_NAV As String = "nav"
        Private Const CSS_HEADER As String = "header"
        Private Const CSS_SIDEBAR As String = "sidebar"
        Private Const CSS_ACTIVE As String = "active"
        '-- The ID's of the underlying control's containers.  
        Private Const CONTAINERID_FINISHNAVIGATION_TEMPLATE As String = "FinishNavigationTemplateContainerID"
        Private Const CONTAINERID_STARTNAVIGATION_TEMPLATE As String = "StartNavigationTemplateContainerID"
        Private Const CONTAINERID_STEPNAVIGATION_TEMPLATE As String = "StepNavigationTemplateContainerID"
        Private Const CONTAINERID_HEADER As String = "HeaderContainer"
        Private Const CONTAINERID_SIDEBAR As String = "SideBarContainer"
        '-- The ID's of the underlying controls within the containers - the ID's are important as the underlying
        '-- control (I assume) uses these to wire up the event handlers to respond to button clicks etc.
        Private Const CONTROLID_STARTNEXT As String = "StartNext"
        Private Const CONTROLID_STEPPREVIOUS As String = "StepPrevious"
        Private Const CONTROLID_STEPNEXT As String = "StepNext"
        Private Const CONTROLID_FINISHPREVIOUS As String = "FinishPrevious"
        Private Const CONTROLID_FINISH As String = "Finish"
        Private Const CONTROLID_CANCEL As String = "Cancel"
        Private Const CONTROLID_SIDEBARLIST As String = "SideBarList"
        Private Const CONTROLID_SIDEBARBUTTON As String = "SideBarButton"
#End Region

#Region "Constructors"
        Public Sub New()
        End Sub
#End Region

#Region "Private Properties"
        Private ReadOnly Property Extender() As WebControlAdapterExtender
            Get
                If ((_extender Is Nothing) AndAlso (Not Control Is Nothing)) OrElse ((Not _extender Is Nothing) AndAlso (Not Control Is _extender.AdaptedControl)) Then
                    _extender = New WebControlAdapterExtender(Control)
                End If
                System.Diagnostics.Debug.Assert(Not _extender Is Nothing, "CSS Friendly adapters internal error", "Null extender instance")
                Return _extender
            End Get
        End Property
#End Region

#Region "Rendering Overrides"
        Protected Overloads Overrides Sub RenderBeginTag(ByVal writer As HtmlTextWriter)
            If Extender.AdapterEnabled Then
                Extender.RenderBeginTag(writer, CSS_WIZARD)
            Else
                MyBase.RenderBeginTag(writer)
            End If
        End Sub
        Protected Overloads Overrides Sub RenderEndTag(ByVal writer As HtmlTextWriter)
            If Extender.AdapterEnabled Then
                Extender.RenderEndTag(writer)
            Else
                MyBase.RenderEndTag(writer)
            End If
        End Sub
        Protected Overloads Overrides Sub RenderContents(ByVal writer As HtmlTextWriter)
            If Extender.AdapterEnabled Then
                Dim wizard As Wizard = TryCast(Control, Wizard)
                If Not wizard Is Nothing Then
                    '-- Render Side Bar
                    RenderSideBar(writer, wizard)
                    '-- Render Header
                    RenderHeader(writer, wizard)
                    '-- Render WizardStep
                    RenderStep(writer, wizard)
                    '-- If on first page of wizard
                    If wizard.ActiveStepIndex = 0 Then
                        RenderStartNavigation(writer, wizard)
                    ElseIf wizard.ActiveStepIndex < (wizard.WizardSteps.Count - 2) Then
                        RenderStepNavigation(writer, wizard)
                    ElseIf wizard.ActiveStepIndex = wizard.WizardSteps.Count - 2 Then
                        RenderFinishNavigation(writer, wizard)
                    Else
                        '-- Yikes
                        ' its ok...this must be the complete step...no navigation buttons here
                    End If
                End If
            Else
                '-- Use the default rendering of the control
                MyBase.RenderContents(writer)
            End If
        End Sub
#End Region

#Region "Private Rendering Methods"
        Private Sub RenderFinishNavigation(ByVal writer As HtmlTextWriter, ByVal wizard As Wizard)
            RenderNavigation(writer, wizard, CONTAINERID_FINISHNAVIGATION_TEMPLATE, wizard.FinishNavigationTemplate)
        End Sub
        Private Sub RenderStartNavigation(ByVal writer As HtmlTextWriter, ByVal wizard As Wizard)
            RenderNavigation(writer, wizard, CONTAINERID_STARTNAVIGATION_TEMPLATE, wizard.StartNavigationTemplate)
        End Sub
        Private Sub RenderStepNavigation(ByVal writer As HtmlTextWriter, ByVal wizard As Wizard)
            If TypeOf wizard.ActiveStep Is TemplatedWizardStep Then
                RenderNavigation(writer, wizard, CONTAINERID_STEPNAVIGATION_TEMPLATE, (DirectCast(wizard.ActiveStep, TemplatedWizardStep)).CustomNavigationTemplate)
            Else
                RenderNavigation(writer, wizard, CONTAINERID_STEPNAVIGATION_TEMPLATE, wizard.StepNavigationTemplate)
            End If
        End Sub
        Private Sub RenderNavigation(ByVal writer As HtmlTextWriter, ByVal wizard As Wizard, ByVal containerID As String, ByVal template As ITemplate)
            '-- Locate the name of the underlying container that will host the step navigation controls
            '-- You just have to know this name - it is used by the underyling Wizard control
            Dim container As Control = wizard.FindControl(containerID)
            '-- Check the container exists - academic it will always exist 
            If Not container Is Nothing Then
                '-- Start the step navigation with a DIV
                WebControlAdapterExtender.WriteBeginDiv(writer, CSS_NAV, "")
                '-- If a Template has been defined then use this
                If Not template Is Nothing Then
                    template.InstantiateIn(container)
                    container.RenderControl(writer)
                ElseIf Not (TypeOf wizard.ActiveStep Is TemplatedWizardStep) Then
                    Select Case containerID
                        Case CONTAINERID_STARTNAVIGATION_TEMPLATE
                            '-- Only display Next and (optionally) Cancel
                            RenderSubmit(writer, wizard, container, wizard.StartNextButtonStyle, wizard.StartNextButtonImageUrl, wizard.StartNextButtonText, wizard.StartNextButtonType, CONTROLID_STARTNEXT)
                            If wizard.DisplayCancelButton Then
                                RenderSubmit(writer, wizard, container, wizard.CancelButtonStyle, wizard.CancelButtonImageUrl, wizard.CancelButtonText, wizard.CancelButtonType, CONTROLID_CANCEL)
                            End If
                            Exit Select
                        Case CONTAINERID_STEPNAVIGATION_TEMPLATE
                            '-- Display Previous (if AllowReturn true in previous step), Next and (optionally) Cancel
                            If wizard.WizardSteps(wizard.ActiveStepIndex - 1).AllowReturn Then
                                RenderSubmit(writer, wizard, container, wizard.StepPreviousButtonStyle, wizard.StepPreviousButtonImageUrl, wizard.StepPreviousButtonText, wizard.StepPreviousButtonType, CONTROLID_STEPPREVIOUS)
                            End If
                            RenderSubmit(writer, wizard, container, wizard.StepNextButtonStyle, wizard.StepNextButtonImageUrl, wizard.StepNextButtonText, wizard.StepNextButtonType, CONTROLID_STEPNEXT)
                            If wizard.DisplayCancelButton Then
                                RenderSubmit(writer, wizard, container, wizard.CancelButtonStyle, wizard.CancelButtonImageUrl, wizard.CancelButtonText, wizard.CancelButtonType, CONTROLID_CANCEL)
                            End If
                            Exit Select
                        Case CONTAINERID_FINISHNAVIGATION_TEMPLATE
                            '-- Display Previous, Complete and (optionally) Cancel
                            RenderSubmit(writer, wizard, container, wizard.FinishPreviousButtonStyle, wizard.FinishPreviousButtonImageUrl, wizard.FinishPreviousButtonText, wizard.FinishPreviousButtonType, CONTROLID_FINISHPREVIOUS)
                            RenderSubmit(writer, wizard, container, wizard.FinishCompleteButtonStyle, wizard.FinishCompleteButtonImageUrl, wizard.FinishCompleteButtonText, wizard.FinishCompleteButtonType, CONTROLID_FINISH)
                            If wizard.DisplayCancelButton Then
                                RenderSubmit(writer, wizard, container, wizard.CancelButtonStyle, wizard.CancelButtonImageUrl, wizard.CancelButtonText, wizard.CancelButtonType, CONTROLID_CANCEL)
                            End If
                            Exit Select
                        Case Else
                            Exit Select
                    End Select
                End If
            End If
            WebControlAdapterExtender.WriteEndDiv(writer)
        End Sub
        Private Sub RenderSubmit(ByVal writer As HtmlTextWriter, ByVal wizard As Wizard, ByVal container As Control, ByVal buttonStyle As Style, ByVal buttonImageUrl As String, ByVal buttonText As String, _
         ByVal buttonType As ButtonType, ByVal submitControlRootName As String)
            '-- Locate the corresponding control placeholder that the Wizard has defined within it's base 
            '-- Control heirarchy. For example, StepNextButton.
            Dim idWithType As String = WebControlAdapterExtender.MakeIdWithButtonType(submitControlRootName, buttonType)
            Dim btn As Control = container.FindControl(idWithType)
            Dim id As String = container.ID + "_" + submitControlRootName
            '-- Will only be null if the submitControlRootName value was passed in. 
            If Not btn Is Nothing Then
                '-- Register the id of the button placeholder so that we can raise postback events
                Page.ClientScript.RegisterForEventValidation(btn.UniqueID)
                '-- Only use client side (javascript based) submits for Links
                Dim clientSubmit As Boolean = True '*** (buttonType = buttonType.Link)
                Dim javascript As String = ""
                If clientSubmit Then
                    Dim options As New PostBackOptions(btn, "", "", False, False, False, clientSubmit, True, wizard.ID)
                    javascript = "javascript:" + Page.ClientScript.GetPostBackEventReference(options)
                    javascript = Page.Server.HtmlEncode(javascript)
                End If
                Extender.WriteSubmit(writer, buttonType, buttonStyle.CssClass, id, buttonImageUrl, javascript, buttonText)
            End If
        End Sub
        Private Sub RenderStep(ByVal writer As HtmlTextWriter, ByVal wizard As Wizard)
            WebControlAdapterExtender.WriteBeginDiv(writer, CSS_STEP, "")
            For Each control As Control In wizard.ActiveStep.Controls
                control.RenderControl(writer)
            Next
            WebControlAdapterExtender.WriteEndDiv(writer)
        End Sub
        Private Sub RenderHeader(ByVal writer As HtmlTextWriter, ByVal wizard As Wizard)
            WebControlAdapterExtender.WriteBeginDiv(writer, CSS_HEADER, "")
            If Not wizard.HeaderTemplate Is Nothing Then
                Dim containerID As String = CONTAINERID_HEADER
                Dim container As Control = wizard.FindControl(containerID)
                '-- Not sure why I don't need this line but it works anyway!
                'wizard.HeaderTemplate.InstantiateIn(container);
                container.RenderControl(writer)
            Else
                writer.Write(wizard.HeaderText)
            End If
            WebControlAdapterExtender.WriteEndDiv(writer)
        End Sub
        Private Sub RenderSideBar(ByVal writer As HtmlTextWriter, ByVal wizard As Wizard)
            If wizard.DisplaySideBar Then
                WebControlAdapterExtender.WriteBeginDiv(writer, CSS_SIDEBAR, "")
                Dim containerID As String = CONTAINERID_SIDEBAR
                Dim container As Control = wizard.FindControl(containerID)
                If Not wizard.SideBarTemplate Is Nothing Then
                    '-- Not sure why I don't need this line but it works anyway!
                    'wizard.SideBarTemplate.InstantiateIn(container);
                    container.RenderControl(writer)
                Else
                    Dim listContainer As Control = container.FindControl(CONTROLID_SIDEBARLIST)
                    Dim listIndex As Integer = 0
                    writer.WriteLine()
                    For Each [step] As WizardStep In wizard.WizardSteps
                        '-- Find the control within the container that contains the linkbutton
                        Dim control As Control = listContainer.Controls(listIndex)
                        '-- Find the LinkButton itself
                        Dim linkButton As LinkButton = TryCast(control.FindControl(CONTROLID_SIDEBARBUTTON), LinkButton)
                        '-- Get the postback javascript code and register the LinkButton control so that we can raise postback events 
                        Dim javascript As String = Page.ClientScript.GetPostBackClientHyperlink(linkButton, "", True)
                        '-- Render the LinkButton using Anchors
                        writer.WriteBeginTag("a")
                        If wizard.ActiveStepIndex = listIndex Then
                            writer.WriteAttribute("class", CSS_ACTIVE)
                        End If
                        writer.WriteAttribute("href", javascript)
                        writer.WriteAttribute("id", linkButton.ClientID)
                        writer.Write(HtmlTextWriter.TagRightChar)
                        writer.Write([step].Title)
                        writer.WriteEndTag("a")
                        writer.WriteLine()
                        System.Math.Max(System.Threading.Interlocked.Increment(listIndex), listIndex - 1)
                    Next
                End If
                WebControlAdapterExtender.WriteEndDiv(writer)
            End If
        End Sub
#End Region
    End Class
End Namespace