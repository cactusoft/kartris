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

Imports System.ServiceModel

<ServiceContract()>
Public Interface IKartrisWebAPI

    <OperationContract()>
    Function Execute(ByVal strMethod As String, ByVal strParametersXML As String) As String
End Interface
