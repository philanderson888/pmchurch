sub Init()
    ' set the name of the function in the Task node component to be executed when the state field changes to RUN.
    ' in our case, this method executes after the following cmd: m.contentTask.control = "run"(see Init method in MainScene)
    m.top.functionName = "GetContent"
    ' Create a DateTime object for later use.
    m.dateObject = CreateObject("roDateTime")
end sub

'''''''''
' ParseJsonFeed: Retrieves the JSON feed file from the URL and parses it.
' 
' @param {string} I: feedURL - the URL of the feed.
'''''''''
sub ParseJsonFeed(feedURL as string)
    ' request the content feed from the API.
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.SetURL(feedURL)
    rsp = xfer.GetToString()
    ' Parent of channel rows.
    rootChildren = []
    ' parse the JSON content feed and build a tree of ContentNodes to populate the GridView.
    m.jsonContentFeed = ParseJson(rsp)
    if m.jsonContentFeed <> invalid
        ' Define an array of rows that contain the Categories from the feed.
        if m.jsonContentFeed.categories <> invalid
            for each category in m.jsonContentFeed.categories
                row = {}
                row.title = category.Lookup("name")
                row.children = []
                rootChildren.Push(row)
            end for
        end if
        ' Parse movie objects from the feed file.
        if m.jsonContentFeed.movies <> invalid
            for each movie in m.jsonContentFeed.movies
                if ObjectContainsTags(movie) = true
                    categories = {}
                    categories = QueryCategoryForTags(movie.tags)
                    if categories <> invalid
                        for each categoryName in categories
                            for each row in rootChildren
                                if row.title = categoryName
                                    ' Build assoc array for the row.
                                    itemData = GetJsonItemData(movie, "movie")
                                    row.children.Push(itemData)
                                end if
                            end for
                        end for
                    end if
                end if
            end for
        end if
        ' Parse liveFeed objects from the feed file.
        if m.jsonContentFeed.liveFeeds <> invalid
            for each liveFeed in m.jsonContentFeed.liveFeeds
                if ObjectContainsTags(liveFeed) = true
                    categories = {}
                    categories = QueryCategoryForTags(liveFeed.tags)
                    if categories <> invalid
                        for each categoryName in categories
                            for each row in rootChildren
                                if row.title = categoryName
                                    ' Build assoc array for the row.
                                    itemData = GetJsonItemData(liveFeed, "livefeed")
                                    row.children.Push(itemData)
                                end if
                            end for
                        end for
                    end if
                end if
            end for
        end if
        ' Parse series objects from the feed file.
        if m.jsonContentFeed.series <> invalid
            for each series in m.jsonContentFeed.series
                if ObjectContainsTags(series) = true
                    categories = {}
                    categories = QueryCategoryForTags(series.tags)
                    if categories <> invalid
                        for each categoryName in categories
                            for each row in rootChildren
                                if row.title = categoryName
                                    ' Build assoc array for the row.
                                    itemData = GetJsonItemData(series, "series", true)
                                    if series.seasons <> invalid
                                        seasons = GetSeasonData(series.seasons)
                                    end if
                                    if series.seasons <> invalid and series.seasons.Count() > 0
                                        itemData.children = seasons
                                    end if
                                    if series.episodes <> invalid and series.episodes.Count() > 0
                                        itemData.children = GetEpisodeData(series)
                                    end if
                                    row.children.Push(itemData)
                                end if
                            end for
                        end for
                    end if
                end if
            end for
        end if
        ' Parse shortFormVideos objects from the feed file.
        if m.jsonContentFeed.shortFormVideos <> invalid
            for each shortFormVideo in m.jsonContentFeed.shortFormVideos
                if ObjectContainsTags(shortFormVideo) = true
                    categories = {}
                    categories = QueryCategoryForTags(shortFormVideo.tags)
                    if categories <> invalid
                        for each categoryName in categories
                            for each row in rootChildren
                                if row.title = categoryName
                                    ' Build assoc array for the row.
                                    itemData = GetJsonItemData(shortFormVideo, "shortFormVideo")
                                    row.children.Push(itemData)
                                end if
                            end for
                        end for
                    end if
                end if
            end for
        end if
        ' Parse tvSpecials objects from the feed file.
        if m.jsonContentFeed.tvSpecials <> invalid
            for each tvSpecial in m.jsonContentFeed.tvSpecials
                if ObjectContainsTags(tvSpecial) = true
                    categories = {}
                    categories = QueryCategoryForTags(tvSpecial.tags)
                    if categories <> invalid
                        for each categoryName in categories
                            for each row in rootChildren
                                if row.title = categoryName
                                    ' Build assoc array for the row.
                                    itemData = GetJsonItemData(tvSpecial, "tvSpecial")
                                    row.children.Push(itemData)
                                end if
                            end for
                        end for
                    end if
                end if
            end for
        end if
        ' Parse playlists objects from the feed file.
        if m.jsonContentFeed.playlists <> invalid
            playlistObjectType = []
            for each playlist in m.jsonContentFeed.playlists
                category = GetCategoryFromPlaylist(playlist.name)
                if category <> invalid
                    if playlist.itemIds <> invalid
                        for each id in playlist.itemIds
                            playlistObjectType[0] = invalid
                            playlistObject = QueryObjectById(id, playlistObjectType)
                            if playlistObject <> invalid
                                row = QueryChannelRowByCategoryName(category.name, rootChildren)
                                ' Build assoc array for the row.
                                'itemData = GetJsonItemData(playlistObject, playlistObjectType[0])
                                itemData = GetJsonItemData(playlistObject, "playlist")
                                row.children.Push(itemData)
                            end if
                        end for
                    end if
                end if
            end for
            row.title = "Playlist: " + row.title
        end if
        ' set up a root ContentNode to represent rowList on the GridScreen.
        contentNode = CreateObject("roSGNode", "ContentNode")
        contentNode.Update({
            children: rootChildren
        }, true)
        ' populate content field with root content node.
        ' Observer(see OnMainContentLoaded in MainScene.brs) is invoked at this moment.
        m.top.content = contentNode
    end if
