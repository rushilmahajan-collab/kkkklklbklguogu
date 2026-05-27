const CAREERS = {
  'Software Engineer': { salary: 85000, stress: 50, growth: 'high' },
  'Management Consultant': { salary: 95000, stress: 80, growth: 'high' },
  'Marketing Coordinator': { salary: 52000, stress: 30, growth: 'medium' },
  'Financial Analyst': { salary: 75000, stress: 50, growth: 'high' },
  'Sales Rep': { salary: 55000, stress: 50, growth: 'medium' },
  'Operations Associate': { salary: 58000, stress: 30, growth: 'low' },
};

const CORPORATE_EVENTS = [
  {
    name: 'Promotion',
    type: 'good',
    apply: (state) => ({
      ...state,
      salary: Math.floor(state.salary * 1.2),
    }),
    flavor: 'Your hard work paid off. Management thinks you\'re "high potential." Salary bump incoming.',
  },
  {
    name: 'Layoff',
    type: 'bad',
    apply: (state) => ({
      ...state,
      employed: false,
      cash: state.cash + Math.floor(state.salary * 0.25),
      stress: Math.min(100, state.stress + 30),
    }),
    flavor: 'Your company "restructured." They gave you 3 months severance and an awkward handshake.',
  },
  {
    name: 'Mentor Appears',
    type: 'good',
    apply: (state) => ({
      ...state,
      connections: Math.min(100, state.connections + 15),
      stress: Math.max(0, state.stress - 10),
    }),
    flavor: 'A senior exec took you under their wing. Lunches and career advice incoming.',
  },
  {
    name: 'Toxic Boss',
    type: 'bad',
    apply: (state) => ({
      ...state,
      stress: Math.min(100, state.stress + 25),
    }),
    flavor: 'Your new boss is a nightmare. Every meeting is an ordeal. Your inbox is a warzone.',
  },
  {
    name: 'Stock Options Vest',
    type: 'good',
    apply: (state) => ({
      ...state,
      cash: state.cash + 15000,
    }),
    flavor: 'Your stock options vested. Free money. Your company\'s stock is probably worthless in 5 years but who cares.',
  },
  {
    name: 'Office Politics',
    type: 'bad',
    apply: (state) => ({
      ...state,
      reputation: Math.max(0, state.reputation - 15),
      stress: Math.min(100, state.stress + 10),
    }),
    flavor: 'Someone threw you under the bus in a meeting. Welcome to corporate.',
  },
  {
    name: 'Burnout',
    type: 'bad',
    apply: (state) => ({
      ...state,
      stress: 95,
      happiness: Math.max(0, state.happiness - 20),
    }),
    flavor: 'You\'re exhausted. Your soul left your body 3 months ago. Time to coast.',
  },
  {
    name: 'Market Rally',
    type: 'good',
    apply: (state) => ({
      ...state,
      happiness: Math.min(100, state.happiness + 10),
    }),
    flavor: 'The market is soaring. Your 401K balance just crossed six figures. Life is good.',
  },
  {
    name: 'Recession Fears',
    type: 'bad',
    apply: (state) => ({
      ...state,
      stress: Math.min(100, state.stress + 15),
      happiness: Math.max(0, state.happiness - 10),
    }),
    flavor: 'Everyone\'s talking about a recession. Your job security suddenly feels fragile.',
  },
];

