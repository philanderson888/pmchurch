' Helper function convert Associative Array to Node
function ContentListToSimpleNode(contentList as Object, nodeType = "ContentNode" as String) as Object
    result = CreateObject("roSGNode", nodeType) ' create node instance based on specified nodeType
    if result <> invalid
        ' go through contentList and create node instance for each item of list
        for each arrayItem in contentList
            item = CreateObject("roSGNode", nodeType)
            item.SetFields(arrayItem)
            result.AppendChild(item)
        end for
    end if
    return result
end function

'''''''''
' EpisodeContentListToSimpleNode: Converts an Episode List to a Simple Content Node.
' 
' @param {object} I: contentList - the Episode list.
' @param {string} [nodeType="ContentNode"]
' @return {object} - Returns the Simple Content node.
'''''''''
function EpisodeContentListToSimpleNode(contentList as Object, nodeType = "ContentNode" as String) as Object
    result = CreateObject("roSGNode", nodeType) ' create node instance based on specified nodeType
    if result <> invalid
        ' go through contentList and create node instance for each item of list
        for each arrayItem in contentList
            item = CreateObject("roSGNode", nodeType)
            item.addFields(arrayItem)
            item.SetFields(arrayItem)
            result.AppendChild(item)
        end for
    end if
    return result
end function

' Helper function converts seconds to mm:ss format.
' getTime(138) returns 2:18.
function GetTime(totalSeconds as Integer) as String
    intHours = totalSeconds \ 3600
    intMinutes = (totalSeconds MOD 3600) \ 60
    intSeconds = (totalSeconds MOD 60)
    if intHours > 0
        duration = intHours.toStr() + "h "
        if intMinutes > 0
            duration += intMinutes.toStr() + "m "
        end if
        if intSeconds > 0
            duration += intSeconds.toStr() + "s"
        end if
    else if intMinutes > 0
        duration = intMinutes.toStr() + "m "
        if intSeconds > 0
            duration += intSeconds.toStr() + "s"
        end if
    else
        duration = intSeconds.toStr() + "s"
    end if
    return duration
end function

function CloneChildren(node as Object, startItem = 0 as Integer)
    numOfChildren = node.GetChildCount() ' get number of row items.
    ' populate children array only wth items started from the selected one.
    ' example: row has 3 items.  user selects second one so we must take just second and third items.
    children = node.GetChildren(numOfChildren - startItem, startItem)
    childrenClone = []
    ' go through each item of children and clone them.
    for each child in children
        ' we need to clone item node because it will be damaged in case of video node content invalidation.
        childrenClone.Push(child.Clone(false))
    end for
    return childrenClone
end function

'''''''''
' GetValueFromManifest: Get the value from the manifest.
' 
' @param {string} key
' @return {string} the found value.
'''''''''
function GetValueFromManifest(key as string) as string
    ' Get the AppInfo object so we can get manifest data.
    appInfo = CreateObject("roAppInfo")
    value = appInfo.GetValue(key)
    return value
end function

'''''''''
' CreateMessageDialog: Creates a message dialog.
' 
' @param {string} title
' @param {object} message
' @param {object} buttons
' @return {object}
'''''''''
function CreateMessageDialog(title as string, message as object, buttons as object) as object
    Dialog = createObject("roSGNode", "StandardMessageDialog")
    Dialog.title = title
    Dialog.message = message
    Dialog.buttons = buttons
    return Dialog
end function

' Helper function finds child node by specified contentId
function FindNodeById(content as Object, contentId as String) as Object
    for each element in content.GetChildren(- 1, 0)
        if element.id = contentId
            return element
        else if element.getChildCount() > 0
            result = FindNodeById(element, contentId)
            if result <> invalid
                return result
            end if
        end if
    end for
    return invalid
end function

