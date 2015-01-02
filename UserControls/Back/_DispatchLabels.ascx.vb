'    DispatchLabels.ascx is a custom control that allows users to select
'    a label format from a drop down and then send the client to a handler
'    that will output a PDF file of dispatch labels in that format.
'    Copyright (C) 2014  Craig Moore - Deadline Automation Limited.
'
'    GNU GENERAL PUBLIC LICENSE v2
'    This program is free software distributed under the GPL without any
'    warranty.
'    www.gnu.org/licenses/gpl-2.0.html
'
'    If you make any modifications to this program please clearly state who,
'    when and some small details in this header.

Partial Class UserControls_Back_DispatchLabels
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            LoadFormats()
        End If
    End Sub

    ''' <summary>
    ''' Load the stored label formats from the database into the drop down list.
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub LoadFormats()
        Dim formats As List(Of LabelFormat) = LabelFormatBLL.GetLabelFormats
        With ddlLabelFormats
            .DataSource = formats
            .DataTextField = "Name"
            .DataValueField = "Id"
            .DataBind()
        End With
    End Sub


    Protected Sub btnPrint_Click(sender As Object, e As EventArgs) Handles btnPrint.Click
        If IsNothing(ddlLabelFormats.SelectedItem) Then
            ' Format has not been selected.
            Page.ClientScript.RegisterStartupScript(Me.GetType, "popupmessage", "Please select a valid format first.", True)
            ' The line below is the production method of outputting messages to the client. 
            ' This code module is not within the scope of the CodeProject article.
            'ClientMessageUtil.showMessage("Please select a valid format first.", Me.Page, "Error")
        Else
            ' We have a format.
            Dim ddli As ListItem = CType(ddlLabelFormats.SelectedItem, ListItem)
            If IsNumeric(ddli.Value) Then
                Response.Redirect("~/Admin/_AddressLabelPdfs.ashx/dispatchlabels?fid=" & CInt(ddli.Value))
            Else
                Page.ClientScript.RegisterStartupScript(Me.GetType, "popupmessage", "Selected format has an invalid reference ID.", True)
                ' The line below is the production method of outputting messages to the client. 
                ' This code module is not within the scope of the CodeProject article.
                'ClientMessageUtil.showMessage("Selected format has an invalid reference ID.", Me.Page, "Error")
            End If
        End If
    End Sub
End Class
