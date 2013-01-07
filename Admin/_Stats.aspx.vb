'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Admin_Stats
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("_Kartris", "BackMenu_Statistics") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub
End Class
