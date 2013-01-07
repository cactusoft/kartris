function CheckBoxValidatorDisableButton(chkId, mustBeChecked, btnId) {
    var button = document.getElementById(btnId);
    var chkbox = document.getElementById(chkId);

    if (button && chkbox) {
        button.disabled = (chkbox.checked != mustBeChecked);
    }
}

function CheckBoxValidatorEvaluateIsValid(val) {
    var control = document.getElementById(val.controltovalidate);
    var mustBeChecked = Boolean(val.mustBeChecked == 'true');

    return control.checked == mustBeChecked;
}
