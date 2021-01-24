        extern  _cls
        extern  currentCoinTable
        extern  _coinTables
        extern  setCurrentItemTable
        extern  currentEggTable
        extern  eggTables
        extern  currentHeartTable
        extern  heartTables
        extern  _setCurrentTileMap
        extern  _currentTileMap
        extern  _displayScreen
        extern  displayItemAttr
        extern  displayItems
        extern  eggCount
        extern  display2BCD
        extern  heartCount
        extern  _displayScore
        extern  _scrollReset
        extern  updateEggImage

        public  setupScreen

        include "defs.asm"

        section code_user

        ;
        ; Display the current level and any uncollected items.
        ;
setupScreen:
        pushall 

        ld      l, INK_WHITE|PAPER_BLACK
        call    _cls

        ;
        ; Set the item tables for this level
        ;
        ld      hl, currentCoinTable
        ld      de, _coinTables
        call    setCurrentItemTable

        ld      hl, currentEggTable
        ld      de, eggTables
        call    setCurrentItemTable

        ld      hl, currentHeartTable
        ld      de, heartTables
        call    setCurrentItemTable

        call    _setCurrentTileMap

        halt    

        ld      hl, (_currentTileMap)
        call    _displayScreen

        ld      a, ID_COIN
        ld      hl, (currentCoinTable)
        call    displayItemAttr

        ld      a, ID_EGG
        ld      hl, (currentEggTable)
        call    displayItemAttr

        ld      a, ID_HEART
        ld      hl, (currentHeartTable)
        call    displayItemAttr

        ld      a, ID_EGG
        ld      hl, (currentEggTable)
        call    displayItems

        ld      a, ID_HEART
        ld      hl, (currentHeartTable)
        call    displayItems

        ld      bc, 0x011a              ; y,x screen location
        ld      hl, eggCount            ; Point to 10's/1's
        call    display2BCD

        ld      bc, 0x011d              ; y,x screen location
        ld      hl, heartCount          ; Point to 10's/1's
        call    display2BCD

        call    _displayScore

        call    _scrollReset

        call    updateEggImage

        popall  
        ret     