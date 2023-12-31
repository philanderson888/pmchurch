' entry point of MainScene
sub Init()
    ' Set bakground color for scene.  Applied only if backgroundUri has empty value.
    m.top.backgroundColor = GetValueFromManifest("BACKGROUND_COLOR")
    backgroundImage = GetValueFromManifest("BACKGROUND_IMAGE")
    ' If background image is supplied, use it.
    if backgroundImage <> ""
        m.background = m.top.findNode("background")
        m.background.uri = backgroundImage
    else
        m.top.backgroundUri = ""
    end if
    m.loadingIndicator = m.top.FindNode("loadingIndicator") ' store loadingIndicator to m
    
    ' Initialize the screen stack.
    InitScreenStack()
    ' Show the grid screen.
    ShowGridScreen()
    ' Collect the content from the feed file.
    LoadChannelContent()
end sub

'   The OnKeyEvent() function receives remote control key events.
function OnKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        ' handle "back" key press.
        if key = "back"
            numberOfScreens = m.screenStack.Count()
            ' close top screen if there are two or more screens in the screen stack.
            if numberOfScreens > 1
                CloseScreen(invalid)
                result = true
            end if
        end if
    end if

    ' The OnKeyEvent() function must return true if the component handled the evnet,
    ' or falsie if it did not handle the event.
    return result
end function'//# sourceMappingURL=./MainScene.brs.map