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
Imports System.Web.HttpContext
Imports System.Collections.Generic
Imports System.Data.Common
Imports CkartrisBLL
Imports CkartrisDataManipulation
Imports System.Web.Configuration
Imports System.Xml
Imports System.Xml.Serialization
Imports KartSettingsManager
Imports System.Web.UI.TemplateControl
Imports System.Globalization
Imports System.Web.UI

Public Class Payment

    Public Shared Function Deserialize(ByVal strValue As String, ByVal strObjectType As Type) As Object
        Dim strStringReader As StringReader = New StringReader(strValue)
        Dim oXS As XmlSerializer '= New XmlSerializer(strObjectType)

        If strObjectType = GetType(Kartris.Basket) Then
            Dim extraTypes(1) As Type
            extraTypes(0) = GetType(List(Of Kartris.Promotion))
            extraTypes(1) = GetType(PromotionBasketModifier)
            oXS = New XmlSerializer(GetType(Kartris.Basket), extraTypes)
        Else
            oXS = New XmlSerializer(strObjectType)
        End If

        Deserialize = oXS.Deserialize(strStringReader)
    End Function

    Public Shared Function Serialize(ByVal strObject As Object) As String
        Try
            'Dim oXS As XmlSerializer = New XmlSerializer(strObject.GetType)
            Dim oXS As XmlSerializer '= New XmlSerializer(strObject.GetType)

            If strObject.GetType = GetType(Kartris.Basket) Then
                Dim extraTypes(1) As Type
                extraTypes(0) = GetType(List(Of Kartris.Promotion))
                extraTypes(1) = GetType(PromotionBasketModifier)
                oXS = New XmlSerializer(GetType(Kartris.Basket), extraTypes)
            Else
                oXS = New XmlSerializer(strObject.GetType)
            End If
            Dim oStrW As New StringWriter()

            'Serialize the object into an XML string
            oXS.Serialize(oStrW, strObject)
            Serialize = oStrW.ToString()
            oStrW.Close()
        Catch ex As Exception
            DumpException(ex)
            Return Nothing
        End Try

    End Function

    Public Shared Sub DumpException(ex As Exception)
        WriteExceptionInfo(ex)
        ex = ex.InnerException
        If ex IsNot Nothing Then
            WriteExceptionInfo(ex.InnerException)
            ex = ex.InnerException
        End If
    End Sub
    Public Shared Sub WriteExceptionInfo(ex As Exception)
        CkartrisFormatErrors.LogError("Message: " & ex.Message & vbCrLf &
                                      "Exception Type: " & ex.[GetType]().FullName & vbCrLf &
                                        "Source: " & ex.Source & vbCrLf &
                                        "StrackTrace: " & ex.StackTrace & vbCrLf)
        'CkartrisFormatErrors.LogError("TargetSite: " & ex.TargetSite)
    End Sub

    Public Shared Function PPLoader(ByVal Path As String) As Interfaces.PaymentGateway
        Dim m_clsPlugins As New Hashtable
        Dim clsType As Type
        Dim clsInterface As Type
        Dim boolAdded As Boolean
        Dim clsPlugins As New Collection
        Dim clsAssembly As System.Reflection.Assembly
        'we're requesting the plugin at the path specified to be added to Kartris. the first step in this process
        'is to try to load the assembly using Reflection. this will give us access to the definitions of the classes defined in 
        'that assembly, and we can look for any classes that implement our PaymentGateway interface...
        Try
            Dim GatewayPath As String = System.Web.HttpContext.Current.Request.PhysicalApplicationPath & "Plugins\" & Path & "\" & Path & ".dll"
            clsAssembly = System.Reflection.Assembly.LoadFrom(GatewayPath)
        Catch ex As Exception
            Throw New System.Exception("An error occured while attempting to access the specified Assembly. - " & ex.Message)
        End Try
        Try
            'look for appropriate types... 
            For Each clsType In clsAssembly.GetTypes
                'only look at types we can create... 
                If clsType.IsPublic = True Then
                    'ignore abstract classes... 
                    If Not ((clsType.Attributes And System.Reflection.TypeAttributes.Abstract) = System.Reflection.TypeAttributes.Abstract) Then
                        'check for the implementation of the specified interface... 
                        clsInterface = clsType.GetInterface("PaymentGateway", True)
                        'process if valid...
                        If Not (clsInterface Is Nothing) Then
                            'create a unique key to identify this plugin (so we don't add it twice)...
                            Dim sPluginKey As String = String.Concat(Path, "_", clsType.FullName)
                            'check to see if we already have this plugin added...
                            If Not m_clsPlugins.ContainsKey(sPluginKey) Then
                                'load the plugin into memory, creating an instance of it...
                                Return LoadPlugin(Path, clsType.FullName)
                                'store a reference to the plugin locally...
                                m_clsPlugins.Add(sPluginKey, PPLoader)
                            End If
                            'set a flag indicating that we have added at least one plugin from the associated file...
                            boolAdded = True
                        End If
                    End If
                End If
            Next
            Return Nothing
        Catch ex As System.Exception
            Return Nothing
        End Try
    End Function

    Private Shared Function LoadPlugin(ByVal AssemblyPath As String, ByVal ClassName As String) As Interfaces.PaymentGateway
        Dim clsRet As Object
        Dim clsAssembly As System.Reflection.Assembly
        Dim GatewayPath As String = System.Web.HttpContext.Current.Request.PhysicalApplicationPath & "Plugins\" & AssemblyPath & "\" & AssemblyPath & ".dll"
        'load the assembly...
        clsAssembly = System.Reflection.Assembly.LoadFrom(GatewayPath)
        'create an instance of the class that implements the PaymentGateway interface...
        clsRet = clsAssembly.CreateInstance(ClassName)
        'return the new instance...
        Return CType(clsRet, Interfaces.PaymentGateway)
    End Function

    Public Shared Function SPLoader(ByVal Path As String) As Interfaces.ShippingGateway
        Dim m_clsPlugins As New Hashtable
        Dim clsType As Type
        Dim clsInterface As Type
        Dim boolAdded As Boolean
        Dim clsPlugins As New Collection
        Dim clsAssembly As System.Reflection.Assembly = Nothing
        'we're requesting the plugin at the path specified to be added to Kartris. the first step in this process
        'is to try to load the assembly using Reflection. this will give us access to the definitions of the classes defined in 
        'that assembly, and we can look for any classes that implement our PaymentGateway interface...
        Try
            Dim GatewayPath As String = System.Web.HttpContext.Current.Request.PhysicalApplicationPath & "Plugins\" & Path & "\" & Path & ".dll"
            If InStr(Path, "GoogleCheckout") Then Return Nothing
            clsAssembly = System.Reflection.Assembly.LoadFrom(GatewayPath)
        Catch ex As Exception
            CkartrisFormatErrors.LogError("An error occured while attempting to access the specified Assembly. - " & ex.Message)
        End Try
        Try
            'look for appropriate types... 
            For Each clsType In clsAssembly.GetTypes
                'only look at types we can create... 
                If clsType.IsPublic = True Then
                    'ignore abstract classes... 
                    If Not ((clsType.Attributes And System.Reflection.TypeAttributes.Abstract) = System.Reflection.TypeAttributes.Abstract) Then
                        'check for the implementation of the specified interface... 
                        clsInterface = clsType.GetInterface("ShippingGateway", True)
                        'process if valid...
                        If Not (clsInterface Is Nothing) Then
                            'create a unique key to identify this plugin (so we don't add it twice)...
                            Dim sPluginKey As String = String.Concat(Path, "_", clsType.FullName)
                            'check to see if we already have this plugin added...
                            If Not m_clsPlugins.ContainsKey(sPluginKey) Then
                                'load the plugin into memory, creating an instance of it...
                                Return LoadSPlugin(Path, clsType.FullName)
                                'store a reference to the plugin locally...
                                m_clsPlugins.Add(sPluginKey, SPLoader)
                            End If
                            'set a flag indicating that we have added at least one plugin from the associated file...
                            boolAdded = True
                        End If
                    End If
                End If
            Next
            Return Nothing
        Catch ex As System.Exception
            CkartrisFormatErrors.LogError("Assembly loaded but there seem to be a problem reading it. - " & Path & " - " & ex.Message)
        End Try
        Return Nothing
    End Function

    Private Shared Function LoadSPlugin(ByVal AssemblyPath As String, ByVal ClassName As String) As Interfaces.ShippingGateway
        Dim clsRet As Object
        Dim clsAssembly As System.Reflection.Assembly
        Dim GatewayPath As String = System.Web.HttpContext.Current.Request.PhysicalApplicationPath & "Plugins\" & AssemblyPath & "\" & AssemblyPath & ".dll"
        'load the assembly...
        clsAssembly = System.Reflection.Assembly.LoadFrom(GatewayPath)
        'create an instance of the class that implements the PaymentGateway interface...
        clsRet = clsAssembly.CreateInstance(ClassName)
        'return the new instance...
        Return CType(clsRet, Interfaces.ShippingGateway)
    End Function

    Public Shared Function GetPluginFriendlyName(ByVal strGatewayName As String) As String
        Try
            Dim strSettingName As String = "FriendlyName(" & LanguagesBLL.GetCultureByLanguageID_s(CInt(System.Web.HttpContext.Current.Session("LANG"))) & ")"

            Dim objConfigFileMap As New ExeConfigurationFileMap()
            objConfigFileMap.ExeConfigFilename = Path.Combine(Current.Request.PhysicalApplicationPath, "Plugins\" & strGatewayName & "\" & strGatewayName & ".dll.config")
            objConfigFileMap.MachineConfigFilename = Path.Combine(Current.Request.PhysicalApplicationPath, "Uploads\resources\Machine.Config")
            Dim objConfiguration As System.Configuration.Configuration = ConfigurationManager.OpenMappedExeConfiguration(objConfigFileMap, ConfigurationUserLevel.None)

            Dim objSectionGroup As ConfigurationSectionGroup = objConfiguration.GetSectionGroup("applicationSettings")
            Dim appSettingsSection As ClientSettingsSection = DirectCast(objSectionGroup.Sections.Item("Kartris.My.MySettings"), ClientSettingsSection)
            Return appSettingsSection.Settings.Get(strSettingName).Value.ValueXml.InnerText
        Catch ex As Exception
            Return ""
        End Try
    End Function
    Public Shared Function isAnonymousCheckoutEnabled(ByVal strGatewayName As String) As Boolean
        Try
            Dim strSettingName As String = "AnonymousCheckout"

            Dim objConfigFileMap As New ExeConfigurationFileMap()
            objConfigFileMap.ExeConfigFilename = Path.Combine(Current.Request.PhysicalApplicationPath, "Plugins\" & strGatewayName & "\" & strGatewayName & ".dll.config")
            objConfigFileMap.MachineConfigFilename = Path.Combine(Current.Request.PhysicalApplicationPath, "Uploads\resources\Machine.Config")
            Dim objConfiguration As System.Configuration.Configuration = ConfigurationManager.OpenMappedExeConfiguration(objConfigFileMap, ConfigurationUserLevel.None)

            Dim objSectionGroup As ConfigurationSectionGroup = objConfiguration.GetSectionGroup("applicationSettings")
            Dim appSettingsSection As ClientSettingsSection = DirectCast(objSectionGroup.Sections.Item("Kartris.My.MySettings"), ClientSettingsSection)
            Dim blnAnonymousCheckoutValue As Boolean = False
            Try
                blnAnonymousCheckoutValue = CBool(appSettingsSection.Settings.Get(strSettingName).Value.ValueXml.InnerText)
            Catch ex As Exception

            End Try
            Return blnAnonymousCheckoutValue
        Catch ex As Exception
            Return ""
        End Try
    End Function

End Class