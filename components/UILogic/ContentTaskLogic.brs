'''''''''
' LoadChannelContent: Loads the channel content by spawning a task to iterate the feed file.
' 
'''''''''
sub LoadChannelContent()
    m.ContentTask = CreateObject("roSGNode", "MainLoaderTask")  ' create task for retrieving channel feed.
    ' observe content so we can know when the feed content will be parsed.
    m.contentTask.ObserveField("content", "OnMainContentLoaded")
    m.contentTask.control = "run"   ' GetContent(see MainLoaderTask.brs) method is executed.
    m.loadingIndicator.visible = true   ' show loading indicator while content is loading.
end sub

'''''''''
' OnMainContentLoaded: Event: called after the content feed has been loaded.
' 
'''''''''
sub OnMainContentLoaded()    ' invoked when content has been parsed and is ready to use.
    m.GridScreen.SetFocus(true) ' set focus to the GridScreen.
    m.loadingIndicator.visible = false  ' hide loading indicator because content was retrieved.
    m.GridScreen.content = m.contentTask.content    ' populate GridScreen with content.

    ' Get the input args to check for Deeplinking invocation.
    args = m.top.inputArgs
    ' If the args are valid, invoke Deeplinking.
    if args <> invalid and ValidateDeepLink(args)
        DeepLink(m.contentTask.content, args.dl_mediaType, args.dl_contentId)
    end if    
end sub
    
'//# sourceMappingURL=./ContentTaskLogic.brs.map