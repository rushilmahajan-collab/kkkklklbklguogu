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

export const generateBusinessOffer = (tier = 1) => {
  const businessTemplate = TIER_1_BUSINESSES[Math.floor(Math.random() * TIER_1_BUSINESSES.length)];

  const variance = 0.2;
  const buyPrice = businessTemplate.buyPrice.min + Math.random() * (businessTemplate.buyPrice.max - businessTemplate.buyPrice.min);
  const revenue = businessTemplate.annualRevenue.min + Math.random() * (businessTemplate.annualRevenue.max - businessTemplate.annualRevenue.min);
  const margin = businessTemplate.netMargin * (0.8 + Math.random() * 0.4);
  const annualProfit = revenue * margin;

  return {
    id: `${businessTemplate.id}-${Date.now()}`,
    ...businessTemplate,
    buyPrice: Math.floor(buyPrice),
    annualRevenue: Math.floor(revenue),
    annualProfit: Math.floor(annualProfit),
    netMargin: margin,
    condition: 80,
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
