Scriptname AELDemo extends activemagiceffect  

AELStruggle Property Main Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
  Main.MakeStruggle(akTarget, akCaster, "")
EndEvent
