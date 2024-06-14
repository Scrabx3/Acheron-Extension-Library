Scriptname AELStruggleAlias extends ReferenceAlias  

float Property DefaultDuration = 8.0 AutoReadOnly

ReferenceAlias Property VictimAlias Auto
Static Property xMarker Auto

String[] anim_leadin
String[] anim_instant
String[] anim_breakfree

Actor _victim
String _callback
bool _victorious

bool _continusesetup

bool Function Create(Actor akAggressor, Actor akVictim, String asCallback, float afDifficulty = 0.0, float afDuration = 0.0)
  If(!DefineAnimations(akAggressor))
    Debug.Trace("[AEL] No struggle animation for actor [" + akAggressor + "]", 1)
    return false
  EndIf

  String[] anims = anim_instant
  If(!anims.Length || (anim_leadin.Length && akVictim.IsBleedingOut() || akVictim.IsBleedingOut()) && anim_leadin.Length)
    anims = anim_leadin
  EndIf
  return CreateEx(akAggressor, akVictim, anims[0], anims[1], asCallback, afDifficulty, afDuration)
EndFunction

bool Function CreateEx(Actor akFst, Actor akSnd, String asAnim1, String asAnim2, String asCallback, float afDifficulty, float afDuration)
  _callback = asCallback
  _victim = akSnd
  _continusesetup = false
  ForceRefTo(akFst)
  ClearActorState(akFst)
  ClearActorState(akSnd)
  Restrain(akFst, true)
  Restrain(akSnd, true)
  ObjectReference ref = akFst.PlaceAtMe(xMarker)
  akFst.SetAngle(akSnd.GetAngleX(), akSnd.GetAngleY(), akSnd.GetAngleZ())
  akFst.SplineTranslateToRef(akSnd, 1.3, 150.0)
  akSnd.SetVehicle(ref)
  akFst.SetVehicle(ref)

  ; While (!_continusesetup)
  ;   Utility.Wait(0.1)
  ; EndWhile

  Debug.SendAnimationEvent(akSnd, asAnim1)
  Debug.SendAnimationEvent(akFst, asAnim2)

  Utility.Wait(1.2)

  If(afDuration <= 0.025 && afDuration >= 0.0)
    Actor PlayerRef = Game.GetPlayer()
    If(akFst == PlayerRef || akSnd == PlayerRef)
      If(AELStruggle.MakeGame(afDifficulty))
        RegisterForModEvent("AEL_GameEnd", "OnGameEnd")
        Debug.Trace("[AEL] Successfully started struggle between victim [" + akSnd + "] and aggressor [" + akFst + "]", 0)
        return true
      EndIf
      Debug.Messagebox("Failed to create flash game. Falling back to timed event")
    EndIf
    afDuration = DefaultDuration
  ElseIf(afDuration < 0)
    Debug.Trace("[AEL] Successfully started struggle between victim [" + akSnd + "] and aggressor [" + akFst + "]", 0)
    return true
  EndIf
  _victorious = Utility.RandomFloat(0, 99.9) < afDifficulty
  RegisterForSingleUpdate(afDuration)
  Debug.Trace("[AEL] Successfully started struggle between victim [" + akSnd + "] and aggressor [" + akFst + "]", 0)
  return true
EndFunction

Event OnGameEnd(string asEventName, string asStringArg, float afNumArg, form akSender)
  Debug.Trace("[AEL] OnGameEnd, afNumArg: " + afNumArg)
  UnregisterForModEvent("AEL_GameEnd")
  SPE_Interface.CloseCustomMenu()
  bool player_won = afNumArg > 0
  If(_victim == Game.GetPlayer())
    _victorious = player_won
  Else
    _victorious = !player_won
  EndIf
  MakeEventAndClose()
EndEvent

Event OnUpdate()
  MakeEventAndClose()
EndEvent

Event OnCellDetach()
  MakeEventAndClose()
EndEvent