end sub

'''''''''
' ParseXMLFeed: Retrieves the XML feed file from the URL and parses it.
' 
' @param {string} I: feedURL - the URL of the feed.
'''''''''
sub ParseXMLFeed(feedURL as string)
    ' request the content feed from the API.
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.SetURL(feedURL)
    rsp = xfer.GetToString()
    ' Parent of channel rows.
    rootChildren = []
    ' Array of channel Categories.
    categories = []
    xmlObject = CreateObject("roXMLElement")
    if xmlObject.Parse(rsp) = true
        ' Define an AA array to keep track of the found categories. 
        uniqueCategories = {}
        ' Get the Channel object.
        channel = xmlObject.GetNamedElements("channel")
        ' Get all of the Channel Items.
        items = channel.GetNamedElements("item")
        ' Get the count of Items.
        count = items.Count()
        ' Set the list index to the top.
        items.ResetIndex()
        ' Iterate the list of Channel Items to extract Categories.
        for index = 0 to count - 1
            ' Get an Item tag.
            itemTag = items.GetIndex()
            ' Get the associated Category tags.
            categoryTags = itemTag.GetNamedElements("media:category")
            ' Get the count of Categories.
            categoryCount = categoryTags.Count()
            ' Set the list index to the top.
            categoryTags.ResetIndex()
            for categoryIndex = 0 to categoryCount - 1
                ' Get the category item.
                categoryItem = categoryTags.GetIndex()
                ' Get the Category text and save it.
                category = categoryItem.GetText()
                ' Make sure we haven't already added the category to the row.
                if uniqueCategories.doesExist(category)
                else
                    categories.Push(category)
                    uniqueCategories[category] = true
                    row = {}
                    row.title = category
                    row.children = []
                    rootChildren.Push(row)
                end if
            end for
        end for
        ' Set the list index to the top.
        items.ResetIndex()
        ' Iterate the list of Channel Items.
        for index = 0 to count - 1
            ' Get an Item tag.
            itemTag = items.GetIndex()
            ' Get the associated Category tags.
            categoryTags = itemTag.GetNamedElements("media:category")
            ' Get the count of Categories.
            categoryCount = categoryTags.Count()
            ' Set the list index to the top.
            categoryTags.ResetIndex()
            for categoryIndex = 0 to categoryCount - 1
                ' Get the category item.
                categoryItem = categoryTags.GetIndex()
                ' Get the Category text and save it.
                category = categoryItem.GetText()
                for each row in rootChildren
                    if row.title = category
                        ' Build assoc array for the row.
                        itemData = GetXmlItemData(itemTag)
                        row.children.Push(itemData)
                    end if
                end for
            end for
        end for
        ' Add all Items to the row.
        rootChildren.Push(row)
        ' set up a root ContentNode to represent rowList on the GridScreen.
        contentNode = CreateObject("roSGNode", "ContentNode")
        contentNode.Update({
            children: rootChildren
        }, true)
        ' populate content field with root content node.
        ' Observer(see OnMainContentLoaded in MainScene.brs) is involed at this moment.
        m.top.content = contentNode
    end if
