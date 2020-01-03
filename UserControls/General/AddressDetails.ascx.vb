'========================================================================
'Kartris - www.kartris.com
'Copyright 2020 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System.Configuration
Imports System.Collections
Imports System.Web
Imports System.Web.Security
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI.WebControls.WebParts
Imports System.Web.UI.HtmlControls
Imports Payment
Imports KartrisClasses

Partial Class UserControls_General_AddressDetails
    Inherits System.Web.UI.UserControl
    Private _AddressID As Integer
    Private m_address As Address = Nothing

    Public ReadOnly Property AddressID() As Integer
        Get
            Return _AddressID
        End Get
    End Property

    Public WriteOnly Property ShowButtons() As Boolean
        Set(ByVal value As Boolean)
            pnlButtons.Visible = value
        End Set
    End Property

    Public WriteOnly Property ShowLabel() As Boolean
        Set(ByVal value As Boolean)
            litAddressLabel.Visible = value
        End Set
    End Property

    Public Property Address() As Address
        Get
            Return m_address
        End Get
        Set(ByVal value As Address)
            _AddressID = value.ID
            m_address = value
            Try
                litAddressLabel.Text = Server.HtmlEncode(value.Label)
                litName.Text = Server.HtmlEncode(value.FullName)
                litCompany.Text = Server.HtmlEncode(IIf(String.IsNullOrEmpty(value.Company), String.Empty, value.Company))
                litAddress.Text = Server.HtmlEncode(value.StreetAddress)
                litTownCity.Text = Server.HtmlEncode(value.TownCity)
                litCounty.Text = Server.HtmlEncode(value.County)
                litCountry.Text = Server.HtmlEncode(Country.Get(value.CountryID).Name)
                litPostcode.Text = Server.HtmlEncode(value.Postcode)
                litPhone.Text = Server.HtmlEncode(value.Phone)
            Catch
                'nothing
            End Try
        End Set
    End Property

    Public Event btnEditClicked(ByVal sender As Object, ByVal e As System.EventArgs)

    Public Event btnDeleteClicked(ByVal sender As Object, ByVal e As System.EventArgs)

    Protected Sub btnEdit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnEdit.Click
        RaiseEvent btnEditClicked(sender, e)
    End Sub

    Protected Sub btnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnDelete.Click
        RaiseEvent btnDeleteClicked(sender, e)
    End Sub

End Class
