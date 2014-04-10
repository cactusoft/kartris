'========================================================================
'Kartris Bitcoin Payments Checker Script - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC
'www.cactusoft.com

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================

'-----------------------------------------------
'SETTINGS
'These ones require changing depending on
'the network and database setup. 
'-----------------------------------------------

'====================
'Kartris Database
'====================
strKartrisDBName = "KartrisSQL_GPL"
strKartrisDBServerName = "localhost\SQLExpress"
blnUseWindowsAuth = false
strKartrisDBUserName = "sa"
strKartrisDBPassword = "sa"
strKartrisDBPort = 1433

'====================
'Bitcoin Client - Should match with your Bitcoin payment gateway settings in Kartris
'====================
strBitcoinHost = "http://localhost"
strBitcoinPort = "8332"
strBitcoinUsername = "bitcoinrpc"  
strBitcoinPassword = "test"

'=======================
'REQUIRED CONFIRMATIONS
'Number of confirmations for bitcoin payments to be considered 'paid'
'=======================
intRequiredConfirmation = "1"

'====================
'WORKING FOLDER PATH
'Folder where the log files will be saved to
'====================
'--don't forget to put backslash at the end (\)
strWorkingFolderPath = "C:\Users\Medz\Desktop\"
'Whether to only log confirmed payments, will not log queries for addresses that returns 0.
'*True = smaller log file size but with less details. 
blnLogConfirmedPaymentsOnly = True

'====================
'Other Settings
'====================
numCursorType = 1 'for SQL Server
strEmailMethod = "off"
strMailServer = "localhost"
strEmailFromAddress = "no_reply@server.com"
strEmailSubject = "Summary"

'-----------------------------------------------
'/SETTINGS
'-----------------------------------------------

'No need to edit this
strKartrisConnection= "Provider=SQLNCLI10.1;Data Source=" & strKartrisDBServerName & ";Initial Catalog=" & strKartrisDBName & ";" 
If blnUseWindowsAuth Then
		strKartrisConnection = strKartrisConnection & "Integrated Security=SSPI"
Else
		strKartrisConnection = strKartrisConnection & "uid=" & strKartrisDBUserName & ";PWD=" & strKartrisDBPassword & ";Persist Security Info=True;"
End If

'-----------------------------------------------
'READY THE POPUP MESSAGE
'-----------------------------------------------
Set WshShell = WScript.CreateObject("WScript.Shell")

Set objDataConn = CreateObject("ADODB.Connection")
Set objRecordSet = CreateObject("ADODB.Recordset")
Set objCommand = CreateObject("ADODB.Command")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objKartrisRecordSet2 = CreateObject("ADODB.Recordset")

'-----------------------------------------------
'CREATE THE LOG FILE NAME
'-----------------------------------------------
strLogFileName = BuildFileName(now(),"_bitcoinpaymentschecklog.txt")

Set objLogFile = objFSO.CreateTextFile(strLogFileName, True)

'Call Wshshell.popup("The script will generate the log file - " & strLogFileName, 7, "Kartris Bitcoin Payments Checker", 0)

'-----------------------------------------------
'QUERY THE KARTRIS DATABASE
'-----------------------------------------------

Dim objKartrisDataConn
Dim objKartrisRecordSet
Dim strQuery

'objLogFile.Write "Trying to open connection to Kartris database..."

strQuery = "SELECT tblKartrisOrders.O_ID, tblKartrisOrders.O_CustomerID, tblKartrisOrders.O_PaymentGateWay, tblKartrisOrders.O_ReferenceCode, tblKartrisOrders.O_CurrencyIDGateway,  tblKartrisCurrencies.CUR_ExchangeRate, tblKartrisOrders.O_TotalPriceGateway FROM tblKartrisOrders LEFT OUTER JOIN tblKartrisCurrencies ON tblKartrisOrders.O_CurrencyIDGateway = tblKartrisCurrencies.CUR_ID WHERE (tblKartrisOrders.O_Sent = 1) AND (tblKartrisOrders.O_Paid = 0) AND (tblKartrisOrders.O_PaymentGateWay = 'bitcoin')"

Set objKartrisDataConn = CreateObject("ADODB.Connection")
Set objKartrisRecordSet = CreateObject("ADODB.Recordset")

objKartrisDataConn.ConnectionString=strKartrisConnection
objKartrisDataConn.Open 
objKartrisRecordSet.cursorType = numCursorType
objKartrisRecordSet.Open strQuery,objKartrisDataConn
'objLogFile.WriteLine "DONE!"

