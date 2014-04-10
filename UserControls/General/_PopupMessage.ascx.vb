'========================================================================
'Kartris - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisEnumerations

Partial Class UserControls_Back_PopupMessage
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' raised when the user click "yes" to confirm the operation
    ''' </summary>
    ''' <remarks></remarks>
    Public Event Confirmed()

    ''' <summary>
    ''' raised when the user click "no" to decline the operation
    ''' </summary>
    ''' <remarks></remarks>
    Public Event Cancelled()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '' The following line is important for the confirmation msg box
        ''  => it will allow the event of the server side button to be fired
        Page.ClientScript.GetPostBackEventReference(Me, String.Empty)
    End Sub

    ''' <summary>
    ''' indicates if the confirmation box will have an image or not
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Public WriteOnly Property ShowImage() As Boolean
        Set(ByVal value As Boolean)
            phdImage.Visible = value
        End Set
    End Property

    ''' <summary>
    ''' calls the popup control to show in the screen
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub ShowConfirmation(ByVal enumType As MESSAGE_TYPE, ByVal strMessage As String)

        Select Case enumType
            Case MESSAGE_TYPE.Confirmation
                litTitle.Text = GetGlobalResourceObject("_Kartris", "ContentText_Confirmation")
                lnkYes.Visible = True
                lnkNo.Visible = True
            Case MESSAGE_TYPE.ErrorMessage
                litTitle.Text = GetGlobalResourceObject("_Kartris", "ContentText_Error")
                lnkYes.Visible = False
                lnkNo.Visible = False
            Case MESSAGE_TYPE.Information
                litTitle.Text = GetGlobalResourceObject("_Kartris", "ContentText_Information")
                lnkYes.Visible = False
                lnkNo.Visible = False
        End Select

        litMessage.Text = strMessage
        popExtender.Show()

    End Sub

    Protected Sub lnkYes_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkYes.Click
        RaiseEvent Confirmed()
    End Sub

    Protected Sub lnkNo_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkNo.Click
        RaiseEvent Cancelled()
    End Sub

End Class
