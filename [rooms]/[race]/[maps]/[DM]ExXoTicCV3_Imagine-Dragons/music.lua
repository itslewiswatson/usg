setRadioChannel(0)
song = playSound("http://vita.gamers-board.com/serverfiles/race/[DM]ExXoTicCV3_Imagine-Dragons.mp3", true)
outputChatBox("#8c8c8cVita|#93E0F1ExXoTicC: #ffffffPress '#93E0F1m#FFFFFF' to turn the music ON/OFF.",255,255,255,true)
outputChatBox("#8c8c8cVita|#93E0F1ExXoTicC: #ffffffGood #93E0F1Luck #FFFFFFand have #93E0F1FUN!",255,255,255,true)
bindKey("m", "down",
function ()
        setSoundPaused(song, not isSoundPaused(song))
end
)