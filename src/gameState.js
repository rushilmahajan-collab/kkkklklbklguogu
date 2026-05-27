const CAREERS = {
  'Software Engineer': { salary: 85000, stress: 50, growth: 'high' },
  'Management Consultant': { salary: 95000, stress: 80, growth: 'high' },
  'Marketing Coordinator': { salary: 52000, stress: 30, growth: 'medium' },
  'Financial Analyst': { salary: 75000, stress: 50, growth: 'high' },
  'Sales Rep': { salary: 55000, stress: 50, growth: 'medium' },
  'Operations Associate': { salary: 58000, stress: 30, growth: 'low' },
};

const LIFE_EVENTS = [
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
];

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

  let newState = {
    ...state,
    age: state.age + 1,
    year: state.year + 1,
    currentEvent: event,
    actionsUsed: 0,
    stress: Math.max(0, Math.min(100, state.stress - 5)),
    cash: state.cash + (state.employed ? state.salary / 12 * 12 : 0) - 3000,
  };

  if (event) {
    newState = event.apply(newState);
  }

  newState.netWorth = calculateNetWorth(newState);

  return newState;
};

export const selectRandomEvent = (state) => {
  const weights = LIFE_EVENTS.map(e => e.type === 'good' ? 1 : e.type === 'bad' ? 1 : 0.5);
  const totalWeight = weights.reduce((a, b) => a + b, 0);
  let rand = Math.random() * totalWeight;

  for (let i = 0; i < LIFE_EVENTS.length; i++) {
    rand -= weights[i];
    if (rand <= 0) return LIFE_EVENTS[i];
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
    businessEquity += b.annualProfit * (b.exitMultiple || 2);
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
  }

  return actions;
};
