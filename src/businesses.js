export const TIER_2_BUSINESSES = [
  {
    id: 'R01',
    name: 'Independent Restaurant',
    category: 'Food & Bev',
    buyPrice: { min: 100000, max: 350000 },
    annualRevenue: { min: 400000, max: 1200000 },
    netMargin: 0.06,
    passiveCoeff: 0.1,
    failureRate: 0.12,
    exitMultiple: { min: 2, max: 2.5 },
    managerCost: 0.12,
    flavor: 'Thin margins, long hours, pure love. Or pure loss.',
  },
  {
    id: 'R02',
    name: 'Pizza Shop',
    category: 'Food & Bev',
    buyPrice: { min: 150000, max: 400000 },
    annualRevenue: { min: 400000, max: 1000000 },
    netMargin: 0.15,
    passiveCoeff: 0.2,
    failureRate: 0.10,
    exitMultiple: { min: 2.5, max: 3 },
    managerCost: 0.10,
    flavor: 'Higher margin than full-service — delivery is king',
  },
  {
    id: 'B01',
    name: 'Laundromat',
    category: 'Passive Assets',
    buyPrice: { min: 200000, max: 500000 },
    annualRevenue: { min: 150000, max: 350000 },
    netMargin: 0.27,
    passiveCoeff: 0.7,
    failureRate: 0.04,
    exitMultiple: { min: 3, max: 4 },
    managerCost: 0.05,
    flavor: 'Card readers + smart machines = semi-passive cash machine',
  },
  {
    id: 'B02',
    name: 'Express Car Wash',
    category: 'Auto Services',
    buyPrice: { min: 300000, max: 500000 },
    annualRevenue: { min: 250000, max: 500000 },
    netMargin: 0.30,
    passiveCoeff: 0.65,
    failureRate: 0.05,
    exitMultiple: { min: 4, max: 6 },
    managerCost: 0.06,
    flavor: 'Membership = recurring revenue. PE loves these.',
  },
  {
    id: 'B03',
    name: 'Auto Repair Shop',
    category: 'Auto Services',
    buyPrice: { min: 150000, max: 400000 },
    annualRevenue: { min: 400000, max: 1200000 },
    netMargin: 0.15,
    passiveCoeff: 0.2,
    failureRate: 0.08,
    exitMultiple: { min: 2.5, max: 3 },
    managerCost: 0.10,
    flavor: '70% of US car repair is independent shops. Steady demand.',
  },
  {
    id: 'H01',
    name: 'HVAC Contractor',
    category: 'Home Services',
    buyPrice: { min: 200000, max: 500000 },
    annualRevenue: { min: 400000, max: 1500000 },
    netMargin: 0.10,
    passiveCoeff: 0.3,
    failureRate: 0.08,
    exitMultiple: { min: 3, max: 4 },
    managerCost: 0.10,
    flavor: 'Top quartile does 13.2% net. Service mix drives margin.',
  },
  {
    id: 'H02',
    name: 'Plumbing Contractor',
    category: 'Home Services',
    buyPrice: { min: 200000, max: 500000 },
    annualRevenue: { min: 500000, max: 1500000 },
    netMargin: 0.14,
    passiveCoeff: 0.3,
    failureRate: 0.07,
    exitMultiple: { min: 3, max: 4 },
    managerCost: 0.10,
    flavor: 'Emergency calls = premium pricing',
  },
  {
    id: 'H04',
    name: 'Pest Control Service',
    category: 'Home Services',
    buyPrice: { min: 150000, max: 400000 },
    annualRevenue: { min: 300000, max: 1000000 },
    netMargin: 0.20,
    passiveCoeff: 0.45,
    failureRate: 0.05,
    exitMultiple: { min: 3.5, max: 4.5 },
    managerCost: 0.08,
    flavor: 'Recurring subscription model. PE darling.',
  },
  {
    id: 'PR01',
    name: 'Accounting Practice',
    category: 'Professional',
    buyPrice: { min: 150000, max: 500000 },
    annualRevenue: { min: 200000, max: 700000 },
    netMargin: 0.30,
    passiveCoeff: 0.15,
    failureRate: 0.05,
    exitMultiple: { min: 3, max: 4 },
    managerCost: 0.12,
    flavor: 'Among highest margins in services',
  },
  {
    id: 'PR02',
    name: 'Insurance Agency',
    category: 'Professional',
    buyPrice: { min: 200000, max: 500000 },
    annualRevenue: { min: 300000, max: 800000 },
    netMargin: 0.30,
    passiveCoeff: 0.55,
    failureRate: 0.03,
    exitMultiple: { min: 4, max: 5 },
    managerCost: 0.08,
    flavor: 'Commission residuals = annuity. Semi-passive gold.',
  },
];