If NOT blnLogConfirmedPaymentsOnly Then 
    objLogFile.WriteLine "======================================================="
    objLogFile.WriteLine "        KARTRIS BITCOIN PAYMENTS CHECKER SCRIPT"
    objLogFile.WriteLine "'[VERBOSE MODE ON] (blnLogConfirmedPaymentsOnly=False)"
    objLogFile.WriteLine "=======================================================" & vbcrlf
End If

'objLogFile.WriteLine "Fetching unpaid bitcoin orders from Kartris database..."

objLogFile.WriteLine objKartrisRecordSet.RecordCount & " unpaid bitcoin orders in Kartris db..."
objLogFile.WriteLine ""

objKartrisRecordSet.MoveFirst

Set objRequest = createobject("MSXML2.XMLHTTP.3.0") 

intPaidOrder = 0

Do while not objKartrisRecordSet.EOF
      strBitcoinPaymentAddress = objKartrisRecordSet("O_ReferenceCode") & ""
      OrderID = objKartrisRecordSet("O_ID") & ""
      numTotalPriceGateway = objKartrisRecordSet("O_TotalPriceGateway") & ""
      CustomerID = objKartrisRecordSet("O_CustomerID") & ""
      O_GatewayCurrencyID = objKartrisRecordSet("O_CurrencyIDGateway") & ""
      O_GatewayCurrencyRate = objKartrisRecordSet("CUR_ExchangeRate") & ""
      If strBitcoinPaymentAddress <> "" AND OrderID > 0 AND numTotalPriceGateway > 0 then
          
          If NOT blnLogConfirmedPaymentsOnly Then objLogFile.WriteLine "Checking order : " & OrderID 
          strBitCoinHostAddress = strBitcoinHost & ":" & strBitcoinPort

          s = "{""jsonrpc"":""1.0"",""id"":""" & OrderID & """,""method"":""getreceivedbyaddress"",""params"":[""" & _
              strBitcoinPaymentAddress & """," & intRequiredConfirmation & "]}"

          objRequest.open "POST", strBitCoinHostAddress, False, strBitcoinUsername, strBitcoinPassword

          objRequest.setRequestHeader "Content-Type", "application/json; charset=UTF-8" 
          objRequest.setRequestHeader "CharSet", "utf-8" 
          objRequest.setRequestHeader "SOAPAction", strBitCoinHostAddress
          
          On Error Resume Next
          objRequest.send s
          strResponseText = objRequest.responseText
          If err.Description <> "" Then
              objLogFile.WriteLine "Error contacting Bitcoin client. Please check your settings: " & Err.Description
              Exit Do
          End If
          On Error Goto 0
          
          If objRequest.Status = 200 Then
               'remove preceeding result text
               numPaymentAmount = Replace(strResponseText,"{""result"":","")
               'remove succeeding result text
               numPaymentAmount = cdbl(Left(numPaymentAmount,instr(numPaymentAmount,",")-1))
               
               'Payment amount matches or is greater than total gateway price, update the order
               If numPaymentAmount => cdbl(numTotalPriceGateway) then
                   objLogFile.WriteLine "response: " & Replace(strResponseText,vblf,"")
                   objLogFile.WriteLine "Payment amount received. Marking order as 'paid' in the database..."
                   strQuery = "UPDATE tblKartrisOrders SET O_Paid = 1 WHERE O_ID = " & OrderID
                   
                   Call ExecuteSQL(strQuery, numCursorType, objKartrisRecordSet2, "")
                   
                   'Also add payment record
                   strQuery = "SET NOCOUNT ON INSERT INTO [dbo].[tblKartrisPayments] ([Payment_CustomerID] ,[Payment_Date] ,[Payment_Amount] ,[Payment_CurrencyID] ,[Payment_ReferenceNo] ,[Payment_Gateway] ,[Payment_CurrencyRate]) VALUES (" & CustomerID & ",'" & ReverseFormatYear(Now()) & "'," & numPaymentAmount & "," & O_GatewayCurrencyID & ",'" &strBitcoinPaymentAddress & "','bitcoin'," & O_GatewayCurrencyRate & ") SELECT @@IDENTITY AS NewID SET NOCOUNT OFF"
                   
                    Set objRecordSet = objKartrisDataConn.Execute(strQuery)
                    
                    lngPaymentID = objRecordSet("NewID")
                   
                   strQuery = "INSERT INTO [dbo].[tblKartrisOrderPaymentLink] ([OP_PaymentID] ,[OP_OrderID] ,[OP_OrderCanceled]) VALUES (" & lngPaymentID & "," & OrderID & ", 0)"
                   Call ExecuteSQL(strQuery, numCursorType, objKartrisRecordSet2, "")
                   
                   objLogFile.WriteLine "Done."
                   intPaidOrder = intPaidOrder + 1
                   objLogFile.WriteLine ""
                ElseIf numPaymentAmount = 0 Then
                    If NOT blnLogConfirmedPaymentsOnly Then
                        objLogFile.WriteLine "response: " & Replace(strResponseText,vblf,"")
                        objLogFile.WriteLine "No payment yet."
                        objLogFile.WriteLine ""
                    End If
                End if
           Else
              objLogFile.WriteLine "response: " & Replace(strResponseText,vblf,"")
              objLogFile.WriteLine "Error encountered in one of the record/s. Skipped."
              objLogFile.WriteLine ""
          End If
          
      End If
    objKartrisRecordSet.MoveNext
Loop

objLogFile.WriteLine intPaidOrder & " matching payments found. DONE!"
objKartrisRecordSet.close

set objRequest = Nothing

'-----------------------------------------------
'SHOW 'COMPLETED' POPUP
'Disable this once everything installed and
'working.
'-----------------------------------------------
'Call WshShell.Popup("The script has written log file entries. The process is complete.", 3, "Process complete!", 0)


'-----------------------------------------------
'CLEAN UP AFTER OURSELVES
'-----------------------------------------------
Set objFileSystem = nothing
Set strLogFileName = nothing
Set objDataConn = nothing
Set objCommand = nothing
Set objRecordSet = nothing



'===============================================
' FUNCTIONS & SUBROUTINES
' Put them here to keep them out of the way
'===============================================

'-----------------------------------------------
'EXECUTE A SQL QUERY STRING
'-----------------------------------------------
Sub ExecuteSQL(strQuery, numCursorType, objRecordSet, strLogInfo)
	'On Error Resume Next
	objCommand.CommandText = strQuery
	objCommand.CommandType = 1
	Set objCommand.ActiveConnection = objKartrisDataConn
	SET objRecordSet = objCommand.Execute
	if err.Description <> "" then
		strErrorText = "An error occurred while executing query: " & strQuery & ": " & err.Description
		objLogFile.WriteLine strErrorText
	end if
	'on error goto 0
End Sub


'-----------------------------------------------
'ENSURE APOSTROPHES DON'T SCREW UP SQL QUERIES
'Since SQL strings use apostrophes, input is
'truncated if you include apostrophes in a text
'box and then submit it. Not any more...	
'-----------------------------------------------
Function SQLSafe(strText)
	SQLSafe = Replace(strText, "'", "''")
End Function


'-----------------------------------------------
'FORMAT DATE IN REVERSE FORMAT					
'e.g. 2000/12/1 for 1st December 2000. This way	
'works (or should work) in all language formats	
'and in the US or UK where standard numerical	
'dates are written MM/DD/YYYY or DD/MM/YYYY.	
'You wouldn't believe how many problems dates	
'cause...
						
'-----------------------------------------------
Function ReverseFormatYear(datDate)
    'On Error Resume Next
	If IsNull(datDate) then 
		strReverseFormatYear = ""
	elseif CStr(datDate) = "" then
		strReverseFormatYear = ""
	elseif Len(datDate) < 2 then
	    strReverseFormatYear = ""
	elseif InStr(datDate, " ") > 0 then 'in case date is format 25 Dec 2005 (some dates in the XML are, but only in text fields - I'm just being careful!)
		If IsDate(datDate) then
			strReverseFormatYear = (Year(datDate) & "/" & Month(datDate) & "/" & Day(datDate))
		Else
			strReverseFormatYear = "1900/01/01"
		End if
	elseif Cstr(datDate) = "00/00/0000" then
		strReverseFormatYear = "1900/01/01"
	elseif Cstr(datDate) = "00000000" then
		strReverseFormatYear = "1900/01/01"
	elseif InStr(datDate, "/") = 0 then
	    ' There is no /, and so it's an error
	     strReverseFormatYear = ""
	else
		aryDate = split(datDate, "/")
		strReverseFormatYear = (aryDate(2) & "/" & aryDate (1) & "/" & aryDate(0))
		'If Err.number > 0 then
		'    Call Wshshell.popup("Date field is wrong!: >>" & datDate & "<<" , 7, "Date Wrong!", 0)
		'end if
	end if
	ReverseFormatYear = strReverseFormatYear
	'On Error Goto 0
End Function

'-----------------------------------------------
'SEND MAIL FUNCTION
'This supports CDONTS and CDOSYS, the two common
'Microsoft methods for sending email from
'scripts. This function is similar to the ones
'we use on web sites but note that objects are
'created a bit differently - no server-dot in
'front of them. Using the function to send mail
'should make it easy to switch between the two
'methods. CDONTS is the win2000 default and
'CDOSYS is used on win2003/XP. It is possible to
'run CDONTS on win2003/XP by installing the
'cdonts.dll file.
'-----------------------------------------------
Sub SendEMail(strEmailMethod, strMailServer, strToAddress, strCCAddress, strBCCAddress, strFromAddress, strFromName, strReplyAddress, strReplyName, strSubjectLine, strBodyText, strAttachmentPath1, strAttachmentPath2, blnHTML)

	strEmailMethod = lcase(strEmailMethod)

	Select Case strEmailMethod

		Case "cdo", "cdonts"
			Set objMail = CreateObject("CDONTS.NewMail")
			objMail.To = strToAddress
			If strCCAddress <> "" then objMail.CC = strCCAddress
			If strBCCAddress <> "" then objMail.BCC = strBCCAddress
			objMail.From = strFromAddress
			objMail.Value("Reply-To") = strReplyAddress
			If blnHTML then
				objMail.BodyFormat = 0 
				objMail.MailFormat = 0 
			end if
			objMail.Subject = strSubjectLine
			objMail.Body = strBodyText
			If strAttachmentPath1 <> "" then objMail.AttachFile strAttachmentPath1, "file1"
			If strAttachmentPath2 <> "" then objMail.AttachFile strAttachmentPath2, "file2"
			objMail.Send
			Set objMail = Nothing
			
		case "cdosys" '(CDOSYS is the successor to CDONTS, used on Win2004 servers)
			
			'Create the CDOSYS objects, objCDOSYSCon
			Dim objCDOSYSMail, objCDOSYSCon
			Set objCDOSYSMail = CreateObject("CDO.Message")
			Set objCDOSYSCon = CreateObject("CDO.Configuration")
			
			'Set configuration settings
			objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpserverport")  = 25
			
			If strMailServer <> "" then
				'if a mail server is set, use that
				objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
				objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpserver") = strMailServer
			else
				'otherwise use the local SMTP service pickup directory
				objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/sendusing") = 1
			end if			
			
			'Set the configuration of the message
			objCDOSYSCon.Fields.Update
			Set objCDOSYSMail.Configuration = objCDOSYSCon
			Set objCDOSYSCon = nothing
			
			'Set settings and send the email 
			With objCDOSYSMail
				.From = strFromAddress
				.To = strToAddress
				.Subject = strSubjectLine
				.ReplyTo = strReplyAddress
				If strCCAddress <> "" then .CC = strCCAddress
				If strBCCAddress <> "" then .BCC  = strBCCAddress
				If blnHTML then .HTMLBody = strBodyText else .TextBody = strBodyText
				If strAttachmentPath1 <> "" then objCDOSYSmail.AddAttachment strAttachmentPath1
				If strAttachmentPath2 <> "" then objCDOSYSmail.AddAttachment strAttachmentPath2
				.Send
			End With
			
			'Destroy mailing object
			Set objCDOSYSMail = nothing

		Case Else
			'JUST DO NOTHING
			'This is way of disabling mail sends totally, again, useful for debugging
	End Select
End Sub

'-----------------------------------------------
'CREATE FILE NAME FUNCTION
'The names are based on the date data, i.e.
'20130710_1315.txt (10th Jul 2013 1:15PM). 
'-----------------------------------------------
Function BuildFileName(datInput,strExtension)
	BuildFileName = Year(datInput)
	If Month(datInput) < 10 Then
		BuildFileName = BuildFileName & "0" & Month(datInput)
	Else
		BuildFileName = BuildFileName & Month(datInput)
	End if
	
	If Day(datInput) < 10 Then
		BuildFileName = BuildFileName & "0" & Day(datInput)
	Else
		BuildFileName = BuildFileName & Day(datInput)	
	End If
	BuildFileName = strWorkingFolderPath & BuildFileName & "_" & BuildTimeCode(datInput) & strExtension
End Function

'-----------------------------------------------
'CREATE TIME CODE FUNCTION
'Nice easy way to create 4 digit time, e.g.
'1230, 0855, etc.
'-----------------------------------------------
Function BuildTimeCode(timInput)
	If Hour(timInput) < 10 Then
		BuildTimeCode = BuildTimeCode & "0" & Hour(timInput)
	Else
		BuildTimeCode = BuildTimeCode & Hour(timInput)	
	End If

	If Minute(timInput) < 10 Then
		BuildTimeCode = BuildTimeCode & "0" & Minute(timInput)
	Else
		BuildTimeCode = BuildTimeCode & Minute(timInput)
	End if
End Function