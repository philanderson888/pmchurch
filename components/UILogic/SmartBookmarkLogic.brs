' Bookmark class
' (c) Copyright 2023, Michael Harnad
function __SmartBookmark_builder()
    instance = __Bookmark_builder()
    '''''''''
    ' new: Class constructor.
    ' 
    '''''''''
    instance.super0_new = instance.new
    instance.new = sub()
        ' Call the base class constructor.
        m._seriesId = invalid
        m._lastSeasonNumber = invalid
        m._lastEpisodeId = invalid
        m._lastEpisodeNumber = invalid
        m.super0_new()
        ' Set some default values.
        m._seriesId = "0"
        m._lastSeasonNumber = 0
        m._lastEpisodeId = "0"
        m._lastEpisodeNumber = 0
    end sub
    ' Content id of the Series.
    ' Last Season number viewed.
    ' Content id of the last Episode.
    ' Last Episode number viewed.
    '''''''''
    ' GetCurrentEpisodeId: Gets the current Epsiode to play.
    ' 
    ' @param {object} series - the Series object.
    ' @return {object} - the Episode to play based on the Bookmark.
    '''''''''
    instance.GetCurrentEpisodeId = function(series as object) as object
        ' Does the Series contain Seasons?
        if m._lastSeasonNumber <> 0
        end if
        ' Check for a prior Episode history.
        if m._lastEpsiodeId = 0
            ' No prior history, so, start with Episode 1.
            episode = series.GetChild(0)
            m._lastEpsiodeId = episode.id
            return episode
        else
            episodes = series.getChildren()
            return episodes
        end if
    end function
    '''''''''
    ' UpdateSmartBookmark: Updates a smart bookmark for the Series.
    ' 
    ' @return {dynamic}
    '''''''''
    instance.UpdateSmartBookmark = function()
        ' Set the Series attributes.
        seriesAttr = {
            seriesId: m._seriesId
            season: m._lastSeasonNumber
            episodeId: m._lastEpisodeId
            episode: m._lastEpisodeNumber
        }
        ' Convert to JSON.
        json = FormatJson(seriesAttr)
        ' Write to the registry.
        m._iRegistrySection.Write(m._seriesId, json)
        m._iRegistrySection.flush()
    end function
    '''''''''
    ' GetRegistrySectionObject: Get the Registry Section object.
    ' 
    ' @return {object} - returns the registry Section object.
    '''''''''
    instance.super0_GetRegistrySectionObject = instance.GetRegistrySectionObject
    instance.GetRegistrySectionObject = function() as object
        return m.super0_GetRegistrySectionObject()
    end function
    '''''''''
    ' EpisodeBookmarkExists: Checks for the existence of an Episode bookmark.
    ' 
    ' @param {string} I: contentId - the Episode content ID to check.
    ' @return {boolean} - returns true if found, else, false.
    '''''''''
    instance.EpisodeBookmarkExists = function(contentId as string) as boolean
        found = false
        if m._iRegistrySection.Exists(contentId)
            found = true
        end if
        return found
    end function
    '''''''''
    ' SeriesCanBeResumed: Checks if the playback for a Series can be resumed.
    ' 
    ' @param {object} I: seriesContent - Series object.
    ' @param {object} O: position - the playback position.
    ' @return {object} returns the Episode to play.
    '''''''''
    instance.SeriesCanBeResumed = function(seriesContent as object, position as object) as object
        ' Save the Series content id.
        m._seriesId = seriesContent.id
        ' Define an Epsiode object.
        _episode = invalid
        ' Check for the Series playback history.
        if m._iRegistrySection.Exists(seriesContent.id)
            json = m._iRegistrySection.Read(seriesContent.id)
            seriesAttr = ParseJson(json)
            m._seriesId = seriesAttr["seriesid"]
            m._lastSeasonNumber = seriesAttr["season"]
            m._lastEpisodeId = seriesAttr["episodeid"]
            m._lastEpisodeNumber = seriesAttr["episode"]
            ' Check for the Episode history.  If it exists, get the last video position.
            if m.EpisodeBookmarkExists(m._lastEpisodeId)
                registrySection = m.super0_GetRegistrySectionObject()
                position[0] = registrySection.Read(m._lastEpisodeId).toFloat()
            else
                ' Set a new playback position.
                position[0] = 0.0
                ' There's no Episode history, so, set the next Episode.
                m._lastEpisodeNumber = m._lastEpisodeNumber + 1
            end if
            ' Is this a Series with Seasons?
            if m._lastSeasonNumber <> 0
                _season = seriesContent.getChild(m._lastSeasonNumber - 1)
                _episode = _season.getChild(m._lastEpisodeNumber - 1)
                m._lastEpisodeId = _episode.id
            else
                ' The Series only contains Episodes, get the Episode.
                _episode = seriesContent.GetChild(m._lastEpisodeNumber - 1)
                m._lastEpisodeId = _episode.id
            end if
        else
            ' No history exists for the Series.  Check if the Series has Seasons.
            if seriesContent.hasSeasons = true
                ' If the Season# and the Episode# are zero, this is a new bookmark.
                if m._lastSeasonNumber = 0 and m._lastEpisodeNumber = 0
                    m._lastSeasonNumber = 1
                    m._lastEpisodeNumber = 1
                    _season = seriesContent.getChild(0)
                    _episode = _season.getChild(0)
                    m._lastEpisodeId = _episode.id
                else
                    ' Prime the objects from the parsed deeplink.
                    _season = seriesContent.getChild(m._lastSeasonNumber - 1)
                    _episode = _season.getChild(m._lastEpisodeNumber - 1)
                    m._lastEpisodeId = _episode.id
                end if
            else
                ' This is a Series with Episodes only.
                m._lastSeasonNumber = 0
                _episode = seriesContent.getChild(0)
                m._lastEpisodeId = _episode.id
                m._lastEpisodeNumber = 1
            end if
        end if
        ' Update the smart bookmark.
        m.UpdateSmartBookmark()
        return _episode
    end function
    return instance
end function
function SmartBookmark()
    instance = __SmartBookmark_builder()
    instance.new()
    return instance
end function'//# sourceMappingURL=./SmartBookmarkLogic.bs.map