'''''''''
' ParsePipedDeeplink: Parses a piped deep link (ie. "myAwesomeShow|Season=1|Episode=1")
' 
' @param {string} I: contentId - content Id from the deep link.
' @param {object} O: seasonNum - parsed season number.
' @param {object} O: episodeNum - parsed episode number.
' @return {string} - returns the Series content Id if successful.
'''''''''
function ParsePipedDeeplink(contentId as string, seasonNum as object, episodeNum as object) as string
    ' Create a String object and init it with the contentId.
    stringObj = CreateObject("roString")
    stringObj.SetString(contentId)
    ' Make sure this is a piped contentId.
    if stringObj.Instr("|") = - 1
        return ""
    end if
    ' First pass parse.
    seriesId = stringObj.Split("|")
    ' Second pass parse.
    stringObj.SetString(seriesId[1])
    seasonNumber = stringObj.Split("=")
    seasonNum[0] = seasonNumber[1].toInt()
    stringObj.SetString(seriesId[2])
    episodeNumber = stringObj.Split("=")
    episodeNum[0] = episodeNumber[1].toInt()
    return seriesId[0]
end function

'''''''''
' DebugListRegistry: Used to list the contents of the registry for debugging.
'                    DEBUG ONLY!
' 
' @return {dynamic}
'''''''''
function DebugListRegistry()
    registry = CreateObject("roRegistry")
    sections = registry.GetSectionList()
    if sections.Count() > 0
        for each section in sections
            ? ">> DEBUG: Registry section: " + section
            iRegistrySection = CreateObject("roRegistrySection", section)
            keyList = iRegistrySection.GetKeyList()
            for each key in keyList
                ? ">>> DEBUG: key is " + key
                ? ">>>> DEBUG: value is " + iRegistrySection.Read(key)
            end for
        end for
    else
        ? ">> DEBUG:  No registry sections available."
    end if
end function

'''''''''
' DebugClearRegistry: Used to clear the registyr entries.
'                     DEBUG ONLY!
' 
' @return {dynamic}
'''''''''
function DebugClearRegistry()
    registry = CreateObject("roRegistry")
    sections = registry.GetSectionList()
    if sections <> invalid
        for each section in sections
            ? ">> DEBUG: Removed registry section - " + section
            registry.Delete(section)
        end for
    end if
end function

'''''''''
' GetFeedItemFromContent: Gets a feed item from the content object.
' 
' @param {object} I: content - the content object.
' @param {integer} I: index - index in the content object.
' @return {object} - returns the feed item object.
'''''''''
function GetFeedItemFromContent(content as object, index as integer) as object
    if content <> invalid
        feedItem = content.getChild(index)
    end if
    return feedItem
end function

'''''''''
' GetEpisodeFromSeries: Gets an Episode from a Series based on the Episode index.
' 
' @param {object} I: _series - the Series feed object.
' @param {integer} I: _index - index into the Episodes array.
' @return {object} - returns the requested Episode.
'''''''''
function GetEpisodeFromSeries(_series as object, _index as integer) as object
    if _series <> invalid
        episode = _series.getChild(_index)
    end if
    return episode
end function

'''''''''
' GetEpisodeFromSeason: Gets an Episode from a Season based on the Episode index.
' 
' @param {object} I: season - the Season feed object.
' @param {integer} I: index - index into the Episodes array.
' @return {object} - returns the requested Episode.
'''''''''
function GetEpisodeFromSeason(season as object, index as integer) as object
    if season <> invalid
        episode = season.getChild(index)
    end if
    return episode
end function

'''''''''
' GetAllEpisodesFromSeries: Get all Epsiodes for a Series.
' 
' @param {object} I: _series - the Series object.
' @return {object} - returns an array of Episodes.
'''''''''
function GetAllEpisodesFromSeries(_series as object) as object
    requestedEpisodes = []
    if _series.hasSeasons <> true
        episodes = CloneChildren(_series)
        for each episode in episodes
            requestedEpisodes.Push(episode)
        end for
    else
        seasons = _series.GetChildren(- 1, 0)
        for each season in seasons
            episodes = CloneChildren(season)
            for each episode in episodes
                requestedEpisodes.Push(episode)
            end for
        end for
    end if
    return requestedEpisodes
