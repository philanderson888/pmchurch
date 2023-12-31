' entry point of detailsScreen
function Init()
    ' observe "visible" so we can know when DetailsScreen change visibility
    m.top.ObserveField("visible", "OnVisibleChange")
    ' observe "itemFocused" so we can know when another item gets in focus
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")
    ' save a references to the DetailsScreen child components in the m variable
    ' so we can access them easily from other functions
    m.buttons = m.top.FindNode("buttons")
    m.poster = m.top.FindNode("poster")
	m.shadow = m.top.FindNode("shadow")
    m.description = m.top.FindNode("descriptionLabel")
'    m.timeLabel = m.top.FindNode("timeLabel")
    m.titleLabel = m.top.FindNode("titleLabel")
'    m.releaseLabel = m.top.FindNode("releaseLabel")
    m.timeReleaseLabel = m.top.FindNode("timeReleaseLabel")
end function

sub OnVisibleChange() ' invoked when DetailsScreen visibility is changed
    ' set focus for buttons list when DetailsScreen become visible
    if m.top.visible = true
        m.buttons.SetFocus(true)
    end if
end sub

'''''''''
' SetButtons: Sets the button set for the Details screen.
' 
' @param {dynamic} buttons
'''''''''
sub SetButtons(buttons)
    ' create buttons
    result = []
    for each button in buttons
        result.Push({
            title: button
        })
    end for
    m.buttons.content = ContentListToSimpleNode(result) ' set list of buttons for DetailsScreen
end sub

sub SetDetailsContent(content as Object)
    ' Get the Bookmarks object.
    if content.mediaType = "series"
        m.contentBookmark = SmartBookmark()
    else
        m.contentBookmark = Bookmark()
    end if
    ' Populate content details information
    m.description.text = content.description ' set description of content
    m.poster.uri = content.hdPosterUrl ' set url of content poster
    if content.length <> invalid and content.length <> 0
        time$ = GetTime(content.length).ToStr()
        ' m.timeLabel.text = GetTime(content.length).ToStr()
    else if content.mediaType = "series"
        time$ = content.GetChildCount().ToStr() + " Episode(s)."
    end if
    m.titleLabel.text = content.title ' set title of content
    ' m.releaseLabel.text = " | " + content.releaseDate
    m.timeReleaseLabel.text = time$ + " | " + content.releaseDate
    if content.mediaType = "series"
        ' buttons for series DetailsScreen.
        SetButtons([
            "Play all"
            "See all episodes"
        ])
    else
        position = [
            0.0
        ]
        ' buttons for content DetailsScreen.
        if m.contentBookmark.VideoCanBeResumed(content.id, position)
            SetButtons([
                "Restart"
                "Resume playback"
            ])
        else
            SetButtons([
                "Watch now"
            ])
        end if
    end if
end sub

sub OnJumpToItem() ' invoked when jumpToItem field is populated
    content = m.top.content
    ' check if jumpToItem field has valid value
    ' it should be set within interval from 0 to content.Getchildcount()
    if content <> invalid and m.top.jumpToItem >= 0 and content.GetChildCount() > m.top.jumpToItem
        m.top.itemFocused = m.top.jumpToItem
    else if content <> invalid and content.mediaType = "episode" and m.top.jumpToItem >= 0
        m.top.itemFocused = m.top.jumpToItem
    end if
end sub

sub OnItemFocusedChanged(event as Object)
    ' Get the position in the Grid of the selected item.
    focusedItem = event.GetData()
    content = m.top.content.GetChild(focusedItem) ' get metadata of focused item
    SetDetailsContent(content) ' populate DetailsScreen with item metadata
end sub

' The OnKeyEvent() function receives remote control key events
function OnkeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        currentItem = m.top.itemFocused ' position of currently focused item
        ' handle "left" button keypress
        if key = "left"
            ' navigate to the left item in case of "left" keypress
            m.top.jumpToItem = currentItem - 1
            result = true
            ' handle "right" button keypress
        else if key = "right"
            ' navigate to the right item in case of "right" keypress
            m.top.jumpToItem = currentItem + 1
            result = true
        else if key = "options"
            ' Get the Content object.
            content = m.top.content.GetChild(m.top.itemFocused)
            message = []
            ' Check for a long description first.  Otherwise, use the short description.
            if content.longDescription <> invalid
                message.Push(content.longDescription)
            else if content.shortDescription <> invalid
                message.Push(content.shortDescription)
            end if
            if content.Actors <> invalid and content.Actors.Count() > 0
                for each actor in content.Actors
                    message.Push("Actor: " + actor)
                end for
            end if
            if content.Hosts <> invalid and content.Hosts.Count() > 0
                for each host in content.Hosts
                    message.Push("Host: " + host)
                end for
            end if
            if content.Narrators <> invalid and content.Narrators.Count() > 0
                for each narrator in content.Narrators
                    message.Push("Narrator: " + narrator)
                end for
            end if
            if content.Directors <> invalid and content.Directors.Count() > 0
                for each director in content.Directors
                    message.Push("Director: " + director)
                end for
            end if
            if content.Producers <> invalid and content.Producers.Count() > 0
                for each producer in content.Producers
                    message.Push("Producer: " + producer)
                end for
            end if
            m.descriptionDialog = CreateMessageDialog(content.title, message, [
                "Ok"
            ])
            ' observe the dialog's buttonSelected field to handle button selections
            m.descriptionDialog.observeFieldScoped("buttonSelected", "OkButtonSelected")
            ' display the dialog
            scene = m.top.getScene()
            scene.dialog = m.descriptionDialog
            result = true
        end if
    end if
    return result
end function

'''''''''
' OkButtonSelected: Handles Ok button click on the Description Dialog.
' 
'''''''''
sub OkButtonSelected()
    if m.descriptionDialog.buttonSelected = 0
        ' handle ok button here
        m.descriptionDialog.close = true
    end if
end sub'//# sourceMappingURL=./DetailsScreen.bs.map