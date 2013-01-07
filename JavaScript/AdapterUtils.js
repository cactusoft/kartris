function CanHaveClass__Kartris(element)
{
    return ((element != null) && (element.className != null));
}

function HasAnyClass__Kartris(element)
{
    return (CanHaveClass__Kartris(element) && (element.className.length > 0));
}

function HasClass__Kartris(element, specificClass)
{
    return (HasAnyClass__Kartris(element) && (element.className.indexOf(specificClass) > -1));
}

function AddClass__Kartris(element, classToAdd)
{
    if (HasAnyClass__Kartris(element))
    {
        if (!HasClass__Kartris(element, classToAdd))
        {
            element.className = element.className + " " + classToAdd;
        }
    }
    else if (CanHaveClass__Kartris(element))
    {
        element.className = classToAdd;
    }
}

function AddClassUpward__Kartris(startElement, stopParentClass, classToAdd)
{
    var elementOrParent = startElement;
    while ((elementOrParent != null) && (!HasClass__Kartris(elementOrParent, topmostClass)))
    {
        AddClass__Kartris(elementOrParent, classToAdd);
        elementOrParent = elementOrParent.parentNode;
    }    
}

function SwapClass__Kartris(element, oldClass, newClass)
{
    if (HasAnyClass__Kartris(element))
    {
        element.className = element.className.replace(new RegExp(oldClass, "gi"), newClass);
    }
}

function SwapOrAddClass__Kartris(element, oldClass, newClass)
{
    if (HasClass__Kartris(element, oldClass))
    {
        SwapClass__Kartris(element, oldClass, newClass);
    }
    else
    {
        AddClass__Kartris(element, newClass);
    }
}

function RemoveClass__Kartris(element, classToRemove)
{
    SwapClass__Kartris(element, classToRemove, "");
}

function RemoveClassUpward__Kartris(startElement, stopParentClass, classToRemove)
{
    var elementOrParent = startElement;
    while ((elementOrParent != null) && (!HasClass__Kartris(elementOrParent, topmostClass)))
    {
        RemoveClass__Kartris(elementOrParent, classToRemove);
        elementOrParent = elementOrParent.parentNode;
    }    
}

function IsEnterKey()
{
    var retVal = false;
    var keycode = 0;
    if ((typeof(window.event) != "undefined") && (window.event != null))
    {
        keycode = window.event.keyCode;
    }
    else if ((typeof(e) != "undefined") && (e != null))
    {
        keycode = e.which;
    }
    if (keycode == 13)
    {
        retVal = true;
    }
    return retVal;
}


