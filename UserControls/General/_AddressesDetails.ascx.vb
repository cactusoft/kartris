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
Imports KartrisClasses

Partial Class UserControls_General_AddressesDetails
    Inherits System.Web.UI.UserControl
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Trim(Request.QueryString("CustomerID")) <> "" Then
            Try
                Dim C_ID As Integer = CInt(Request.QueryString("CustomerID"))
                'retrieve address list based on the current customer ID and the set adddress type
                Dim dtUserDetails As DataTable = UsersBLL._GetAddressesByUserID(C_ID, hidDisplayAddressType.Value)
                rptrUserAddresses.DataSource = dtUserDetails
                rptrUserAddresses.DataBind()
            Catch ex As Exception

            End Try
         
        End If
    End Sub

    ''' <summary>
    ''' Determines the address type to display
    ''' </summary>
    ''' <value>value should either be "s" for shipping or "b" for billing</value>
    ''' <remarks></remarks>
    Public WriteOnly Property AddressType() As String
        Set(ByVal value As String)
            hidDisplayAddressType.Value = value
        End Set
    End Property

    Private Sub rptrUserAddresses_ItemDataBound(ByVal Sender As Object, ByVal e As RepeaterItemEventArgs) Handles rptrUserAddresses.ItemDataBound
        If (e.Item.ItemType = ListItemType.Item) Or (e.Item.ItemType = ListItemType.AlternatingItem) Then
            Dim litCountry As Literal = CType(e.Item.FindControl("litCountry"), Literal)
            If litCountry IsNot Nothing Then
                Try
                    'Replace Country ID with proper Country Name
                    litCountry.Text = Country.Get(CInt(litCountry.Text)).Name
                Catch ex As Exception

                End Try
            End If
        End If
    End Sub
End Class
