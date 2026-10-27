# KIF: Elite Redux

Elite Redux's innates, abilities, battle effects, moves and Pokémon data for KIF (Kuray's Infinite Fusion), fusions included. This page describes KIF: Elite Redux 0.6.30.

## What it adds

- **Innates:** every Pokémon has 3 extra abilities that are always on, next to its normal ability. Your Pokémon, trainers' Pokémon and wild Pokémon all have them.
- **Choice abilities:** a Pokémon's ability is one of the 3 Elite Redux gives its species. A fusion chooses from 6 (head's 3 and body's 3).
- **Abilities tab:** a new Summary tab to read every ability's full text and to change the ability and a fusion's innates for free, whenever you're not in a battle.
- **259 new abilities:** every Elite Redux ability that a Pokémon in this game has and PIF doesn't, with Elite Redux's full descriptions.
- **Ability versions:** Elite Redux's rules for 111 abilities PIF already has.
- **New battle effects:** fog, frostbite, bleeding, fear, drench, Toxic Terrain, enrage, Inverse Room, Elite Redux infatuation and spores.
- **Moves:** Elite Redux numbers and effects for 590 of PIF's moves, 279 Elite Redux moves PIF doesn't have, Elite Redux learnsets, Elite Redux tutor moves in Tutor.net, and a field tool with each HM.
- **Pokémon data:** Elite Redux base stats and types. For example, Flygon is Ground/Bug.
- **Item changes:** Elite Redux's changes to items PIF has (boost items, pinch berries, weather turns, potions, prices).
- **Types from abilities:** abilities like Aquatic add a type.
- The trainers' battle AI understands innates, the new abilities and the new effects.
- KIF's Battle Info screen lists every Pokémon's innates.

## Installing

Options > Mods > Browse > KIF Mods (cody-png) > KIF: Elite Redux. It starts working the next time the game starts. If Mods is greyed out, set Options > KIF Settings > Modules > Mod Settings to On first.

## Settings

Options > KIF Settings > Mods > KIF: Elite Redux settings. The settings apply to every save file and can be changed at any time. Each one works on its own, except Damage log, which needs Innates On: for example, Moves and Pokemon data still work with Innates Off.

- **Innates** (Off / On, default **On**):
  - On: innates, Elite Redux choice abilities, the Abilities tab and the fusion pickers.
  - Off: every Pokémon has its PIF ability and no innates. The Summary has no Abilities tab.
- **Ability versions** (Elite Redux / PIF, default **Elite Redux**):
  - Elite Redux: 111 of the abilities both games have work as in Elite Redux. The other shared abilities are the same in both games.
  - PIF: those 111 work as in PIF.
  - Their short descriptions follow the setting. The Abilities tab always shows Elite Redux's full text, so with PIF it describes the Elite Redux version of these abilities.
- **Damage log** (Off / On, default **Off**): for testing, and only with Innates On. See Damage log.
- **New battle effects** (Off / On, default **On**):
  - On: fog, frostbite, bleeding, fear, drench, Toxic Terrain, enrage, Inverse Room, Elite Redux infatuation and spores.
  - Off: nothing causes them. The abilities and moves that would cause them do their other parts only. Infatuation works as in PIF, and freezing works as KIF's own Frostbite setting says (Options > KIF Settings > Battles > Frostbite).
- **Moves** (Off / On, default **On**):
  - On: Elite Redux move numbers and effects, the Elite Redux moves PIF doesn't have, Elite Redux learnsets, Elite Redux tutor moves in Tutor.net, and field tools with HMs.
  - Off: every PIF move is PIF's again, with PIF's learnsets.
- **Types from abilities** (Elite Redux / PokeRogue Redux, default **Elite Redux**):
  - Elite Redux: abilities like Aquatic add their type when the Pokémon comes into battle.
  - PokeRogue Redux: the Pokémon always has those types, also on the Summary.
