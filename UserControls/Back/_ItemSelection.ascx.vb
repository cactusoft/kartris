'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class UserControls_Back_ItemSelection
    Inherits System.Web.UI.UserControl

    Public Event ItemSelectionChanged(ByVal sender As Object)
    Public ReadOnly Property IsSelected() As Boolean
        Get
            Return chk.Checked
        End Get
    End Property
    Public WriteOnly Property Checked() As Boolean
        Set(ByVal value As Boolean)
            chk.Checked = value
        End Set
    End Property
    Public WriteOnly Property ItemNo() As String
        Set(ByVal value As String)
            litItemNo.Text = value
        End Set
    End Property
    Public ReadOnly Property GetItemNo() As Integer
        Get
            Return CInt(litItemNo.Text)
        End Get
    End Property
    Public WriteOnly Property AutoPostBack() As Boolean
        Set(ByVal value As Boolean)
            chk.AutoPostBack = value
        End Set
    End Property

    Protected Sub chk_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chk.CheckedChanged
        RaiseEvent ItemSelectionChanged(Me)
    End Sub
End Class
