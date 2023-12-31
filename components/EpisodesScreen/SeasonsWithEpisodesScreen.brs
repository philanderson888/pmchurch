 ' entry point of EpisodesScreen
 function Init()
    m.seasonsList = m.top.FindNode("seasonsList")
    ' observe "visible" so we can know when EpisodesScreen change visibility
    m.top.ObserveField("visible", "onVisibleChange")
    ' observe "itemFocused" so we can know which season gain focus
    m.seasonsList.ObserveField("itemFocused", "OnSeasonsItemFocused")
    m.seasonIndex = 0

    m.episodesList = m.top.FindNode("episodesList")
    ' observe "itemFocused" so we can know which episode gain focus
    m.episodesList.ObserveField("itemFocused", "OnEpisodeListItemFocused")
    ' observe "itemSelected" so we can know which episode is selected
    m.episodesList.ObserveField("itemSelected", "OnListItemSelected")
    m.top.ObserveField("content", "OnContentChange")
    m.episodeIndex = 0
end function

sub OnEpisodeListItemFocused(event as Object) ' invoked when episode is focused with the remote.
    focusedItem = event.GetData() ' index of episode
    m.episodeIndex = focusedItem    

    ' index of season which contains focused episode
    if (m.seasonIndex - 1) = m.seasonsList.jumpToItem
        m.seasonsList.animateToItem = m.seasonIndex
    else if not m.seasonsList.IsInFocusChain()
        m.seasonsList.jumpToItem = m.seasonIndex
    end if
end sub

'''''''''
' FillEpisodeList: Sets the items in the Episodes list.
' 
' @param {object} I: _season - the selected Season object.
' @return {dynamic}
'''''''''
function FillEpisodeList(_season as object)
    episodes = []
    for each episode in _season.GetChildren(-1, 0)
        fields = episode.getFields()
        episodes.Push(fields)
    end for
    
    ' Populate episodesList with list of Episodes.
    m.episodesList.content = EpisodeContentListToSimpleNode(episodes)
end function

'''''''''
' FillSeasonList: Fills the Season list.
' 
' @param {object} I: _content - the Series content.
'''''''''
sub FillSeasonList(_content as Object)
    ' save the title of each season
    seasons = []
    for each season in _content.GetChildren(-1, 0)
        seasons.push({title : season.title}) ' save title of each season
    end for
    m.seasonsList.content = ContentListToSimpleNode(seasons) ' populate seasonsList with list of seasons
end sub

sub OnSeasonsItemFocused(event as Object) ' invoked when Season is focused
    ' Get the Season index.
    focusedItem = event.GetData()
    m.seasonIndex = focusedItem
    m.episodeIndex = 0

    season = m.top.content.getChild(m.seasonIndex)
    FillEpisodeList(season)

    ' we shouldn't change the focus in the episodes list as soon as we have switched to the list of seasons
    if m.seasonsListGainFocus = true
        m.seasonsListGainFocus = false
    else
        ' navigate to the first episode of season
        m.episodesList.jumpToItem = m.episodeIndex
    end if
end sub

sub OnJumpToItem() ' invoked when "jumpToItem field is changed
        m.episodesList.jumpToItem = m.episodeIndex
end sub

sub OnContentChange() ' invoked when EpisodesScreen content is changed
    content = m.top.content
    FillSeasonList(content) ' populate seasons list

    season = content.GetChild(m.seasonIndex)    
    FillEpisodeList(season)

end sub

sub onVisibleChange() ' invoked when Episodes screen becomes visible
    if m.top.visible = true
        m.episodesList.setFocus(true) ' set focus to the episodes list
    end if
end sub

sub OnListItemSelected() ' invoked when Episode is selected
        m.top.selectedItem = [m.seasonIndex, m.episodeIndex]
end sub

' The OnKeyEvent() function receives remote control key events
function OnKeyEvent(key as String, press as Boolean) as Boolean
    result = false

    if press
        ' Look for Options press to display full text.
        if key = "options"
            episodes = m.episodesList.content.GetChildren(-1, 0)
            episode = episodes[m.episodeIndex]

            message = []

            if episode.Actors <> invalid and episode.Actors.Count() > 0
                for each actor in episode.Actors
                    message.Push("Actor: " + actor)                    
                end for
            end if

            if episode.Hosts <> invalid and episode.Hosts.Count() > 0
                for each host in episode.Hosts
                    message.Push("Host: " + host)                    
                end for
            end if

            if episode.Narrators <> invalid and episode.Narrators.Count() > 0
                for each narrator in episode.Narrators
                    message.Push("Narrator: " + narrator)                    
                end for
            end if

            if episode.Directors <> invalid and episode.Directors.Count() > 0
                for each director in episode.Directors
                    message.Push("Director: " + director)                    
                end for
            end if

            if episode.Producers <> invalid and episode.Producers.Count() > 0
                for each producer in episode.Producers
                    message.Push("Producer: " + producer)                    
                end for
            end if

            ' Check for a long description first.  Otherwise, use the short description.
            if episode.longDescription <> invalid
                message.Push(episode.longDescription)
            else if episode.shortDescription<> invalid
                message.Push(episode.shortDescription)                
            end if

            m.descriptionDialog = CreateMessageDialog(episode.title, message, ["Ok"])
            ' observe the dialog's buttonSelected field to handle button selections
            m.descriptionDialog.observeFieldScoped("buttonSelected", "OkButtonSelected")
        
            ' display the dialog
            scene = m.top.getScene()
            scene.dialog = m.descriptionDialog                
            result = true        

        ' handle "left" key press
        else if key = "left" and m.episodesList.HasFocus() ' episodes list should be focused
            m.seasonsListGainFocus = true
            ' navigate to seasons list
            m.seasonsList.SetFocus(true)
            m.episodesList.drawFocusFeedback = false
            result = true
        ' handle "right" key press
        else if key = "right" and m.seasonsList.HasFocus() ' seasons list should be focused
            m.episodesList.drawFocusFeedback = true
            ' navigate to episodes list
            m.episodesList.SetFocus(true)
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
end sub'//# sourceMappingURL=./SeasonsWithEpisodesScreen.brs.map