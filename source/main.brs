' BrightScript code version 1.0.0.0-alpha-8
' https://github.com/rrirower
' Constant values.


'''''''''
' Main: Main entry point of the channel.
' 
' @param {object} args - Associative array that contains content ID and media type.
'''''''''
sub Main(args as Object)
    ' Next lines DEBUG ONLY!
    'DebugClearRegistry()
    'DebugListRegistry()
    ShowChannelRSGScreen(args)
end sub

sub ShowChannelRSGScreen(args as Object)
    ' The RoSCScreen object is a SceneGraph canvas that displays the contents of a Scene node instance.
    screen = CreateObject("roSGScreen")
    ' message port is the place where events are sent.
    m.eventmessages = CreateObject("roMessagePort")
    ' sets the message port which will be used for events from the screen.
    screen.SetMessagePort(m.eventmessages)
    ' every screen object must have a Scene node, or a node that derives from the Scene node.
    scene = screen.CreateScene("MainScene")
    screen.Show() ' Init method in MainScene.brs is invoked. 
    ' Required by Roku certification.
    scene.signalBeacon("AppLaunchComplete")
    ' Deep Linking: Save the launch arguments and set a flag.
    m.global = screen.getGlobalNode()
    m.global.id = "GlobalNode"
    m.global.addFields(args)
    m.global.addFields({
        "isDeepLink": false
    })
    ' Deep Linking: Create roInput object that receives events from ECP.
    inputObject = CreateObject("roInput")
    ' Deep Linking: Set the message port of the roInput object.
    inputObject.SetMessagePort(m.eventmessages)
    ' RAF: Are we rendering ads?
    useRAF = GetValueFromManifest("USE_RAF")
    if useRAF = "1"
        adServerUrl = GetValueFromManifest("AD_SERVER")
        m.global.addFields({
            "UseRaf": true
        })
        m.global.addFields({
            "AdServerURL": adServerUrl
        })
    end if
    ' OPTIONAL Manifest setting: USE_THUMBNAIL_BACKGROUND.
    useThumbnailForBackground = GetValueFromManifest("USE_THUMBNAIL_BACKGROUND")
    if useThumbnailForBackground <> invalid and useThumbnailForBackground = "true"
        m.global.addFields({
            "UseThumbnailBackground": true
        })
    end if
    ' OPTIONAL Manifest setting: TEXT_COLOR.
    textColor = GetValueFromManifest("TEXT_COLOR")
    if textColor <> invalid and textColor <> ""
        m.global.addFields({
            "TextColor": textColor
        })
    end if
    ' Check for Deep Linking Launch event.
    ' If valid, set the inputArgs which will be used later in ContentTaskLogic::OnMainContentLoaded().
    if (args.mediaType <> invalid) and (args.contentId <> invalid)
        SaveDeepLinkingArgs(scene, args.mediaType, args.contentId)
    end if
    ' Main event loop.
    while (true)
        ' waiting for events from the screen
        msg = wait(0, m.eventmessages)
        msgType = type(msg)
        ' Next line for debugging only.
        '? ">> DEBUG: msgType= " msgType
        if msgType = "roSGScreenEvent"
            if msg.IsScreenClosed() then
                return
            end if
            ' Check for Deep Linking Input event.
        else if msgType = "roInputEvent"
            eventData = msg.getInfo()
            ' Next line for debugging only.
            '? ">> DEBUG: Input received by channel from Deep Linking."
            ' Pass the event to the channel UI.
            if eventData.DoesExist("mediaType") and eventData.DoesExist("contentId")
                SaveDeepLinkingArgs(scene, eventData.mediaType, eventData.contentId)
            end if
        end if
    end while
end sub

'''''''''
' SaveDeepLinkingArgs: Saves the Deep Linking arguments for later use.
' 
' @param {string} I: mediaType - the media type.
' @param {string} I: contentId - the content id.
' @return {dynamic}
'''''''''
function SaveDeepLinkingArgs(scene as object, mediaType as string, contentId as string)
    deepLinkArgsArray = {
        dl_contentId: contentId
        dl_mediaType: mediaType
    }
    m.global.addFields(deepLinkArgsArray)
    m.global.isDeepLink = true
    ' Setting inputArgs triggers the OnInputDeepLinking event.
    scene.inputArgs = deepLinkArgsArray
end function'//# sourceMappingURL=./main.bs.map