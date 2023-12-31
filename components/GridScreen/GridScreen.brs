' entry point of GridScreen.
' Note that we need to iport this file in GridScreen.xml using relative path.
sub Init()
    'm.rowList = m.top.FindNode("rowList")
	m.rowList = m.top.FindNode("zoomRowList")
    m.rowList.SetFocus(true)

    ' Check for user requested optional text color change.
    ' NOTE: we need to query the manifest because the global node
    ' is not establised at this time due to execution timing.
    textColor = GetValueFromManifest("TEXT_COLOR")

    print "textColor" 
    print textColor

    print "m.rowList"
    print m.rowList.id

    if textColor <> invalid and textColor <> ""
        m.rowList.rowTitleColor = textColor
    end if

    ' label with item description.
    m.descriptionLabel = m.top.FindNode("descriptionLabel")

    ' observe visible field so we can see GridScreen change visibility.
    m.top.ObserveField("visible", "OnVisibleChange")

    ' label with item title.
    m.titleLabel = m.top.FindNode("titleLabel")

    ' observe rowItemFocused so we can know when another item of rowList will be focused.
    m.rowList.ObserveField("rowItemFocused", "OnItemFocused")
end sub

sub OnVisibleChange()
    if m.top.visible = true
        m.rowList.SetFocus(true)    ' set focus to RowList if GridScreen is visible.
    end if
end sub

sub OnItemFocused() ' invoked when another item is focused.
    focusedIndex = m.rowList.rowItemFocused ' get position of focused item.
    row = m.rowList.content.GetChild(focusedIndex[0])   ' get all items of row.
    item = row.GetChild(focusedIndex[1])    ' get focused item.

    if item <> invalid
        ' update description label with description of focused item.
        m.descriptionLabel.text = item.shortDescription
        ' update title label with title of focused item.
        m.titleLabel.text = item.title
        ' append length of playback to the title if item length field was populated.
        if item.length <> invalid and item.length <> 0
            m.titleLabel.text += " | " + GetTime(item.length)
        end if
    else
        m.descriptionLabel.text = "Content for this category has not been defined."
        m.titleLabel.text = "Warning: Missing content."
    end if

    ApplyManifestOptions(item)

end sub

'''''''''
' ApplyManifestOptions: Apply any manifest options.
' 
' @param {object} I: _item - the selected grid item.
' @return {dynamic}
'''''''''
function ApplyManifestOptions(_item as object)
    CheckForTextColorChange()

    ' Check for dynamic background assignment.
    if m.global.useThumbnailBackground = true and _item <> invalid
        m.mainScene = m.top.getScene()
        m.mainScene.backgrounduri = _item.hdposterurl        
    end if

end function

'''''''''
' CheckForTextColorChange: Checks for a text color change.
' 
' @return {dynamic}
'''''''''
function CheckForTextColorChange()
    if m.global.TextColor <> invalid and m.global.TextColor <> ""
        m.descriptionLabel.color = m.global.TextColor
        m.titleLabel.color = m.global.TextColor
    end if

end function'//# sourceMappingURL=./GridScreen.brs.map