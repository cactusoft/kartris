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
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports MailChimp.Net.Models
Imports MailChimp.Net.Core
Partial Class Admin_MailChimp
    Inherits _PageBaseClass

    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = "MailChimp | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        'Fill config setting values in 
        txtCFG_Value1.Text = KartSettingsManager.GetKartConfig("general.mailchimp.apikey")
        txtCFG_Value2.Text = KartSettingsManager.GetKartConfig("general.mailchimp.apiurl")
        txtCFG_Value3.Text = KartSettingsManager.GetKartConfig("general.mailchimp.listid")
        txtCFG_Value4.Text = KartSettingsManager.GetKartConfig("general.mailchimp.storeid")

        txtCFG_Value5.Text = KartSettingsManager.GetKartConfig("general.mailchimp.mailinglistid")

        'Show status
        If KartSettingsManager.GetKartConfig("general.mailchimp.enabled") = "y" Then
            litStatus.Text = "enabled"
        Else
            litStatus.Text = "not enabled"
        End If
        'Only show the code to create a store if all the required
        'config settings are set
        If txtCFG_Value1.Text = "" Or txtCFG_Value2.Text = "" Or txtCFG_Value3.Text = "" Or txtCFG_Value4.Text = "" Then
            phdMailChimpAPI.Visible = False
        Else
            phdMailChimpAPI.Visible = True

            ' Fill Up MailChimp Extra Fields
            Try
                If Not txtCFG_Value4.Text.Equals("") Then
                    Dim manager As MailChimpBLL = New MailChimpBLL()
                    Dim store As Store = manager.manager.ECommerceStores.GetAsync(txtCFG_Value4.Text).Result
                    If store IsNot Nothing Then
                        txtStoreName.Text = store.Name
                        txtStoreDomain.Text = store.Domain
                        txtStoreEmail.Text = store.EmailAddress
                    End If
                End If
            Catch ex As Exception
                'probably no mailchimp store created yet
            End Try

        End If


    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles Me.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub

    Protected Sub lnkCreateStore_Click() Handles lnkCreateStore.Click
        Dim manager As MailChimpBLL = New MailChimpBLL()
        Try
            Dim storeEmail As String = If((txtStoreEmail.Text.Equals("")), Nothing, txtStoreEmail.Text)
            Dim storeDomain As String = If((txtStoreDomain.Text.Equals("")), Nothing, txtStoreDomain.Text)
            Dim storeName As String = If((txtStoreName.Text.Equals("")), Nothing, txtStoreName.Text)
            Dim store As Store = manager.AddStore(txtCFG_Value4.Text, storeName, storeDomain, storeEmail).Result()
            ShowMasterUpdateMessage()

        Catch ex As Exception
            If ex.InnerException IsNot Nothing Then
                Dim exceptionType As Type = ex.InnerException.GetType()
                If exceptionType.Name.Equals("MailChimpException") Then
                    Dim mcException As MailChimpException = DirectCast(ex.InnerException, MailChimpException)
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, mcException.Detail)
                Else
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, "An error occured. Please check your MailChimp setup and your config setting values.")
                End If
            End If

        End Try
    End Sub
End Class