end sub

'''''''''
' GetContent: Gets the content feed and populates the rowList.
' 
'''''''''
sub GetContent()
    ' Get the feed URL.
    feedURL = GetValueFromManifest("FEED_URL")
    ' Convert to lowercase.
    lfeedURL = LCase(feedURL)
    jsonIndex = Instr(1, lfeedURL, ".json")
    if jsonIndex <> 0
        ParseJsonFeed(feedURL)
    else
        xmlIndex = Instr(1, lfeedURL, ".xml")
        if xmlIndex <> 0
            ParseXMLFeed(feedURL)
        else
            xmlIndex = Instr(1, lfeedURL, ".rss")
            if xmlIndex <> 0
                ParseXMLFeed(feedURL)
            end if
        end if
    end if
end sub

'''''''''
' GetXmlItemData: Gets the XML item data.
' 
' @param {object} I: channelItem - an Item object.
' @return {object} - returns a playable item.
'''''''''
function GetXmlItemData(channelItem as object) as object
    item = {}
    ' Set the object type.
    item.mediaType = "shortFormVideo"
    ' Get the child nodes of the Item.
    nodes = channelItem.GetChildNodes()
    ' Iterate through the child nodes of the Item.
    for each node in nodes
        ' Get the node name.
        name = node.GetName()
        ' Get its value.
        value = node.GetText()
        if name = "guid"
            item.id = value
        end if
        if name = "media:description"
            item.longDescription = value
            item.shortDescription = value
            item.description = value
        end if
        if name = "media:thumbnail"
            attrs = node.GetAttributes()
            item.hdPosterURL = attrs["url"]
        end if
        if name = "media:title"
            item.title = value
        end if
        if name = "pubDate"
            m.dateObject.FromISO8601String(value)
            releaseDate = m.dateObject.asDateStringLoc("y-MM-dd")
            item.releaseDate = releaseDate
        end if
        if name = "media:content"
            attrs = node.GetAttributes()
            item.length = attrs["duration"]
            item.Url = attrs["url"]
        end if
        ' CAPTION FILES.
        if name = "media:subTitle"
            attrs = node.GetAttributes()
            tracks = {}
            item.SubtitleUrl = attrs["href"]
            tracks["Language"] = attrs["lang"]
            tracks["TrackName"] = attrs["href"]
            item.SubtitleTracks = tracks
        end if
    end for
    ' Default the video start position to 0.0
    item.PlayStart = 0.0
    return item
end function

