sub OnContentSet()  ' invoked when item metadata is retrieved.
    content = m.top.itemContent
    ' set poster uri if content is valid.
    if content <> invalid
        m.top.FindNode("poster").uri = content.hdPosterUrl
    end if
end sub

'//# sourceMappingURL=./RowListItemComponent.brs.map