const ENTREPRENEUR_EVENTS = [
  {
    name: 'Viral Success',
    type: 'good',
    apply: (state) => {
      const bigBusiness = state.businesses[Math.floor(Math.random() * state.businesses.length)];
      if (!bigBusiness) return state;
      return {
        ...state,
        businesses: state.businesses.map(b =>
          b.id === bigBusiness.id
            ? { ...b, annualRevenue: Math.floor(b.annualRevenue * 1.3) }
            : b
        ),
      };
    },
    flavor: 'One of your businesses exploded on social media. Revenue +30% this year.',
  },
  {
    name: 'Lawsuit Incoming',
    type: 'bad',
    apply: (state) => ({
      ...state,
      cash: Math.max(0, state.cash - 25000),
      stress: Math.min(100, state.stress + 20),
    }),
    flavor: 'A customer is suing. Legal fees are a nightmare. You\'re out $25K.',
  },
  {
    name: 'Key Employee Quits',
    type: 'bad',
    apply: (state) => {
      const targetBusiness = state.businesses[Math.floor(Math.random() * state.businesses.length)];
      if (!targetBusiness) return state;
      return {
        ...state,
        businesses: state.businesses.map(b =>
          b.id === targetBusiness.id
            ? { ...b, annualRevenue: Math.floor(b.annualRevenue * 0.85) }
            : b
        ),
      };
    },
    flavor: 'Your best employee just quit to start a competitor. Revenue dips 15%.',
  },
  {
    name: 'Unexpected Deal',
    type: 'good',
    apply: (state) => ({
      ...state,
      cash: state.cash + 50000,
    }),
    flavor: 'A corporate buyout of one of your suppliers. You negotiated a $50K bonus.',
  },
  {
    name: 'System Failure',
    type: 'bad',
    apply: (state) => ({
      ...state,
      cash: Math.max(0, state.cash - 10000),
      happiness: Math.max(0, state.happiness - 15),
    }),
    flavor: 'Your server crashed for 48 hours. Lost customers and $10K in emergency fixes.',
  },
  {
    name: 'Investor Approaches',
    type: 'good',
    apply: (state) => ({
      ...state,
      connections: Math.min(100, state.connections + 20),
      happiness: Math.min(100, state.happiness + 15),
    }),
    flavor: 'A VC partner saw your business and wants to talk. Your network just expanded.',
  },
];

export const LIFE_EVENTS = [...CORPORATE_EVENTS];

const generateMarketReturn = () => {
  const rand = Math.random();
  if (rand < 0.05) return -0.25 - Math.random() * 0.15; // crash
  if (rand < 0.15) return -0.10 - Math.random() * 0.15; // bear
  if (rand < 0.30) return -0.05 + Math.random() * 0.07; // flat/down
  if (rand < 0.70) return 0.05 + Math.random() * 0.1; // normal
  if (rand < 0.90) return 0.15 + Math.random() * 0.1; // bull
  return 0.25 + Math.random() * 0.15; // euphoria
};

export const createInitialState = (playerName, career) => ({
  screen: 'game',
  playerName,
  career,
  age: 22,
  year: 1,
  cash: 5000,
  salary: CAREERS[career].salary,
  employed: true,
  debt: 0,
  netWorth: 5000,
  businesses: [],
  portfolio: {
    indexFund: 0,
    stocks: {},
    bonds: {},
    crypto: 0,
    pennies: {},
  },
  clcIndex: 1000,
  lastClcValue: 1000,
  marketHistory: [1000],
  lastMarketReturn: 0,
  marketNews: 'Welcome to the market. Your journey begins here.',

  // Stats (0-100)
  stress: CAREERS[career].stress,
  hustle: 20,
  connections: 30,
  reputation: 50,
  happiness: 60,

  // Current turn data
  currentEvent: null,
  actionSlots: 3,
  actionsUsed: 0,
});

