<%@ Control Language="VB" AutoEventWireup="false" EnableViewState="false" CodeFile="CategoryMenuAccordion.ascx.vb"
    Inherits="UserControls_Skin_CategoryMenuAccordion" %>
<%
    '-----------------------------------
    'We don't cache this control because
    'it messes up as it seems the js
    'needs to be recreated on each page
    'So probably best not to use this
    'on really big sites.
    '-----------------------------------
%>
<!-- CategoryMenu - accordion -->
<div id="categorymenu">
    <div class="box">
        <div class="accordion">
            <ajaxToolkit:Accordion ID="accCategories" runat="server" AutoSize="none" FramesPerSecond="48"
                RequireOpenedPane="false" SuppressHeaderPostbacks="false" TransitionDuration="150"
                HeaderCssClass="AccordionHeader" ContentCssClass="AccordionContent" SelectedIndex="-1">
            </ajaxToolkit:Accordion>
        </div>
    </div>
</div>