Function MakeEventAndClose()
  Actor aggressor = GetReference() as Actor
  If(_victorious)
    If(anim_breakfree.Length)
      Debug.SendAnimationEvent(_victim, anim_breakfree[0])
      Debug.SendAnimationEvent(aggressor, anim_breakfree[1])
      Utility.Wait(2.3)
    Else
      Debug.SendAnimationEvent(_victim, "IdleForceDefaultState")
      Debug.SendAnimationEvent(aggressor, "StaggerStart")
    EndIf
    String rt = SPE_Actor.GetRaceType(aggressor)
    If(rt == "Human")
      ; nothing
    ElseIf(rt == "Skeever" || rt == "Wolf")
      _victim.PushActorAway(aggressor, 5.00000)
    ElseIf(rt == "Riekling" || rt == "DwarvenSpider")
      _victim.PushActorAway(aggressor, 3.50000)
    ElseIf(rt == "FrostbiteSpider" || rt == "Falmer" || rt == "Draugr")
      _victim.PushActorAway(aggressor, 2.00000)
    ElseIf(rt == "Sabrecat" || rt == "Gargoyle")
      _victim.PushActorAway(aggressor, 1.00000)
    ElseIf(rt == "Bear" || rt == "Werewolf" || rt == "Chaurus" || rt == "ChaurusReaper" || rt == "ChaurusHunter")
      _victim.PushActorAway(aggressor, 0.500000)
    Else ; If(rt == "Troll" || rt == "Giant")
      _victim.PushActorAway(aggressor, 0.200000)
    EndIf
  Else
    String anim = "IdleForceDefaultState"
    If(SKSE.GetPluginVersion("Acheron") > -1 && AELAcheron.IsDefeated(_victim))
      anim = "bleedoutStart"
    EndIf
    Debug.SendAnimationEvent(_victim, anim)
    Debug.SendAnimationEvent(aggressor, "ReturnDefaultState")
    Debug.SendAnimationEvent(aggressor, "ReturnToDefault")
    Debug.SendAnimationEvent(aggressor, "IdleReturnToDefault")
    Debug.SendAnimationEvent(aggressor, "forceFurnExit")
    Debug.SendAnimationEvent(aggressor, "IdleForceDefaultState")
    Debug.SendAnimationEvent(aggressor, "reset")
  EndIf
  Restrain(aggressor, false)
  Restrain(_victim, false)
  aggressor.SetVehicle(none)
  _victim.SetVehicle(none)
  Clear()

  If (!_callback)
    return
  EndIf
  int handle = ModEvent.Create(_callback)
  ModEvent.PushForm(handle, _victim)
  ModEvent.PushForm(handle, aggressor)
  ModEvent.PushBool(handle, _victorious)
  ModEvent.Send(handle)
EndFunction

Function Restrain(Actor akActor, bool abRestrain)
  If(akActor == Game.GetPlayer())
    Game.SetPlayerAIDriven(abRestrain)
  Else
    akActor.SetRestrained(abRestrain)
  EndIf
EndFunction

Function ClearActorState(Actor akActor)
  akActor.StopCombat()
  akActor.SheatheWeapon()
	If (akActor.IsSneaking())
		akActor.StartSneaking()
  EndIf
  akActor.ClearKeepOffsetFromActor()
EndFunction

bool Function DefineAnimations(Actor akAggressor)
  String type = SPE_Actor.GetRaceType(akAggressor)
  int file = JValue.zeroLifetime(JValue.readFromFile("Data\\SKSE\\QTRessource\\Animations.json"))
  int root = JMap.getObj(file, type)
  anim_leadin = jObjToArray(root, "LeadIn")
  anim_instant = jObjToArray(root, "Instant")
  anim_breakfree = jObjToArray(root, "Breakfree")
  return anim_leadin.Length || anim_instant.Length
EndFunction
String[] Function jObjToArray(int root, String attribute)
  int jobj = JMap.getObj(root, attribute)
  If(!jobj)
    return Utility.CreateStringArray(0)
  EndIf
  return JArray.asStringArray(jobj)
EndFunction


Function ForceRefTo(ObjectReference akNewRef)
  Parent.ForceRefTo(akNewRef)
  VictimAlias.ForceRefTo(_victim)
EndFunction

Function Clear()
  Parent.Clear()
  VictimAlias.Clear()
EndFunction

Event OnTranslationComplete()
  _continusesetup = true
EndEvent
