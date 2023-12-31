sub ShowGridScreen()
    m.GridScreen = CreateObject("roSGNode", "GridScreen")
    m.GridScreen.ObserveField("rowItemSelected", "OnGridScreenItemSelected")
    ShowScreen(m.GridScreen)    ' show GridScreen.
end sub

sub OnGridScreenItemSelected(event as Object)   ' invoked when GridScreen item is selected.
    grid = event.GetRoSGNode()
    ' extract the row and column of indices of the item the user selected.
    m.selectedIndex = event.GetData()
    ' the entire row from the RowList will be used by the Video node.
    rowContent = grid.content.GetChild(m.selectedIndex[0])
    m.selectedRow = m.selectedIndex[0]
    ShowDetailsScreen(rowContent, m.selectedIndex[1])
end sub
'//# sourceMappingURL=./GridScreenLogic.brs.map