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

''' <summary>
''' This control runs lets customers enter an email address
''' for out-of-stock items, so they can be notified when the
''' item is back in stock.
''' </summary>
Partial Class UserControls_Front_StockNotification
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' Version ID, this is what we use to check for 
    ''' stock notifications when a version is updated
    ''' </summary>
    Private _VersionID As Int64

    ''' <summary>
    ''' There is a problem with using validation groups if
    ''' we want to use this control more than once per page
    ''' (which we do). To get around this, we need to set
    ''' the validation group dynamically. This is part of that
    ''' process.
    ''' </summary>
    Protected ReadOnly Property UniqueValidationGroup() As String
        Get
            Return ClientID + "StockTracking"
        End Get
    End Property

    Public Property VersionID() As Int64
        Get
            Return _VersionID
        End Get
        Set(ByVal value As Int64)
            _VersionID = value
        End Set
    End Property

    ''' <summary>
    ''' Product ID is returned so we can look up the
    ''' product name to store with the notification,
    ''' this way, when we send the notification we
    ''' already have the product name.
    ''' </summary>
    Private _ProductID As String

    Public Property ProductID() As Integer
        Get
            Return _ProductID
        End Get
        Set(ByVal value As Integer)
            _ProductID = value
        End Set
    End Property

    ''' <summary>
    ''' We set version name so we can put it in the
    ''' confirmation popup and the stock notification
    ''' email
    ''' </summary>
    Private _VersionName As String

    Public Property VersionName() As String
        Get
            Return _VersionName
        End Get
        Set(ByVal value As String)
            _VersionName = value
        End Set
    End Property

    ''' <summary>
    ''' Product link, this is the friendly link to
    ''' the product page. We set it here within the
    ''' stock notification record because it's easily
    ''' available on this page, and it saves as having
    ''' to recreate it later
    ''' </summary>
    Private _PageLink As String

    Public Property PageLink() As String
        Get
            Return _PageLink
        End Get
        Set(ByVal value As String)
            _PageLink = value
        End Set
    End Property

    ''' <summary>
    ''' Language ID is stored so when sending the
    ''' email when know which language template to
    ''' use for it.
    ''' </summary>
    Private _LanguageID As Byte

    Public Property LanguageID() As Byte
        Get
            Return _LanguageID
        End Get
        Set(ByVal value As Byte)
            _LanguageID = value
        End Set
    End Property

    ''' <summary>
    ''' This sub can be called from the
    ''' ProductVersions.ascx.vb in response to
    ''' button clicks on notify-me buttons to
    ''' show the popup for users to enter their
    ''' email address into.
    ''' </summary>
    Public Sub ShowStockNotificationsPopup()

        'Format full product name from lookup of product
        'name plus version name
        Dim strProductFullName As String = ProductsBLL.GetNameByProductID(_ProductID, _LanguageID)

        'Options products won't have version name, but rest will
        If _VersionName <> "" Then strProductFullName &= " - " & Server.UrlDecode(_VersionName)

        'We want to create the message to display on the popup
        Dim strDetails As String = GetGlobalResourceObject("StockNotification", "ContentText_NotifyMeDetails")
        strDetails = Replace(strDetails, "[productname]", "<strong>" & strProductFullName & "</strong>")

        'Set values for this product to hidden fields, when
        'use submits email address, we have everything we
        'need to create the stock notification record
        hidVersionID.Value = _VersionID
        hidProductName.Value = strProductFullName
        hidPageLink.Value = _PageLink
        hidLanguageID.Value = _LanguageID

        'Let's show the name of the product on the popup
        'just to confirm to the user
        litDetails.Text = strDetails
        popStockNotification.Show()
        updPnlStockNotification.Update()
    End Sub

    ''' <summary>
    ''' handles the save button being clicked
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click

        'We just want to validate the group for this
        'particular item, that's why below we find the
        'validation control of the button that was 
        'clicked
        Page.Validate(btnSave.ValidationGroup)
        If Page.IsValid Then
            StockNotificationsBLL.AddNewStockNotification(txtEmail.Text, hidVersionID.Value, hidPageLink.Value, hidProductName.Value, hidLanguageID.Value)
        Else
            CkartrisFormatErrors.LogError("Something not valid in group " & btnSave.ValidationGroup)
        End If
    End Sub
End Class
