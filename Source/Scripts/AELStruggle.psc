Scriptname AELStruggle Extends Quest  
{ Main Script to start and manage struggle mechanics }

AELStruggle Function Get() global
  return Quest.GetQuest("AEL_Struggle") as AELStruggle
EndFunction

; Create a struggle between akAggressor and akVictim with the specified parameters
; --- Params:
; akAggressor:  The actor attacking (choking) the victim
; akVictim:     The actor being attacked. MUST be a NPC (human)
; asCallback:   A callback event to use with ModEvent.Send, signature see below
; afDifficulty: Difficulty for the victim to escape, between 0 and 100. NPC: RNG check, Player: Higher is easier, below 30 becomes humanly impossible, 70 is 'normal'
; afDuration:   Struggle duration; Negative plays until unload. 0 is default. If player is participating, anything other than 0 suppresses the mini game
bool Function MakeStruggle(Actor akAggressor, Actor akVictim, String asCallback, float afDifficulty = 70.0, float afDuration = 0.0)
  If(!akAggressor || !akVictim || !asCallback)
    Debug.Trace("[AEL] Invalid Parameter/s [" + akAggressor + ", " + akVictim + "]", 2)
    return false
  ElseIf(akAggressor.HasKeyword(StruggleKywd) || akVictim.HasKeyword(StruggleKywd))
    Debug.Trace("[AEL] Actor is already struggling [" + akAggressor + ", " + akVictim + "]", 2)
    return false
  ElseIf(Acheron.GetRaceType(akVictim) != "Human")
    Debug.Trace("[AEL] Victim Actor must be 'Human' but is '" + Acheron.GetRaceType(akVictim) + "' [" + akAggressor + ", " + akVictim + "]", 2)
    return false
  EndIf
  AELStruggleAlias slot = GetEmptySlot()
  If(!slot)
    Debug.Trace("[AEL] Unable to find empty slot to animate [" + akAggressor + ", " + akVictim + "]", 2)
    return false
  EndIf
  return slot.Create(akAggressor, akVictim, asCallback, afDifficulty, afDuration)
EndFunction

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
