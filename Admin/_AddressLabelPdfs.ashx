<%@ WebHandler Language="VB" Class="_AddressLabelPdfs" %>

'    DispatchLabels.ascx is a custom control that allows users to select
'    a label format from a drop down and then send the client to a handler
'    that will output a PDF file of dispatch labels in that format.
'    Copyright (C) 2014  Craig Moore - Deadline Automation Limited.
'
'    GNU GENERAL PUBLIC LICENSE v2
'    This program is free software distributed under the GPL without any
'    warranty.
'    www.gnu.org/licenses/gpl-2.0.html
'
'    If you make any modifications to this program please clearly state who,
'    when and some small details in this header.

Imports System
Imports System.Web

Public Class _AddressLabelPdfs : Implements IHttpHandler
    Private _context As HttpContext
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        _context = context
        
        Dim segments() As String = context.Request.Url.Segments
        
        ' Produce a switch based on the last element of the url.
        ' This allows us to use this handler for multiple purposes. e.g. if you wanted to produce dispatch labels you would call
        ' _AddressLabelPdfs.ashx/dispatchlabels and then you can put query string parameters on the end. e.g.
        ' _AddressLabelPdfs.ashx/dispatchlabels?para1=123&para2=456
        Select Case segments(segments.Count - 1).ToLower
            Case "dispatchlabels"
                DispatchLabels()
            Case Else
                context.Response.ContentType = "text/plain"
                context.Response.Write("No Function!")
        End Select
    End Sub
    
    Public Sub DispatchLabels()
        
        Dim myMem As MemoryStream
        Dim lf As LabelFormat
        
        If IsNumeric(_context.Request.QueryString("FId")) Then
            ' We have got a label format Id. Now load it.
            lf = LabelFormatBLL.GetLabelFormat(CInt(_context.Request.QueryString("FId")))
        Else
            _context.Response.Write("Label format Id missing.")
            _context.Response.End()
            Exit Sub
        End If
        
        If IsNothing(lf) Then
            ' Label format failed to retrieve (maybe an incorrect ID)
            _context.Response.Write("Label format could not be retrieved from database.")
            _context.Response.End()
            Exit Sub
        End If
        
        ' Get the PDF
        myMem = PdfLabelUtil.GeneratePdfDispatchLabels(lf, 1)
        Dim docData() As Byte = Nothing
        
        Try
            ' Convert PDF memory stream into byte array.
            docData = myMem.GetBuffer
        Catch ex As Exception
            CkartrisFormatErrors.LogError(ex.Message)
        End Try
        If Not IsNothing(docData) Then
            _context.Response.AppendHeader("Content-Disposition", "inline; filename=DispatchLabels.pdf")
            _context.Response.ContentType = "application/pdf"
            _context.Response.BinaryWrite(docData)
            _context.Response.End()
        Else
            _context.Response.Write("No document data to display.")
            _context.Response.End()
        End If
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class