export const advanceYear = (state) => {
  const event = selectRandomEvent(state);
  const marketReturn = generateMarketReturn();
  const newClcValue = Math.floor(state.clcIndex * (1 + marketReturn));
  const actualReturn = (newClcValue - state.clcIndex) / state.clcIndex;

  // Update portfolio values based on market performance
  const updatedPortfolio = {
    indexFund: Math.floor(state.portfolio.indexFund * (1 + actualReturn)),
    stocks: Object.fromEntries(
      Object.entries(state.portfolio.stocks).map(([key, val]) => [
        key,
        Math.floor(val * (1 + actualReturn + (Math.random() - 0.5) * 0.1))
      ])
    ),
    bonds: state.portfolio.bonds,
    crypto: Math.floor(state.portfolio.crypto * (1 + (Math.random() - 0.5) * 0.4)),
    pennies: Object.fromEntries(
      Object.entries(state.portfolio.pennies).map(([key, val]) => [
        key,
        Math.random() < 0.7 ? 0 : Math.floor(val * (2 + Math.random() * 4))
      ])
    ),
  };

  // Generate market news
  let marketNews = '';
  if (actualReturn > 0.15) {
    marketNews = `Bull run incoming! CLC jumped ${(actualReturn * 100).toFixed(1)}%. Even your bad picks are making money.`;
  } else if (actualReturn > 0.05) {
    marketNews = `Steady gains. CLC up ${(actualReturn * 100).toFixed(1)}%. A quiet week on the markets.`;
  } else if (actualReturn > 0) {
    marketNews = `Flat day. CLC crawling up ${(actualReturn * 100).toFixed(1)}%. Nothing to see here.`;
  } else if (actualReturn > -0.1) {
    marketNews = `Minor pullback. CLC down ${Math.abs(actualReturn * 100).toFixed(1)}%. Don't panic.`;
  } else if (actualReturn > -0.2) {
    marketNews = `Market tumble. CLC dropped ${Math.abs(actualReturn * 100).toFixed(1)}%. Blood in the streets. Time to buy?`;
  } else {
    marketNews = `CRASH. CLC plummeted ${Math.abs(actualReturn * 100).toFixed(1)}%. Fortunes evaporating. This is a recession.`;
  }

  // Degrade business condition and apply failure checks
  let businessList = state.businesses.map(b => {
    const degradation = 5 + Math.random() * 10;
    const newCondition = Math.max(0, b.condition - degradation);

    // Check for failure
    const failureChance = b.failureRate * (1 - b.condition / 100);
    const failed = Math.random() < failureChance;

    if (failed) {
      return { ...b, failed: true };
    }

    return { ...b, condition: newCondition };
  }).filter(b => !b.failed);

  // Calculate cash flow from businesses
  const businessCashFlow = businessList.reduce((sum, b) => {
    const monthlyProfit = (b.annualProfit * (b.condition / 100)) / 12;
    const managerCost = b.manager ? (b.annualRevenue * b.managerCost) / 12 : 0;
    return sum + (monthlyProfit - managerCost);
  }, 0);

  let newState = {
    ...state,
    age: state.age + 1,
    year: state.year + 1,
    currentEvent: event,
    actionsUsed: 0,
    stress: Math.max(0, Math.min(100, state.stress - 5)),
    happiness: Math.min(100, state.happiness + 2),
    cash: state.cash + (state.employed ? state.salary : businessCashFlow * 12) - 3000,
    portfolio: updatedPortfolio,
    businesses: businessList,
    clcIndex: newClcValue,
    lastClcValue: state.clcIndex,
    lastMarketReturn: actualReturn,
    marketNews,
    marketHistory: [...state.marketHistory.slice(-9), newClcValue],
  };

  if (event) {
    newState = event.apply(newState);
  }

  // Bankruptcy check
  newState.netWorth = calculateNetWorth(newState);
  if (newState.netWorth < -50000) {
    newState.bankrupt = true;
  }

  return newState;
};

export const selectRandomEvent = (state) => {
  const eventPool = state.employed ? CORPORATE_EVENTS : ENTREPRENEUR_EVENTS;
  const weights = eventPool.map(e => e.type === 'good' ? 1.2 : e.type === 'bad' ? 1 : 0.5);
  const totalWeight = weights.reduce((a, b) => a + b, 0);
  let rand = Math.random() * totalWeight;

  for (let i = 0; i < eventPool.length; i++) {
    rand -= weights[i];
    if (rand <= 0) return eventPool[i];
  }

  return null;
};

export const calculateNetWorth = (state) => {
  let portfolioValue = state.portfolio.indexFund;
  Object.values(state.portfolio.stocks).forEach(v => portfolioValue += v);
  Object.values(state.portfolio.bonds).forEach(v => portfolioValue += v);
  portfolioValue += state.portfolio.crypto;
  Object.values(state.portfolio.pennies).forEach(v => portfolioValue += v);

  let businessEquity = 0;
  state.businesses.forEach(b => {
    const multiple = b.exitMultiple.min + (b.exitMultiple.max - b.exitMultiple.min) * 0.5;
    businessEquity += b.annualProfit * multiple;
  });

  return state.cash + portfolioValue + businessEquity - state.debt;
};