'''''''''
' GetJsonItemData: Gets the item content as an AA.
' 
' @param {object} I: contentObject - the feed content object.
' @param {string} I: contentType - the fedd content type.
' @param {boolean} I: [isSeries=false] - flag to indicate a Series.
' @return {object} - returns a playable item.
'''''''''
function GetJsonItemData(contentObject as Object, contentType as string, isSeries = false as boolean) as Object
    ' Initialize a content item.
    item = {}
    ' Initialize the item's genres.
    genres = []
    ' Initialize the item's adBreaks.
    adbreaks = []
    ' Set the object type.
    item.mediaType = contentType
    ' populate some standard content metadata fields to be displayed on the GridScreen
    ' LONG DESCRIPTION and SHORT DESCRIPTION.
    if contentObject.longDescription <> invalid
        item.longDescription = contentObject.longDescription
    end if
    if contentObject.shortDescription <> invalid
        item.shortDescription = contentObject.shortDescription
    end if
    if item.longDescription <> invalid
        item.description = item.longDescription
    else if item.shortDescription <> invalid
        item.description = item.shortDescription
    end if
    ' THUMBNAIL.
    item.hdPosterURL = contentObject.thumbnail
    ' SEASON NUMBER.
    ' If the content does NOT contain a 'seasonNumber' field, it's not a Series/Season object.
    if contentObject.seasonNumber = invalid
        item.title = contentObject.title
    else
        item.title = "Season " + contentObject.seasonNumber.ToStr()
    end if
    ' RELEASE DATE.
    item.releaseDate = contentObject.releaseDate
    item.id = contentObject.id
    if contentObject.episodeNumber <> invalid
        item.episodePosition = contentObject.episodeNumber.ToStr()
        item.episodeNumber = contentObject.episodeNumber
    end if
    ' DURATION.
    if contentObject.content <> invalid
        ' populate length of content to tbe displayed on the GridScreen.
        item.length = contentObject.content.duration
        item.Url = contentObject.content.videos[0].Url
    end if
    ' GENRES.
    if isSeries = false and contentObject.genres <> invalid and contentObject.genres.Count() > 0
        for each genre in contentObject.genres
            genres.Push(genre)
        end for
        item.genres = genres
    end if
    ' ADBREAKS.
    if isSeries = false
        if contentObject.content <> invalid
            if contentObject.content.adBreaks <> invalid and contentObject.content.adBreaks.Count() > 0
                for each adbreak in contentObject.content.adBreaks
                    adbreaks.Push(adbreak)
                end for
                item.adBreaks = adbreaks
            end if
        end if
    end if
    ' TRICKPLAY FILES.
    if isSeries = false and contentType <> "season"
        if contentObject.content.trickPlayFiles <> invalid and contentObject.content.trickPlayFiles.Count() > 0
            for each tpf in contentObject.content.trickPlayFiles
                if tpf.quality = "HD"
                    item.HDBifUrl = tpf.url
                else if tpf.quality = "SD"
                    item.SDBifUrl = tpf.url
                end if
            end for
        end if
    end if
    ' CAPTION FILES.
    if isSeries = false and contentType <> "season"
        if contentObject.content.captions <> invalid and contentObject.content.captions.Count() > 0
            tracks = {}
            for each caption in contentObject.content.captions
                item.SubtitleUrl = caption.url
                tracks["Language"] = caption.language
                tracks["TrackName"] = caption.url
            end for
            item.SubtitleTracks = tracks
        end if
    end if
    ' CREDITS.
    if contentType <> "season"
        if contentObject.credits <> invalid and contentObject.credits.Count() > 0
            Actors = []
            Hosts = []
            Narrators = []
            Directors = []
            Producers = []
            for each credit in contentObject.credits
                if credit.role = "actor"
                    Actors.Push(credit.name)
                else if credit.role = "host"
                    Hosts.Push(credit.name)
                else if credit.role = "narrator"
                    Narrators.Push(credit.name)
                else if credit.role = "director"
                    Directors.Push(credit.name)
                else if credit.role = "producer"
                    Producers.Push(credit.name)
                end if
            end for
            item.Actors = Actors
            item.Hosts = Hosts
            item.Narrators = Narrators
            item.Directors = Directors
            item.Producers = Producers
        end if
    end if
    ' SERIES/SEASONS.
    if isSeries = true and contentObject.seasons <> invalid
        item.hasSeasons = true
    else
        item.hasSeasons = false
    end if
    ' Default the video start position to 0.0
    item.PlayStart = 0.0
    return item
end function

'''''''''
' GetEpisodeData: Gets the Episodes data.
' 
' @param {object} I: series - the Series conent.
' @return {object} = returns an array of Series Episodes.
'''''''''
function GetEpisodeData(series as Object) as object
    ' Init some arrays.
    episodeArray = []
    genresArray = []
    for each episode in series.episodes
        episodeData = GetJsonItemData(episode, "episode")
        ' Embed the Series genres in the Episode.
        for each genre in series.genres
            genresArray.Push(genre)
        end for
        ' save episode title for element to represent it on the episodes screen
        episodeData.titleEpisode = episode.title
        episodeData.episodeNumber = episode.episodeNumber
        episodeData.thumbnail = episode.thumbnail
        episodeData.genres = genresArray
        episodeData.mediaType = "episode"
        episodeArray.Push(episodeData)
    end for
    return episodeArray
end function

