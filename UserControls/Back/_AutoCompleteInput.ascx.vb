'========================================================================
'Kartris - www.kartris.com
'Copyright 2016 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class _AutoCompleteInput
    Inherits System.Web.UI.UserControl

    Private c_MethodName As String
    Private c_ContextKey As String
    Private c_Behavior As String

    Public Property MethodName() As String
        Get
            Return autCompleteCtrl.ServiceMethod
        End Get
        Set(ByVal value As String)
            c_MethodName = value
            autCompleteCtrl.ServiceMethod = c_MethodName
        End Set
    End Property

    Public WriteOnly Property ContextKey() As String
        Set(ByVal value As String)
            c_ContextKey = value
        End Set
    End Property

    Public WriteOnly Property Behavior() As String
        Set(ByVal value As String)
            autCompleteCtrl.BehaviorID = value
        End Set
    End Property

    Public Function GetText() As String
        Return txtBox.Text
    End Function

    Public Sub SetText(ByVal strText As String)
        txtBox.Text = strText
    End Sub

    Public Sub SetWidth(ByVal intWidth As Integer)
        txtBox.Width = intWidth
    End Sub

    Public Sub ClearText()
        txtBox.Text = ""
    End Sub

    Public Sub SetFoucs()
        txtBox.Focus()
    End Sub

End Class
