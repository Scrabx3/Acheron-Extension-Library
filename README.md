# Acheron-Extension-Library

Modders ressource to streamline various more complex tasks to simplify add on creation for Acheron based mods.

## Features

### Struggling

Create a struggle motion between 2 actors.
If one of them is the player, and there is no custom duration given, this will include an interactve flash game to decide if the attacked actor is able to escape, otherwise escape will be based on chance.

#### Example:

```Papyrus
AELStruggle struggle_api = AELStruggle.Get()

If (struggle_api.MakeStruggle(my_aggressor, my_victim, my_callback))
  RegisterForModEvent(my_callback, "OnStruggleEnd")
Else
  Debug.Trace("There was an error starting my struggle scene") ; See your papyrus log for more information
EndIf
```

Then, later in your code:

```Papyrus
Event OnStruggleEnd(Form akVictim, Form akAggressor, bool abVictimEscaped)
  If(abVictimEscaped)
    Debug.Trace("Did Victim " + akVictim + " managed to escape from " + akAggressor + "!")
  Else
    Debug.Trace("Victim " + akVictim + " has been struck down by " + akAggressor + "!")
  EndIf
EndEvent
```

## Credits

BakaFactory - Included animations files