'''''''''
' GetSeasonData: Gets the Season data.
' 
' @param {object} seasons
' @return {object}
'''''''''
function GetSeasonData(seasons as Object) as Object
    seasonsArray = []
    if seasons <> invalid
        episodeCounter = 0
        for each season in seasons
            if season.episodes <> invalid
                episodes = []
                for each episode in season.episodes
                    episodeData = GetJsonItemData(episode, "episode")
                    ' save season title for element to represent it on the episodes screen
                    episodeData.titleSeason = season.title
                    episodeData.numEpisodes = episodeCounter
                    episodeData.mediaType = "episode"
                    episodes.Push(episodeData)
                    episodeCounter++
                end for
                seasonData = GetJsonItemData(season, "season")
                ' populate season's children field with its episodes
                ' as a result season's ContentNode will contain episode's nodes
                seasonData.children = episodes
                ' set content type for season object to represent it on the screen as section with episodes
                seasonData.contentType = "section"
                seasonsArray.Push(seasonData)
            end if
        end for
    end if
    return seasonsArray
end function

'''''''''
' ObjectContainsTags: Checks the object for category tags.
' 
' @param {object} obj
' @return {boolean} true if object contains tags, else, fale.
'''''''''
function ObjectContainsTags(obj as Object) as boolean
    if obj.tags <> invalid
        return true
    else
        return false
    end if
end function

'''''''''
' QueryCategoryForTags: Query categories for the passed tags.
' 
' @param {object} tags
' @return {object} an array of categories that specify the tags.
'''''''''
function QueryCategoryForTags(tags as Object) as Object
    categories = []
    ' Scan all categories.
    for each category in m.jsonContentFeed.categories
        ' If the query field is valid...
        if category.query <> invalid
            ' Scan all tags for a match in the category.
            for each tag in tags
                rexp = Substitute("\b{0}\b", tag)
                regxp = CreateObject("roRegex", rexp, "i")
                ' If the tag is specified by the category, save the category name.
                if regxp.IsMatch(category.query)
                    categories.Push(category.name)
                end if
            end for
        else
            continue for
        end if
    end for
    return categories
end function

'''''''''
' GetCategoryFromPlaylist: Get the catgegory object from the playlist name.
' 
' @param {string} playlistname
' @return {object}  a category object.
'''''''''
function GetCategoryFromPlaylist(playlistname as string) as Object
    foundcategory = ""
    if m.jsonContentFeed.categories <> invalid
        for each category in m.jsonContentFeed.categories
            if playlistname = category.playlistName
                foundcategory = category
                exit for
            end if
        end for
    end if
    return foundcategory
end function

'''''''''
' QueryObjectById: Query a feed object by its id.
' 
' @param {string} I: id - id of the feed object.
' @return {object} - returns the found feed object.
'''''''''
function QueryObjectById(id as string, contentType as object) as Object
    object = invalid
    rexp = Substitute("\b{0}\b", id)
    regxp = CreateObject("roRegex", rexp, "i")
    ' Parse movies.
    if m.jsonContentFeed.movies <> invalid
        for each movie in m.jsonContentFeed.movies
            ' If the passed id matches the movie id, we found the object.
            if regxp.IsMatch(movie.id)
                contentType[0] = "movies"
                return movie
            end if
        end for
    end if
    ' Parse liveFeeds.
    if m.jsonContentFeed.liveFeeds <> invalid
        for each liveFeed in m.jsonContentFeed.liveFeeds
            ' If the passed id matches the liveFeed id, we found the object.
            if regxp.IsMatch(liveFeed.id)
                contentType[0] = "liveFeeds"
                return liveFeed
            end if
        end for
    end if
    ' Parse shortFormVideos.
    if m.jsonContentFeed.shortFormVideos <> invalid
        for each shortFormVideo in m.jsonContentFeed.shortFormVideos
            ' If the passed id matches the shortFormVideo id, we found the object.
            if regxp.IsMatch(shortFormVideo.id)
                contentType[0] = "shortFormVideos"
                return shortFormVideo
            end if
        end for
    end if
    ' Parse tvSpecials.
    if m.jsonContentFeed.tvSpecials <> invalid
        for each tvSpecial in m.jsonContentFeed.tvSpecials
            ' If the passed id matches the tvSpecial id, we found the object.
            if regxp.IsMatch(tvSpecial.id)
                contentType[0] = "tvSpecials"
                return tvSpecial
            end if
        end for
    end if
    return object
end function

'''''''''
' QueryChannelRowByCategoryName: Query the channel row for a matching category.
' 
' @param {string} name
' @param {object} rootChildren
' @return {object}  The corresponding row of the category.
'''''''''
function QueryChannelRowByCategoryName(name as string, rootChildren as object) as object
    for each row in rootChildren
        if row.title = name
            return row
        end if
    end for
end function'//# sourceMappingURL=./MainLoaderTask.bs.map