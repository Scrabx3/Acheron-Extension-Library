Scriptname AELStruggle Extends Quest  
{ Main Script to start and manage struggle mechanics }

AELStruggle Function Get() global
  return Quest.GetQuest("AEL_Struggle") as AELStruggle
EndFunction

; Create a context free game, without struggle animations
; Listen for "AEL_GameEnd("", "", afVictory, none)" to receive the game result
; afDifficulty is a value between 0 and 100. Higher is easier, 70 is default difficulty, below 20 becomes humanly impossible
bool Function MakeGame(float afDifficulty = 70.0) global
  If (!SPE_Interface.OpenCustomMenu("AELStruggling\\AELStruggling_Game"))
    Debug.Trace("[AEL] Failed to open custom menu")
    return false
  EndIf
  int handle = UICallback.Create(SPE_Interface.GetMenuName(), "_root.main.beginGame")
  If(!handle)
    Debug.Trace("[AEL] Failed to create beginGame() handle")
    return false
  EndIf
  UICallback.PushFloat(handle, afDifficulty)
  UICallback.PushBool(handle, Game.UsingGamepad())
  If (!UICallback.Send(handle))
    Debug.Trace("[AEL] Failed to send beginGame() handle")
    SPE_Interface.CloseCustomMenu()
    return false
  EndIf
  return true
EndFunction

; Create a struggle between the two actors, using the given animation events, starting the QTE while said animation plays (iff the player is involved)
; --- Params:
; akFst, akSnd:     The actorst o animate
; asAnim1, asAnim2: The animations to use (akFst will use asAnim1)
; asCallback:       A callback event to use with ModEvent.Send(), Function signature given below
; afDifficulty:     Difficulty for the victim to escape, between 0 and 100. NPC: RNG check, Player: See MakeGame()
; afDuration:       Struggle duration; Negative plays until unload. 0 is default. If player is participating, anything other than 0 will only play the animation
bool Function MakeAnimation(Actor akFst, Actor akSnd, String asAnim1, String asAnim2, String asCallback, float afDifficulty = 0.0, float afDuration = 0.0)
  If(!akFst || !akSnd || asAnim1 ==  "" && asAnim2 == "")
    Debug.Trace("[AEL] Invalid Parameter/s [" + akFst + ", " + akSnd + "]", 2)
    return false
  ElseIf(akFst.HasKeyword(StruggleKywd) || akSnd.HasKeyword(StruggleKywd))
    Debug.Trace("[AEL] Actor is already in animation [" + akFst + ", " + akSnd + "]", 2)
    return false
  EndIf
  AELStruggleAlias slot = GetEmptySlot()
  If(!slot)
    Debug.Trace("[AEL] Unable to find empty slot to animate [" + akFst + ", " + akSnd + "]", 2)
    return false
  EndIf
  return slot.CreateEx(akFst, akSnd, asAnim1, asAnim2, asCallback, afDifficulty, afDuration)
EndFunction

; Create a struggle between akAggressor and akVictim with the specified parameters
; This will also fail if akAggressor is a creature that has no animations available
; --- Params:
; akAggressor:                          The actor attacking (choking) the victim
; akVictim:                             The actor being attacked. MUST be a NPC (human)
; asCallback, afDifficulty, afDuration: See MakeAnimation()
bool Function MakeStruggle(Actor akAggressor, Actor akVictim, String asCallback, float afDifficulty = 70.0, float afDuration = 0.0)
  If(!akAggressor || !akVictim)
    Debug.Trace("[AEL] Invalid Parameter/s [" + akAggressor + ", " + akVictim + "]", 2)
    return false
  ElseIf(akAggressor.HasKeyword(StruggleKywd) || akVictim.HasKeyword(StruggleKywd))
    Debug.Trace("[AEL] Actor is already  in animation [" + akAggressor + ", " + akVictim + "]", 2)
    return false
  ElseIf(SPE_Actor.GetRaceType(akVictim) != "Human")
    Debug.Trace("[AEL] Victim Actor must be 'Human' but is '" + SPE_Actor.GetRaceType(akVictim) + "' [" + akAggressor + ", " + akVictim + "]", 2)
    return false
  EndIf
  AELStruggleAlias slot = GetEmptySlot()
  If(!slot)
    Debug.Trace("[AEL] Unable to find empty slot to animate [" + akAggressor + ", " + akVictim + "]", 2)
    return false
  EndIf
  return slot.Create(akAggressor, akVictim, asCallback, afDifficulty, afDuration)
EndFunction

; Function signature for the callback. Listen to this using RegisterForModEvent(asCallback, OnStruggleEnd)
Event OnStruggleEnd(Form akVictim, Form akAggressor, bool abVictimEscaped)
EndEvent

; =============================================================================== ;
; =============================================================================== ;
;                                                                                 ;
;              ██████╗ ██████╗ ██╗██╗   ██╗ █████╗ ████████╗███████╗              ;
;              ██╔══██╗██╔══██╗██║██║   ██║██╔══██╗╚══██╔══╝██╔════╝              ;
;              ██████╔╝██████╔╝██║██║   ██║███████║   ██║   █████╗                ;
;              ██╔═══╝ ██╔══██╗██║╚██╗ ██╔╝██╔══██║   ██║   ██╔══╝                ;
;              ██║     ██║  ██║██║ ╚████╔╝ ██║  ██║   ██║   ███████╗              ;
;              ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝  ╚═╝  ╚═╝   ╚═╝   ╚══════╝              ;
;                                                                                 ;
; =============================================================================== ;
; =============================================================================== ;

AELStruggleAlias[] Property Slots Auto
Keyword Property StruggleKywd Auto

AELStruggleAlias Function GetEmptySlot()
  int i = 0
  While(i < Slots.Length)
    If(!Slots[i].GetReference())
      return Slots[i]
    EndIf
    i += 1
  EndWhile
  return none
EndFunction
