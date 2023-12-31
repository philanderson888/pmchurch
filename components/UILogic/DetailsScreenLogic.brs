'import "pkg:/source/utils.bs"
'import "pkg:/components/UILogic/EpisodesOnlyScreenLogic.bs"
'import "pkg:/components/UILogic/SeasonsWithEpisodesScreenLogic.bs"
'import "pkg:/components/UILogic/VideoPlayer.bs"




sub ShowDetailsScreen(content as Object, selectedItem as Integer)
    ' create new instance of details screen
    m.detailsScreen = CreateObject("roSGNode", "DetailsScreen")
    m.detailsScreen.content = content
    m.detailsScreen.jumpToItem = selectedItem ' set index of item which should be focused
    m.detailsScreen.ObserveField("visible", "OnDetailsScreenVisibilityChanged")
    m.detailsScreen.ObserveField("buttonSelected", "OnButtonSelected")
    ShowScreen(m.detailsScreen)
end sub

'''''''''
' OnButtonSelected: Handles a remote button press.
' 
' @param {dynamic} I: event - the event object.
'''''''''
sub OnButtonSelected(event)
    ' Define the screen button indices.
    PlayOrPlayAllButtonIndex = 0
    ResumeOrSeeAllEpisodesButtonIndex = 1
    details = event.GetRoSGNode()
    content = details.content
    ' Get the index of the selected button.
    buttonIndex = event.getData()
    ' Get the index of the selected content.
    selectedItem = details.itemFocused
    ' Get the video object associated with the content.
    videoObject = content.GetChild(selectedItem)
    ' Get the buttons object.
    buttons = m.detailsScreen.FindNode("buttons")
    ' Get the text of the selected button.
    buttonText = GetButtonText(buttons, buttonIndex)
    ' Init some content flags.
    content.removeFields([
        "PlayAll"
    ])
    videoObject.removeFields([
        "Restart"
    ])
    videoObject.addFields({
        "Restart": false
    })
    ' Check for a Play or Play all button press.
    if buttonIndex = PlayOrPlayAllButtonIndex
        ' Check for Play or Restart button press.
        if buttonText = "Play" or buttonText = "Restart"
            ' Set content field to disable 'play all'.
            content.addFields({
                "PlayAll": false
            })
            ' Set content field to indicate 'restart' was requested.
            videoObject.setFields({
                "Restart": true
            })
            HandlePlayButton(content, selectedItem)
        else
            content.addFields({
                "PlayAll": true
            })
            HandlePlayButton(content, selectedItem)
        end if
    else if buttonIndex = ResumeOrSeeAllEpisodesButtonIndex
        if videoObject.mediaType = "series"
            series = GetFeedItemFromContent(content, selectedItem)
            ' create EpisodesScreen instance and show it.
            if series.hasSeasons = true
                ShowEpisodesScreen(content, selectedItem)
            else
                ShowEpisodesOnlyScreen(content, selectedItem)
            end if
        else
            HandlePlayButton(content, selectedItem)
        end if
    end if
end sub

sub OnDetailsScreenVisibilityChanged(event as Object) ' invoked when DetailsScreen "visible" field is changed
    visible = event.GetData()
    detailsScreen = event.GetRoSGNode()
    currentScreen = GetCurrentScreen()
    screenType = currentScreen.SubType()
    ' update GridScreen's focus when navigate back from DetailsScreen
    if visible = false
        if screenType = "GridScreen"
            ' update GridScreen's focus when navigating back from DetailsScreen.
            currentScreen.jumpToRowItem = [
                m.selectedIndex[0]
                detailsScreen.itemFocused
            ]
        else if screenType = "EpisodesScreen"
            ' update EpisodesScreen's focus when navigating back from DetailsScreen.
            content = detailsScreen.content.GetChild(detailsScreen.itemFocused)
            currentScreen.jumpToItem = content.numEpisodes
        end if
    end if
end sub

'''''''''
' HandlePlayButton: Handles Play/OK button press.
' 
' @param {object} I: content - the content to play.
' @param {integer} I: selectedItem - index of the selected item.
'''''''''
sub HandlePlayButton(content as Object, selectedItem as Integer)
    ' Get the associated feed item.
    feedContent = GetFeedItemFromContent(content, selectedItem)
    ' If PlayAll has been requested, set the flag.
    if content.PlayAll <> invalid
        feedContent.removeFields([
            "PlayAll"
        ])
        feedContent.addFields({
            "PlayAll": content.PlayAll
        })
        if content.playAll = true
            selectedItem = 0
        end if
    end if
    if feedContent.mediaType = "series"
        ShowVideoScreen(feedContent, selectedItem, true)
    else
        ShowVideoScreen(feedContent, selectedItem, false)
    end if
    m.selectedIndex[1] = selectedItem ' store index of selected item
end sub'//# sourceMappingURL=./DetailsScreenLogic.bs.map