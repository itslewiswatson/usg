setRadioChannel(0)
song = playSound("http://vita.gamers-board.com/serverfiles/race/lindsey88.mp3", true)
bindKey("z", "down",
function ()
        setSoundPaused(song, not isSoundPaused(song))
end
)
outputChatBox("#8c8c8cVita|#88ff00ExXoTicC: #ffffffPress '#88ff00z#FFFFFF' to turn the music ON/OFF.",255,255,255,true)
outputChatBox("#8c8c8cVita|#88ff00ExXoTicC: #ffffffPress '#88ff00lshift#FFFFFF' for a mini-jump.",255,255,255,true)
outputChatBox("#8c8c8cVita|#88ff00ExXoTicC: #ffffffGood #88ff00Luck #FFFFFFand have #88ff00FUN!",255,255,255,true)