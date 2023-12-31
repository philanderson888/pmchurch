'import "pkg:/components/UILogic/ScreenStackLogic.brs"
'import "pkg:/components/UILogic/DetailsScreenLogic.bs"

'''''''''
' ShowEpisodesOnlyScreen: 
' 
' @param {object} content
' @param {integer} selectedItem
'''''''''
sub ShowEpisodesOnlyScreen(content as Object, selectedItem as Integer)
    ' create instance of the EpisodesScreen
    episodesOnlyScreen = CreateObject("roSGNode", "EpisodesOnlyScreen")
    ' observe selectedItem field so we can know which episode is selected
    episodesOnlyScreen.ObserveField("selectedItem", "OnEpisodesOnlyScreenItemSelected")
    ' populate episodeScreen with content based on which serial was chosen
    episodesOnlyScreen.content = content.GetChild(selectedItem)
    ' Show the Episodes only screen.
    ShowScreen(episodesOnlyScreen)
end sub

'''''''''
' OnEpisodesOnlyScreenItemSelected: 
' 
' @param {object} event
'''''''''
sub OnEpisodesOnlyScreenItemSelected(event as Object)
    episodesScreen = event.GetRoSGNode()
    ' extract the row and column indexes of the item the user selected
    selectedIndex = event.GetData()
    ' Add to the content payload by saving the selected Season index and the selected Epsiode index.
    episodesScreen.content.removeFields([
        "SelectedEpisodeIndex"
    ])
    episodesScreen.content.addFields({
        "SelectedEpisodeIndex": selectedIndex
    })
    ' Clear the PlayAll flag since the user has requeted to play a single Episode.
    episodesScreen.content.removeFields([
        "PlayAll"
    ])
    episodesScreen.content.addFields({
        "PlayAll": false
    })
    ' Handle the OK (Play) button.
    HandlePlayButton(episodesScreen.content, selectedIndex)
end sub'//# sourceMappingURL=./EpisodesOnlyScreenLogic.bs.map