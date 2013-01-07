Imports Microsoft.VisualBasic
Namespace Kartris
    Public Class FormRewriterControlAdapter
        Inherits System.Web.UI.Adapters.ControlAdapter

        Protected Overrides Sub Render(ByVal writer As System.Web.UI.HtmlTextWriter)
            MyBase.Render(New RewriteFormHtmlTextWriter(writer))
        End Sub

    End Class

    Public Class RewriteFormHtmlTextWriter
        Inherits HtmlTextWriter

        Sub New(ByVal writer As HtmlTextWriter)
            MyBase.New(writer)
            Me.InnerWriter = writer.InnerWriter
        End Sub

        Sub New(ByVal writer As System.IO.TextWriter)
            MyBase.New(writer)
            MyBase.InnerWriter = writer
        End Sub

        Public Overrides Sub WriteAttribute(ByVal name As String, ByVal value As String, ByVal fEncode As Boolean)

            ' If the attribute we are writing is the "action" attribute, and we are not on a sub-control, 
            ' then replace the value to write with the raw URL of the request - which ensures that we'll
            ' preserve the PathInfo value on postback scenarios

            If (name = "action") Then

                Dim Context As HttpContext
                Context = HttpContext.Current

                If Context.Items("ActionAlreadyWritten") Is Nothing Then

                    value = Context.Request.RawUrl

                    ' Indicate that we've already rewritten the <form>'s action attribute to prevent
                    ' us from rewriting a sub-control under the <form> control

                    Context.Items("ActionAlreadyWritten") = True

                End If

            End If

            MyBase.WriteAttribute(name, value, fEncode)

        End Sub

    End Class
End Namespace
