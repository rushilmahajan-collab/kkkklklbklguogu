# CorpLife: Corporate to Empire

A browser-based, single-player life simulation game. Start as a fresh college grad picking a corporate job, grind through corporate life, stack cash, and transition into entrepreneurship — buying, growing, and flipping businesses to build an empire.

## Tech Stack

- **Frontend:** React + Vite + Tailwind CSS
- **State:** In-memory (no backend, no localStorage)
- **Design:** Mobile-first (max-width 430px), dark theme
- **Data:** All business types, margins, multiples grounded in real U.S. market data

## Running Locally

```bash
npm install
npm run dev
```

Dev server runs on `http://localhost:5173`

## Build for Production

```bash
npm run build
```

Output in `dist/`

## Game Loop

**Turn-based.** Each turn = 1 year. Player starts at Age 22.

### Phase 1: Corporate Grind (Age 22-30+)

- Pick 1 of 6 careers (Software Engineer, Consultant, etc.)
- Actions: Grind, Coast, Network, Side Hustle, Skill Up, Ask for Raise
- Build: Cash, Connections, Reputation
- Unlock: Quit & Go Entrepreneur (at Age 25 or $100K+ cash)

### Phase 2: Early Entrepreneur

- Buy businesses from browser (start Tier 1: $5K-$75K)
- Grow businesses: invest in condition/revenue
- Hire managers: reduce owner dependency
- Sell businesses: collect exit multiples
- Unlock: Tier 2 businesses (at $75K+ cash)

### Phase 3: Empire Builder

- Scale to multiple businesses
- Build wealth through business profits + market investments
- Exit through selling businesses or going public (future)

## Core Systems

### Business System

- **Tier 1** (11 businesses): Lawn care, cleaning, detailing, vending machines, digital stores, etc.
- **Tier 2** (10 businesses): Restaurants, laundromats, HVAC, accounting, pest control, etc.
- Each business has:
  - Buy price, annual revenue, net margin, passive coefficient
  - Failure rate, exit multiple, manager cost
  - Condition (degrades 5-15pts/year, affects profit)
  - Manager (improves passive coeff by 0.2-0.4 based on Connections)

### Market System

- **CLC Composite Index** (fictional): Starts at 1000
- **Annual Returns:** -40% to +40% (drawn from realistic distribution)
- **Investment Vehicles:**
  - Index Fund: 2% dividend, tracks CLC
  - Bonds: 4% fixed interest (future: different types)
  - Stocks, Crypto, Penny Stocks (future: fuller implementation)
- **Portfolio Tracking:** All positions tracked with current value

### Economy

- **Living Expenses:** $3K/month base (scales with wealth)
- **Taxes:** 25% flat on business profits
- **Market Cycles:** Recession every ~7-10 years (-20% to -35% drop)
- **Inflation:** All revenue/expenses grow 2-4%/year (implicit)

### Player Stats (0-100)

- **Stress:** Affected by actions, events. High stress → bad events more likely
- **Hustle:** Improves business growth & side income
- **Connections:** Unlocks better businesses, improves deal prices, better managers
- **Reputation:** Affects raise success, loan rates, business revenue (+/- 10%)
- **Happiness:** Tracks quality of life. Below 20 = crisis event

### Random Events

**Corporate Events** (when employed):
- Promotion, Layoff, Mentor, Toxic Boss, Stock Vesting, Office Politics, Burnout, Market Rally, Recession Fears

**Entrepreneur Events** (when self-employed):
- Viral Success, Lawsuit, Key Employee Quits, Unexpected Deal, System Failure, Investor Approaches

Events apply stat changes and cash impacts.

## Game End

**Win Condition:** Retire intentionally (Retire button for entrepreneurs)

**Lose Condition:** Bankruptcy (net worth drops below -$50K)

**Auto-End:** Age 100+

## Scoring

Final grade based on:
- Net worth at retirement (40% weight)
- Peak businesses owned (20%)
- Average happiness (15%)
- Years survived (15%)
- Reputation (10%)

Grades: S (A+), A, B, C, D, F

## File Structure

```
src/
  main.jsx                 # React entry point
  App.jsx                  # Main app component
  index.css                # Global styles + Tailwind
  gameState.js             # Game logic, state management
  businesses.js            # Business database & generation
  components/
    CharacterCreationScreen.jsx
    MainGameScreen.jsx
    GameOverScreen.jsx
    PortfolioCard.jsx      # Market/investment display
    BusinessBrowser.jsx    # Business shopping modal
    BusinessesCard.jsx     # Owned businesses list
    BusinessActionsModal.jsx # Grow/hire manager
    InvestModal.jsx        # Market investment

```

## Design Philosophy

1. **Real-world data:** All business multiples, margins, failure rates from public sources (BizBuySell, Flippa, BLS, etc.)
2. **No pay-to-win:** 100% free
3. **Meaningful choices:** Different strategies (boring home services vs risky emerging tech) create different runs
4. **Tension & reward:** Watching net worth tick up from $0 to $1M should feel satisfying
5. **Replayability:** Random events + business generation mean each run is unique

## Future Features (Post-MVP)

- Tier 3+ businesses ($500K-$5M+)
- Roll-up mechanic (acquire 3+ same-category businesses at premium multiple)
- Loan system (borrow against net worth, 8-15% interest)
- Better stock/crypto system (individual companies, more volatility)
- Franchise opportunities
- Angel investing in startups
- Recession impact events
- More detailed analytics screen
- Save/load game state (localStorage)
- Sound effects (optional muted by default)
- Achievements/badges

## Known Limitations

- No backend/multiplayer
- No real-time market tracking
- No complex tax system (flat 25%)
- Limited to Tier 1-2 businesses in MVP
- No ability to expand existing businesses (just buy/grow/sell)

## Contact / Feedback

This is an educational simulation game. Feedback welcome!