export const TIER_1_BUSINESSES = [
  {
    id: 'S01',
    name: 'Lawn Care Route',
    category: 'Home Services',
    buyPrice: { min: 8000, max: 25000 },
    annualRevenue: { min: 30000, max: 150000 },
    netMargin: 0.08,
    passiveCoeff: 0.15,
    failureRate: 0.12,
    exitMultiple: { min: 1.5, max: 2 },
    managerCost: 0.30,
    flavor: 'Seasonal grind — route density is everything',
  },
  {
    id: 'S02',
    name: 'Residential Cleaning',
    category: 'Home Services',
    buyPrice: { min: 5000, max: 15000 },
    annualRevenue: { min: 40000, max: 150000 },
    netMargin: 0.18,
    passiveCoeff: 0.2,
    failureRate: 0.10,
    exitMultiple: { min: 1.5, max: 2 },
    managerCost: 0.25,
    flavor: 'Recurring revenue if you lock subscription clients',
  },
  {
    id: 'S03',
    name: 'Mobile Detailing',
    category: 'Auto Services',
    buyPrice: { min: 8000, max: 30000 },
    annualRevenue: { min: 50000, max: 150000 },
    netMargin: 0.22,
    passiveCoeff: 0.15,
    failureRate: 0.11,
    exitMultiple: { min: 1.5, max: 2 },
    managerCost: 0.30,
    flavor: 'Membership model lifts retention',
  },
  {
    id: 'S04',
    name: 'Pressure Washing',
    category: 'Home Services',
    buyPrice: { min: 5000, max: 25000 },
    annualRevenue: { min: 40000, max: 200000 },
    netMargin: 0.30,
    passiveCoeff: 0.1,
    failureRate: 0.10,
    exitMultiple: { min: 1.5, max: 2 },
    managerCost: 0.35,
    flavor: 'Highest margin in the tier — low overhead',
  },
  {
    id: 'S05',
    name: 'Window Cleaning',
    category: 'Home Services',
    buyPrice: { min: 5000, max: 15000 },
    annualRevenue: { min: 40000, max: 150000 },
    netMargin: 0.25,
    passiveCoeff: 0.15,
    failureRate: 0.10,
    exitMultiple: { min: 1.5, max: 2 },
    managerCost: 0.30,
    flavor: 'Commercial routes = recurring gold',
  },
  {
    id: 'P01',
    name: 'Vending Machine Route',
    category: 'Passive Assets',
    buyPrice: { min: 15000, max: 50000 },
    annualRevenue: { min: 30000, max: 80000 },
    netMargin: 0.35,
    passiveCoeff: 0.65,
    failureRate: 0.05,
    exitMultiple: { min: 2, max: 2.5 },
    managerCost: 0.10,
    flavor: '~$300/month/machine. Semi-passive at 10+ units',
  },
  {
    id: 'P02',
    name: 'ATM Route',
    category: 'Passive Assets',
    buyPrice: { min: 15000, max: 50000 },
    annualRevenue: { min: 25000, max: 60000 },
    netMargin: 0.50,
    passiveCoeff: 0.7,
    failureRate: 0.04,
    exitMultiple: { min: 2, max: 2.5 },
    managerCost: 0.08,
    flavor: '$300-$1K/machine/month at good placements',
  },
  {
    id: 'D01',
    name: 'Content/Affiliate Website',
    category: 'Digital',
    buyPrice: { min: 10000, max: 75000 },
    annualRevenue: { min: 15000, max: 80000 },
    netMargin: 0.60,
    passiveCoeff: 0.5,
    failureRate: 0.20,
    exitMultiple: { min: 2, max: 3 },
    managerCost: 0.15,
    flavor: 'Google algo update could tank it overnight',
  },
  {
    id: 'D02',
    name: 'Small Shopify Store',
    category: 'Digital',
    buyPrice: { min: 10000, max: 75000 },
    annualRevenue: { min: 30000, max: 150000 },
    netMargin: 0.15,
    passiveCoeff: 0.35,
    failureRate: 0.18,
    exitMultiple: { min: 2, max: 3 },
    managerCost: 0.20,
    flavor: 'Tariff exposure is a real risk now',
  },
  {
    id: 'D03',
    name: 'Faceless YouTube Channel',
    category: 'Digital',
    buyPrice: { min: 5000, max: 50000 },
    annualRevenue: { min: 15000, max: 100000 },
    netMargin: 0.55,
    passiveCoeff: 0.45,
    failureRate: 0.15,
    exitMultiple: { min: 1.8, max: 3.9 },
    managerCost: 0.15,
    flavor: 'Fastest-growing acquisition category — +155% YoY',
  },
  {
    id: 'D05',
    name: 'Digital Products / Courses',
    category: 'Digital',
    buyPrice: { min: 10000, max: 50000 },
    annualRevenue: { min: 20000, max: 100000 },
    netMargin: 0.70,
    passiveCoeff: 0.35,
    failureRate: 0.14,
    exitMultiple: { min: 2, max: 3 },
    managerCost: 0.15,
    flavor: 'Margins are insane but audience is everything',
  },
];

