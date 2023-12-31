' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********
'import "pkg:/components/UILogic/BookmarkLogic.bs"
'import "pkg:/source/utils.bs"
' We need to include this library only in task which handles RAF.
Library "Roku_Ads.brs"

sub init()
    m.top.functionName = "PlayContentWithAds" ' func to run by task
    m.top.id = "PlayerTask"
    ' Create a Bookmark object.
    m.bookMark = Bookmark()
end sub

'''''''''
' PlayContentWithAds: Play the video content with Ads.
' 
'''''''''
sub PlayContentWithAds()
    ' "parentNode" is the node to which the stitched stream can be attached 
    ' (passed as 2nd argument of renderStitchedStream).
    parentNode = m.top.GetParent()
    content = m.top.content
    m.top.lastIndex = m.top.startIndex ' assume that index of last played item equals to index of first played one
    items = content.getChildren(- 1, 0)
    ' This is the main entry point for instantiating the ad interface.
    ' This object manages ad server requests, parses ad structure, schedules and renders ads, and triggers tracking beacons.
    RAF = Roku_Ads()
    ' Uncomment the next line for RAF debugging.
    'RAF.setDebugOutput(true)
    RAF.enableAdMeasurements(true)
    ' Set the ad URL to be used for a new getAds() request.
    if m.global.adServerUrl <> invalid
        RAF.SetAdUrl(m.global.adServerUrl)
    end if
    playContent = true
    index = m.top.startIndex - 1
    ' Play the content with ads until all content is played.
    while playContent
        ' Define the default video start position.
        position = [
            0.0
        ]
        scheduledAds = false
        for each item in items
            ' we need to give parentNode a focus in order to handle "back" button key press during ads retrieving
            parentNode.SetFocus(true)
            index++
            ' Get the last video position for this item and set it as the 'Playstart'.
            position[0] = m.bookMark.GetLastVideoPosition(item.id)
            item.playStart = position[0]
            ' Content details used by RAF for ad targeting
            RAF.SetContentId(item.id)
            if item.genres <> invalid
                RAF.SetContentGenre(item.genres)
            end if
            RAF.SetContentLength(int(item.length)) ' in seconds
            adPods = RAF.GetAds() ' ads retrieving
            ' If adBreaks are requested, set up the schedule pod.
            if item.adBreaks <> invalid and item.adBreaks.Count() > 0
                adBreakSchedule = []
                for each adBreak in item.adBreaks
                    adBreakSchedule.Push(adBreak)
                end for
                scheduledAds = true
                scheduledPods = []
                adBreakIndex = 0
                for each ad in adPods[0].ads
                    if adBreakIndex < adBreakSchedule.Count()
                        ' Get the start time for the ad.
                        scheduledTimeInSeconds = ConvertAdbreakToSeconds(adBreakSchedule[adBreakIndex])
                        ' Default to midroll.
                        adSequence = "midroll"
                        ' Check for preroll ad.
                        if scheduledTimeInSeconds = 0
                            adSequence = "preroll"
                        end if
                        ' schedule one ad per ad break
                        scheduledPods.Push({
                            viewed: false
                            renderSequence: adSequence
                            duration: ad.duration
                            renderTime: scheduledTimeInSeconds
                            ads: [
                                ad
                            ]
                        })
                        adBreakIndex = adBreakIndex + 1
                    end if
                end for
                RAF.importAds(scheduledPods)
            end if
            ' save the index of last played item to navigate to appropriate detailsScreen
            m.top.lastIndex = index
            ' combine video and ads into a single playlist
            if scheduledAds = true
                csasStream = RAF.constructStitchedStream(item, scheduledPods)
            else
                csasStream = RAF.constructStitchedStream(item, adPods)
            end if
            ' render the stitched stream.  If playContent is false, user pressed Back button.
            playContent = RAF.renderStitchedStream(csasStream, parentNode)
            ' Stitched stream has stopped or finished.  Save video position.
            m.bookMark.UpdateVideoPosition(item.id, csasStream.positionInfo["video"], item.length)
            ' Check for user Back button to stop playback.  Exit the for loop.
            if playContent = false
                exit for
            end if
        end for
        playContent = false
    end while
end sub'//# sourceMappingURL=./PlayerTask.bs.map