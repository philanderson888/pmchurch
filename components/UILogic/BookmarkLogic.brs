' Bookmark class
' (c) Copyright 2023, Michael Harnad
function __Bookmark_builder()
    instance = {}
    '''''''''
    ' new: Class constructor.
    ' 
    '''''''''
    instance.new = sub()
        m._section = invalid
        m._iRegistry = invalid
        m._iRegistrySection = invalid
        ' Use the 'Transient' registry section.  Per Roku, this section is has a 
        ' lifetime of a single boot.
        m._section = "Transient"
        ' Create the registry object.
        m._iRegistry = CreateObject("roRegistry")
        m._iRegistrySection = CreateObject("roRegistrySection", m._section)
    end sub
    '''''''''
    ' UpdateBookmark: Updates a bookmark for the content.
    ' 
    ' @param {string} I: contentId - the id of the content.
    ' @param {float} I: videoPosition - the current video position.
    ' @return {dynamic}
    '''''''''
    instance.UpdateBookmark = function(contentId as string, videoPosition as float)
        m._iRegistrySection.Write(contentId, videoPosition.toStr())
        m._iRegistrySection.flush()
    end function
    '''''''''
    ' GetVideoPlaybackPercentage: Gets the video playback percentage.
    ' 
    ' @param {string} I: contentId - the content id.
    ' @param {integer} I: videoDuration - the video duration.
    ' @param {float} I: [newPosition=invalid] - the new video position.
    ' @return {float} Returns the total video playback percentage.
    '''''''''
    instance.GetVideoPlaybackPercentage = function(contentId as string, videoDuration as integer, newPosition = invalid as float) as float
        if newPosition = invalid
            lastPosition = m.GetLastVideoPosition(contentId)
        else
            lastPosition = newPosition
        end if
        percentage = lastPosition / videoDuration
        return percentage
    end function
    '''''''''
    ' UpdateVideoPosition: Updates the video postion in the bookmark.
    ' 
    ' @param {string} I: contentId - the content Id.
    ' @param {float} I: newPosition - the new video content position.
    ' @param {integer} I: videoDuration - the duration of the video content.
    ' @return {dynamic}
    '''''''''
    instance.UpdateVideoPosition = function(contentId as string, newPosition as float, videoDuration as integer)
        percentage = m.GetVideoPlaybackPercentage(contentId, videoDuration, newPosition)
        ' If the playback postion is at least 95% complete, delete the bookmark.
        if percentage > 0.95
            m.DeleteBookmark(contentId)
        else
            m.UpdateBookmark(contentId, newPosition)
        end if
    end function
    '''''''''
    ' GetLastVideoPosition: Get the last video position.
    ' 
    ' @param {string} contentId - the id of the content.
    ' @return {float} the last video position.
    '''''''''
    instance.GetLastVideoPosition = function(contentId as string) as float
        if m._iRegistrySection.Exists(contentId)
            strPosition = m._iRegistrySection.Read(contentId)
            return strPosition.toFloat()
        else
            return 0.0
        end if
    end function
    '''''''''
    ' VideoCanBeResumed: Checks to see if the video can be resumed.
    ' 
    ' @param {string} I: contentId - id of video to check.
    ' @param {object} O: positiion - current video position.
    ' @return {boolean} returns true if video can be resumed, else, false.
    '''''''''
    instance.VideoCanBeResumed = function(contentId as string, position as object) as boolean
        if m._iRegistrySection.Exists(contentId)
            strPosition = m._iRegistrySection.Read(contentId)
            if strPosition.toFloat() > 0
                position[0] = strPosition.toFloat()
                return true
            else
                position[0] = 0.0
                return false
            end if
        else
            position[0] = 0.0
            return false
        end if
    end function
    '''''''''
    ' DeleteBookmark: Delete the content bookmark.
    ' 
    ' @param {string} contentId - id of the content.
    ' @return {dynamic}
    '''''''''
    instance.DeleteBookmark = function(contentId as string)
        if m._iRegistrySection.Exists(contentId)
            m._iRegistrySection.Delete(contentId)
            m._iRegistrySection.flush()
        end if
    end function
    '''''''''
    ' GetRegistrySectionObject: Gets the registry section object by name.
    ' 
    ' @return {object} returns the registry Section object.
    '''''''''
    instance.GetRegistrySectionObject = function() as object
        return m._iRegistrySection
    end function
    '''''''''
    ' DebugListRegistrySections: Iterates the registry sections to the debug window.
    ' 
    ' @return {dynamic}
    '''''''''
    instance.DebugListRegistrySections = function()
        for each sectionItem in m.iRegistry.GetsectionList()
            ? ">> DEBUG Section name= " sectionItem
            registrySection = m.GetRegistrySectionObject()
            sectionKeys = registrySection.GetKeylist()
            for each sectionKey in sectionKeys
                value = registrySection.Read(sectionKey)
                ? ">> DEBUG content id= " sectionKey " position= " value
            end for
        end for
    end function
    return instance
end function
function Bookmark()
    instance = __Bookmark_builder()
    instance.new()
    return instance
end function'//# sourceMappingURL=./BookmarkLogic.bs.map