- **Pokemon data** (Off / On, default **On**):
  - On: Elite Redux base stats and types for every Pokémon, and so for their fusions.
  - Off: PIF's stats and types.
- **Item changes** (Off / On, default **On**):
  - On: Elite Redux's changes to items PIF has.
  - Off: every item works and costs as in PIF.

## Innates

- Every Pokémon has 3 innates: abilities that are always on, next to its normal ability.
  - Example: Bulbasaur always has Overgrow, Thick Fat and Poison Absorb, whichever ability it has.
  - Example: Gyarados always has Intimidate, Draconize and Overwhelm.
- An innate works like a normal ability. When it does something, the pop-up shows the innate's own name.
- Whatever stops an ability stops innates too: Gastro Acid and Neutralizing Gas turn them off, and a Mold Breaker attacker's moves ignore them.
- Innates also count outside battle wherever an ability matters there:
  - Pickup, Honey Gather, Flame Body and Magma Armor for hatching eggs, Synchronize, Cute Charm.
  - Wild encounter rates (Stench, Sand Veil, Snow Cloak, Quick Feet...), Static and Magnet Pull, Intimidate and Keen Eye against weak wild Pokémon, Sticky Hold and Suction Cups when fishing.
  - The normal ability counts first. If it does nothing there, the first innate that does counts.
- Eggs and triple fusions have no innates.

## Choice abilities

- Each species has 3 Elite Redux abilities to choose from.
  - Example: Bulbasaur can have Chloroplast, Pastel Veil or Chlorophyll.
  - Example: Mudkip can have Swift Swim, Multiscale or Regenerator.
- A new Pokémon starts with the choice that matches the ability slot PIF gave it: first slot = choice 1, second slot = choice 2, hidden ability = choice 3. A fusion: first slot = the body's choice 1, second slot = the head's choice 1, hidden ability = the body's choice 3.
- Evolving:
  - If you never picked a choice, the Pokémon keeps the choice's place (choice 1, 2 or 3), even when the evolution has another ability there. Example: Mudkip's choice 2 is Multiscale, Marshtomp's is Field Explorer.
  - An ability you picked yourself stays if the evolution can have it. If it can't, the Pokémon goes back to the choice that matches its PIF ability slot. Pick again on the Abilities tab.
- Change it on the Abilities tab (see below), for free, whenever you're not in a battle.
- **Ability Capsule and Secret Capsule:** pick one of the Pokémon's other Elite Redux choices from a list (a fusion: the other 5 of its 6, marked head or body; a dual-ability fusion: the 4 that are neither of its abilities). They never give a plain PIF ability.
- Trainers' Pokémon whose team data sets an ability use that ability. Wild Pokémon and Pokémon you catch always have one of their Elite Redux choices.
- If an event gave one of your Pokémon a set ability, its row on the Abilities tab says just "Ability". Picking a choice there replaces it.
- With Innates Off, the capsules work as in KIF.

## The Abilities tab

- With Innates On, the Summary gets a new tab, **Abilities**, between Skills and Moves (6 tabs in all).
- It shows the ability ("Ability 1 of 3") and the 3 innates ("Innate 1 of 3").
- Press the Use key (C) on the tab to open the details:
  - The highlighted row's full Elite Redux description shows on the left.
  - Up and Down move between rows. Left and Right turn the page of a long description.
  - The Back key (X) closes the details.
- **Change the ability:** highlight the ability row in the details and press Use.
  - A list shows every choice. "(now)" marks the current one. A fusion's list marks each choice "(head)" or "(body)".
  - Pick one, or Cancel to keep it.
- **Change a fusion's innates:** highlight any innate row and press Use. The innate picker opens:
  - On the right: the head's 3 innates and the body's 3, each with a tick box. On the left: the highlighted innate's full description.
  - Press Use to tick or untick. The counter at the top shows how many are ticked, for example 2/3.
  - Done saves only with exactly 3 ticked. It is green with 3, grey with fewer and red with more. Pressing it otherwise shows "Pick 3 innates."
  - Back leaves the picker without changing anything.
