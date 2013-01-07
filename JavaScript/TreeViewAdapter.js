var collapseClass = "Kartris-TreeView-Collapse";
var expandClass = "Kartris-TreeView-Expand";
var showClass = "Kartris-TreeView-Show";
var hideClass = "Kartris-TreeView-Hide";

function IsExpanded__KartrisTreeView(element)
{
    return (HasClass__Kartris(element, collapseClass));
}

function TogglePlusMinus__KartrisTreeView(element, showPlus)
{
    if (HasAnyClass__Kartris(element))
    {
        var showPlusLocal = IsExpanded__KartrisTreeView(element);
        if ((typeof(showPlus) != "undefined") && (showPlus != null))
        {
            showPlusLocal = showPlus;
        }    
        var oldClass = showPlusLocal ? collapseClass : expandClass;
        var newClass = showPlusLocal ? expandClass : collapseClass;
        SwapClass__Kartris(element, oldClass, newClass);
    }
}

function ToggleChildrenDisplay__KartrisTreeView(element, collapse)
{
    if ((element != null) && (element.parentNode != null) && (element.parentNode.getElementsByTagName != null))
    {    
        var childrenToHide = element.parentNode.getElementsByTagName("ul");
        var oldClass = collapse ? showClass : hideClass;
        var newClass = collapse ? hideClass : showClass;
    	for (var i=0; i<childrenToHide.length; i++)
    	{
    	    if ((childrenToHide[i].parentNode != null) && (childrenToHide[i].parentNode == element.parentNode))
    	    {
        	    SwapOrAddClass__Kartris(childrenToHide[i], oldClass, newClass);
        	}
		}
	}
}

function ExpandCollapse__KartrisTreeView(sourceElement)
{
    if (HasAnyClass__Kartris(sourceElement))
    {
        var expanded = IsExpanded__KartrisTreeView(sourceElement);
        TogglePlusMinus__KartrisTreeView(sourceElement, expanded);
        ToggleChildrenDisplay__KartrisTreeView(sourceElement, expanded);
    }
}

function GetViewState__KartrisTreeView(id)
{
    var retStr = "";
    if ((typeof(id) != "undefined") && (id != null) && (document.getElementById(id) != null))
    {
        var topUL = document.getElementById(id);
        retStr = ComposeViewState__KartrisTreeView(topUL, "");        
    }
    return retStr;
}

function ComposeViewState__KartrisTreeView(element, state)
{
    var child = element.firstChild;
    var bConsiderChildren = true;

    //  The following line must be changed if you alter the TreeView adapters generation of
    //  markup such that the first child within the LI no longer is the expand/collapse <span>.
    if ((element.tagName == "LI") && (child != null))
    {
        var expandCollapseSPAN = null;
        var currentChild = child;
        while (currentChild != null)
        {
            if ((currentChild.tagName == "SPAN") &&
                (currentChild.className != null) &&
                ((currentChild.className.indexOf(collapseClass) > -1) ||
                 (currentChild.className.indexOf(expandClass) > -1)))
            {
                expandCollapseSPAN = currentChild;
                break;
            }
            currentChild = currentChild.nextSibling;
        }
    
        if (expandCollapseSPAN != null)
        {
            if (expandCollapseSPAN.className.indexOf(collapseClass) > -1)
            {
                //  If the "collapse" class is currently being used then the "collapse" icon is, presumably, being shown.
                //  In other words, the node itself is actually expanded at the present moment (which is why you now
                //  have the option of collapsing it.  So we mark it as an "expanded" node for purposes of the view state
                //  we are now accumulating.
                state +=  "e";
            }
            else if (expandCollapseSPAN.className.indexOf(expandClass) > -1)
            {
                //  This part of the tree is collapsed so we don't need to consider its children.
                bConsiderChildren = false;
                state +=  "n";
            }
        }
    }
        
    if (bConsiderChildren && (child != null))
    {
        state = ComposeViewState__KartrisTreeView(child, state);
    }
    
    if (element.nextSibling != null)
    {
        state = ComposeViewState__KartrisTreeView(element.nextSibling, state);
    }
    
    return state;
}
