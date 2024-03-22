Scriptname AELStruggle Extends Quest  
{ Main Script to start and manage struggle mechanics }

AELStruggle Function Get() global
  return Quest.GetQuest("AEL_Struggle") as AELStruggle
EndFunction

; Create a context free game, without struggle animations
; Listen for "AEL_GameEnd("", "", afVictory, none)" to receive the game result
; afDifficulty is a value between 0 and 100. Higher is easier, 70 is default difficulty, below 20 becomes humany impossible
bool Function MakeGame(float afDifficulty = 70.0) global
  If (!SPE_Interface.OpenCustomMenu("QTRessource\\QuickTimeRessource_Game"))
    return false
  EndIf
  int handle = UICallback.Create(SPE_Interface.GetMenuName(), "_root.main.beginGame")
  If(!handle)
    return false
  EndIf
  UICallback.PushFloat(handle, afDifficulty)
  UICallback.PushBool(handle, Game.UsingGamepad())
  If (!UICallback.Send(handle))
    SPE_Interface.CloseCustomMenu()
    return false
  EndIf
  return true
EndFunction

; Create a struggle between akAggressor and akVictim with the specified parameters
; NOTE: This requires the full version. If the user installed the "Light" version of this mod, this will ALWAYS fail
; This will also fail if akAggressor is a creature that has no animations available
; --- Params:
; akAggressor:  The actor attacking (choking) the victim
; akVictim:     The actor being attacked. MUST be a NPC (human)
; asCallback:   A callback event to use with ModEvent.Send(), Function signature given below
; afDifficulty: Difficulty for the victim to escape, between 0 and 100. NPC: RNG check, Player: See MakeGame()
; afDuration:   Struggle duration; Negative plays until unload. 0 is default. If player is participating, anything other than 0 will only play the animation
bool Function MakeStruggle(Actor akAggressor, Actor akVictim, String asCallback, float afDifficulty = 70.0, float afDuration = 0.0)
  If(!akAggressor || !akVictim || !asCallback)
    Debug.Trace("[AEL] Invalid Parameter/s [" + akAggressor + ", " + akVictim + "]", 2)
    return false
  ElseIf(akAggressor.HasKeyword(StruggleKywd) || akVictim.HasKeyword(StruggleKywd))
    Debug.Trace("[AEL] Actor is already struggling [" + akAggressor + ", " + akVictim + "]", 2)
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
