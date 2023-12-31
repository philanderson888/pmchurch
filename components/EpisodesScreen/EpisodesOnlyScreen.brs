' entry point of EpisodesScreen
function Init()
    m.episodesList = m.top.FindNode("episodesList")
    ' observe "visible" so we can know when EpisodesScreen change visibility
    m.top.ObserveField("visible", "onVisibleChange")
    ' observe "itemFocused" so we can know which episode gain focus
    m.episodesList.ObserveField("itemFocused", "OnEpisodeListItemFocused")
    ' observe "itemSelected" so we can know which episode is selected
    m.episodesList.ObserveField("itemSelected", "OnEpisodeListItemSelected")
    m.top.ObserveField("content", "OnEpisodeContentChange")    
end function

sub onVisibleChange() ' invoked when Episodes screen becomes visible
    if m.top.visible = true
        m.episodesList.setFocus(true) ' set focus to the episodes list
    end if
end sub

sub OnEpisodeListItemSelected(event as Object) ' invoked when episode is selected
    itemSelected = event.GetData() ' index of selected item
    m.top.selectedItem = itemSelected    
end sub

sub OnEpisodeListItemFocused(event as Object) ' invoked when episode is focused
    ' Set the Episode long description.
    focusedItem = event.GetData() ' index of episode
    content = m.top.content
    ' Get the array of Episodes.
    episodes = content.GetChildren(-1, 0)
    m.top.FindNode("episodeDescription").text = episodes[focusedItem].longDescription
end sub

sub OnJumpToItem(event as Object) ' invoked when "jumpToItem field is changed
    itemIndex = event.GetData()
    m.episodesList.jumpToItem = itemIndex ' navigate to the specified item
end sub

'''''''''
' OnEpisodeContentChange: Called when the content is changed.
' 
'''''''''
sub OnEpisodeContentChange()
    content = m.top.content
    ' Get all of the series Episodes.
    episodes = content.GetChildren(-1, 0)
    ' Set the thumbnail of the first episode.
    m.top.FindNode("seriesThumbnail").uri = episodes[0].thumbnail
    m.top.FindNode("episodeDescription").text = episodes[0].longDescription

    ' Populate the list of Episodes in the MarkupList.
    m.episodesList.content = content
end sub

' The OnKeyEvent() function receives remote control key events
function OnKeyEvent(key as String, press as Boolean) as Boolean
    result = false

    if press
        ' Look for Options press to display full text.
        if key = "options"
            ' Get the Series object.
            series = m.top.content
            ' Get the Episodes attached to the Series.
            episodes = series.GetChildren(-1, 0)
            selectedEpisode = episodes[m.episodesList.itemFocused]
            description = []
            description.Push(selectedEpisode.longDescription)

            if selectedEpisode.Actors <> invalid and selectedEpisode.Actors.Count() > 0
                for each actor in selectedEpisode.Actors
                    description.Push("Actor: " + actor)                    
                end for
            end if

            if selectedEpisode.Hosts <> invalid and selectedEpisode.Hosts.Count() > 0
                for each host in selectedEpisode.Hosts
                    description.Push("Host: " + host)                    
                end for
            end if

            if selectedEpisode.Narrators <> invalid and selectedEpisode.Narrators.Count() > 0
                for each narrator in selectedEpisode.Narrators
                    description.Push("Narrator: " + narrator)                    
                end for
            end if

            if selectedEpisode.Directors <> invalid and selectedEpisode.Directors.Count() > 0
                for each director in selectedEpisode.Directors
                    description.Push("Director: " + director)                    
                end for
            end if

            if selectedEpisode.Producers <> invalid and selectedEpisode.Producers.Count() > 0
                for each producer in selectedEpisode.Producers
                    description.Push("Producer: " + producer)                    
                end for
            end if

            m.descriptionDialog = CreateMessageDialog(episodes[m.episodesList.itemFocused].title, description, ["Ok"])
            ' observe the dialog's buttonSelected field to handle button selections
            m.descriptionDialog.observeFieldScoped("buttonSelected", "onOptionOkButtonSelected")
        
            ' display the dialog
            scene = m.top.getScene()
            scene.dialog = m.descriptionDialog                
            result = true

        end if
    end if
    return result
end function

'''''''''
' onOptionOkButtonSelected: Handles Ok button click on the Description Dialog.
' 
'''''''''
sub onOptionOkButtonSelected()
    if m.descriptionDialog.buttonSelected = 0
        ' handle ok button here
        m.descriptionDialog.close = true        
    end if
end sub
'//# sourceMappingURL=./EpisodesOnlyScreen.brs.map