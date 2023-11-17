'========================================================================
'Kartris - www.kartris.com
'Copyright 2023 CACTUSOFT

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
Imports CkartrisEnumerations

Partial Class UserControls_General_AddressesDetails
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' Event to indicate data updated, channelled upwards to show the 'updated' animation
    ''' </summary>
    ''' <remarks></remarks>
    Public Event _UCEvent_DataUpdated()

    ''' <summary>
    ''' Page load
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Trim(Request.QueryString("CustomerID")) <> "" Then
            Try
                Dim U_ID As Integer = CInt(Request.QueryString("CustomerID"))
                Dim objUsersBLL As New UsersBLL
                hidUserID.Value = U_ID
                'retrieve address list based on the current customer ID and the set adddress type
                Dim dtUserDetails As DataTable = objUsersBLL._GetAddressesByUserID(U_ID, hidDisplayAddressType.Value)
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

    ''' <summary>
    ''' Binding addresses to repeater
    ''' </summary>
    ''' <remarks></remarks>
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

    ''' <summary>
    ''' Handles clicks on Edit or Delete links on addresses
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub LinkButton_Command(ByVal Sender As Object, ByVal e As CommandEventArgs)
        Dim strCommandName = e.CommandName
        Dim numCommandArgument As Integer = e.CommandArgument
        If strCommandName.ToLower = "edit" Then
            ResetAddressInput()
            Dim objAddress As KartrisClasses.Address = KartrisClasses.Address.Get(numCommandArgument)
            UC_NewEditAddress.InitialAddressToDisplay = objAddress
            'pnlNewAddress.Visible = True
            popExtender.Show()
        ElseIf strCommandName.ToLower = "delete" Then
            hidAddressToDeleteID.Value = numCommandArgument
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))

        Else
            'Erm, something up?
        End If
    End Sub

    ''' <summary>
    ''' Add new address
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub NewAddress() Handles lnkAddBilling.Click
        ResetAddressInput()
        popExtender.Show()
    End Sub


    ''' <summary>
    ''' Submit/save address 
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub btnSaveNewAddress_Click() Handles btnSaveNewAddress.Click
        Dim intGeneratedAddressID As Integer = Address.AddUpdate(UC_NewEditAddress.EnteredAddress, hidUserID.Value, , UC_NewEditAddress.EnteredAddress.ID)
        Dim objUsersBLL As New UsersBLL
        Dim dtUserDetails As DataTable = objUsersBLL._GetAddressesByUserID(hidUserID.Value, hidDisplayAddressType.Value)
        rptrUserAddresses.DataSource = dtUserDetails
        rptrUserAddresses.DataBind()
        RaiseEvent _UCEvent_DataUpdated()
    End Sub

    ''' <summary>
    ''' Confirms deleting an address
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        KartrisClasses.Address.Delete(hidAddressToDeleteID.Value, hidUserID.Value)
        Dim objUsersBLL As New UsersBLL
        Dim dtUserDetails As DataTable = objUsersBLL._GetAddressesByUserID(hidUserID.Value, hidDisplayAddressType.Value)
        rptrUserAddresses.DataSource = dtUserDetails
        rptrUserAddresses.DataBind()
        RaiseEvent _UCEvent_DataUpdated()
    End Sub

    ''' <summary>
    ''' Cancel popup
    ''' </summary>
    ''' <remarks>Need this for the delete popup, because the popExtender is linked to the edit address panel cancel</remarks>
    Protected Sub _UC_PopupMsg_Cancelled() Handles _UC_PopupMsg.Cancelled
        'Dim dtUserDetails As DataTable = UsersBLL._GetAddressesByUserID(hidUserID.Value, hidDisplayAddressType.Value)
        'rptrUserAddresses.DataSource = dtUserDetails
        'rptrUserAddresses.DataBind()
        'updAddresses.Update()
    End Sub

    ''' <summary>
    ''' Resets the address form
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub ResetAddressInput()
        UC_NewEditAddress.Clear()
    End Sub
End Class