export const performAction = (state, actionName) => {
  if (state.actionsUsed >= state.actionSlots) return state;

  switch (actionName) {
    case 'grind':
      return {
        ...state,
        stress: Math.min(100, state.stress + 15),
        reputation: Math.min(100, state.reputation + 10),
        actionsUsed: state.actionsUsed + 1,
      };
    case 'coast':
      return {
        ...state,
        stress: Math.max(0, state.stress - 10),
        actionsUsed: state.actionsUsed + 1,
      };
    case 'network':
      return {
        ...state,
        cash: state.cash - 1000,
        connections: Math.min(100, state.connections + 12),
        actionsUsed: state.actionsUsed + 1,
      };
    case 'sideHustle':
      const sideIncome = 5000 + Math.random() * 15000;
      return {
        ...state,
        cash: state.cash + sideIncome,
        hustle: Math.min(100, state.hustle + 8),
        stress: Math.min(100, state.stress + 10),
        actionsUsed: state.actionsUsed + 1,
      };
    case 'skillUp':
      return {
        ...state,
        cash: state.cash - 3000,
        salary: Math.floor(state.salary * 1.1),
        actionsUsed: state.actionsUsed + 1,
      };
    case 'askRaise':
      const raiseChance = state.reputation / 100;
      const getRaise = Math.random() < raiseChance;
      return {
        ...state,
        salary: getRaise ? Math.floor(state.salary * 1.08) : state.salary,
        reputation: getRaise ? state.reputation : Math.max(0, state.reputation - 10),
        actionsUsed: state.actionsUsed + 1,
      };
    case 'quitAndEntrepreneur':
      return {
        ...state,
        employed: false,
        stress: Math.max(0, state.stress - 10),
        happiness: Math.min(100, state.happiness + 20),
        actionsUsed: state.actionsUsed + 1,
      };
    case 'goBackCorporate':
      return {
        ...state,
        employed: true,
        salary: Math.floor(state.salary * 0.8),
        stress: Math.min(100, state.stress + 20),
        happiness: Math.max(0, state.happiness - 15),
        actionsUsed: state.actionsUsed + 1,
      };
    default:
      return state;
  }
};

export const getAvailableActions = (state) => {
  const actions = [];

  if (state.employed) {
    actions.push(
      { id: 'grind', label: 'Grind', desc: 'Work hard, boost reputation, increase stress' },
      { id: 'coast', label: 'Coast', desc: 'Maintain, reduce stress, no growth' },
      { id: 'network', label: 'Network', desc: 'Spend $1K on events, build connections' },
      { id: 'sideHustle', label: 'Side Hustle', desc: 'Earn $5K-$20K extra, risk getting fired' },
      { id: 'skillUp', label: 'Skill Up', desc: 'Spend $3K on courses, unlock higher salary' },
      { id: 'askRaise', label: 'Ask for Raise', desc: 'Success based on reputation' },
    );

    if (state.age >= 25 || state.cash > 100000) {
      actions.push({
        id: 'quitAndEntrepreneur',
        label: 'Quit & Go Entrepreneur',
        desc: 'Leave corporate life and start your empire',
      });
    }
  } else {
    actions.push(
      { id: 'buyBusiness', label: 'Buy Business', desc: 'Browse available businesses' },
      { id: 'growBusiness', label: 'Grow Business', desc: 'Invest in an owned business' },
    );

    if (state.businesses.length > 0) {
      actions.push({
        id: 'sellBusiness',
        label: 'Sell Business',
        desc: 'Flip a business for profit',
      });
    }

    if (state.age >= 30) {
      actions.push({
        id: 'goBackCorporate',
        label: 'Go Back Corporate',
        desc: 'Return to corporate (salary penalty)',
      });
    }
  }

  return actions;
};

export const buyBusiness = (state, business) => {
  if (state.cash < business.buyPrice) return state;

  return {
    ...state,
    cash: state.cash - business.buyPrice,
    businesses: [
      ...state.businesses,
      {
        ...business,
        boughtAt: state.year,
      },
    ],
  };
};

export const sellBusiness = (state, businessId) => {
  const business = state.businesses.find(b => b.id === businessId);
  if (!business) return state;

  const salePrice = calculateSalePrice(business);

  return {
    ...state,
    cash: state.cash + salePrice,
    businesses: state.businesses.filter(b => b.id !== businessId),
  };
};

export const growBusiness = (state, businessId, investAmount) => {
  if (state.cash < investAmount) return state;

  const business = state.businesses.find(b => b.id === businessId);
  if (!business) return state;

  const newCondition = Math.min(100, business.condition + Math.floor(investAmount / 100));
  const newRevenue = Math.floor(business.annualRevenue * 1.05);

  return {
    ...state,
    cash: state.cash - investAmount,
    businesses: state.businesses.map(b =>
      b.id === businessId
        ? { ...b, condition: newCondition, annualRevenue: newRevenue, annualProfit: Math.floor(newRevenue * b.netMargin) }
        : b
    ),
  };
};
