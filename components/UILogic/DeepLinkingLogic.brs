


'''''''''
' GetSupportedMediaTypes: Gets the supported media types.
' 
' @return {object}
'''''''''
function GetSupportedMediaTypes() as Object ' returns AA with supported media types
    return {
        "series": "series"
        "season": "season"
        "episode": "episode"
        "movie": "movie"
        "shortFormVideo": "shortFormVideo"
    }
end function

'''''''''
' ValidateDeepLink: Validates the arguments that were passed.
' 
' @param {object} args
' @return {boolean}
'''''''''
function ValidateDeepLink(args as Object) as Boolean
    mediaType = args.dl_mediaType
    contentId = args.dl_contentId
    types = GetSupportedMediaTypes()
    return mediaType <> invalid and contentId <> invalid and types[mediaType] <> invalid
end function

'''''''''
' OnInputDeepLinking: Called when the scene input args is defined.
' 
' @param {object} event
'''''''''
sub OnInputDeepLinking(event as Object) ' invoked in case of "roInputEvent"
    args = event.getData()
    if args <> invalid and ValidateDeepLink(args) ' validate deep link arguments
        ' Make sure the content is valid before Deep Linking.
        if m.GridScreen.content <> invalid
            DeepLink(m.GridScreen.content, args.dl_mediaType, args.dl_contentId) ' Perform deep linking
        end if
    end if
end sub

'''''''''
' DeepLink: Perform a deep link to start the requested content.
' 
' @param {object} I: content - content object established from passed deep link content id.
' @param {string} I: mediaType - media type established from the passed deep link media type.
' @param {string} I: contentId - the content id.
'''''''''
sub DeepLink(content as Object, mediaType as String, contentId as String)
    ' Define some default values.
    seasonNumber = [
        0
    ]
    episodeNumber = [
        0
    ]
    ' Get the Bookmarks object.
    if mediaType <> "series"
        contentBookmark = Bookmark()
    else
        contentBookmark = SmartBookmark()
    end if
    ' Default video start position.
    position = [
        0.0
    ]
    ' Parse the content id to see if it contains an embedded Season and Episode.
    parsedContentId = ParsePipedDeeplink(contentId, seasonNumber, episodeNumber)
    if parsedContentId <> ""
        contentBookmark._seriesId = parsedContentId
        contentBookmark._lastSeasonNumber = seasonNumber[0]
        contentBookmark._lastEpisodeNumber = episodeNumber[0]
        contentId = parsedContentId
    end if
    playableItem = FindNodeById(content, contentId) ' find content for deep linking by contentId
    if playableItem <> invalid
        SetPlayAllFlag(playableItem, false)
    end if
    ' Check for a valid playable item.  An item is typically not valid due to an invalid content id.
    if playableItem <> invalid
        ClearScreenStack() ' remove all screen from screen stack except GridScreen
        ' Episodes and Movies.
        if mediaType = "episode" or mediaType = "movie"
            ' See if the content can be resumed.
            if contentBookmark.VideoCanBeResumed(playableItem.id, position) = true
                playableItem.PlayStart = position[0]
            end if
            ShowVideoScreen(playableItem, 0)
            ' Short form videos.
        else if playableItem.mediaType = "shortFormVideo"
            ShowVideoScreen(playableItem, 0)
            ' TV specials.
        else if playableItem.mediaType = "tvSpecial"
            if contentBookmark.VideoCanBeResumed(playableItem.id, position) = true
                playableItem.PlayStart = position[0]
            end if
            ShowVideoScreen(playableItem, 0)
            ' Series.
        else if mediaType = "series"
            ' Get the Episode to play based on Bookmark history.
            playableItem = contentBookmark.SeriesCanBeResumed(playableItem, position)
            SetPlayAllFlag(playableItem, false)
            if playableItem <> invalid
                playableItem.PlayStart = position[0]
                contentBookmark.UpdateSmartBookmark()
            end if
            ShowVideoScreen(playableItem, 0, true)
        end if
    else
        ' If code reaches this point, the content ID was not found.
        msg = []
        str = "The requested content ID '" + contentId + "' is not available."
        msg.Push(str)
        msg.Push("Please contact the channel devloper.")
        buttons = []
        buttons.Push("Ok")
        m.Dialog = ShowAMessageDialog("Content Not Found", msg, buttons)
        m.Dialog.observeFieldScoped("buttonSelected", "onOk")
        ' display the dialog
        scene = m.top.getScene()
        scene.dialog = m.Dialog
    end if
end sub

'''''''''
' onOk: Handles click on the OK button.
' 
'''''''''
sub onOk()
    if m.Dialog.buttonSelected = 0
        ' handle ok button here
        m.Dialog.close = true
    end if
end sub'//# sourceMappingURL=./DeepLinkingLogic.bs.map