end function

'''''''''
' GetAllEpisodesFromSeason: Get all Episodes for a Season.
' 
' @param {object} I: _season - the Season object.
' @return {object} - returns an array of Episodes.
'''''''''
function GetAllEpisodesFromSeason(_season as object) as object
    requestedEpisodes = []
    if _season.getChildCount() > 0
        episodes = CloneChildren(_season)
        for each episode in episodes
            requestedEpisodes.Push(episode)
        end for
    end if
    return requestedEpisodes
end function

'''''''''
' GetAllEpisodesStartingAt: Get all Episodes from a Series starting at an Episode index.
' 
' @param {object} I: _series - the Series object.
' @param {integer} I: _startIndex - the starting Episode index.
' @return {object} - returns an array of Episodes.
'''''''''
function GetAllEpisodesStartingAt(_series as object, _startIndex as integer) as object
    requestedEpisodes = []
    numOfEpisodes = _series.getChildCount()
    episodes = _series.GetChildren(numOfEpisodes - _startIndex, _startIndex)
    for each episode in episodes
        requestedEpisodes.Push(episode)
    end for
    return requestedEpisodes
end function

'''''''''
' ContentIsSeries: Checks to see it the content is a Series.
' 
' @param {object} I: content - content to check.
' @return {boolean} - returns true if content is a Series, else, false.
'''''''''
function ContentIsSeries(content as object) as boolean
    return content.isSeries
end function

'''''''''
' SetPlayAllFlag: Sets the PlayAll flag on the feed content object.
' 
' @param {object} I: feedContent - the feed content.
' @param {boolean} I: bPlayall - true, or, false.
' @return {object} - returns the feed content.
'''''''''
function SetPlayAllFlag(feedContent as object, bPlayall as boolean) as object
    feedContent.removeFields([
        "PlayAll"
    ])
    feedContent.addFields({
        "PlayAll": bPlayall
    })
    return feedContent
end function

'''''''''
' GetButtonText: Gets the button text of a selected button.
' 
' @param {object} I: buttons - buttons object.
' @param {integer} I: index - index of the requested button.
' @return {string} - returns the text of the button.
'''''''''
function GetButtonText(buttons as object, index as integer) as string
    if buttons <> invalid
        children = buttons.content.GetChildren(- 1, 0)
    end if
    return children[index].title
end function

'''''''''
' ShowADialog: Shows a dialog on the screen.
' 
' @param {string} I: title - title of the dialog.
' @param {string} I: message - message to display.
' @param {object} I: buttons - buttons to display.
' @return {object} returns the dialog object.
'''''''''
function ShowAMessageDialog(title as string, message as object, buttons as object) as object
    modalDialog = CreateMessageDialog(title, message, buttons)
    scene = m.top.getScene()
    scene.dialog = modalDialog
    return modalDialog
end function

'''''''''
' ConvertAdbreakToSeconds: Converts Adbreak time to total seconds.
' 
' @param {string} I: adbreak - the adbreak string.
' @return {integer} - returns the adbreak in total seconds.
'''''''''
function ConvertAdbreakToSeconds(adbreak as string) as integer
    stringObj = CreateObject("roString")
    stringObj.SetString(adbreak)
    ' Make sure adbreak is 'mm:ss' format.
    if stringObj.Instr(":") = - 1
        totalSeconds = stringObj.toInt()
    else
        time = stringObj.Split(":")
        hours = time[0].toInt()
        minutes = time[1].toInt()
        seconds = time[2].toInt()
        totalSeconds = (hours * 60) * 60
        totalSeconds += minutes * 60
        totalSeconds += seconds
    end if
    return totalSeconds
end function'//# sourceMappingURL=./utils.bs.map