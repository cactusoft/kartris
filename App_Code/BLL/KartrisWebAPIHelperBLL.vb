'========================================================================
'Kartris - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC
'Copyright 2014 POLYCHROME (additions and changes related to Web API)

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports Microsoft.VisualBasic
Imports CkartrisEnumerations
Imports System.Xml.Serialization

Public Class KartrisWebAPIHelperBLL
    ''' <summary>
    ''' Serialize Function
    ''' </summary>
    ''' <param name="strObject">Name of the object being passed in</param>
    ''' <returns>XML String</returns>
    ''' <remarks></remarks>
    Public Shared Function Serialize(ByVal strObject As Object) As String
        Dim strType As String = strObject.GetType.ToString.ToLower
        Debug.Print(strType)

        If strType = "system.data.datatable" Then
            Return SerializeTableToString(strObject)
        Else
            Dim oXS As XmlSerializer = New XmlSerializer(strObject.GetType)
            Dim oStrW As New StringWriter()

            'Serialize the object into an XML string
            oXS.Serialize(oStrW, strObject)
            Serialize = oStrW.ToString()
            oStrW.Close()
        End If
    End Function

    ''' <summary>
    ''' Serialize Datatable
    ''' </summary>
    ''' <param name="ptable">Datatable to be serialized</param>
    ''' <returns>XML String</returns>
    ''' <remarks></remarks>
    Public Shared Function SerializeTableToString(ptable As DataTable) As String
        If ptable Is Nothing Then
            Return Nothing
        Else
            Using sw = New StringWriter()
                Using tw = New XmlTextWriter(sw)
                    ' Must set name for serialization to succeed.
                    ptable.TableName = "results"
                    tw.Formatting = Formatting.Indented
                    tw.WriteStartDocument()
                    tw.WriteStartElement("KartrisdataTable")

                    DirectCast(ptable, Serialization.IXmlSerializable).WriteXml(tw)

                    tw.WriteEndElement()
                    tw.WriteEndDocument()
                    tw.Flush()
                    tw.Close()
                    sw.Flush()

                    Return sw.ToString()
                End Using
            End Using
        End If
    End Function

    ''' <summary>
    ''' Datable of Language Elements
    ''' </summary>
    ''' <returns>Datatable</returns>
    ''' <remarks></remarks>
    Public Shared Function Create_ptblElements() As DataTable
        Dim dt As New DataTable
        dt.TableName = "tblCategoryLanguageElements"

        dt.Columns.Add(New DataColumn With {.ColumnName = "_LE_LanguageID", .DataType = System.Type.GetType("System.String")})
        dt.Columns.Add(New DataColumn With {.ColumnName = "_LE_FieldID", .DataType = System.Type.GetType("System.String")})
        dt.Columns.Add(New DataColumn With {.ColumnName = "_LE_Value", .DataType = System.Type.GetType("System.String")})

        Return dt
    End Function

    ''' <summary>
    ''' Add Row to Datatable of Language Elements
    ''' </summary>
    ''' <param name="p_ptblElements">Datatable name</param>
    ''' <param name="pLE_LanguageID">ID of language element</param>
    ''' <param name="p_LE_FieldID">Type of language element (ID of Type)</param>
    ''' <param name="p_LE_Value">Value of language element</param>
    ''' <remarks></remarks>
    Public Shared Sub Add_ptblElements_Row(p_ptblElements As DataTable, pLE_LanguageID As Int32, p_LE_FieldID As Int32, p_LE_Value As String)
        p_ptblElements.Rows.Add(pLE_LanguageID, p_LE_FieldID, p_LE_Value)
    End Sub

    ''' <summary>
    ''' Get ID of country by ISO code
    ''' </summary>
    ''' <param name="pISOCode3Letter">Three letter ISO country code</param>
    ''' <remarks></remarks>
    Public Shared Function GetCountryID(pISOCode3Letter As String) As Int32
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Try
            Using sqlConn As New SqlClient.SqlConnection(strConnString)

                Dim cmd As SqlCommand = sqlConn.CreateCommand
                cmd.CommandText = "SELECT D_ID, D_ISOCode3Letter FROM tblKartrisDestination WHERE (D_ISOCode3Letter = @Code)"
                cmd.Parameters.AddWithValue("@Code", pISOCode3Letter)

                Using da As New SqlClient.SqlDataAdapter
                    Dim dt As New DataTable

                    da.SelectCommand = cmd
                    da.Fill(dt)

                    If dt.Rows.Count > 0 Then
                        For Each drow As DataRow In dt.Rows
                            Return drow("D_ID")
                        Next
                    Else
                        Return 0
                    End If
                End Using
            End Using

        Catch ex As Exception
            Return 0
        End Try
        Return 0
    End Function

    ''' <summary>
    ''' Check if language element exists, return parent ID if it does
    ''' </summary>
    ''' <param name="pCode">Code</param>
    ''' <param name="pLE_Type">Language element type</param>
    ''' <remarks></remarks>
    Public Shared Function ItemExists(pCode As String, pLE_Type As LANG_ELEM_TABLE_TYPE) As Int32
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Try
            Using sqlConn As New SqlClient.SqlConnection(strConnString)

                Dim cmd As SqlCommand = sqlConn.CreateCommand
                cmd.CommandText = String.Format("SELECT LE_LanguageID, LE_TypeID, LE_FieldID, LE_ParentID, LE_Value, LE_ID FROM tblKartrisLanguageElements WHERE (LE_TypeID = {0}) AND (LE_FieldID = 1) AND (LE_Value = @Code)", Convert.ToInt32(pLE_Type))
                cmd.Parameters.AddWithValue("@Code", pCode)
                Using da As New SqlClient.SqlDataAdapter

                    Dim dt As New DataTable

                    da.SelectCommand = cmd
                    da.Fill(dt)

                    If dt.Rows.Count > 0 Then
                        For Each drow As DataRow In dt.Rows
                            Return drow("LE_ParentID")
                        Next
                    Else
                        Return 0
                    End If
                End Using
            End Using
        Catch ex As Exception
            Return 0
        End Try
        Return 0
    End Function
End Class
