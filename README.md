# ♠ Max's Lucky Odds

A live Texas Hold'em odds calculator and session tracker in a single HTML file, in a matte black and gold design. Type your cards as the hand plays out and your equity updates on every keystroke. Log each hand when it ends, including folds, blinds and bomb pots, and the page tracks your whole session: buy-ins, profit, $/hour, hands played, and how your results compare to your equity.

No build step. Open `index.html` in a browser, or use the hosted version at **https://maxherrera06.github.io/poker-tracker/**.

## Accounts

The app opens on a **Log in / Create account** screen. Sign up with your email and a password and your sessions save to your own account, so you can log in from any computer or phone. Nobody else can see your sessions.

- **Export backup** downloads every session and hand as a `.json` file. **Import backup** loads one into the account you're signed in to (sessions already in the account are skipped, so importing twice is safe).
- **Forgot password?** emails you a reset link.

### Setting up accounts (one time, for whoever hosts the app)

Accounts run on a free [Supabase](https://supabase.com) project:

1. Create a project at supabase.com.
2. Open **SQL Editor → New query**, paste in [`supabase/setup.sql`](supabase/setup.sql), and run it. It creates the `sessions` and `hands` tables and the row-level security rules that keep every user's data private.
3. In **Authentication → URL Configuration**, set **Site URL** to where the app is hosted (for example `https://maxherrera06.github.io/poker-tracker/`) so confirmation and reset emails link back to it.
4. In **Project Settings → API**, copy the **Project URL** and the **anon public** key into `SUPABASE_URL` and `SUPABASE_ANON_KEY` near the top of the script in `index.html`. The anon key is meant to be public; the security rules protect the data.

With those two values left empty, the app skips the login screen and saves in the browser only.

## Features

- **Live equity.** Monte Carlo simulation, up to 400k runouts, against however many opponents are still in. It shows win/tie/lose, your current made hand, and your chances of finishing with each hand type by the river.
- **Suggested action.** A big CALL / FOLD / RAISE badge when you face a bet (your equity vs the equity the pot odds require), and CHECK / BET when nobody has bet (your equity vs an even share for the number of opponents). It assumes opponents hold random hands.
- **Pot odds.** Enter the pot and the amount to call to see the equity you need and whether calling is +EV.
- **Fast keyboard entry.** One text box for the whole hand (see below). A tap-to-pick card grid is available for phones.
- **Table tracking.** Max seats (2–10), how many are seated, and a "someone folded" counter that resets every hand.
- **Blinds.** SB/BB toggles. A blind fold charges the blind automatically, and hands where you only put in the blind don't count as voluntary plays. It moves itself from SB to BB.
- **Bomb pots.** Set the ante and player count once, then toggle bomb pot per hand. It goes straight to the flop, and bomb pots are tracked separately from voluntary play. Turning bomb pot on shows a warning with your all-time bomb pot record and a one-tap "Sit this one out".
- **Money in the hand.** A running total of what you've put in: the blinds and bomb pot ante are counted automatically, you add each bet or call, and folds and losses are charged that total. Also shows your estimated stack right now.
- **Cash out & rebuy.** One click closes the current stretch at your cash-out and starts a new one with your rebuy (remembered, default $50), same game and blinds. An ended session has "Start again at this buy-in". The header shows today's running total across all of today's sessions.
- **Days.** The All sessions view groups sessions by day (6am to 6am). Click a day for its stats, a hand-by-hand chart of the whole day (dashed lines between sessions, bomb pots marked), its biggest pots, and its sessions.
- **Session tracking.** Buy-ins and rebuys, current stack, cash-out, profit, $/hr, hands/hr, bb/100, hands-played %, win rate when you play vs expected win rate (preflop equity), equity of folded hands, and folds that would have won.
- **All sessions view.** A tab at the top with totals across every session: profit, $/hr, bb/100, hands played, win rate vs expected, bomb pots, blinds, biggest win and loss, a running-profit chart (with and without bomb pots), key takeaways, a per-session table, and your best and worst starting hands. Click any session in the table to expand it: its own stats, a hand-by-hand profit chart (bomb pots marked), and collapsible sections for biggest pots, the full hand log, starting hands and bomb pots. It's read-only, so your live session keeps running.
- **🧠 Tilt meter.** Live on the session page (with a 🧠 score badge next to the text box): a 0–100 gauge from recent big losses, playing more hands than usual, bomb pots, chasing with weak equity, losing streaks, and giving back what you were up. It suggests a stop point to lock up a win and tells you to tighten up or take a break. The Hall of Fame shows the long-term version: how your profit, hands played and bomb pots change in the 10 hands after a big loss.
- **🏆 Hall of Fame.** A tab of fun stats: biggest pot, worst beat (the highest equity you lost with), luckiest win, your money hand, and the hand you're dealt most, plus a fun row: total hands, total hours, hands sent to the muck, longest heater, and pocket aces dealt. Below, a sideways-scrolling row of your best win with each kind of hand (straight flush down to high card), and under it your worst beat with each kind of hand.
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
| Everyone folded to you (preflop: wins the blinds automatically) | tap **Everyone folded 🙌** or press `e` |
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
