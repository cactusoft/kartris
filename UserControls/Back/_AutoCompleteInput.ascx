<%@ Control Language="VB" AutoEventWireup="false" CodeFile="_AutoCompleteInput.ascx.vb" Inherits="_AutoCompleteInput" %>

<asp:TextBox runat="server" ID="txtBox" autocomplete="off" />
            <ajaxToolkit:AutoCompleteExtender
                runat="server" 
                BehaviorID="bhvCompleteEx"
                ID="autCompleteCtrl" 
                TargetControlID="txtBox"
                ServicePath="~/Admin/kartrisServices.asmx" 
                MinimumPrefixLength="1" 
                CompletionInterval="500"
                ServiceMethod="GetCategories"
                EnableCaching="true"
                CompletionSetCount="10"
                CompletionListCssClass="autocomplete_completionListElement" 
                CompletionListItemCssClass="autocomplete_listItem" 
                CompletionListHighlightedItemCssClass="autocomplete_highlightedListItem"
                DelimiterCharacters=","
                UseContextKey="true">
                <Animations>
                    <OnShow>
                        <Sequence>
                            <%-- Make the completion list transparent and then show it --%>
                            <OpacityAction Opacity="0" />
                            <HideAction Visible="true" />
                            
                            <%--Cache the original size of the completion list the first time
                                the animation is played and then set it to zero --%>
                            <ScriptAction Script="
                                // Cache the size and setup the initial size
                                var behavior = $find('bhvCompleteEx');
                                if (!behavior._height) {
                                    var target = behavior.get_completionList();
                                    behavior._height = target.offsetHeight - 2;
                                    target.style.height = '0px';
                                }" />
                            
                            <%-- Expand from 0px to the appropriate size while fading in --%>
                            <Parallel Duration=".2">
                                <FadeIn />
                                <Length PropertyKey="height" StartValue="0" EndValueScript="$find('bhvCompleteEx')._height" />
                            </Parallel>
                        </Sequence>
                    </OnShow>
                    <OnHide>
                        <%-- Collapse down to 0px and fade out --%>
                        <Parallel Duration=".2">
                            <FadeOut />
                            <Length PropertyKey="height" StartValueScript="$find('bhvCompleteEx')._height" EndValue="0" />
                        </Parallel>
                    </OnHide>
                </Animations>
            </ajaxToolkit:AutoCompleteExtender>

            <script type="text/javascript">
                // Work around browser behavior of "auto-submitting" simple forms
                var frm = document.getElementById("aspnetForm");
                if (frm) {
                    frm.onsubmit = function() { return false; };
                }
            </script>
