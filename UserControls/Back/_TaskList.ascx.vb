'========================================================================
'Kartris - www.kartris.com
'Copyright 2015 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class UserControls_Back_TaskList
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            LoadTaskList()
        End If
    End Sub

    Public Sub LoadTaskList()
        Dim arrAuth As String() = HttpSecureCookie.Decrypt(Session("Back_Auth"))
        Dim blnOrders As Boolean = CBool(arrAuth(3))
        If blnOrders Then
            phdCustomerOrders.Visible = True
            LoadOrders()
        Else
            phdCustomerOrders.Visible = False
        End If
        Dim blnSupport As Boolean = CBool(arrAuth(8))
        If blnSupport Then
            phdSupportTickets.Visible = True
            LoadTickets()
        Else
            phdSupportTickets.Visible = False
        End If
        Dim blnProducts As Boolean = CBool(arrAuth(2))
        If blnProducts Then
            If Not blnOrders Then
                phdCustomerOrders.Visible = True
                LoadOrders()
                phdOrders.Visible = False
                phdAffiliates.Visible = False
                phdStock.Visible = True
            End If
        Else
            phdStock.Visible = False
        End If
        updMain.Update()
    End Sub

    Protected Sub LoadOrders()
        Dim numOrdersToInvoice As Integer = 0, numOrdersNeedPayment As Integer = 0, numOrdersToDispatch As Integer = 0
        Dim numStockWarning As Integer = 0, numOutOfStock As Integer = 0
        Dim numWaitingReviews As Integer = 0
        Dim numWaitingAffiliates As Integer = 0
        Dim numCustomersAwatingRefunds As Integer = 0
        Dim numCustomersInArrears As Integer = 0
        Dim strMessage As String = ""
        KartrisDBBLL._LoadTaskList(numOrdersToInvoice, numOrdersNeedPayment, numOrdersToDispatch, _
                                      numStockWarning, numOutOfStock, numWaitingReviews, numWaitingAffiliates, _
                                      numCustomersAwatingRefunds, numCustomersInArrears, strMessage)

        'Orders
        If numOrdersToInvoice > 0 OrElse numOrdersNeedPayment > 0 OrElse numOrdersToDispatch > 0 Then
            litToInvoice.Text = numOrdersToInvoice
            litNeedPayment.Text = numOrdersNeedPayment
            litToDispatch.Text = numOrdersToDispatch
            If numOrdersToInvoice = 0 Then phdToInvoice.Visible = False
            If numOrdersNeedPayment = 0 Then phdNeedPayment.Visible = False
            If numOrdersToDispatch = 0 Then phdToDispatch.Visible = False
        Else
            phdOrders.Visible = False
        End If

        'Awaiting refunds
        If numCustomersAwatingRefunds > 0 OrElse numCustomersInArrears > 0 Then
            phdCustomers.Visible = True
            litCustomersAwaitingRefundsCount.Text = numCustomersAwatingRefunds
            litCustomersInArrearsCount.Text = numCustomersInArrears
            If numCustomersAwatingRefunds = 0 Then phdCustomersAwaitingRefunds.Visible = False Else phdCustomersAwaitingRefunds.Visible = True
            If numCustomersInArrears = 0 Then phdCustomersInArrears.Visible = False Else phdCustomersInArrears.Visible = True
        Else
            phdCustomers.Visible = False
        End If

        'Stock warnings
        If numStockWarning > 0 OrElse numOutOfStock > 0 Then
            litStockWarning.Text = numStockWarning
            litOutOfStock.Text = numOutOfStock
            If numStockWarning <= 0 Then phdStockWarning.Visible = False
            If numOutOfStock <= 0 Then phdOutOfStock.Visible = False
        Else
            phdStock.Visible = False
        End If

        'Affiliates
        If numWaitingAffiliates > 0 Then
            litWaitingAffiliates.Text = numWaitingAffiliates
        Else
            phdAffiliates.Visible = False
        End If

        'Reviews
        If CInt(numWaitingReviews) > 0 Then
            litWaitingReviews.Text = numWaitingReviews
        Else
            phdReviews.Visible = False
        End If

        'Orders
        If phdOrders.Visible = False AndAlso phdStock.Visible = False AndAlso _
            phdAffiliates.Visible = False AndAlso phdReviews.Visible = False Then
            phdNoItems.Visible = True
        End If

    End Sub

    Sub LoadTickets()
        Dim numUnassignedTickets As Integer, numAwaitingTickets As Integer
        TicketsBLL._TicketsCounterSummary(numUnassignedTickets, numAwaitingTickets, Session("_UserID"))
        litAwaitingResponse.Text = numAwaitingTickets
        litUnassigned.Text = numUnassignedTickets

        'Show awaiting tickets link
        If numAwaitingTickets > 0 Then
            lnkAwaitingResponse.NavigateUrl = "~/Admin/_SupportTickets.aspx?u=" & Session("_UserID") & "&s=w"
            lnkAwaitingResponse.Visible = True
        Else
            lnkAwaitingResponse.Visible = False
        End If

        'Show unassigned tickets link
        If numUnassignedTickets > 0 Then
            lnkUnAssignedTickets.Visible = True
        Else
            lnkUnAssignedTickets.Visible = False
        End If

        'Show support tickets heading
        If numAwaitingTickets > 0 Or numUnassignedTickets > 0 Then
            lnkMyTickets.NavigateUrl = "~/Admin/_SupportTickets.aspx"
            phdSupportTickets.Visible = True
        Else
            phdSupportTickets.Visible = False
        End If
        updMain.Update()
    End Sub

End Class
