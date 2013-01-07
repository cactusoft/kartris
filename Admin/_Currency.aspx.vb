﻿'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Admin_Currency
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("_Currency", "PageTitle_Currencies") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles _UC_Currency.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub
End Class