- A Pokémon that isn't a fusion always has its species' 3 innates, so its innate rows can be read but not changed.
- Changes work only on your own Pokémon, and not during a battle.
- Eggs have no Abilities tab.

## Fusions

- **Innates:** a fusion has 6 innates to choose from, its head's 3 and its body's 3, and uses 3 of them.
  - The first time they are needed, 3 of the 6 are picked at random and kept on the Pokémon. This goes for your fusions, trainers' fusions and wild fusions.
  - A trainer's fusion gets the same 3 innates each time you fight that trainer again.
  - Change your fusion's picks on the Abilities tab.
  - The picks stay through evolution and DNA Reversers while all 3 are still among the fusion's 6. If one isn't (for example an evolution changed that half's innates), 3 are picked at random again.
- **Ability:** a fusion chooses its ability from 6, its head's 3 choices and its body's 3.
  - With Innates On, PIF's fusion screen has no Ability row. Right after the fusion the game asks "Pick (name)'s ability." with all 6, marked "(head)" or "(body)".
  - The list marks the current choice "(now)". Press Back to keep it.
  - The choice is saved as the ability itself, so a DNA Reverser keeps it.
- Triple fusions have no innates and no Elite Redux choices; they keep PIF's abilities.

## Ability versions

- For abilities both games have, the Ability versions setting picks whose rules are used. With Elite Redux (default), 111 abilities change. The ability's short description follows the setting; the Abilities tab always shows Elite Redux's full text.
- Some examples:
  - Drizzle, Drought, Sand Stream, Snow Warning: the weather lasts 8 turns, 12 with its rock (PIF: until another weather replaces it).
  - Swift Swim, Chlorophyll, Sand Rush, Slush Rush: Speed x1.5 in their weather (PIF: x2).
  - Overgrow, Blaze, Torrent, Swarm: x1.2 at any HP, x1.5 at 1/3 HP or less (PIF: only x1.5 at 1/3 HP or less).
  - Filter, Solid Rock, Prism Armor: super effective hits do x0.65 (PIF: x0.75).
  - Iron Fist, Strong Jaw, Mega Launcher and Tough Claws: x1.3 (PIF: Iron Fist x1.2, Strong Jaw and Mega Launcher x1.5, Tough Claws x1.33).
  - Battle Armor and Shell Armor: also take x0.8 damage from attacks.
  - Levitate: also Flying moves x1.25.
  - Big Pecks: contact moves x1.3 (PIF: no Defense drops).
  - Pickup, in battle: clears entry hazards on its side when it comes in.
  - Justified: immune to Dark moves; a Dark move aimed at it raises its higher attacking stat.
- They work the same as normal abilities and as innates.

## New battle effects

All of these need the New battle effects setting On.

- **Fog** (a weather):
  - Lasts 8 turns, 12 if the Pokémon that started it holds a Smoke Ball.
  - At the end of each turn, every raised stat of a Pokémon that isn't Ghost or Psychic type drops by 1.
  - Ghost and Psychic types take 20% less damage from moves.
  - Weather Ball becomes a Ghost move, Ominous Wind does double damage, every Curse is the Ghost-type Curse, Harvest doesn't work.
  - Synthesis, Moonlight and Morning Sun heal 1/4 of max HP.
  - Started by the ability Low Visibility (for example Drifloon and Duskull) and, with Moves On, by the move Eerie Fog.
- **Frostbite** (a status, like burn):
  - Loses 1/8 of its max HP at the end of each turn.
  - Its special moves do half damage. Facade's power doubles.
  - It replaces freezing: anything that would freeze a Pokémon frostbites it instead.
  - Frost Breath has a 30% chance to frostbite.
  - Ice Punch, Ice Beam, Powder Snow, Blizzard, Freezing Glare and Frost Breath (and, with Moves On, Frost Brand and Chilling Water) are 3 times as likely to frostbite in hail.
  - Ice types can't get it. Sun doesn't stop it.
  - Cured by Ice Heal, Aspear Berry, Lum Berry, Full Heal, moves that thaw (Flame Wheel, Scald...), Refresh, Heal Bell, Aromatherapy, Natural Cure, Shed Skin, Hydration, Healer, or a Pokémon Center.
  - Caused by abilities such as Freezing Point (for example Sneasel and Snorunt).
  - KIF's own Frostbite setting (Options > KIF Settings > Battles > Frostbite) is hidden while New battle effects is On, and frostbite is always used. Your own choice there comes back when New battle effects is Off.
- **Bleeding** (a status):
  - Loses 1/16 of its max HP at the end of each turn.
  - It can't heal: no HP from moves, items, abilities, drain moves or Leftovers. Using a healing move cures the bleeding instead, and the move doesn't heal that turn.
  - Its stat stages count as 0, raised and lowered.
  - Rock and Ghost types can't bleed.
  - Cured by Lum Berry, Full Heal, healing moves (as above), Heal Bell, Aromatherapy, Natural Cure, Shed Skin, Hydration, Healer, or a Pokémon Center.
  - Caused by abilities such as Deep Cuts, Razor Sharp and Mineralize, and, with Moves On, by the added-effect chance of Night Slash, X-Scissor, Leaf Blade, Shadow Claw, Stone Edge, Psycho Cut, Dragon Claw, Crabhammer, Drill Peck, Drill Run and Horn Attack, and by Elite Redux moves such as Aqua Cutter, Blood Shot, Caltrops and Rip and Tear. Slash, Cut and Razor Leaf don't cause it.
- Frostbite and bleeding have their own icons in battle, on the party screen and on the Summary.
- **Fear:**
  - Lasts 2 turns: the turn it starts and the next.
  - The Pokémon can't switch out or flee. Ghost types and Shed Shell still get out.
  - Attacks do x1.5 damage to it.
  - It ends when the Pokémon leaves the field, also when it is forced out by Roar or Whirlwind.
  - Caused by Fearmonger (Rayquaza, Giratina: 10% on its contact moves), Grass Flute (Nuzleaf: every hit of its sound moves) and Spectralize (10% on a Ghost-type user's Ghost moves).
- **Drench:**
  - For 3 turns the Pokémon moves last among moves of the same priority. Quick Claw, Custap Berry and Quick Draw don't work for it then.
  - Caused by Hydrate when a Water-type Pokémon hits with a Water move (10%, for example Cloyster or Poliwag) and, with Moves On, by Hydro Pump (30%) and Water Gun (10%).
  - Amphibious and Shield Dust block it. It ends on switching out.
- **Toxic Terrain:**
  - Lasts 8 turns, 12 with a Terrain Extender.
  - At the end of each turn, grounded Pokémon that aren't Poison or Steel type lose 1/16 of their max HP. Magic Guard, Stench and Poison Heal block it.
  - Grounded Pokémon's Poison moves do 30% more damage.
  - Spikes turn into Toxic Spikes.
  - Started by Toxic Surge (for example Tentacool, Swalot and Vileplume).
- **Enrage:**
  - After an enraged Pokémon's move deals damage, it loses 1/3 of the damage it dealt. Magic Guard and Rock Head block this.
  - Lasts until it switches out.
  - Swagger and Flatter enrage instead of confusing.
  - Berserk DNA (Mewtwo) enrages the Pokémon itself when it comes in, after raising its higher attacking stat by 2.
  - Deviate gives a Dark-type user's Dark moves a 10% chance to enrage the target.
- **Inverse Room:**
  - The type chart is reversed: super effective becomes not very effective, and not very effective or no effect becomes super effective.
  - 3 turns from the ability Inversion (for example Natu, Xatu and Exeggutor).
  - 5 turns from the move Inverse Room (with Moves On). Using that move while Inverse Room is up ends it.
- **Elite Redux infatuation:** every infatuation (Attract, Cute Charm, Destiny Knot...) no longer stops the Pokémon from moving. Its attacks on the Pokémon it is in love with use half its Attack or Sp. Atk instead. It ends on switching out.
- **Spores:**
  - A Pokémon with Parasitic Spores (Parasect) covers itself in spores when it comes in.
  - A Pokémon with spores loses 1/8 of its max HP at the end of each turn (not with Magic Guard) and passes them on to the targets of its contact moves.
  - Ghost types can't get them and take no damage from them. They end on switching out.
  - Parasect's Phantom innate makes it Ghost type right after, so it takes no damage from its own spores. With Types from abilities on PokeRogue Redux it is Ghost type from the start, so it gets no spores and can't pass them on.

## Moves

Everything here needs the Moves setting On.

- **Elite Redux numbers:** 590 of PIF's moves use Elite Redux's power, type, category, accuracy, PP, added-effect chance, target, priority and description. The other PIF moves keep all of PIF's values.
  - Examples: Dragon Claw 90 power (PIF 80), Rock Slide 100% accuracy (90%), Stone Edge 90% accuracy and 10 PP (80%, 5 PP), Thunder 85% accuracy (70%), Hurricane 80% accuracy (70%), Mega Drain 50 power (40).
- **Elite Redux effects for PIF moves**, for example:
  - Sunny Day, Rain Dance, Sandstorm and Hail last 8 turns, 12 with the matching rock. Electric, Grassy, Misty and Psychic Terrain last 8 turns, 12 with a Terrain Extender.
  - Astonish works like Fake Out: first turn only, always flinches.
  - Cross Poison hits twice. Rapid Spin also raises the user's Speed.
  - Focus Punch doesn't fail when the user is hit; it does 40 power instead.
  - Acrobatics does x1.5 without a held item (PIF: x2).
  - Growl deals damage (60 power, special) as well as lowering Attack.
  - Detect blocks only moves that can miss.
  - Magic Room: for 5 turns nobody takes indirect damage (poison, burn, weather, hazards, recoil...) and, with the Megas mod, nobody can Mega Evolve.
  - Wonder Room: for 5 turns every Pokémon's Attack and Sp. Atk are swapped.
  - Needle Arm no longer flinches. It lays Creeping Thorns on the target's side: a Pokémon coming in there loses 1/8 of its max HP, times how well Grass hits it. Magic Guard and Magic Room block them, and Rapid Spin and Defog clear them.
  - Thunder Wave, Will-O-Wisp and Leech Seed never miss when the user is Electric, Fire or Grass type.
  - Refresh also cures frostbite and heals 25%.
- **New moves:** 279 Elite Redux moves PIF doesn't have, including every one that a Pokémon in this game learns. Examples: Aqua Fang, Aqua Cutter, Flip Turn, Life Dew, Scale Shot, Salt Cure, Rage Fist, Make It Rain, Inverse Room.
  - Their animation is a similar PIF move's.
  - The Move Relearner also offers Elite Redux moves a Pokémon knew before.
- **Learnsets:** Pokémon learn Elite Redux's level-up moves. Elite Redux's lists also decide which TMs and tutors can teach a Pokémon. PIF's egg moves stay.
  - Elite Redux's level-up moves sit on fixed levels: 1, 17, 24, 37, 46, 51, 56, 61, 71, 81 and 100. Several moves can come at the same level.
  - Example: Mudkip starts with Tackle, Growl, Mud Sport and Bubble Beam, and learns Body Slam, Mud Shot, Water Pledge and Yawn at level 17.
- **Tutor.net:** open Tutor.net from the pause menu (KIF setting Options > KIF Settings > Game > Tutor.net On). It also lists every move on your party's Elite Redux tutor lists that it doesn't list yet, at 10,000 each.
  - Once bought, a move stays free in Tutor.net for good.
  - Moves you don't buy are not kept in the list after you close it, so it only shows the ones your current party can learn.
  - Example: in a new save, a Mudkip in the party adds 33 moves, among them Earthquake, Ice Beam, Flip Turn and Life Dew.
- **Change moves** (party menu) shows KIF's own list: moves the Pokémon learned before and level-up moves up to its level, plus egg and event moves if KIF's settings allow them. Elite Redux tutor moves are not in Change moves. Tutor.net teaches them, and so does a TM or move tutor for that move.
- **HMs give field tools:** Elite Redux's lists leave many HMs out, so getting the machine for one of these moves also gives you its tool:
  - Cut: Shears. Surf: Surfboard. Strength: Dolly. Waterfall: Jetpack. Dive: Scuba Gear. Rock Climb: Climbing Gear. Rock Smash: Pickaxe. Fly and Teleport: Teleporter. Flash: Lantern.
  - The message reads "You also got the Shears!". Nothing is given if you already have the tool.
  - A save that already has those machines gets the tools when it loads.
  - With the tool in your Bag you can use that field move without a Pokémon that knows it or the badge. Use the Teleporter and the Lantern from the Bag.
- **Saves:** a Pokémon that knows an Elite Redux-only move is saved with a similar PIF move as well, so the save still loads without the mod. With Moves Off, or without the mod, it shows that PIF move.

## Types from abilities

- These abilities give their Pokémon a type: Aquatic and Waterborne (Water), Grounded (Ground), Half Drake and Dragonfly (Dragon), Metallic and Metallic Jaws (Steel), Phantom (Ghost), Witch Broom (Psychic). With Ability versions on Elite Redux, also Turboblaze (Fire) and Teravolt (Electric).
- **Elite Redux** (default): the type is added when the Pokémon comes into battle. It has room for one added type: if two of its abilities add one, the last one replaces the first.
- **PokeRogue Redux:** the Pokémon always has those types, as many as its ability and innates give (a third, fourth... type).
  - In battle from the start, and on the Summary's Type row.
  - Example: Flygon (Ground/Bug with Pokemon data On) has the Dragonfly innate, so it is Ground/Bug/Dragon.
- Moves that set a Pokémon's types (Soak, Reflect Type...) replace these types too.

## Pokémon data

- With Pokemon data On (default), every Pokémon uses Elite Redux's base stats and types. 328 species change stats and 48 change types. Fusions follow, since they are built from their head and body.
- Examples:
  - Flygon: Ground/Bug (PIF: Ground/Dragon), Sp. Atk 100 (PIF: 80).
  - Butterfree: Bug/Psychic (PIF: Bug/Flying), 475 base stat total (PIF: 395).
  - Absol: Dark/Fairy (PIF: Dark), 500 base stat total (PIF: 465).
- Your party and boxes get their stats recalculated when the setting changes.

## Item changes

With Item changes On (default):

- Type-boosting held items (Charcoal, Mystic Water, Miracle Seed...) and the Sea, Wave, Odd, Rock and Rose Incense: x1.3 (PIF: x1.2). Plates stay at x1.2.
- Muscle Band and Wise Glasses: x1.15 (PIF: x1.1).
- Figy, Wiki, Mago, Aguav and Iapapa Berries: eaten at 1/4 HP (1/2 with Gluttony), heal 1/2 of max HP (PIF: eaten at 1/2 HP, heal 1/8).
- Sun, rain, sandstorm and hail started by a move: 8 turns, 12 with the matching rock (PIF: 5, or 8). Weather from abilities follows Ability versions instead.
- Super Potion and Energy Powder heal 60 HP (PIF: 50).
- Light Ball works for Raichu too.
- Shell Bell heals 1/4 of the damage dealt (PIF: 1/8).
- Elite Redux's prices for 96 items. Examples: Ability Capsule 4,000 (PIF: 9,500), Fire Stone 3,000 (5,000), Protein 5,000 (10,000), Focus Sash 5,000 (4,000). The Fire, Water, Thunder, Leaf, Moon, Sun, Shiny, Dusk, Dawn and Ice Stones cost 3,000, and every vitamin (HP Up, Protein, Iron, Calcium, Zinc, Carbos) costs 5,000. Rare Candy keeps its price.

## Battle Info

- In battle, KIF's Battle Info screen (the INFO button, or the Action key) has an Abilities page. With Innates On it lists each Pokémon's innates under its ability, marked "INNATE". A dual-ability fusion's second ability is marked "ABILITY 2".
- Pick a row with Use to read its full description.
- Your own Pokémon's innates always show.
- A foe's innates follow KIF's Foe Info setting (Options > KIF Settings > Battles > Foe Info):
  - **All** (default): shown from the start of the battle.
  - **As seen:** "???" until the innate's pop-up shows, then its name, marked "WORKED THIS BATTLE".
- "WORKED THIS BATTLE" marks an innate that did something in this battle.
- KIF's move effectiveness marks in the Fight menu count a foe's innates too (for example a Levitate or Volt Absorb innate): from the start with Foe Info All, after the innate's pop-up with As seen.

## Damage log

- For testing. With the Damage log setting On (and Innates On), every hit where the attacker, the target or an ally has innates writes one line to KIF_log.txt.
- Each line shows the damage with no innates, with innates, the damage dealt, and each innate that changed it. For example:
  - "Damage: The opposing Charmander's Ember on Bulbasaur - no innates 27, with innates 16, dealt 16 | Bulbasaur's Thick Fat: 27 -> 16"
- Copies of one innate are named once, for example "Fluffy x2".
- Moves with set damage (Dragon Rage, Seismic Toss...) get a "set damage" line, since innates can't change them.
- The log never changes the battle.

## The battle AI

- Trainers use DemICE's AI or PIF's own (Options > KIF Settings > Battles > Battle AI). Both know about innates, the new abilities and the new effects, in single and double battles.
- **Innates:** the AI sees innates the way it sees abilities. Examples:
  - It doesn't aim a move at a Pokémon whose innate makes it immune, for example no Toxic into Poison Absorb, no Fire move into Heat Sink.
  - Its damage guesses count damage, stat and extra-hit abilities from innates (Hyper Aggressive, Multi-Headed...).
  - DemICE's AI also counts priority abilities such as Opportunist, and teammates that like a weather or terrain, from innates.
- **New effects:** for example, an afraid Pokémon doesn't try to switch, it doesn't use Potions on a bleeding Pokémon, it values frostbite like burn against special attackers, and it reverses type matchups under Inverse Room.
- **Elite Redux versions and moves:** it uses the Elite Redux numbers and rules while those settings are On.
- The AI's guesses never trigger anything in the battle, and never count as "worked" on Battle Info.

## Duplicate abilities stack

Copies of the same ability stack. This is on purpose.

- Copies come from:
  - an innate that is the same as the Pokémon's ability;
  - a fusion picking an innate both halves have, for example a self-fusion like Charizard x Charizard, which has Blaze, Draconize and Egoist twice among its 6;
  - a dual-ability fusion with the same ability from each half.
- A self-fusion's random pick takes one innate twice 6 times in 10. You can also tick both copies yourself in the innate picker.
- Effects with a number stack once per copy:
  - Two Thick Fats take 1/4 damage from Fire and Ice moves, three take 1/8.
  - Two Blazes give x1.44 (1.2 x 1.2) at any HP, with Ability versions on Elite Redux.
  - Two Intimidates lower the foe's Attack by 2, with two pop-ups.
  - Two Speed Boosts raise Speed by 2 each turn.
- Yes-or-no effects count once: Adaptability, Levitate's immunity, Clear Body, Poison Heal.

## Dual-ability fusions

- With a mod or item that gives fusions a second ability (Kanto Reloaded's Double Abilities, Ghost's Master, Unstable, Ultra or Chaos Splicers, or PIF's own double abilities), a fusion gets:
  - 2 choice abilities, both chosen from its 6 (head's 3 and body's 3);
  - all 6 innates, with no picking.
- Right after the fusion the game asks for Ability 1, then Ability 2. Ability 2 starts as the other half's first choice.
- The Abilities tab shows Ability 1, Ability 2, a line, then Innate 1 to 6. Change either ability there; picking the other slot's ability swaps the two.
- The two abilities are never the same slot, but can be the same ability from each half (they stack).
- In battle the second ability works next to the innates, and other mods that show a second ability show this one.

## KIF's randomizer

- While Innates is On, the randomizer's Pokémon data page has an extra row under Abilities: **ER abilities** (Choice / Innates / Both).
  - Choice: randomizes each Pokémon's 3 choice abilities. Innates: its 3 innates. Both: all 6.
- It works when the randomizer's Abilities is Random, Flavour or Bound, with the randomizer's seed, ability pool and bans. An evolution family with the same types gets the same rolls.
- The rolls are saved with the randomizer's other changes and listed in its log.
- PIF's own ability slots never get an Elite Redux-only ability, so a randomized save still works without the mod.

## Works with other mods

- **Megas:**
  - With Innates and Pokemon data On (both default), a Mega uses its Elite Redux ability choices, innates, stats and types (for example, Mega Blastoise is Water/Steel). The Megas page explains other mixes of these settings.
  - Megas' Elite Redux-only Megas (for example Mega Charizard Z) and their stones need Innates On.
  - A fusion with one Mega half: the innates it picked from that half become the Mega's innates in the same places; picks from the other half stay. That half's choices are the Mega's.
  - With Moves On, Rayquaza learns Dragon Ascent at level 56, which Mega Rayquaza needs.
  - With Moves On, Magic Room stops Mega Evolution while it is up.
- **Differentiating Duplicates:**
  - Both mods change some of the same abilities and moves. Differentiating Duplicates' setting **KIF:ER conflicts** (Options > KIF Settings > Mods > Differentiating Duplicates settings) decides whose version runs: **KIF:ER wins** (default) or **This mod wins**.
  - Abilities: Vital Spirit, Solid Rock, Turboblaze, Teravolt, Keen Eye, Illuminate, White Smoke, Air Lock, Battle Armor and Minus, while this mod's Ability versions is Elite Redux. With Ability versions PIF, Differentiating Duplicates' versions are used.
  - Moves: all 14 moves Differentiating Duplicates changes (Detect, Acid Armor, Barrier, Meditate, Sharpen, Soft-Boiled, Milk Drink, Slack Off, Heal Order, Morning Sun, Moonlight, Spider Web, Block, Withdraw), while this mod's Moves is On. Elite Redux gives Acid Armor, Morning Sun, Moonlight, Spider Web and Block PIF's numbers and effects, so with KIF:ER wins those 5 play as in PIF. With This mod wins, all 14 use PIF's numbers plus Differentiating Duplicates' change.
  - With This mod wins, Turboblaze and Teravolt don't add the Fire or Electric type.
  - Ability and move descriptions show the version that is used.

## Limits

- Some abilities keep PIF's rules even with Ability versions on Elite Redux: Forecast, Disguise and Shields Down. Immunity blocks only poison (and halves Poison damage).
- Revelation (Unown) changes Unown's stats only, not its sprite.
- 76 Elite Redux moves are not in the game. No Pokémon in this game learns any of them.
- After a save loads, a move with more PP in Elite Redux than in PIF (for example Stone Edge, 10 instead of 5) has at most PIF's PP left until the Pokémon is healed.
- Elite Redux's new items, its trainers' teams and its new species are not in the game.
- Fear, drench, enrage and spores have no icon; battle messages show them.
- Settings and picks from the old Innates mod are not carried over.
- **Without the mod** (removed or turned off), saves still load:
  - Frostbitten or bleeding Pokémon are healthy again.
  - Elite Redux-only moves show as the similar PIF move saved with them.
  - Your ability and innate picks stay in the save for when the mod is back.

## Credits

- Innate, ability, move and Pokémon data from Pokémon Elite Redux (Elite Redux team).
