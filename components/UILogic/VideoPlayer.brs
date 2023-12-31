'import "pkg:/source/main.bs"

'''''''''
' ShowVideoScreenWithAds: Starts the Video task with Ads for playbak.
' 
' @param {object} I: _feedContent - the feed content.
' @param {integer} I: _selectedItem - selected item index.
' @param {boolean} I: [_isSeries=false] - isSeries flag.
'''''''''
sub ShowVideoScreenWithAds(_feedContent as object, _selectedItem as Integer, _isSeries = false as boolean)
    videoScreen = CreateObject("roSGNode", "VideoScreen") ' create an instance of videoScreen
    videoScreen.observeField("close", "OnVideoScreenWithAdsClose")
    ' populate videoScreen data
    videoScreen.isSeries = _isSeries
    videoScreen.content = _feedContent
    ' Next line starts the Task.
    videoScreen.startIndex = _selectedItem
    ' append videoScreen to scene and show it
    ShowScreen(videoScreen)
end sub

sub OnVideoScreenWithAdsClose(event as Object) ' invoked once videoScreen's close field is changed
    videoScreen = event.GetRoSGNode()
    close = event.GetData()
    if close = true
        CloseScreen(videoScreen) ' remove videoScreen from scene and close it
        screen = GetCurrentScreen()
        screen.SetFocus(true) ' return focus to DetailsScreen
        ' in case of series we shouldn't change focus on DetailsScreen
        if videoScreen.isSeries = false
            screen.jumpToItem = videoScreen.lastIndex
        end if
    end if
end sub

'''''''''
' ConstructContentNodeForStitchedAds: Constructs a ContentNode for an Ad stitched playback.
' 
' @param {object} I: _feedContent - the feed content object.
' @param {integer} I: _selectedItem - index of selected item.
' @return {object} - Returns the Ad content node.
'''''''''
function ConstructContentNodeForStitchedAds(_feedContent as object, _selectedItem as integer) as object
    ' Construct a parent ContentNode for the stitched ad.
    adContentNode = CreateObject("roSGNode", "ContentNode")
    ' Are we playing one single content item?
    if m.playAll <> true
        itemContent = CreateObject("roSGNode", "ContentNode")
        if _feedContent.mediaType <> "series" and _feedContent.mediaType <> "episode"
            fields = _feedContent.getfields()
            itemContent.addFields(fields)
            ' Set the 'id' field of the ContentNode.
            itemContent.setFields({
                "id": _feedContent.id
            })
            ' Set the 'Length' field of the ContentNode.
            itemContent.SetFields({
                "Length": _feedContent.length
            })
        else
            ' Content is a Series requesting a single Episode.
            if _feedContent.hasSeasons <> true
                itemContent = _feedContent
            else
                ' Series has Seasons, so we must find the associated Episode.
                season = _feedContent.GetChild(_feedContent.SelectedSeasonIndex)
                itemContent = season.getChild(_feedContent.SelectedEpisodeIndex)
                ' Set the 'Length' field of the ContentNode.
                itemContent.SetFields({
                    "Length": itemContent.length
                })
            end if
        end if
        adContentNode.AppendChild(itemContent)
    else
        ' Play all has been selected for a Series.
        seasonIndex = _feedContent.SelectedSeasonIndex
        episodeIndex = _feedContent.SelectedEpisodeIndex
        episodes = GetAllEpisodesFromSeries(_feedContent)
        adContentNode.Update({
            children: episodes
        }, true)
    end if
    return adContentNode
end function

