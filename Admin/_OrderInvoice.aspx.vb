﻿'========================================================================
'Kartris - www.kartris.com
'Copyright 2024 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisFormatErrors
Imports KartSettingsManager
Partial Class _OrderInvoice

    Inherits Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Invoice", "PageTitle_Invoice") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        Dim numOrderIDQS, numCustomerIDQS As String()

        Dim dtbInvoices As DataTable = New DataTable
        dtbInvoices.Columns.Add("OrderID", GetType(Integer))
        dtbInvoices.Columns.Add("CustomerID", GetType(Integer))

        Authenticate()

        numOrderIDQS = Request.QueryString("OrderID").Split("-")
        numCustomerIDQS = Request.QueryString("CustomerID").Split("-")

        For x As Integer = 0 To numOrderIDQS.Length - 1
            dtbInvoices.Rows.Add(Convert.ToInt32(numOrderIDQS(x)), Convert.ToInt32(numCustomerIDQS(x)))
        Next

        rptCompleteInvoice.DataSource = dtbInvoices
        rptCompleteInvoice.DataBind()

    End Sub

    ''' <summary>
    ''' This is only here to handle this page's authentication as its not handled by _PageBaseClass.
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub Authenticate()
        Dim cokKartris As HttpCookie = Request.Cookies(HttpSecureCookie.GetCookieName("BackAuth"))
        Dim arrAuth As String() = Nothing
        Session("Back_Auth") = ""
        If cokKartris IsNot Nothing Then
            arrAuth = HttpSecureCookie.DecryptValue(cokKartris.Value, "Order Invoice")
            If UBound(arrAuth) = 8 Then
                Dim strClientIP As String = CkartrisEnvironment.GetClientIPAddress()
                If Not String.IsNullOrEmpty(arrAuth(0)) And strClientIP = arrAuth(7) Then
                    Session("Back_Auth") = cokKartris.Value
                    Session("_LANG") = arrAuth(4)
                    Session("_USER") = arrAuth(0)
                Else
                    Session("Back_Auth") = ""
                    cokKartris = New HttpCookie(HttpSecureCookie.GetCookieName("BackAuth"))
                    cokKartris.Expires = CkartrisDisplayFunctions.NowOffset.AddDays(-1D)
                    Response.Cookies.Add(cokKartris)
                End If
            End If
        End If
        Response.Cache.SetCacheability(HttpCacheability.NoCache)


        Dim strScriptURL As String = Request.RawUrl.Substring(Request.Path.LastIndexOf("/") + 1)

        If String.IsNullOrEmpty(Session("Back_Auth")) Then
            If Left(strScriptURL, 11) <> "Default.aspx" Then Response.Redirect("~/Admin/Default.aspx?page=" & strScriptURL)
        Else
            Dim strScriptName As String = Request.Path.Substring(Request.Path.LastIndexOf("/") + 1)
            Dim nodeCurrent As SiteMapNode = SiteMap.Providers("_KartrisSiteMap").FindSiteMapNodeFromKey("~/Admin/" & strScriptName)
            If Not nodeCurrent Is Nothing Then
                Dim strNodeValue As String = nodeCurrent.Item("Value")
                If UBound(arrAuth) = 8 Then

                    Select Case strNodeValue
                        Case "orders"
                            Dim blnOrders As Boolean = CBool(arrAuth(3))
                            'Session("Back_Orders")
                            If Not blnOrders Then
                                Response.Write("You are not authorized to view this page")
                                Response.End()
                            End If
                        Case "products"
                            Dim blnProducts As Boolean = CBool(arrAuth(2))
                            'Session("Back_Products")
                            If Not blnProducts Then
                                Response.Write("You are not authorized to view this page")
                                Response.End()
                            End If
                        Case "config"
                            Dim blnConfig As Boolean = CBool(arrAuth(1))
                            'Session("Back_Config")
                            If Not blnConfig Then
                                Response.Write("You are not authorized to view this page")
                                Response.End()
                            End If
                        Case "support"
                            Dim blnSupport As Boolean = CBool(arrAuth(8))
                            'Session("Back_Support")
                            If Not blnSupport Then
                                Response.Write("You are not authorized to view this page")
                                Response.End()
                            End If
                    End Select
                Else
                    Response.Write("Invalid Cookie")
                    Response.End()
                End If

            Else
                Response.Write("Unknown Backend Page. This needs to be added to the sitemap. If you don't want to show the link to the navigation menu. set its 'visible' tag to 'false' in the sitemap entry. <br/> e.g." & Server.HtmlEncode("<siteMapNode title=""default"" url=""~/Admin/_Default.aspx"" visible=""false"" />"))
                Response.End()
            End If
        End If
    End Sub

    Protected Sub rptCompleteInvoice_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptCompleteInvoice.ItemDataBound
        Dim numOrderID, numCustomerID As Integer

        numOrderID = e.Item.DataItem("OrderID")
        numCustomerID = e.Item.DataItem("CustomerID")
        Dim UC_Invoice As UserControls_General_Invoice = e.Item.FindControl("UC_Invoice")

        UC_Invoice.OrderID = numOrderID
        UC_Invoice.CustomerID = numCustomerID
        UC_Invoice.FrontOrBack = "back" 'tell user control is on back end
    End Sub

    Protected Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Error
        LogError()
    End Sub

End Class