export const generateBusinessOffer = (playerCash = 0, playerConnections = 0) => {
  // Unlock Tier 2 as player accumulates capital and connections
  let pool = TIER_1_BUSINESSES;

  if (playerCash > 75000) {
    // Add some Tier 2 options
    pool = [...TIER_1_BUSINESSES, ...TIER_2_BUSINESSES];
  }

  // Favor businesses you can afford
  const affordableBusinesses = pool.filter(b => playerCash > b.buyPrice.min);
  const preferredPool = affordableBusinesses.length > 2 ? affordableBusinesses : pool;

  const businessTemplate = preferredPool[Math.floor(Math.random() * preferredPool.length)];

  const buyPrice = businessTemplate.buyPrice.min + Math.random() * (businessTemplate.buyPrice.max - businessTemplate.buyPrice.min);
  const revenue = businessTemplate.annualRevenue.min + Math.random() * (businessTemplate.annualRevenue.max - businessTemplate.annualRevenue.min);
  const margin = businessTemplate.netMargin * (0.8 + Math.random() * 0.4);
  const annualProfit = revenue * margin;

  // Connections improve deal quality
  let discountFactor = 1;
  if (playerConnections > 70) discountFactor = 0.85;
  else if (playerConnections > 50) discountFactor = 0.9;
  else if (playerConnections > 30) discountFactor = 0.95;

  return {
    id: `${businessTemplate.id}-${Date.now()}-${Math.random()}`,
    ...businessTemplate,
    buyPrice: Math.floor(buyPrice * discountFactor),
    annualRevenue: Math.floor(revenue),
    annualProfit: Math.floor(annualProfit),
    netMargin: margin,
    condition: 75 + Math.random() * 25,
    age: 0,
    manager: false,
  };
};

export const calculateSalePrice = (business) => {
  const multiple = business.exitMultiple.min + Math.random() * (business.exitMultiple.max - business.exitMultiple.min);
  return Math.floor(business.annualProfit * multiple);
};

export const calculateMonthlyProfit = (business) => {
  const adjustedProfit = business.annualProfit * (business.condition / 100);
  const managerCost = business.manager ? business.annualRevenue * business.managerCost : 0;
  return Math.floor((adjustedProfit - managerCost) / 12);
};
