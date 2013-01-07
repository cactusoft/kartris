Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls

Namespace Kartris
    ''' <summary>
    ''' Overrides the default table layout of the <see cref="System.Web.UI.WebControls.RadioButtonList"/>
    ''' control, to a XHTML unordered list layout (structural markup).
    ''' </summary>
    Public Class RadioButtonListAdapter
        Inherits System.Web.UI.WebControls.Adapters.WebControlAdapter
        Private Const WRAPPER_CSS_CLASS As String = "Kartris-RadioButtonList"
        Private Const ITEM_CSS_CLASS As String = "Kartris-RadioButtonList-Item"

        Protected Overloads Overrides Sub RenderBeginTag(ByVal writer As HtmlTextWriter)
            ' Div
            writer.AddAttribute(HtmlTextWriterAttribute.[Class], WRAPPER_CSS_CLASS)
            writer.AddAttribute(HtmlTextWriterAttribute.Id, Me.Control.ClientID)
            writer.RenderBeginTag(HtmlTextWriterTag.Div)
            writer.Indent += 1

            ' Ul
            If Not String.IsNullOrEmpty(Me.Control.CssClass) Then
                writer.AddAttribute(HtmlTextWriterAttribute.[Class], Me.Control.CssClass)
            End If
            writer.RenderBeginTag(HtmlTextWriterTag.Ul)
        End Sub

        Protected Overloads Overrides Sub RenderEndTag(ByVal writer As HtmlTextWriter)
            writer.RenderEndTag()
            ' Ul
            writer.Indent -= 1
            writer.RenderEndTag()
            ' Div
        End Sub

        Protected Overloads Overrides Sub RenderContents(ByVal writer As HtmlTextWriter)
            Dim buttonList As RadioButtonList = TryCast(Me.Control, RadioButtonList)
            If buttonList IsNot Nothing Then
                For Each li As ListItem In buttonList.Items
                    Dim itemClientID As String = Helpers.GetListItemClientID(buttonList, li)

                    ' Li
                    writer.AddAttribute(HtmlTextWriterAttribute.[Class], ITEM_CSS_CLASS)
                    writer.RenderBeginTag(HtmlTextWriterTag.Li)

                    If buttonList.TextAlign = TextAlign.Right Then
                        RenderRadioButtonListInput(writer, buttonList, li)
                        RenderRadioButtonListLabel(writer, buttonList, li)
                    Else
                        ' TextAlign.Left
                        RenderRadioButtonListLabel(writer, buttonList, li)
                        RenderRadioButtonListInput(writer, buttonList, li)
                    End If

                    writer.RenderEndTag()
                    ' </li>
                    If Me.Page IsNot Nothing Then
                        Page.ClientScript.RegisterForEventValidation(buttonList.UniqueID, li.Value)
                    End If
                Next

                If Me.Page IsNot Nothing Then
                    Page.ClientScript.RegisterForEventValidation(buttonList.UniqueID)
                End If
            End If
        End Sub

        Private Sub RenderRadioButtonListInput(ByVal writer As HtmlTextWriter, ByVal buttonList As RadioButtonList, ByVal li As ListItem)
            ' Input
            writer.AddAttribute(HtmlTextWriterAttribute.Id, Helpers.GetListItemClientID(buttonList, li))
            writer.AddAttribute(HtmlTextWriterAttribute.Type, "radio")
            writer.AddAttribute(HtmlTextWriterAttribute.Name, buttonList.UniqueID)
            writer.AddAttribute(HtmlTextWriterAttribute.Value, li.Value)
            If li.Selected Then
                writer.AddAttribute(HtmlTextWriterAttribute.Checked, "checked")
            End If
            If li.Enabled = False OrElse buttonList.Enabled = False Then
                writer.AddAttribute(HtmlTextWriterAttribute.Disabled, "disabled")
            End If
            If li.Enabled = True AndAlso buttonList.Enabled = True AndAlso buttonList.AutoPostBack Then
                writer.AddAttribute(HtmlTextWriterAttribute.Onclick, [String].Format("setTimeout('__doPostBack(\'{0}\',\'\')', 0)", Helpers.GetListItemUniqueID(buttonList, li)))
            End If
            writer.RenderBeginTag(HtmlTextWriterTag.Input)
            writer.RenderEndTag()
            ' </input>
        End Sub

        Private Sub RenderRadioButtonListLabel(ByVal writer As HtmlTextWriter, ByVal buttonList As RadioButtonList, ByVal li As ListItem)
            ' Label
            writer.AddAttribute("for", Helpers.GetListItemClientID(buttonList, li))
            writer.RenderBeginTag(HtmlTextWriterTag.Label)
            writer.Write(li.Text)
            writer.RenderEndTag()
            ' </label>
        End Sub
    End Class
End Namespace
