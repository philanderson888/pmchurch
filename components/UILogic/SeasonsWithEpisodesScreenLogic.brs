sub ShowEpisodesScreen(content as Object, selectedItem as Integer)
    m.content = content
    ' create instance of the EpisodesScreen
    episodesScreen = CreateObject("roSGNode", "EpisodesScreen")
    ' observe selectedItem field so we can know which episode is selected
    episodesScreen.ObserveField("selectedItem", "OnEpisodesScreenItemSelected")
    ' populate episodeScreen with content based on which series was chosen
    episodesScreen.content = content.GetChild(selectedItem)
    ShowScreen(episodesScreen)
end sub

sub OnEpisodesScreenItemSelected(event as Object)
    episodesScreen = event.GetRoSGNode()
    ' extract the row and column indexes of the item the user selected
    selectedIndex = event.GetData()
    ' Add to the content payload by saving the selected Season index and the selected Epsiode index.
    episodesScreen.content.removeFields([
        "SelectedSeasonIndex"
        "SelectedEpisodeIndex"
    ])
    episodesScreen.content.addFields({
        "SelectedSeasonIndex": selectedIndex[0]
    })
    episodesScreen.content.addFields({
        "SelectedEpisodeIndex": selectedIndex[1]
    })
    ' Clear the PlayAll flag since the user has requeted to play a single Episode.
    episodesScreen.content.removeFields([
        "PlayAll"
    ])
    episodesScreen.content.addFields({
        "PlayAll": false
    })
    ' Handle the OK (Play) button.
    HandlePlayButton(m.content, 0)
end sub'//# sourceMappingURL=./SeasonsWithEpisodesScreenLogic.bs.map