sub ShowVideoScreen(feedContent as object, selectedItem as Integer, isSeries = false as boolean)
    ' Save Series flag.
    m.isSeries = isSeries
    ' Save playAll flag.
    m.playAll = feedContent.PlayAll
    m.playAll = false
    ' Define the default video start position.
    position = [
        0.0
    ]
    ' Check for restart request.
    if feedContent.restart = true
        ResetBookmark(feedContent)
    end if
    ' Set the start position for the content.
    SetVideoPosition(feedContent, position)
    ' If user channel uses RAF, show content with ads.  
    ' Otherwise, just start the video content.
    if m.global.UseRaf = true
        adContentNode = ConstructContentNodeForStitchedAds(feedContent, selectedItem)
        ShowVideoScreenWithAds(adContentNode, selectedItem, isSeries)
    else
        ' Create new instance of Video object for playback.
        m.videoPlayer = CreateObject("roSGNode", "Video")
        ' Check for "Play all" (playlist).

        print "play all ?"
        print m.playAll

        if m.playAll = true
            ' Save the feed content.
            videoObject = feedContent
            ' Check for first Episode selection.
            if selectedItem <> 0
                ' Create a playlist Node starting after the first Episode.
                playlistNode = CreateObject("roSGNode", "ContentNode")
                episodes = GetAllEpisodesStartingAt(feedContent, selectedItem)
                ' Add the Episodes.
                playlistNode.Update({
                    children: episodes
                }, true)
                m.videoPlayer.content = playlistNode ' set node with children to video node content
            else
                if feedContent.hasSeasons <> true
                    ' if playback must start from first item we clone all row node
                    m.videoPlayer.content = feedContent.Clone(true)
                else
                    ' Create a playlist Node.
                    playlistNode = CreateObject("roSGNode", "ContentNode")
                    episodes = GetAllEpisodesFromSeries(feedContent)
                    playlistNode.Update({
                        children: episodes
                    }, true)
                    ' Set the content of the Video node to the playlist.
                    m.videoPlayer.content = playlistNode
                end if
            end if
        else
            ' Create a new ContentNode for the Video object.
            singleVideoNode = CreateObject("roSGNode", "ContentNode")
            ' Extract the selected video content to play.
            ' Check for a deeplink request first.
            if m.global.isDeeplink = false
                ' Check for a Series.
                if feedContent.mediaType = "series"
                    ' Does the Series have Seasons?
                    if feedContent.hasSeasons = false
                        ' Get the Episode feed item.
                        videoObject = GetEpisodeFromSeries(feedContent, selectedItem)
                    else
                        season = feedContent.getChild(feedContent.SelectedSeasonIndex)
                        videoObject = GetEpisodeFromSeason(season, feedContent.SelectedEpisodeIndex)
                    end if
                else
                    videoObject = feedContent
                end if
            else
                ' Deeplink was requested.
                videoObject = feedContent
                m.selectedIndex = [
                    0
                    0
                ]
                m.selectedIndex[1] = selectedItem
            end if
            ' Set the video position.
            SetVideoPosition(videoObject, position)
            ' Get all of the video fields.
            fields = videoObject.getfields()
            ' Assign them to the new ContentNode.
            singleVideoNode.SetFields(fields)
            ' Assign the new ContentNode to the Video object.
            m.videoPlayer.content = singleVideoNode
        end if
        ' Set playlist flag.
        m.videoPlayer.contentIsPlaylist = feedContent.PlayAll
        ShowScreen(m.videoPlayer) ' show video screen
        m.videoPlayer.control = "play" ' start playback
        m.videoPlayer.ObserveField("state", "OnVideoPlayerStateChange")
        m.videoPlayer.ObserveField("visible", "OnVideoVisibleChange")
        m.videoPlayer.ObserveField("contentIndex", "OnPlaylistIndexChange")
    end if
end sub

sub OnVideoPlayerStateChange()

    print "play all ?"
    print m.playAll

    print "video player"
    print m.videoPlayer 

    print "video player content"
    print m.videoPlayer.content

    print "video player content child 0"
    print m.videoPlayer.content.getChild(0)

    if m.playAll = true
        contentId = m.videoPlayer.content.GetChild(m.videoPlayer.contentIndex).id
    else
        videoContent = m.videoPlayer.content
        contentId = videoContent.id
    end if
    state = m.videoPlayer.state
    ' check for playback stop so we can save the position.
    if state = "stopped"
        m.contentBookmark.UpdateBookmark(contentId, m.videoPlayer.position)
    end if
    ' close video screen in case of error or end of playback
    if state = "finished"
        CloseScreen(m.videoPlayer)
        m.contentBookmark.DeleteBookmark(contentId)
    end if
    if state = "error"
        description = []
        description.Push(m.videoPlayer.errorMsg)
        m.errorDialog = createObject("roSGNode", "StandardMessageDialog")
        m.errorDialog.title = m.videoPlayer.state + ": " + m.videoPlayer.errorStr
        m.errorDialog.message = description
        m.errorDialog.buttons = [
            "Ok"
        ]
        ' observe the dialog's buttonSelected field to handle button selections
        m.errorDialog.observeFieldScoped("buttonSelected", "onOkButtonSelected")
        ' display the dialog
        scene = m.top.getScene()
        scene.dialog = m.errorDialog
    end if
end sub

'''''''''
' onOkButtonSelected: Handles Ok button click on the Description Dialog.
' 
'''''''''
sub onOkButtonSelected()
    m.errorDialog.close = true
    CloseScreen(m.videoPlayer)
end sub

sub OnVideoVisibleChange() ' invoked when video node visibility is changed
    if m.videoPlayer.visible = false and m.top.visible = true
        ' the index of the video in the video playlist that is currently playing.
        m.videoPlayer.control = "stop" ' stop playback
        'clear video player content, for proper start of next video player
        m.videoPlayer.content = invalid
        ' Clear the Playall flag.
        m.playAll = false
        m.isSeries = false
        screen = GetCurrentScreen()
        screen.SetFocus(true) ' return focus to details screen
        screen.jumpToItem = screen.itemFocused
    end if
end sub

'''''''''
' OnPlaylistIndexChange: Handles change in the playlist index.  This occurs when the next item starts.
' 
'''''''''
sub OnPlaylistIndexChange()
    if m.videoPlayer.state = "finished"
    end if
end sub

'''''''''
' SetVideoPosition: Set the Video playback position based on any bookmark.
' 
' @param {object} I: feedContent - the feed content object.
' @param {object} O: position - the playback position.
' @return {object}
'''''''''
function SetVideoPosition(feedContent as object, position as object) as object
    ' Get the Bookmark object.
    m.contentBookmark = Bookmark()
    if m.contentBookmark.VideoCanBeResumed(feedContent.id, position) = true
        feedContent.PlayStart = position[0]
    end if
end function

'''''''''
' ResetBookmark: Resets the content bookmark by removing it.
' 
' @param {object} I: _feedContent - the feed content.
' @return {dynamic}
'''''''''
function ResetBookmark(_feedContent as object)
    ' Get the Bookmark object.
    m.contentBookmark = Bookmark()
    m.contentBookmark.DeleteBookmark(_feedContent.id)
end function'//# sourceMappingURL=./VideoPlayer.bs.map