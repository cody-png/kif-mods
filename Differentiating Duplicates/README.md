# Differentiating Duplicates

Small battle changes for KIF (Kuray's Infinite Fusion) that give moves and abilities which did exactly the same thing a difference of their own. This page describes Differentiating Duplicates 0.6.3.

## What it adds

- 14 changed moves: Detect, Acid Armor, Barrier, Meditate, Sharpen, Withdraw, Soft-Boiled, Milk Drink, Slack Off, Heal Order, Morning Sun, Moonlight, Spider Web and Block.
- 15 changed abilities: Vital Spirit, Insomnia, Solid Rock, Turboblaze, Teravolt, Keen Eye, Illuminate, Pure Power, White Smoke, Air Lock, Battle Armor, Iron Barbs, Tangling Hair, Minus and Queenly Majesty.
- The move or ability each one used to copy stays as it was: Protect, Iron Defense, Harden, Recover, Synthesis, Mean Look, Filter, Mold Breaker, Huge Power, Clear Body, Cloud Nine, Shell Armor, Rough Skin, Gooey, Plus and Dazzling.
- New descriptions for every changed move and ability, and new battle messages.
- The battle AI knows about several of the changes; see How the AI uses them.
- Many of the ideas come from x_bell's video "Differentiating Duplicate Pokemon Mechanics".

## Installing

Options > Mods > Browse > KIF Mods (cody-png) > Differentiating Duplicates. It starts working the next time the game starts. If Mods is greyed out, set Options > KIF Settings > Modules > Mod Settings to On first.

## Settings

Options > KIF Settings > Mods > Differentiating Duplicates settings. A change takes effect at once and applies to every save file.

- **Changed moves:** Off or On (default On).
  - On: the 14 moves work as described on this page.
  - Off: they work as they would without this mod (the base game's version, or KIF: Elite Redux's where it changes them), with that version's description.
- **Changed abilities:** Off or On (default On).
  - On: the 15 abilities work as described on this page.
  - Off: they work as they would without this mod (the base game's version, or KIF: Elite Redux's where it changes them), with that version's description.
- **KIF:ER conflicts:** KIF:ER wins (default) or This mod wins. Only listed while KIF: Elite Redux is installed and On (from the next game start).
  - It decides whose version is used when KIF: Elite Redux also changes a move or ability.
  - KIF:ER wins: KIF: Elite Redux's version is used.
  - This mod wins: this mod's version is used.
  - See "With KIF: Elite Redux" below for which moves and abilities this covers.

## Changed moves

### Detect

- Before: the same as Protect.
- Now: attacks, and status moves like Thunder Wave, miss the user instead of being blocked. The message reads "Hitmonlee avoided the attack!".
- Moves that can't miss still hit it:
  - moves that never miss, such as Swift and Aerial Ace;
  - Thunder and Hurricane in rain, and Blizzard in hail;
  - status moves that never miss, such as Mean Look and Block;
  - any move used by a Pokémon with No Guard, or aimed at a Detect user that has No Guard;
  - moves used after Lock-On or Mind Reader on it;
  - Toxic used by a Poison type.
- Stomp and similar moves don't count, even though they normally can't miss a Minimized Pokémon: Detect dodges them.
- Feint misses too, so it can't break Detect.
- Using Detect several turns in a row can fail, as with Protect.

### Acid Armor

- Before: the same as Iron Defense (+2 Defense).
- Now: still +2 Defense, and "Grimer is coated in acid!".
- For the rest of that round, a Pokémon that hits it with a contact move has a 30% chance to be poisoned: "Rattata was poisoned by the acid!".
- Only hits that come after Acid Armor in the same round count. Hits that do no damage or hit a substitute don't, and a Pokémon that can't be poisoned isn't.
- If its Defense is already at +6, Acid Armor fails as before and there is no acid.

### Barrier

- Before: the same as Iron Defense (+2 Defense to the user).
- Now: +2 Defense to the user or its partner. In a double battle you pick which. In a single battle it raises the user's Defense as before.
- It fails if the target's Defense is already at +6.

### Meditate

- Before: the same as Sharpen (+1 Attack).
- Now: +1 Attack and +1 Sp. Def.
- It fails only when both are already at +6: "Meditite's stats won't go any higher!".

### Sharpen

- Before: the same as Meditate (+1 Attack).
- Now: +1 Attack, and one more critical-hit stage: "Porygon sharpened its aim!".
- Up to 3 critical-hit stages. The chance per hit:
  - no stages: 1 in 24;
  - 1 stage: 1 in 8;
  - 2 stages: 1 in 2;
  - 3 stages: every hit.
- Scope Lens and moves like Slash add to the stages, up to 3 in all.
- Focus Energy, Dire Hit and the Lansat Berry set the stages to 2 instead of adding to them. So use Focus Energy first: Focus Energy followed by one Sharpen makes every hit a critical hit.
- Sharpen followed by Focus Energy gives only 2 stages, and after two Sharpens Focus Energy fails.
- It fails only when Attack is at +6 and it already has 3 stages.

### Withdraw

- Before: the same as Harden (+1 Defense).
- Now: still +1 Defense, and "Squirtle is safe inside its shell!": for the rest of that round it can't take a critical hit, not even from moves that always land one.
- Only attacks that come after Withdraw in the same round count.
- If its Defense is already at +6, Withdraw fails as before and gives no protection.

### Soft-Boiled and Milk Drink

- Before: the same as Recover (the user heals half its max HP).
- Now: they heal half the max HP of the user or its partner. In a double battle you pick which. In a single battle they heal the user as before.
- On the partner, they fail if its HP is full or it is under Heal Block.
- Using them from the party menu outside battle is not changed.

### Slack Off

- Before: the same as Recover.
- Now: it still heals half the user's max HP, and it also cures drowsiness from Yawn: "Slowbro shook off its drowsiness!".
- While drowsy, it works even at full HP, just to cure the drowsiness.

### Heal Order

- Before: the same as Recover.
- Now: it still heals half the user's max HP, and also heals its partner by a quarter of the partner's max HP.
- A partner at full HP or under Heal Block isn't healed.
- As before, it fails if the user is at full HP. The partner isn't healed then either.

### Morning Sun and Moonlight

- Before: the same as Synthesis: half the max HP with no weather, 2/3 in sun, 1/4 in other weather.
- Now, with no weather:
  - Morning Sun heals 2/3 during the day (5:00 to 19:59 on the game's clock);
  - Moonlight heals 2/3 at night (20:00 to 4:59).
- On maps darkened by the Darkrai quest it always counts as night.
- At other times, and in any weather, they heal as before.
- Synthesis is unchanged.

### Spider Web

- Before: the same as Mean Look.
- Now: the trap stays after the Spider Web user switches out or faints. It ends when the trapped Pokémon leaves the field.
- Mean Look and Block traps still end when their user leaves.
- As before, Ghost types can't be trapped.

### Block

- Before: the same as Mean Look.
- Now: the target also can't get out with U-turn, Volt Switch, Baton Pass or Parting Shot (with KIF: Elite Redux, also its Flip Turn, Fluttering Leaf and Take Flight). The message reads "Pikachu is blocked and can't switch out!".
  - U-turn and Volt Switch still do their damage, and Parting Shot still lowers stats, but the Pokémon stays in.
  - Baton Pass has no effect.
- It ends when the Block user leaves the field, as with Mean Look.
- Only Block does this. Traps from Mean Look, Spider Web, Anchor Shot or Spirit Shackle don't stop these moves.
- As before, Ghost types can't be trapped.

## Changed abilities

### Vital Spirit and Insomnia

- Before: both only stop the Pokémon from falling asleep.
- Now: it still can't fall asleep. When another Pokémon uses a sleep move on it, the move does nothing and:
  - Vital Spirit raises its Speed by 1;
  - Insomnia raises its Sp. Atk by 1.
- The sleep moves are Spore, Sleep Powder, Hypnosis, Sing, Lovely Kiss, Grass Whistle, Dark Void and Yawn.
- If that stat is already at +6, the move just doesn't affect it.
- A partner's sleep move counts too. In a double battle you can aim Spore at your own Vital Spirit Pokémon for +1 Speed.

### Solid Rock

- Before: the same as Filter: super-effective hits do 25% less damage.
- Now: 4x hits do half damage, so they hit like 2x. 2x hits still do 25% less.
- Example: Surf on a Ground/Rock Rhyperior with Solid Rock now does 2x damage, where before it did 3x.
- Filter is unchanged.

### Turboblaze and Teravolt

- Before: the same as Mold Breaker.
- Now: they still ignore the target's abilities, and the Pokémon's own moves of one type do 10% more damage:
  - Turboblaze: Fire moves;
  - Teravolt: Electric moves.
- The message when it comes in is the same as before.

### Keen Eye

- Before: it only stops the Pokémon's accuracy from being lowered.
- Now: that still works, and its Psychic moves can hit Dark types for not very effective (half) damage instead of no damage.
- Examples: Psychic on Umbreon does half damage. On a Dark/Fighting Pokémon like Scrafty it does normal damage.

### Illuminate

- Before: no effect in battle.
- Now: while a Pokémon with Illuminate is on the field, on either side, light moves do 20% more damage for every Pokémon, foes included.
- The light moves are Signal Beam, Flash Cannon, Dazzling Gleam, Luster Purge, Mirror Shot, Aurora Beam, Solar Beam, Solar Blade, Photon Geyser, Prismatic Laser, Light of Ruin and Charge Beam.
- Two Illuminates on the field don't add up: it stays 20%.

### Pure Power

- Before: the same as Huge Power (doubles Attack).
- Now: it still doubles Attack, and the Pokémon can't be confused: "Medicham doesn't become confused!".
- Swagger still raises its Attack, but it doesn't get confused. Outrage, Thrash and Petal Dance don't confuse it at the end either.
- If it gets confused anyway, for example by a foe with Mold Breaker, it snaps out of it right away.

### White Smoke

- Before: the same as Clear Body: other Pokémon can't lower its stats.
- Now: that still works, and a foe whose stat drop it stops loses 1 accuracy.
- This counts every stat drop from a foe: moves like Growl, Intimidate, an attack's chance to lower a stat, and abilities that lower stats.
- Each foe loses at most 1 accuracy from each White Smoke Pokémon per round.
- Drops from its own moves, like Overheat, still happen as before.

### Air Lock

- Before: the same as Cloud Nine: no weather effects while it is on the field.
- Now: that still works, and when it comes in it also ends Tailwind on both sides: "The tailwind stopped blowing!".
- A Tailwind set after it is already on the field works as normal.
- Cloud Nine is unchanged.

### Battle Armor

- Before: the same as Shell Armor: no critical hits on it.
- Now: that still works, and it takes no damage from Rough Skin, Iron Barbs or Rocky Helmet when it attacks with contact.
- Shell Armor is unchanged.

### Iron Barbs

- Before: the same as Rough Skin: a contact attacker loses 1/8 of its max HP.
- Now: the damage is Steel-type and depends on how Steel does against the attacker, like Stealth Rock:
  - most attackers: 1/8;
  - one type weak to Steel (Fairy, Ice or Rock), with no second type or a neutral one: 1/4;
  - one type that resists Steel (Fire, Water, Electric or Steel), with no second type or a neutral one: 1/16;
  - one weak type and one resisting type, such as Rock/Steel: 1/8;
  - both types weak to Steel (Rock/Ice): 1/2;
  - both types resisting Steel (for example Water/Steel): 1/32.
- The message reads "Clefairy is hurt by the iron barbs!".
- Rough Skin is unchanged.

### Tangling Hair

- Before: the same as Gooey: a contact attacker loses 1 Speed.
- Now: it still loses 1 Speed, and it gets tangled up: "Rattata got tangled up!".
- During the next round, a tangled Pokémon can't be switched out, by you or by the AI: "Rattata is tangled up and can't be switched out!".
- Ghost types and Pokémon holding a Shed Shell can still switch. U-turn, Volt Switch and Baton Pass still work.
- Gooey is unchanged.

### Minus

- Before: the same as Plus: Sp. Atk x1.5 while its partner has Plus or Minus.
- Now: Speed x1.5 instead, with the same condition. So it only matters in double battles.
- Plus is unchanged.

### Queenly Majesty

- Before: the same as Dazzling: foes can't use priority moves on it or its partner.
- Now: that still works, and a foe whose priority move it stops also loses 1 Attack.
- Dazzling is unchanged.

## How the AI uses them

These work with both choices of KIF's Battle AI option (PIF and DemICE).

- **Detect:** the AI counts Detect as a wasted turn when its foe's strongest attack can't miss, for example against a No Guard Machamp.
- **Soft-Boiled, Milk Drink and Barrier:** the AI can use them on its partner. It counts them as a wasted turn on a partner at full HP or under Heal Block, or, for Barrier, a partner whose Defense is already at +6.
- **Block:**
  - A Pokémon hit by Block doesn't count on U-turn, Volt Switch, Baton Pass or Parting Shot to get out.
  - When the AI thinks about using Block, it knows those moves won't get the target out.
- **Damage estimates** include Solid Rock's halved 4x hits, Keen Eye's Psychic moves on Dark types, Illuminate's 20% and Turboblaze and Teravolt's 10%.
- The other changes get no special scoring. For example, the AI values Meditate and Sharpen as Attack boosts and Withdraw as a Defense boost.

## Descriptions and battle messages

- Each changed move and ability has a new description, shown in the Summary, in Battle Info and on the move screens. For example, Detect reads "Lets the user dodge attacks that turn. Moves that can't miss still hit."
- With a setting Off, its moves or abilities show their old descriptions again.
- With KIF: Elite Redux, each description matches the version that is used (see below).
- New battle messages:
  - "... avoided the attack!" (Detect)
  - "... is coated in acid!" and "... was poisoned by the acid!" (Acid Armor)
  - "... sharpened its aim!" (Sharpen)
  - "... is safe inside its shell!" (Withdraw)
  - "... shook off its drowsiness!" (Slack Off)
  - "... is blocked and can't switch out!" (Block)
  - "... doesn't become confused!" (Pure Power)
  - "The tailwind stopped blowing!" (Air Lock)
  - "... is hurt by the iron barbs!" (Iron Barbs)
  - "... got tangled up!" and "... is tangled up and can't be switched out!" (Tangling Hair)

## Works with other mods

### With KIF: Elite Redux

- KIF: Elite Redux changes many of the same moves and abilities. The KIF:ER conflicts setting decides whose version is used. Its default is KIF:ER wins.
- KIF: Elite Redux's settings are in Options > KIF Settings > Mods > KIF: Elite Redux settings.
- **Moves:**
  - While KIF: Elite Redux's Moves setting is On (its default), it has its own version of all 14 moves on this page.
  - KIF:ER wins: all 14 use KIF: Elite Redux's version, and none of this mod's move changes are used.
    - Acid Armor, Withdraw, Slack Off, Heal Order, Morning Sun, Moonlight, Spider Web and Block: Elite Redux's version is the base game's effect with Elite Redux's type, PP and priority, so they work like their duplicates again. For example, Withdraw is Harden as a Water-type move with +1 priority.
    - Detect, Barrier, Meditate, Sharpen, Soft-Boiled and Milk Drink get Elite Redux's own effects.
  - This mod wins: all 14 use this mod's version, with the base game's power, accuracy, PP, type and priority instead of Elite Redux's.
  - With KIF: Elite Redux's Moves setting Off, this mod's versions are used whatever KIF:ER conflicts says.
- **Abilities:**
  - While KIF: Elite Redux's Ability versions setting is Elite Redux (its default), 10 of the abilities have an Elite Redux version too: Vital Spirit, Solid Rock, Turboblaze, Teravolt, Keen Eye, Illuminate, White Smoke, Air Lock, Battle Armor and Minus.
  - KIF:ER wins: those 10 use KIF: Elite Redux's version. For example, its Solid Rock cuts every super-effective hit by 35%, where this mod's halves 4x hits and cuts 2x hits by 25%.
  - This mod wins: those 10 use this mod's version instead, except that Vital Spirit still can't be taunted, which comes from Elite Redux's version. For example, Turboblaze and Teravolt then don't add a Fire or Electric type, and White Smoke makes no smoke when it comes in.
  - Insomnia, Pure Power, Iron Barbs, Tangling Hair and Queenly Majesty always use this mod's version.
  - With Ability versions set to PIF, all 15 use this mod's version whatever KIF:ER conflicts says.
- **Descriptions** follow the version in use: with KIF:ER wins, the shared moves and abilities show Elite Redux's description where it has one; with This mod wins, they show this mod's.
- To use every change on this page together with KIF: Elite Redux, set KIF:ER conflicts to This mod wins.

### With Megas

- Nothing to set up; the two mods don't change each other.
- A Mega with one of the changed abilities uses the changed version. Without KIF: Elite Redux, Mega Medicham's Pure Power keeps it from being confused, and Mega Mewtwo Y's Insomnia turns sleep moves into +1 Sp. Atk.

## Limits

- Heal Order fails when the user is at full HP, so it can't be used only to heal the partner.
- Soft-Boiled, Milk Drink and Barrier can't be aimed at foes.
- Acid Armor's acid and Withdraw's shell only last for the round they are used in, and only against attacks that come after them.
- Apart from the new descriptions, nothing changes outside battle.
