﻿'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Admin_Coupons
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("_Coupons", "PageTitle_Coupons") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles _UC_Coupons.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub
End Class
