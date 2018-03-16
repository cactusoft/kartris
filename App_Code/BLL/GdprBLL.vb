'========================================================================
'Kartris - www.kartris.com
'Copyright 2018 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports kartrisGDPRData
Imports kartrisGDPRDataTableAdapters
Imports CkartrisDisplayFunctions
Imports CkartrisFormatErrors
Imports CkartrisDataManipulation
Imports System.Web.HttpContext


'GDPR BLL
'The GDPR (General Data Protection Regulations)
Public Class GdprBLL

    ''' <summary>
    ''' User adapter
    ''' </summary>
    Private Shared _Adptr_User As UserTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr_User() As UserTblAdptr
        Get
            _Adptr_User = New UserTblAdptr
            Return _Adptr_User
        End Get
    End Property

    ''' <summary>
    ''' Addresses adapter
    ''' </summary>
    Private Shared _Adptr_Addresses As AddressesTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr_Addresses() As AddressesTblAdptr
        Get
            _Adptr_Addresses = New AddressesTblAdptr
            Return _Adptr_Addresses
        End Get
    End Property

    ''' <summary>
    ''' Orders adapter
    ''' </summary>
    Private Shared _Adptr_Orders As OrdersTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr_Orders() As OrdersTblAdptr
        Get
            _Adptr_Orders = New OrdersTblAdptr
            Return _Adptr_Orders
        End Get
    End Property

    ''' <summary>
    ''' Invoice rows adapter
    ''' </summary>
    Private Shared _Adptr_InvoiceRows As InvoiceRowsTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr_InvoiceRows() As InvoiceRowsTblAdptr
        Get
            _Adptr_InvoiceRows = New InvoiceRowsTblAdptr
            Return _Adptr_InvoiceRows
        End Get
    End Property

    ''' <summary>
    ''' Reviews adapter
    ''' </summary>
    Private Shared _Adptr_Reviews As ReviewsTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr_Reviews() As ReviewsTblAdptr
        Get
            _Adptr_Reviews = New ReviewsTblAdptr
            Return _Adptr_Reviews
        End Get
    End Property

    ''' <summary>
    ''' WishLists adapter
    ''' </summary>
    Private Shared _Adptr_WishLists As WishListsTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr_WishLists() As WishListsTblAdptr
        Get
            _Adptr_WishLists = New WishListsTblAdptr
            Return _Adptr_WishLists
        End Get
    End Property

    ''' <summary>
    ''' Support tickets adapter
    ''' </summary>
    Private Shared _Adptr_SupportTickets As SupportTicketsTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr_SupportTickets() As SupportTicketsTblAdptr
        Get
            _Adptr_SupportTickets = New SupportTicketsTblAdptr
            Return _Adptr_SupportTickets
        End Get
    End Property

    ''' <summary>
    ''' Support ticket messages adapter
    ''' </summary>
    Private Shared _Adptr_SupportTicketMessages As SupportTicketMessagesTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr_SupportTicketMessages() As SupportTicketMessagesTblAdptr
        Get
            _Adptr_SupportTicketMessages = New SupportTicketMessagesTblAdptr
            Return _Adptr_SupportTicketMessages
        End Get
    End Property

    ''' <summary>
    ''' Saved baskets adapter
    ''' </summary>
    Private Shared _Adptr_SavedBaskets As SavedBasketsTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr_SavedBaskets() As SavedBasketsTblAdptr
        Get
            _Adptr_SavedBaskets = New SavedBasketsTblAdptr
            Return _Adptr_SavedBaskets
        End Get
    End Property

    ''' <summary>
    ''' Saved basket values adapter
    ''' </summary>
    Private Shared _Adptr_SavedBasketValues As SavedBasketValuesTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr_SavedBasketValues() As SavedBasketValuesTblAdptr
        Get
            _Adptr_SavedBasketValues = New SavedBasketValuesTblAdptr
            Return _Adptr_SavedBasketValues
        End Get
    End Property

    ''' <summary>
    ''' Write to text file
    ''' </summary>
    Public Shared Sub WriteToTextFile(ByVal strFileName As String,
                                 ByVal strContent As String)

        Dim strData As New StringBuilder("")
        strData.Append(strContent)

        Dim data() As Byte = System.Text.UTF8Encoding.UTF8.GetBytes(strData.ToString)

        Current.Response.Clear()
        Current.Response.AddHeader("Content-Type", "application/Word; charset=utf-8") 'this is to force a file download dialog, text/plain seems to show the output in browser
        Current.Response.AddHeader("Content-Disposition", "inline;filename=" & strFileName.Replace(" ", "_").Replace(".", "-") & ".txt")
        Current.Response.AddHeader("Content-Length", data.Length.ToString)
        Current.Response.ContentEncoding = Encoding.Unicode
        Current.Response.BinaryWrite(data)
        Current.Response.End()
        Current.Response.Flush()

    End Sub

    ''' <summary>
    ''' Format the text for the GDPR file
    ''' </summary>
    Public Shared Function FormatGDPRText(ByVal numUserID As Integer) As String

        Dim strData As New StringBuilder("")

        'First, we put a header with time and date and some
        'details of the data within the file

        '============== GDPR DATA REQUEST ===============
        strData.AppendLine("============== GDPR DATA REQUEST ===============")
        strData.AppendLine("File created: " & CkartrisDisplayFunctions.FormatDate(Now(), "t", 1))
        strData.AppendLine("The data contained within this file is a direct export")
        strData.AppendLine("from the site database at " & CkartrisBLL.WebShopURL.ToLower & ".")
        strData.AppendLine("")
        strData.AppendLine("")


        '============== CUSTOMER DATA ===============
        strData.AppendLine("")
        strData.AppendLine("== CUSTOMER DATA ==")
        strData.AppendLine("")

        Dim dtbUser As DataTable = Adptr_User.GetData(numUserID)
        For Each drwUser As DataRow In dtbUser.Rows 'loop through users, but should only be one!

            For i = 0 To dtbUser.Columns.Count - 1 'loop through columns

                Dim strColumnName As String = dtbUser.Columns(i).ColumnName
                Dim strColumnValue As String = drwUser(i).ToString

                'Format dates nicely
                If strColumnName = "U_TempPasswordExpiry" Or strColumnName = "U_ML_SignupDateTime" Or strColumnName = "U_ML_ConfirmationDateTime" Then
                    Try
                        strColumnValue = CkartrisDisplayFunctions.FormatDate(strColumnValue, "t", 1)
                        If strColumnValue.Contains("1/1/1900") Then strColumnValue = "-" 'some default dates are stored as 1/1/1900, but really means no date
                    Catch ex As Exception
                        strColumnValue = "-" 'some issue with converting date, return a dash
                    End Try

                End If

                strData.AppendLine(strColumnName & ": [ " & strColumnValue & " ]")
            Next
            'For i = 0 To drwUser.GetColumnsInError.Count
            'strData.AppendLine(WriteDataInfo(dtbUser.Columns, drwUser))
        Next

        '============== ADDRESSES ===============
        strData.AppendLine("")
        strData.AppendLine("== ADDRESSES ==")
        strData.AppendLine("")

        Dim dtbAddresses As DataTable = Adptr_Addresses.GetData(numUserID)
        For Each drwAddress As DataRow In dtbAddresses.Rows
            For i = 0 To dtbAddresses.Columns.Count - 1
                strData.AppendLine(dtbAddresses.Columns(i).ColumnName & ": [ " & drwAddress(i).ToString & " ]")
            Next
            'For i = 0 To drwUser.GetColumnsInError.Count
            'strData.AppendLine(WriteDataInfo(dtbUser.Columns, drwUser))
        Next

        '============== ORDERS ===============
        strData.AppendLine("")
        strData.AppendLine("== ORDERS ==")
        strData.AppendLine("")

        Dim O_ID As Integer = 0 'need this to be found in order to get invoice rows later
        Dim dtbOrders As DataTable = Adptr_Orders.GetData(numUserID)
        For Each drwOrder As DataRow In dtbOrders.Rows 'loop through orders, could be multiple

            strData.AppendLine("== Start of Order ==")
            For i = 0 To dtbOrders.Columns.Count - 1 'loop through columns

                Dim strColumnName As String = dtbOrders.Columns(i).ColumnName
                Dim strColumnValue As String = drwOrder(i).ToString


                If strColumnName <> "O_Details" And strColumnName <> "O_Data" And strColumnName <> "O_Status" Then 'exclude these fields, they hold big messy HTML versions that only contains other data here

                    'Get the order ID
                    If strColumnName = "O_ID" Then O_ID = strColumnValue

                    'Format street addresses nicely
                    If strColumnName = "O_BillingAddress" Or strColumnName = "O_ShippingAddress" Then
                        strColumnValue = Replace(strColumnValue, vbCrLf, ", ") 'put address on single line, cleaner for data export
                        strColumnValue = Replace(strColumnValue, ", , ", ", ") 'fix any blank values
                        strColumnValue = Replace(strColumnValue, ", , ", ", ") 'fix any blank values
                    End If

                    'Format dates nicely
                    If strColumnName = "O_Date" Or strColumnName = "O_LastModified" Then
                        Try
                            strColumnValue = CkartrisDisplayFunctions.FormatDate(strColumnValue, "t", 1)
                            If strColumnValue.Contains("1/1/1900") Then strColumnValue = "-" 'some default dates are stored as 1/1/1900, but really means no date
                        Catch ex As Exception
                            strColumnValue = "-" 'some issue with converting date, return a dash
                        End Try
                    End If
                    strData.AppendLine(strColumnName & ": [ " & strColumnValue & " ]")
                End If
            Next

            '-------------- INVOICE ROWS --------------
            Dim dtbInvoiceRows As DataTable = Adptr_InvoiceRows.GetData(O_ID)
            For Each drwInvoiceRow As DataRow In dtbInvoiceRows.Rows  'loop through each invoice row in order
                strData.AppendLine("-------------------------------------")
                For i = 0 To dtbInvoiceRows.Columns.Count - 1
                    strData.AppendLine(dtbInvoiceRows.Columns(i).ColumnName & ": [ " & drwInvoiceRow(i).ToString & " ]")
                Next

            Next
            strData.AppendLine("-------------------------------------")
            strData.AppendLine("== End of Order ==")
            strData.AppendLine("")
        Next

        '============== REVIEWS ===============
        strData.AppendLine("")
        strData.AppendLine("== REVIEWS ==")
        strData.AppendLine("")

        Dim dtbReviews As DataTable = Adptr_Reviews.GetData(numUserID)
        For Each drwReview As DataRow In dtbReviews.Rows
            For i = 0 To dtbReviews.Columns.Count - 1

                Dim strColumnName As String = dtbReviews.Columns(i).ColumnName
                Dim strColumnValue As String = drwReview(i).ToString

                'Format dates nicely
                If strColumnName = "REV_DateCreated" Or strColumnName = "REV_DateLastUpdated" Then
                    Try
                        strColumnValue = CkartrisDisplayFunctions.FormatDate(strColumnValue, "t", 1)
                        If strColumnValue.Contains("1/1/1900") Then strColumnValue = "-" 'some default dates are stored as 1/1/1900, but really means no date
                    Catch ex As Exception
                        strColumnValue = "-" 'some issue with converting date, return a dash
                    End Try
                End If

                strData.AppendLine(strColumnName & ": [ " & strColumnValue & " ]")
            Next
        Next

        '============== WISHLISTS ===============
        strData.AppendLine("")
        strData.AppendLine("== WISHLISTS ==")
        strData.AppendLine("")

        Dim dtbWishLists As DataTable = Adptr_WishLists.GetData(numUserID)
        For Each drwWishList As DataRow In dtbWishLists.Rows

            strData.AppendLine("== Start of WishList ==")
            For i = 0 To dtbWishLists.Columns.Count - 1

                Dim strColumnName As String = dtbWishLists.Columns(i).ColumnName
                Dim strColumnValue As String = drwWishList(i).ToString

                'Format dates nicely
                If strColumnName = "WL_DateTimeAdded" Or strColumnName = "WL_LastUpdated" Then
                    Try
                        strColumnValue = CkartrisDisplayFunctions.FormatDate(strColumnValue, "t", 1)
                        If strColumnValue.Contains("1/1/1900") Then strColumnValue = "-" 'some default dates are stored as 1/1/1900, but really means no date
                    Catch ex As Exception
                        strColumnValue = "-" 'some issue with converting date, return a dash
                    End Try
                End If

                strData.AppendLine(strColumnName & ": [ " & strColumnValue & " ]")
            Next
            strData.AppendLine("== End of WishList ==")
            strData.AppendLine("")
        Next

        '============== SUPPORT TICKETS ===============
        strData.AppendLine("")
        strData.AppendLine("== SUPPORT TICKETS ==")
        strData.AppendLine("")

        Dim TIC_ID As Integer = 0 'need this to be found in order to get messages later
        Dim dtbSupportTickets As DataTable = Adptr_SupportTickets.GetData(numUserID)
        For Each drwSupportTicket As DataRow In dtbSupportTickets.Rows 'loop through orders, could be multiple

            strData.AppendLine("== Start of Support Ticket ==")
            For i = 0 To dtbSupportTickets.Columns.Count - 1 'loop through columns

                Dim strColumnName As String = dtbSupportTickets.Columns(i).ColumnName
                Dim strColumnValue As String = drwSupportTicket(i).ToString



                'Get the order ID
                If strColumnName = "TIC_ID" Then TIC_ID = strColumnValue

                'Format dates nicely
                If strColumnName = "TIC_DateOpened" Or strColumnName = "TIC_DateClosed" Then
                    Try
                        strColumnValue = CkartrisDisplayFunctions.FormatDate(strColumnValue, "t", 1)
                        If strColumnValue.Contains("1/1/1900") Then strColumnValue = "-" 'some default dates are stored as 1/1/1900, but really means no date
                    Catch ex As Exception
                        strColumnValue = "-" 'some issue with converting date, return a dash
                    End Try
                End If
                strData.AppendLine(strColumnName & ": [ " & strColumnValue & " ]")

            Next

            '-------------- SUPPORT TICKET MESSAGES --------------
            Dim dtbSupportTicketMesssages As DataTable = Adptr_SupportTicketMessages.GetData(TIC_ID)
            For Each drwSupportTicketMesssage As DataRow In dtbSupportTicketMesssages.Rows  'loop through each message in order
                strData.AppendLine("-------------------------------------")
                For i = 0 To dtbSupportTicketMesssages.Columns.Count - 1
                    strData.AppendLine(dtbSupportTicketMesssages.Columns(i).ColumnName & ": [ " & drwSupportTicketMesssage(i).ToString & " ]")
                Next

            Next
            strData.AppendLine("-------------------------------------")
            strData.AppendLine("== End of Support Ticket ==")
            strData.AppendLine("")
        Next

        '============== SAVED BASKETS ===============
        strData.AppendLine("")
        strData.AppendLine("== SAVED BASKETS ==")
        strData.AppendLine("")

        Dim SBSKT_ID As Integer = 0 'need this to be found in order to get line items later
        Dim dbtSavedBaskets As DataTable = Adptr_SavedBaskets.GetData(numUserID)
        For Each drwSavedBasket As DataRow In dbtSavedBaskets.Rows 'loop through orders, could be multiple

            strData.AppendLine("== Start of Saved Basket ==")
            For i = 0 To dbtSavedBaskets.Columns.Count - 1 'loop through columns

                Dim strColumnName As String = dbtSavedBaskets.Columns(i).ColumnName
                Dim strColumnValue As String = drwSavedBasket(i).ToString

                'Get the saved basket ID
                If strColumnName = "SBSKT_ID" Then SBSKT_ID = strColumnValue

                'Format dates nicely
                If strColumnName = "SBSKT_DateTimeAdded" Or strColumnName = "SBSKT_LastUpdated" Then
                    Try
                        strColumnValue = CkartrisDisplayFunctions.FormatDate(strColumnValue, "t", 1)
                        If strColumnValue.Contains("1/1/1900") Then strColumnValue = "-" 'some default dates are stored as 1/1/1900, but really means no date
                    Catch ex As Exception
                        strColumnValue = "-" 'some issue with converting date, return a dash
                    End Try
                End If
                strData.AppendLine(strColumnName & ": [ " & strColumnValue & " ]")

            Next

            '-------------- SAVED BASKET VALUES --------------
            Dim dtbSavedBasketValues As DataTable = Adptr_SavedBasketValues.GetData(SBSKT_ID)
            For Each drwSavedBasketValue As DataRow In dtbSavedBasketValues.Rows  'loop through each item in order
                strData.AppendLine("-------------------------------------")
                For i = 0 To dtbSavedBasketValues.Columns.Count - 1

                    Dim strColumnName As String = dtbSavedBasketValues.Columns(i).ColumnName
                    Dim strColumnValue As String = drwSavedBasketValue(i).ToString

                    'Format dates nicely
                    If strColumnName = "BV_DateTimeAdded" Then
                        Try
                            strColumnValue = CkartrisDisplayFunctions.FormatDate(strColumnValue, "t", 1)
                            If strColumnValue.Contains("1/1/1900") Then strColumnValue = "-" 'some default dates are stored as 1/1/1900, but really means no date
                        Catch ex As Exception
                            strColumnValue = "-" 'some issue with converting date, return a dash
                        End Try
                    End If
                    strData.AppendLine(strColumnName & ": [ " & strColumnValue & " ]")
                Next

            Next
            strData.AppendLine("-------------------------------------")
            strData.AppendLine("== End of Saved Basket ==")
            strData.AppendLine("")
        Next

        '============== END OF FILE ===============
        strData.AppendLine("============== END OF FILE ===============")

        Return strData.ToString
    End Function
End Class
