# Poker Tracker

A live Texas Hold'em odds calculator and session tracker in a single HTML file. Type your cards as the hand plays out and your equity updates on every keystroke. Log each hand when it ends, including folds, blinds and bomb pots, and the page tracks your whole session: buy-ins, profit, $/hour, hands played, and how your results compare to your equity.

No build step, no dependencies. Open `index.html` in a browser.

## Features

- **Live equity.** Monte Carlo simulation, up to 400k runouts, against however many opponents are still in. It shows win/tie/lose, your current made hand, and your chances of finishing with each hand type by the river.
- **Pot odds.** Enter the pot and the amount to call to see the equity you need and whether calling is +EV.
- **Fast keyboard entry.** One text box for the whole hand (see below). A tap-to-pick card grid is available for phones.
- **Table tracking.** Max seats (2–10), how many are seated, and a "someone folded" counter that resets every hand.
- **Blinds.** SB/BB toggles. A blind fold charges the blind automatically, and hands where you only put in the blind don't count as voluntary plays. It moves itself from SB to BB.
- **Bomb pots.** Set the ante and player count once, then toggle bomb pot per hand. It goes straight to the flop, and bomb pots are tracked separately from voluntary play.
- **Money in the hand.** A running total of what you've put in: the blinds and bomb pot ante are counted automatically, you add each bet or call, and folds and losses are charged that total. Also shows your estimated stack right now.
- **Session tracking.** Buy-ins and rebuys, current stack, cash-out, profit, $/hr, hands/hr, bb/100, hands-played %, win rate when you play vs expected win rate (preflop equity), equity of folded hands, and folds that would have won.
- **Visuals.** Running-profit chart, a 13×13 starting-hand grid colored by net result, and a full hand log with per-hand delete.

## Entering hands

Cards are a rank (`2–9 t j q k a`, or `10`) plus a suit (`s h d c`). Spaces don't matter.

| What happened | Type |
|---|---|
| Just see the odds | `ahkd 7c8c9d` |
| Folded preflop, nothing in | `7h2c f` |
| Called $6 preflop, folded to a reraise | `khjd f6` |
| Folded to a bet on the flop after putting in $14 | `khjd 9s5c2d f14` |
| Won, $40 net profit | `ahkd 7c8c9d w40` |
| Lost $60 at showdown | `ahkd 7c8c9d2s3h l60` |
| Split pot, up $10 | `asks 7c8c9d2s3h x10` |
| Folded, then saw the runout | `qsjd f 9c8c2h4d5s` |
| Bomb pot, folded on the flop (charges the ante) | `b qhqd 2c5h9s f` |
| Put in $2 preflop and $4 on the flop, then folded (logs −$6) | `khjd $2 9s5c2d $4 f` |
| Collected a $30 pot after putting in $12 (logs +$18) | `ahkd $2 7c8c9d $10 w@30` |

Press **Enter** to log the hand. The line under the box shows exactly what will be logged before you press it.

**Money in the hand:** type `$` and an amount each time you put chips in (or use **+ Put in** / **+1 BB**). With no amount after `f` or `l`, the hand is charged everything you put in. `w@30` means you collected a $30 pot, so it logs 30 minus what you put in.

**Amounts after the result letter are always net:** for a win, how much you came out ahead (pot minus what you put in); for a loss or fold, everything you put in.

### Keys

| Key | Action |
|---|---|
| `Enter` | Log the hand |
| `Esc` | Clear the hand |
| `-` / `+` | Someone folded / undo |
| `[` / `]` | I'm the small blind / big blind |
| `b` | Bomb pot (typed in the box) |
| `$2` | Add $2 to what you've put in this hand |
| `w@30` | Won, collected a $30 pot |

## Saving data

- **As a Claude artifact:** sessions and hands are saved to the artifact's database and sync across devices.
- **As a standalone file:** everything is saved in your browser's `localStorage`, so it's tied to that browser only. Clearing site data clears it.

## How the odds work

- Hands are scored by a bitmask-based 7-card evaluator.
- Equity is estimated by random runouts with opponents dealt **random hands**. This runs a bit optimistic against players who have raised or called, since their real ranges are stronger than random.
- The evaluator was checked against known matchups (AA vs KK ≈ 82%, AKs vs QQ ≈ 46%) and the standard 7-card hand-category frequencies.

## Files

- `index.html` is the entire app: HTML, CSS and JavaScript in one file.
