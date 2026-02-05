import React, { useState, useRef, useEffect } from 'react';

// Game constants and data
const FOUNDER_PATHS = {
  'Technical': {
    description: 'Build products yourself without relying on agencies or no-code tools',
    advantages: [
      "Don't need no-code platform ($200/mo + AI tokens)",
      'Faster development cycles (15% speed boost)',
      'Better bug detection and fixes (30% fewer bugs)',
      'Can build complex features in-house',
      'Lower technical debt over time'
    ],
    disadvantages: [
      'Must hire marketing agency or take courses ($2K-5K) for campaigns',
      'Must hire sales agency or take courses ($3K-7K) for outbound',
      'Lower base closing rates (-10%)',
      'Weaker at pitching and storytelling'
    ],
    career: {
      base: 95000,
      levels: [
        'Software Engineer',
        'Senior Software Engineer', 
        'Software Engineering Manager',
        'Director of Software Engineering',
        'VP of Software Engineering'
      ],
      weeksRequired: [156, 260, 520, 520, 520], // 3yr, 5yr, 10yr, 10yr, 10yr
      bonuses: [
        { type: 'development', description: '15% faster development, no no-code fees', value: 0.15, skipNoCode: true },
        { type: 'development', description: '20% faster development, 10% fewer bugs', value: 0.20, bugReduction: 0.10, skipNoCode: true },
        { type: 'development', description: '25% faster development, 20% fewer bugs', value: 0.25, bugReduction: 0.20, skipNoCode: true },
        { type: 'development', description: '30% faster development, 30% fewer bugs', value: 0.30, bugReduction: 0.30, skipNoCode: true },
        { type: 'development', description: '35% faster development, 30% fewer bugs, architect mode', value: 0.35, bugReduction: 0.30, skipNoCode: true }
      ]
    }
  },
  'Non-Technical': {
    description: 'Master sales and marketing to drive growth without building yourself',
    advantages: [
      'Better closing rates (+15% base)',
      'Better marketing conversion (+20%)',
      'Can run campaigns yourself (no agency needed)',
      'Can do cold outreach yourself (no agency needed)',
      'Natural at pitching and storytelling'
    ],
    disadvantages: [
      'Must pay for no-code platform ($200/mo + $50-150/mo AI tokens)',
      'Slower development cycles (normal speed)',
      'Cannot build complex technical features',
      'Higher technical debt over time',
      'Must hire developers for custom features'
    ],
    career: {
      base: 65000,
      levels: [
        'Sales Development Representative',
        'Commercial Account Executive',
        'Mid Market Account Executive',
        'Enterprise Account Executive',
        'Commercial Sales Manager',
        'Senior Commercial Sales Manager',
        'Director, Commercial Sales'
      ],
      weeksRequired: [78, 156, 104, 156, 260, 104, 208], // 1.5yr, 3yr, 2yr, 3yr, 5yr, 2yr, 4yr
      bonuses: [
        { type: 'sales', description: '+15% closing rate, can run campaigns', value: 0.15, canMarketing: true, canSales: true },
        { type: 'sales', description: '+20% closing rate, +10% marketing conversion', value: 0.20, marketingBonus: 0.10, canMarketing: true, canSales: true },
        { type: 'sales', description: '+25% closing rate, +15% marketing conversion', value: 0.25, marketingBonus: 0.15, canMarketing: true, canSales: true },
        { type: 'sales', description: '+30% closing rate, +20% marketing conversion', value: 0.30, marketingBonus: 0.20, canMarketing: true, canSales: true },
        { type: 'sales', description: '+35% closing rate, +25% marketing conversion', value: 0.35, marketingBonus: 0.25, canMarketing: true, canSales: true },
        { type: 'sales', description: '+40% closing rate, +30% marketing conversion', value: 0.40, marketingBonus: 0.30, canMarketing: true, canSales: true },
        { type: 'sales', description: '+45% closing rate, +35% marketing conversion', value: 0.45, marketingBonus: 0.35, canMarketing: true, canSales: true }
      ]
    }
  }
};

// Backwards compatibility - keep JOBS for legacy code
const JOBS = {
  'Technical': FOUNDER_PATHS['Technical'].career,
  'Non-Technical': FOUNDER_PATHS['Non-Technical'].career
};

// Startup progression levels and checklist
const STARTUP_LEVELS = {
  'Delusional Founder': {
    description: 'You have an idea but nothing else',
    tasks: [
      { id: 'build_mvp', name: 'Build an MVP', completed: false },
      { id: 'setup_llc', name: 'Set up LLC ($800)', completed: false },
      { id: 'setup_social', name: 'Set up social media accounts', completed: false },
      { id: 'setup_strupe', name: 'Set up Strupe for payments', completed: false },
      { id: 'research_startup', name: 'Research startup essentials', completed: false }
    ],
    nextLevel: 'Pre-Seed Startup'
  },
  'Pre-Seed Startup': {
    description: 'MVP built, ready to find customers',
    tasks: [
      { id: 'first_customer', name: 'Get your first paying customer', completed: false },
      { id: 'arr_1k', name: 'Reach $1K ARR', completed: false },
      { id: 'open_bank', name: 'Open business bank account', completed: false },
      { id: 'setup_accounting', name: 'Set up accounting software', completed: false }
    ],
    nextLevel: 'Bootstrapped Startup'
  },
  'Bootstrapped Startup': {
    description: 'Early traction, growing revenue',
    tasks: [
      { id: 'arr_10k', name: 'Reach $10K ARR', completed: false },
      { id: 'hire_first', name: 'Make your first hire', completed: false },
      { id: 'pmf_50', name: 'Reach 50% product-market fit', completed: false },
      { id: 'customers_10', name: 'Get 10 paying customers', completed: false }
    ],
    nextLevel: 'Seed Stage'
  },
  'Seed Stage': {
    description: 'Strong PMF, ready to scale',
    tasks: [
      { id: 'arr_100k', name: 'Reach $100K ARR', completed: false },
      { id: 'team_5', name: 'Build team to 5 people', completed: false },
      { id: 'pmf_80', name: 'Reach 80% product-market fit', completed: false },
      { id: 'raise_seed', name: 'Raise seed funding ($500K)', completed: false }
    ],
    nextLevel: 'Series A'
  },
  'Series A': {
    description: 'Scaling fast, proven model',
    tasks: [
      { id: 'arr_1m', name: 'Reach $1M ARR', completed: false },
      { id: 'team_20', name: 'Build team to 20 people', completed: false },
      { id: 'customers_100', name: 'Get 100 paying customers', completed: false },
      { id: 'raise_series_a', name: 'Raise Series A ($5M)', completed: false }
    ],
    nextLevel: 'Unicorn Track'
  }
};

const INDUSTRIES = [
  'B2B SaaS',
  'FinTech',
  'HealthTech',
  'E-commerce',
  'AI/ML',
  'Real Estate Tech',
  'EdTech',
  'Food & Beverage Tech',
  'CleanTech',
  'Media & Entertainment'
];

const STARTUP_IDEAS_BY_INDUSTRY = {
  'B2B SaaS': [
    { name: 'AI-Powered Sales Intelligence', problem: 'Sales teams waste 60% of time on manual research', tam: 12 },
    { name: 'Customer Success Automation', problem: 'CS teams cant scale personalized outreach', tam: 15 },
    { name: 'Employee Onboarding Platform', problem: 'Companies spend $4000 per new hire on onboarding', tam: 9 },
    { name: 'Project Management AI', problem: 'Teams waste 23 hours per week on status updates', tam: 14 },
    { name: 'Contract Management System', problem: 'Legal teams spend 40% of time finding contracts', tam: 8 },
    { name: 'Revenue Operations Platform', problem: 'Sales and marketing data lives in 12+ tools', tam: 11 },
    { name: 'Procurement Automation', problem: 'Companies spend $25K per employee on procurement admin', tam: 13 },
    { name: 'Internal Communications Hub', problem: 'Remote workers miss 30% of important updates', tam: 7 },
    { name: 'Vendor Management System', problem: 'Enterprises manage 500+ vendors manually', tam: 10 },
    { name: 'Customer Feedback Analytics', problem: 'Product teams cant prioritize feature requests', tam: 6 }
  ],
  'FinTech': [
    { name: 'Real-time Fraud Detection', problem: 'E-commerce loses $48B annually to fraud', tam: 20 },
    { name: 'Embedded Banking Platform', problem: 'Apps take 18 months to add payment features', tam: 16 },
    { name: 'Small Business Lending', problem: '70% of small businesses get rejected by banks', tam: 24 },
    { name: 'Crypto Tax Automation', problem: 'Traders spend 40 hours per year on tax calculations', tam: 5 },
    { name: 'Open Banking API', problem: 'Developers spend 6 months integrating banks', tam: 12 },
    { name: 'Invoice Financing Platform', problem: 'Small businesses wait 60 days for payments', tam: 18 },
    { name: 'Personal CFO Assistant', problem: 'Affluent individuals spend $50K/year on wealth management', tam: 22 },
    { name: 'Expense Management for SMBs', problem: 'Companies lose 15% to improper expense tracking', tam: 9 },
    { name: 'Cross-border Payments', problem: 'International transfers cost 3-7% in fees', tam: 28 },
    { name: 'Buy Now Pay Later for B2B', problem: 'Businesses need 60-90 day payment terms', tam: 14 }
  ],
  'HealthTech': [
    { name: 'Healthcare Claims Automation', problem: 'Insurance claims take 45 days on average', tam: 18 },
    { name: 'Telemedicine Platform', problem: 'Rural patients drive 2+ hours for specialist care', tam: 25 },
    { name: 'Clinical Trial Matching', problem: 'Only 3% of cancer patients enroll in trials', tam: 8 },
    { name: 'Mental Health Therapy App', problem: 'Average wait time for therapist is 5 weeks', tam: 15 },
    { name: 'Medical Billing Automation', problem: 'Practices lose 20% revenue to billing errors', tam: 12 },
    { name: 'Remote Patient Monitoring', problem: 'Hospital readmissions cost $17B annually', tam: 22 },
    { name: 'Pharmacy Management System', problem: 'Independent pharmacies waste 30% margin on inventory', tam: 7 },
    { name: 'Medical Scribe AI', problem: 'Doctors spend 2 hours on charts per 1 hour of patient care', tam: 10 },
    { name: 'Health Data Interoperability', problem: 'Patient records exist in 8 different systems', tam: 16 },
    { name: 'Preventive Care Platform', problem: 'Chronic disease costs $3.7T annually', tam: 30 }
  ],
  'E-commerce': [
    { name: 'Social Commerce Platform', problem: 'Influencers lose 80% of sales to checkout friction', tam: 24 },
    { name: 'Returns Management System', problem: 'Returns cost retailers $550B annually', tam: 18 },
    { name: 'Inventory Optimization AI', problem: 'Retailers lose 10% revenue to stockouts', tam: 15 },
    { name: 'Live Shopping Platform', problem: 'Live commerce is $300B in China, $20B in US', tam: 35 },
    { name: 'Subscription Box Platform', problem: 'Starting a subscription business takes 6 months', tam: 8 },
    { name: 'Virtual Try-On Technology', problem: '30% of online apparel is returned', tam: 12 },
    { name: 'Omnichannel Loyalty Program', problem: 'Customer data is siloed across online and retail', tam: 14 },
    { name: 'Dynamic Pricing Engine', problem: 'Retailers leave 20% margin on table with static pricing', tam: 10 },
    { name: 'Warehouse Automation Software', problem: 'Fulfillment centers operate at 50% efficiency', tam: 22 },
    { name: 'Cross-border E-commerce', problem: 'Only 1% of retailers sell internationally', tam: 28 }
  ],
  'AI/ML': [
    { name: 'Developer Productivity Analytics', problem: 'Engineering leaders lack visibility into team velocity', tam: 8 },
    { name: 'AI Content Generation', problem: 'Marketing teams spend 60% of time creating content', tam: 16 },
    { name: 'Code Review Automation', problem: 'Senior engineers spend 10 hours per week on code review', tam: 6 },
    { name: 'Document Intelligence Platform', problem: 'Companies process 2.5B documents manually per year', tam: 20 },
    { name: 'Predictive Maintenance AI', problem: 'Unplanned downtime costs manufacturers $50B annually', tam: 14 },
    { name: 'Customer Support AI', problem: 'Support teams answer same questions 1000x per day', tam: 12 },
    { name: 'Video Content Moderation', problem: 'Platforms manually review 500M hours of video monthly', tam: 10 },
    { name: 'Speech-to-Text API', problem: 'Enterprises spend $2B on transcription services', tam: 7 },
    { name: 'Synthetic Data Generation', problem: 'AI teams spend 80% of time collecting training data', tam: 9 },
    { name: 'AI Model Monitoring', problem: 'ML models degrade 40% in first 3 months in production', tam: 5 }
  ],
  'Real Estate Tech': [
    { name: 'Property Management Software', problem: 'Landlords spend 20 hours per month on tenant communication', tam: 12 },
    { name: 'Home Buying Platform', problem: 'Average home buyer tours 10 properties in person', tam: 18 },
    { name: 'Construction Project Tracking', problem: '77% of construction projects go over budget', tam: 14 },
    { name: 'Commercial Lease Management', problem: 'Commercial tenants manage leases in spreadsheets', tam: 8 },
    { name: 'Smart Building Platform', problem: 'Buildings waste 30% of energy consumption', tam: 22 },
    { name: 'Real Estate Investment Platform', problem: 'Individual investors cant access commercial deals', tam: 16 },
    { name: 'Virtual Staging Software', problem: 'Physical staging costs $3K per property', tam: 4 },
    { name: 'Title and Escrow Automation', problem: 'Closing a home takes 40 days on average', tam: 10 },
    { name: 'Home Renovation Marketplace', problem: 'Homeowners get quotes from 8 contractors', tam: 15 },
    { name: 'HOA Management Platform', problem: 'HOA boards spend 40% of budget on management fees', tam: 6 }
  ],
  'EdTech': [
    { name: 'Adaptive Learning Platform', problem: 'Students learn at different paces but receive same instruction', tam: 20 },
    { name: 'Career Training Bootcamps', problem: 'College degrees cost $200K and take 4 years', tam: 14 },
    { name: 'Language Learning App', problem: '2B people want to learn English', tam: 12 },
    { name: 'Corporate Training LMS', problem: 'Companies spend $1300 per employee on training annually', tam: 16 },
    { name: 'Student Loan Refinancing', problem: 'Students pay average 6.8% interest on loans', tam: 18 },
    { name: 'Tutoring Marketplace', problem: 'Parents spend $1B annually on private tutoring', tam: 8 },
    { name: 'School Administration Software', problem: 'Teachers spend 50% of time on administrative tasks', tam: 10 },
    { name: 'Exam Preparation Platform', problem: 'Test prep courses cost $2K per student', tam: 7 },
    { name: 'Remote Learning Tools', problem: '55M students now learn remotely', tam: 22 },
    { name: 'Education Content Marketplace', problem: 'Teachers create lesson plans from scratch', tam: 6 }
  ],
  'Food & Beverage Tech': [
    { name: 'Restaurant Demand Forecasting', problem: 'Restaurants waste 30% of inventory due to poor predictions', tam: 6 },
    { name: 'Ghost Kitchen Platform', problem: 'Starting a restaurant requires $500K upfront', tam: 12 },
    { name: 'Restaurant POS System', problem: 'Legacy POS systems charge 3% per transaction', tam: 10 },
    { name: 'Food Delivery Logistics', problem: 'Restaurants pay 30% commission to delivery apps', tam: 18 },
    { name: 'Meal Planning App', problem: 'Households waste $1800 per year on food', tam: 8 },
    { name: 'Restaurant Staffing Platform', problem: 'Restaurants have 150% annual employee turnover', tam: 7 },
    { name: 'Alcohol E-commerce', problem: 'Alcohol e-commerce is only 3% of $250B market', tam: 14 },
    { name: 'Recipe Content Platform', problem: 'Food bloggers spend 20 hours per recipe post', tam: 5 },
    { name: 'Restaurant Reservations', problem: '30% of reservations result in no-shows', tam: 9 },
    { name: 'Farm-to-Table Marketplace', problem: 'Restaurants source from 15 different suppliers', tam: 11 }
  ],
  'CleanTech': [
    { name: 'Solar Installation Marketplace', problem: 'Solar installation quotes take 6 weeks', tam: 16 },
    { name: 'Carbon Credit Trading', problem: 'Carbon credit market is fragmented and opaque', tam: 12 },
    { name: 'EV Charging Network', problem: 'EV owners drive 20 miles to find charging stations', tam: 22 },
    { name: 'Energy Management Platform', problem: 'Factories waste 25% of energy consumption', tam: 14 },
    { name: 'Sustainable Supply Chain', problem: 'Companies cant track product carbon footprint', tam: 10 },
    { name: 'Waste Management Software', problem: 'Only 9% of plastic gets recycled', tam: 8 },
    { name: 'Water Conservation Tech', problem: 'Agriculture uses 70% of global freshwater', tam: 11 },
    { name: 'Green Building Certification', problem: 'LEED certification takes 18 months', tam: 6 },
    { name: 'Battery Storage Platform', problem: 'Renewable energy needs 10TWh of storage by 2030', tam: 18 },
    { name: 'Climate Risk Analytics', problem: 'Real estate cant price climate risk accurately', tam: 9 }
  ],
  'Media & Entertainment': [
    { name: 'Creator Economy Platform', problem: 'Creators make $0.003 per stream on Spotify', tam: 15 },
    { name: 'Short-Form Video Editor', problem: 'Video editors spend 10 hours per video', tam: 8 },
    { name: 'Music Rights Management', problem: 'Artists lose 40% of royalties to poor tracking', tam: 12 },
    { name: 'Live Event Ticketing', problem: 'Ticketing fees average 25% of ticket price', tam: 18 },
    { name: 'Podcast Analytics Platform', problem: 'Podcasters have no data on listener engagement', tam: 6 },
    { name: 'Gaming Tournament Platform', problem: 'Esports market is $1.4B with no central hub', tam: 14 },
    { name: 'Virtual Events Software', problem: 'Event industry lost $1T during COVID', tam: 10 },
    { name: 'Influencer Marketing Platform', problem: 'Brands spend $16B on influencers with no ROI tracking', tam: 20 },
    { name: 'Fan Engagement Platform', problem: 'Sports teams have 100M fans but no direct relationship', tam: 16 },
    { name: 'Content Licensing Marketplace', problem: 'Stock footage costs $500 per clip', tam: 7 }
  ]
};

const LOGOS = [
  { icon: '🚀', color: '#3B82F6' },
  { icon: '⚡', color: '#8B5CF6' },
  { icon: '🎯', color: '#EF4444' },
  { icon: '💎', color: '#10B981' },
  { icon: '🔥', color: '#F59E0B' },
  { icon: '⭐', color: '#EC4899' },
  { icon: '🌟', color: '#14B8A6' },
  { icon: '💡', color: '#6366F1' },
  { icon: '🎨', color: '#F97316' },
  { icon: '🔮', color: '#A855F7' }
];

// Features available for each industry type
const FEATURES_BY_INDUSTRY = {
  'B2B SaaS': [
    { name: 'User Authentication', hours: 20, description: 'Secure login and signup' },
    { name: 'Dashboard', hours: 30, description: 'Main analytics dashboard' },
    { name: 'API Integration', hours: 25, description: 'Connect with third-party tools' },
    { name: 'Team Management', hours: 20, description: 'Invite and manage team members' },
    { name: 'Reporting', hours: 30, description: 'Generate custom reports' },
    { name: 'Notifications', hours: 15, description: 'Email and in-app alerts' },
    { name: 'Search', hours: 20, description: 'Search functionality' },
    { name: 'Mobile App', hours: 40, description: 'iOS and Android apps' },
    { name: 'Admin Panel', hours: 25, description: 'Admin controls and settings' }
  ],
  'FinTech': [
    { name: 'Account Creation', hours: 25, description: 'KYC and account setup' },
    { name: 'Security & Encryption', hours: 30, description: 'Bank-level security' },
    { name: 'Transaction History', hours: 20, description: 'View past transactions' },
    { name: 'Fraud Detection', hours: 40, description: 'AI-powered fraud prevention' },
    { name: 'Compliance Dashboard', hours: 30, description: 'Regulatory compliance' },
    { name: 'Multi-currency Support', hours: 25, description: 'Support multiple currencies' },
    { name: 'API for Developers', hours: 30, description: 'Developer integration' },
    { name: 'Mobile Banking', hours: 45, description: 'Mobile-first experience' },
    { name: 'Analytics', hours: 25, description: 'Financial insights' }
  ],
  'HealthTech': [
    { name: 'Patient Portal', hours: 30, description: 'Patient access and records' },
    { name: 'Appointment Scheduling', hours: 25, description: 'Book and manage appointments' },
    { name: 'HIPAA Compliance', hours: 35, description: 'Healthcare data security' },
    { name: 'Telemedicine', hours: 40, description: 'Video consultations' },
    { name: 'EHR Integration', hours: 35, description: 'Electronic health records' },
    { name: 'Prescription Management', hours: 25, description: 'Digital prescriptions' },
    { name: 'Lab Results', hours: 20, description: 'View test results' },
    { name: 'Provider Directory', hours: 20, description: 'Find healthcare providers' },
    { name: 'Health Tracking', hours: 25, description: 'Track vitals and symptoms' },
    { name: 'Waitlist Management', hours: 20, description: 'Manage patient waitlists' }
  ],
  'E-commerce': [
    { name: 'Product Catalog', hours: 25, description: 'Browse and search products' },
    { name: 'Shopping Cart', hours: 20, description: 'Add items to cart' },
    { name: 'Checkout Flow', hours: 30, description: 'Complete purchases' },
    { name: 'Inventory Management', hours: 30, description: 'Track stock levels' },
    { name: 'Order Tracking', hours: 20, description: 'Track shipments' },
    { name: 'Reviews & Ratings', hours: 20, description: 'Customer feedback' },
    { name: 'Recommendations', hours: 35, description: 'AI product suggestions' },
    { name: 'Wishlist', hours: 15, description: 'Save products for later' },
    { name: 'Customer Accounts', hours: 25, description: 'User profiles and history' },
    { name: 'Admin Dashboard', hours: 30, description: 'Manage store operations' }
  ],
  'AI/ML': [
    { name: 'Data Upload', hours: 20, description: 'Import training data' },
    { name: 'Model Training', hours: 40, description: 'Train AI models' },
    { name: 'API Endpoint', hours: 25, description: 'Deploy model API' },
    { name: 'Model Monitoring', hours: 30, description: 'Track performance' },
    { name: 'Data Visualization', hours: 25, description: 'Visualize results' },
    { name: 'A/B Testing', hours: 30, description: 'Test model versions' },
    { name: 'AutoML', hours: 45, description: 'Automated model selection' },
    { name: 'Data Preprocessing', hours: 25, description: 'Clean and prepare data' },
    { name: 'Model Explainability', hours: 35, description: 'Understand predictions' },
    { name: 'Batch Processing', hours: 30, description: 'Process large datasets' }
  ],
  'Real Estate Tech': [
    { name: 'Property Listings', hours: 25, description: 'Browse properties' },
    { name: 'Search & Filters', hours: 30, description: 'Find perfect property' },
    { name: 'Virtual Tours', hours: 35, description: '3D property walkthroughs' },
    { name: 'Agent Matching', hours: 25, description: 'Connect with agents' },
    { name: 'Mortgage Calculator', hours: 20, description: 'Calculate payments' },
    { name: 'Document Management', hours: 30, description: 'Store contracts and docs' },
    { name: 'Scheduling', hours: 20, description: 'Book property viewings' },
    { name: 'Market Analytics', hours: 30, description: 'Pricing insights' },
    { name: 'Offer Management', hours: 25, description: 'Submit and track offers' },
    { name: 'Neighborhood Info', hours: 25, description: 'Area demographics' }
  ],
  'EdTech': [
    { name: 'Course Creation', hours: 30, description: 'Build online courses' },
    { name: 'Video Player', hours: 25, description: 'Stream lessons' },
    { name: 'Assessments', hours: 30, description: 'Quizzes and tests' },
    { name: 'Progress Tracking', hours: 25, description: 'Monitor student progress' },
    { name: 'Discussion Forums', hours: 25, description: 'Student community' },
    { name: 'Grading System', hours: 30, description: 'Automated grading' },
    { name: 'Certificates', hours: 20, description: 'Issue completion certificates' },
    { name: 'Live Classes', hours: 35, description: 'Virtual classrooms' },
    { name: 'Assignment Submissions', hours: 25, description: 'Submit homework' },
    { name: 'Parent Dashboard', hours: 25, description: 'Parent monitoring' }
  ],
  'Food & Beverage Tech': [
    { name: 'Menu Management', hours: 25, description: 'Create and update menus' },
    { name: 'Online Ordering', hours: 30, description: 'Order food online' },
    { name: 'Delivery Tracking', hours: 30, description: 'Track order status' },
    { name: 'Reservations', hours: 25, description: 'Table booking system' },
    { name: 'Loyalty Program', hours: 25, description: 'Rewards for customers' },
    { name: 'Inventory Tracking', hours: 30, description: 'Track ingredients' },
    { name: 'Driver App', hours: 35, description: 'Delivery driver interface' },
    { name: 'Reviews & Ratings', hours: 20, description: 'Customer feedback' },
    { name: 'Restaurant Dashboard', hours: 30, description: 'Manage operations' }
  ],
  'CleanTech': [
    { name: 'Energy Monitoring', hours: 30, description: 'Track energy usage' },
    { name: 'Data Analytics', hours: 30, description: 'Analyze consumption patterns' },
    { name: 'Device Integration', hours: 35, description: 'Connect IoT devices' },
    { name: 'Alerts & Notifications', hours: 20, description: 'Usage alerts' },
    { name: 'Savings Calculator', hours: 25, description: 'Calculate cost savings' },
    { name: 'Reporting', hours: 25, description: 'Generate energy reports' },
    { name: 'Carbon Tracking', hours: 30, description: 'Track carbon footprint' },
    { name: 'Smart Scheduling', hours: 30, description: 'Optimize energy usage' },
    { name: 'Mobile App', hours: 35, description: 'Control from anywhere' },
    { name: 'Multi-site Management', hours: 30, description: 'Manage multiple locations' }
  ],
  'Media & Entertainment': [
    { name: 'Content Upload', hours: 25, description: 'Upload videos/audio' },
    { name: 'Streaming Player', hours: 35, description: 'Video/audio playback' },
    { name: 'User Profiles', hours: 20, description: 'Personalized accounts' },
    { name: 'Recommendations', hours: 35, description: 'AI content suggestions' },
    { name: 'Search & Discovery', hours: 30, description: 'Find content' },
    { name: 'Social Features', hours: 30, description: 'Comments, likes, shares' },
    { name: 'Subscriptions', hours: 30, description: 'Premium memberships' },
    { name: 'Content Moderation', hours: 25, description: 'Review user content' },
    { name: 'Analytics Dashboard', hours: 30, description: 'Creator insights' },
    { name: 'Live Streaming', hours: 40, description: 'Broadcast live content' }
  ]
};

// Production Platform Components
const PLATFORM_FEATURES = [
  { name: 'Advanced Authentication', hours: 30, cost: 8000, description: 'OAuth, SSO, 2FA' },
  { name: 'Real-time Sync', hours: 40, cost: 12000, description: 'WebSocket infrastructure' },
  { name: 'Advanced Analytics', hours: 35, cost: 10000, description: 'Custom dashboards & reports' },
  { name: 'API Rate Limiting', hours: 25, cost: 6000, description: 'Protect against abuse' },
  { name: 'Caching Layer', hours: 30, cost: 7000, description: 'Redis/Memcached' },
  { name: 'Search Engine', hours: 40, cost: 15000, description: 'Elasticsearch integration' },
  { name: 'File Storage', hours: 25, cost: 5000, description: 'S3/cloud storage' },
  { name: 'Email System', hours: 20, cost: 4000, description: 'Transactional emails' },
  { name: 'Push Notifications', hours: 25, cost: 6000, description: 'Mobile & web push' },
  { name: 'Admin Dashboard', hours: 35, cost: 9000, description: 'Internal tools' }
];

const PLATFORM_INFRASTRUCTURE = [
  { name: 'Database (PostgreSQL)', hours: 30, cost: 10000, description: 'Production database setup' },
  { name: 'CDN Setup', hours: 20, cost: 5000, description: 'CloudFlare/AWS CloudFront' },
  { name: 'Load Balancer', hours: 25, cost: 8000, description: 'Distribute traffic' },
  { name: 'Monitoring & Logging', hours: 30, cost: 7000, description: 'DataDog/New Relic' },
  { name: 'CI/CD Pipeline', hours: 35, cost: 9000, description: 'Automated deployments' },
  { name: 'Backup System', hours: 25, cost: 6000, description: 'Automated backups' },
  { name: 'Security Scanning', hours: 20, cost: 5000, description: 'Vulnerability detection' },
  { name: 'SSL/TLS Setup', hours: 15, cost: 3000, description: 'HTTPS certificates' },
  { name: 'Auto-scaling', hours: 40, cost: 12000, description: 'Scale with traffic' },
  { name: 'Redis Cache', hours: 20, cost: 4000, description: 'In-memory caching' }
];

// LLC State Filing Fees (2024 accurate data)
const LLC_STATE_FEES = {
  'Delaware': { fee: 90, annualTax: 300, processingTime: '1-2 weeks' },
  'Wyoming': { fee: 100, annualTax: 60, processingTime: '1-2 weeks' },
  'Nevada': { fee: 425, annualTax: 350, processingTime: '1-2 weeks' },
  'California': { fee: 70, annualTax: 800, processingTime: '2-3 weeks' },
  'New York': { fee: 200, annualTax: 25, processingTime: '2-3 weeks' },
  'Texas': { fee: 300, annualTax: 0, processingTime: '1-2 weeks' },
  'Florida': { fee: 125, annualTax: 138, processingTime: '1-2 weeks' },
  'Colorado': { fee: 50, annualTax: 10, processingTime: '1-2 weeks' }
};

// Strupe (Stripe) Pricing - Accurate as of 2024
const STREEP_PRICING = {
  standard: {
    name: 'Standard',
    transactionFee: 2.9,
    flatFee: 0.30,
    monthlyFee: 0,
    description: 'Simple pricing for online payments'
  },
  plus: {
    name: 'Plus',
    transactionFee: 2.7,
    flatFee: 0.30,
    monthlyFee: 30,
    description: 'Lower rates with automated sales tax'
  }
};

const DEPARTMENTS = ['Engineering', 'Sales', 'Marketing', 'Product', 'Finance', 'Operations', 'HR', 'Customer Success'];

const POSITIONS = {
  'Engineering': ['CTO', 'VP Engineering', 'Engineering Manager', 'Senior Engineer', 'Engineer', 'Junior Engineer'],
  'Sales': ['CRO', 'VP Sales', 'Sales Director', 'Sales Manager', 'Account Executive', 'SDR'],
  'Marketing': ['CMO', 'VP Marketing', 'Marketing Director', 'Content Lead', 'Marketing Manager', 'Marketing Coordinator'],
  'Product': ['CPO', 'VP Product', 'Product Director', 'Senior PM', 'Product Manager', 'Associate PM'],
  'Finance': ['CFO', 'VP Finance', 'Controller', 'Finance Manager', 'Financial Analyst'],
  'Operations': ['COO', 'VP Operations', 'Operations Director', 'Operations Manager', 'Operations Coordinator'],
  'HR': ['CHRO', 'VP HR', 'HR Director', 'HR Manager', 'HR Coordinator', 'Recruiter'],
  'Customer Success': ['VP CS', 'CS Director', 'CS Manager', 'CSM', 'Support Engineer']
};

const COMPANIES_TO_INVEST = [
  { name: 'DataBot AI', stage: 'Series A', valuation: 45, growth: 0.15 },
  { name: 'CloudScale', stage: 'Series B', valuation: 180, growth: 0.12 },
  { name: 'FinTrust', stage: 'Seed', valuation: 12, growth: 0.25 },
  { name: 'HealthML', stage: 'Series A', valuation: 60, growth: 0.18 },
  { name: 'LogiChain', stage: 'Series C', valuation: 500, growth: 0.08 }
];

const STOCK_TICKERS = [
  { ticker: 'AAPL', name: 'Apple Inc.', price: 178.23, change: 0.012 },
  { ticker: 'MSFT', name: 'Microsoft Corp.', price: 412.45, change: -0.008 },
  { ticker: 'GOOGL', name: 'Alphabet Inc.', price: 142.89, change: 0.015 },
  { ticker: 'AMZN', name: 'Amazon.com Inc.', price: 175.32, change: 0.022 },
  { ticker: 'NVDA', name: 'NVIDIA Corp.', price: 875.67, change: 0.035 },
  { ticker: 'META', name: 'Meta Platforms', price: 487.21, change: -0.012 },
  { ticker: 'TSLA', name: 'Tesla Inc.', price: 245.78, change: 0.018 },
  { ticker: 'BRK.B', name: 'Berkshire Hathaway', price: 412.90, change: 0.005 },
  { ticker: 'JPM', name: 'JPMorgan Chase', price: 189.45, change: -0.003 },
  { ticker: 'V', name: 'Visa Inc.', price: 267.32, change: 0.009 }
];

// Isometric Office Component
const IsometricOffice = ({ office, employees, startupName, startupLogo }) => {
  const officeConfigs = {
    'Basement': { width: 400, height: 300, desks: 1, color: '#8B7355' },
    'Co-working Space': { width: 500, height: 350, desks: 3, color: '#94A3B8' },
    'Small Office': { width: 600, height: 400, desks: 6, color: '#60A5FA' },
    'Medium Office': { width: 700, height: 450, desks: 12, color: '#34D399' },
    'Large Office': { width: 800, height: 500, desks: 20, color: '#F59E0B' },
    'Headquarters': { width: 900, height: 550, desks: 30, color: '#A78BFA' }
  };

  const config = officeConfigs[office];
  const employeeCount = Math.min(employees.length, config.desks);

  return (
    <div style={{
      width: '100%',
      maxWidth: '100%',
      height: 'calc(100vh - 60px)',
      background: 'linear-gradient(135deg, #FFF8DC 0%, #F5DEB3 100%)',
      borderRadius: '0',
      position: 'relative',
      overflow: 'hidden',
      border: 'none',
      boxShadow: 'none'
    }}>
      {/* Office Floor */}
      <svg width="100%" height="100%" viewBox="0 0 900 550" style={{ position: 'absolute' }}>
        {/* Floor */}
        <path
          d="M 100 400 L 450 200 L 800 400 L 450 550 Z"
          fill="#D2691E"
          stroke="#8B4513"
          strokeWidth="3"
        />
        
        {/* Floor pattern */}
        {[...Array(8)].map((_, i) => (
          <line
            key={`floor-line-${i}`}
            x1={150 + i * 80}
            y1={400 - i * 25}
            x2={450}
            y2={550 - i * 25}
            stroke="#A0522D"
            strokeWidth="1"
            opacity="0.3"
          />
        ))}

        {/* Back Wall */}
        <path
          d="M 100 400 L 450 200 L 800 400 L 800 250 L 450 50 L 100 250 Z"
          fill={config.color}
          stroke="#333"
          strokeWidth="2"
          opacity="0.9"
        />

        {/* Company Name on Wall */}
        {startupName && (
          <g>
            <rect
              x="350"
              y="120"
              width="200"
              height="60"
              fill="#fff"
              stroke="#333"
              strokeWidth="2"
              rx="5"
            />
            <text
              x="450"
              y="155"
              fontSize="24"
              fontWeight="700"
              fill="#1e293b"
              textAnchor="middle"
            >
              {startupLogo?.icon} {startupName}
            </text>
          </g>
        )}

        {/* Desks and Employees */}
        {[...Array(employeeCount)].map((_, i) => {
          const row = Math.floor(i / 3);
          const col = i % 3;
          const baseX = 250 + col * 120 - row * 60;
          const baseY = 350 + col * 50 + row * 60;
          const employee = employees[i];

          return (
            <g key={`desk-${i}`}>
              {/* Desk */}
              <path
                d={`M ${baseX - 40} ${baseY} 
                    L ${baseX + 40} ${baseY} 
                    L ${baseX + 50} ${baseY + 20} 
                    L ${baseX - 30} ${baseY + 20} Z`}
                fill="#8B4513"
                stroke="#654321"
                strokeWidth="2"
              />
              
              {/* Computer Monitor */}
              <rect
                x={baseX - 15}
                y={baseY - 25}
                width="30"
                height="20"
                fill="#1e293b"
                stroke="#334155"
                strokeWidth="1"
                rx="2"
              />
              <rect
                x={baseX - 12}
                y={baseY - 22}
                width="24"
                height="16"
                fill="#3b82f6"
                opacity="0.8"
              />

              {/* Employee Character */}
              <g transform={`translate(${baseX - 30}, ${baseY - 10})`}>
                {/* Head */}
                <circle
                  cx="0"
                  cy="-15"
                  r="8"
                  fill={['#FFD7A8', '#C68642', '#8D5524', '#F5CBA7'][i % 4]}
                />
                {/* Body */}
                <path
                  d="M -6 -7 L -8 10 L -3 10 L 3 10 L 8 10 L 6 -7 Z"
                  fill={['#3b82f6', '#10b981', '#f59e0b', '#ec4899', '#8b5cf6'][i % 5]}
                />
                {/* Arms */}
                <line x1="-6" y1="-5" x2="-12" y2="0" stroke="#333" strokeWidth="2" />
                <line x1="6" y1="-5" x2="12" y2="0" stroke="#333" strokeWidth="2" />
              </g>

              {/* Employee Name Label */}
              {employee && (
                <text
                  x={baseX}
                  y={baseY + 35}
                  fontSize="8"
                  fill="#1e293b"
                  textAnchor="middle"
                  fontWeight="600"
                >
                  {employee.name?.split(' ')[0]}
                </text>
              )}
            </g>
          );
        })}

        {/* Founder's Personal Workspace (always visible) */}
        <g>
          {/* Founder's Desk - in the corner */}
          <path
            d="M 650 420 L 730 420 L 740 440 L 640 440 Z"
            fill="#8B4513"
            stroke="#654321"
            strokeWidth="2"
          />
          
          {/* Laptop */}
          <rect
            x="675"
            y="395"
            width="35"
            height="20"
            fill="#333"
            stroke="#1e293b"
            strokeWidth="1"
            rx="2"
          />
          <rect
            x="678"
            y="398"
            width="29"
            height="14"
            fill="#3b82f6"
            opacity="0.9"
          />
          
          {/* Coffee Cup */}
          <ellipse cx="720" cy="425" rx="6" ry="4" fill="#8B4513" />
          <rect x="717" y="415" width="6" height="10" fill="#D2691E" stroke="#8B4513" strokeWidth="1" />
          
          {/* Founder (User) Character */}
          <g transform="translate(620, 415)">
            {/* Head */}
            <circle cx="0" cy="-15" r="10" fill="#FFD7A8" />
            {/* Body */}
            <path
              d="M -7 -5 L -9 15 L -4 15 L 4 15 L 9 15 L 7 -5 Z"
              fill="#1e293b"
            />
            {/* Arms */}
            <line x1="-7" y1="-3" x2="-15" y2="3" stroke="#1e293b" strokeWidth="2.5" />
            <line x1="7" y1="-3" x2="15" y2="3" stroke="#1e293b" strokeWidth="2.5" />
            {/* Label */}
            <text x="0" y="35" fontSize="9" fill="#fff" textAnchor="middle" fontWeight="700">
              You
            </text>
          </g>
        </g>

        {/* Basement/Garage Items */}
        {office === 'Basement' && (
          <>
            {/* Bike 1 */}
            <g transform="translate(180, 460)">
              {/* Wheels */}
              <circle cx="0" cy="0" r="12" fill="none" stroke="#333" strokeWidth="2" />
              <circle cx="35" cy="0" r="12" fill="none" stroke="#333" strokeWidth="2" />
              {/* Frame */}
              <path
                d="M 0 0 L 17 -15 L 35 0"
                fill="none"
                stroke="#DC143C"
                strokeWidth="3"
              />
              <line x1="17" y1="-15" x2="17" y2="0" stroke="#DC143C" strokeWidth="2" />
              {/* Handlebars */}
              <line x1="17" y1="-15" x2="15" y2="-22" stroke="#333" strokeWidth="2" />
              <line x1="12" y1="-22" x2="18" y2="-22" stroke="#333" strokeWidth="2" />
              {/* Seat */}
              <ellipse cx="25" cy="-8" rx="6" ry="3" fill="#654321" />
            </g>
            
            {/* Bike 2 */}
            <g transform="translate(240, 475)">
              {/* Wheels */}
              <circle cx="0" cy="0" r="11" fill="none" stroke="#333" strokeWidth="2" />
              <circle cx="32" cy="0" r="11" fill="none" stroke="#333" strokeWidth="2" />
              {/* Frame */}
              <path
                d="M 0 0 L 16 -13 L 32 0"
                fill="none"
                stroke="#1E90FF"
                strokeWidth="3"
              />
              <line x1="16" y1="-13" x2="16" y2="0" stroke="#1E90FF" strokeWidth="2" />
              {/* Handlebars */}
              <line x1="16" y1="-13" x2="14" y2="-19" stroke="#333" strokeWidth="2" />
              {/* Seat */}
              <ellipse cx="23" cy="-7" rx="5" ry="3" fill="#654321" />
            </g>
            
            {/* Car in garage */}
            <g transform="translate(550, 500)">
              {/* Car Body */}
              <path
                d="M 0 0 L 100 0 L 110 -10 L 110 -25 L 90 -40 L 30 -40 L 10 -25 L 10 -10 Z"
                fill="#2C3E50"
                stroke="#1a252f"
                strokeWidth="2"
              />
              {/* Windows */}
              <path
                d="M 25 -26 L 40 -35 L 70 -35 L 85 -26 L 85 -15 L 25 -15 Z"
                fill="#87CEEB"
                opacity="0.6"
                stroke="#333"
                strokeWidth="1"
              />
              {/* Wheels */}
              <circle cx="20" cy="0" r="8" fill="#333" stroke="#000" strokeWidth="2" />
              <circle cx="20" cy="0" r="4" fill="#666" />
              <circle cx="90" cy="0" r="8" fill="#333" stroke="#000" strokeWidth="2" />
              <circle cx="90" cy="0" r="4" fill="#666" />
              {/* Headlight */}
              <rect x="108" y="-8" width="3" height="5" fill="#FFFF00" opacity="0.8" />
            </g>
            
            {/* Storage Boxes */}
            <rect x="130" y="480" width="30" height="25" fill="#8B7355" stroke="#654321" strokeWidth="2" />
            <rect x="135" y="455" width="25" height="20" fill="#A0826D" stroke="#654321" strokeWidth="1" />
            
            {/* Tool Board on Wall */}
            <rect x="680" y="280" width="60" height="80" fill="#654321" stroke="#333" strokeWidth="2" />
            <line x1="685" y1="290" x2="720" y2="290" stroke="#999" strokeWidth="3" />
            <line x1="685" y1="310" x2="710" y2="310" stroke="#999" strokeWidth="3" />
            <circle cx="700" cy="330" r="8" fill="none" stroke="#999" strokeWidth="2" />
          </>
        )}

        {/* Office Decorations */}
        {office !== 'Basement' && (
          <>
            {/* Window */}
            <rect x="150" y="280" width="80" height="60" fill="#87CEEB" stroke="#333" strokeWidth="2" />
            <line x1="190" y1="280" x2="190" y2="340" stroke="#333" strokeWidth="2" />
            <line x1="150" y1="310" x2="230" y2="310" stroke="#333" strokeWidth="2" />
          </>
        )}

        {office === 'Headquarters' && (
          <>
            {/* Trophy Case */}
            <rect x="700" y="320" width="60" height="50" fill="#FFD700" stroke="#DAA520" strokeWidth="2" />
            <text x="730" y="350" fontSize="24">🏆</text>
          </>
        )}

        {/* Plant in corner */}
        <ellipse cx="120" cy="420" rx="15" ry="8" fill="#228B22" />
        <circle cx="120" cy="410" r="12" fill="#32CD32" />
        <circle cx="115" cy="405" r="8" fill="#00FF00" />
        <circle cx="125" cy="405" r="8" fill="#00FF00" />
      </svg>

      {/* Office Label */}
      <div style={{
        position: 'absolute',
        bottom: '20px',
        left: '20px',
        background: 'rgba(30, 41, 59, 0.9)',
        padding: '0.75rem 1.5rem',
        borderRadius: '0.5rem',
        border: '2px solid #3b82f6',
        color: '#fff',
        fontWeight: '700',
        fontSize: '1rem'
      }}>
        {office} • {employeeCount} / {config.desks} desks
      </div>
    </div>
  );
};

export default function StartupTycoon() {
  // Start date: January 1, 2026
  const [currentDate, setCurrentDate] = useState(new Date(2026, 0, 1));
  const [gameWeek, setGameWeek] = useState(1); // Keep for backward compatibility
  const [gameHour, setGameHour] = useState(16); // Start at 4:00pm (16:00)
  const [gameMinute, setGameMinute] = useState(0);
  const [gameSpeed, setGameSpeed] = useState(1); // 1x speed: 1 game hour = 1 real minute
  const [isPaused, setIsPaused] = useState(false);
  
  // LinkedInOut states
  const [linkedInOutFollowers, setLinkedInOutFollowers] = useState(0);
  const [linkedInOutPosts, setLinkedInOutPosts] = useState([]);
  const [showLinkedInOut, setShowLinkedInOut] = useState(false);
  
  // Real-time clock system (1 game hour = 1 real minute)
  const [gameHour, setGameHour] = useState(16); // Start at 4:00pm (employed) or 8:00am (unemployed)
  const [gameMinute, setGameMinute] = useState(0);
  const [gameSpeed, setGameSpeed] = useState(1); // 1x, 2x, 4x speed multiplier
  const [isPaused, setIsPaused] = useState(false);
  
  // LinkedInOut social media system
  const [linkedInOut, setLinkedInOut] = useState({
    hasAccount: false,
    followers: 0,
    posts: [],
    weeklyImpressions: 0,
    inboundLeads: 0
  });
  const [activeTab, setActiveTab] = useState('job');
  const [activePanel, setActivePanel] = useState(null); // For Game Dev Tycoon style panels: 'mvp', 'sales', 'team', 'money', etc.
  
  // Personal finances
  const [personalCash, setPersonalCash] = useState(0); // Start with nothing
  const [personalCashFlow, setPersonalCashFlow] = useState(0); // Monthly cash flow rate
  const [personalLoans, setPersonalLoans] = useState([]);
  const [stockPortfolio, setStockPortfolio] = useState([]);
  
  // Job state
  const [founderType, setFounderType] = useState(null); // 'Technical' or 'Non-Technical'
  const [currentJob, setCurrentJob] = useState(null);
  const [jobBonus, setJobBonus] = useState(null); // Stores the bonus from your job background
  const [jobLevel, setJobLevel] = useState(0);
  const [weeksInCurrentRole, setWeeksInCurrentRole] = useState(0);
  const [grossMonthlyIncome, setGrossMonthlyIncome] = useState(0); // Before taxes
  const [netMonthlyIncome, setNetMonthlyIncome] = useState(0); // After taxes
  
  // Startup state
  const [hasStartup, setHasStartup] = useState(false);
  const [startupName, setStartupName] = useState('');
  const [startupIdea, setStartupIdea] = useState(null);
  const [startupLogo, setStartupLogo] = useState(null);
  const [businessCash, setBusinessCash] = useState(0);
  const [businessCashFlow, setBusinessCashFlow] = useState(0); // Monthly cash flow rate (revenue - burn)
  const [overdraftFees, setOverdraftFees] = useState(0); // Accumulated overdraft fees
  
  // Startup milestones/checklist
  const [currentMilestone, setCurrentMilestone] = useState('Delusional Founder');
  const [checklistItems, setChecklistItems] = useState({
    mvpBuilt: false,
    llcSetup: false,
    socialMediaSetup: false,
    strupeSetup: false,
    researchCompleted: false
  });
  
  // In-game websites and timers
  const [showLLCWebsite, setShowLLCWebsite] = useState(false);
  const [showStrupeWebsite, setShowStrupeWebsite] = useState(false);
  const [activeTimers, setActiveTimers] = useState([]); // Array of {id, name, hoursRemaining, totalHours, onComplete}
  const [researchProgress, setResearchProgress] = useState(0); // 0-100 for research timer
  
  const [arr, setArr] = useState(0);
  const [fundingStage, setFundingStage] = useState('Bootstrapped');
  const [businessLoans, setBusinessLoans] = useState([]);
  const [mvpBuilt, setMvpBuilt] = useState(false);
  const [hasNoCodePlatform, setHasNoCodePlatform] = useState(false);
  const [noCodeMonthlyCost, setNoCodeMonthlyCost] = useState(0); // $200 base + AI tokens
  const [pricing, setPricing] = useState(99);
  const [customers, setCustomers] = useState([]); // Array of customer objects
  const [office, setOffice] = useState('Basement');
  
  // Startup Progression & Checklist
  const [startupLevel, setStartupLevel] = useState('Delusional Founder');
  const [completedTasks, setCompletedTasks] = useState({});
  const [hasLLC, setHasLLC] = useState(false);
  const [hasSocialMedia, setHasSocialMedia] = useState(false);
  const [hasStrupe, setHasStrupe] = useState(false);
  const [hasResearched, setHasResearched] = useState(false);
  const [hasBankAccount, setHasBankAccount] = useState(false);
  const [hasAccounting, setHasAccounting] = useState(false);
  
  // MVP Creation Process
  const [mvpInProgress, setMvpInProgress] = useState(false);
  const [mvpProgress, setMvpProgress] = useState(0);
  const [mvpChoices, setMvpChoices] = useState({
    ui: null,      // 'Basic', 'Modern', 'Custom'
    infrastructure: null, // 'Hosted', 'Cloud', 'Serverless'
    database: null, // 'Simple', 'Relational', 'NoSQL'
    features: []   // Array of features to build
  });
  
  // Feature-based MVP building
  const [selectedFeatures, setSelectedFeatures] = useState([]); // Features user chose to build
  const [builtFeatures, setBuiltFeatures] = useState([]); // Completed features
  
  // Debug logging for state changes
  useEffect(() => {
    console.log('🔄 STATE UPDATE - selectedFeatures:', selectedFeatures.length, selectedFeatures.map(f => f.name));
    console.log('🔄 STATE UPDATE - builtFeatures:', builtFeatures.length, builtFeatures.map(f => f.name));
  }, [selectedFeatures, builtFeatures]);
  
  // Research timer: 1 real minute = 1 game hour
  useEffect(() => {
    if (researchProgress > 0 && researchProgress < 100) {
      const interval = setInterval(() => {
        setResearchProgress(prev => {
          const newProgress = prev + (100 / 4); // 4 hours total = 4 minutes = 25% per minute
          if (newProgress >= 100) {
            setChecklistItems(prevItems => ({ ...prevItems, researchCompleted: true }));
            setTimeout(checkMilestoneComplete, 100);
            alert('✅ Research Complete!\n\nYou now understand the fundamentals of starting a business.');
            return 100;
          }
          return newProgress;
        });
      }, 60000); // Every 60 seconds (1 real minute)
      
      return () => clearInterval(interval);
    }
  }, [researchProgress]);
  
  // Real-time clock progression: 1 game hour = 1 real minute
  useEffect(() => {
    if (isPaused) return;
    
    const interval = setInterval(() => {
      setGameMinute(prev => {
        if (prev >= 59) {
          // Hour completed, advance hour
          setGameHour(prevHour => {
            let newHour = prevHour + 1;
            
            // Handle day transitions
            if (newHour >= 24) {
              newHour = 0;
              // Advance date
              setCurrentDate(prevDate => {
                const newDate = new Date(prevDate);
                newDate.setDate(newDate.getDate() + 1);
                return newDate;
              });
            }
            
            // Work hours check (employed: 4pm-12am, unemployed: 8am-12pm)
            const workStart = currentJob ? 16 : 8;
            const workEnd = currentJob ? 24 : 12;
            
            // Auto-pause outside work hours if employed
            if (currentJob && (newHour < workStart || newHour >= workEnd)) {
              // Skip to next work day
              if (newHour >= workEnd && newHour < 16) {
                setGameHour(16);
                setGameMinute(0);
                return 16;
              }
            }
            
            return newHour;
          });
          return 0;
        }
        return prev + 1;
      });
    }, 60000 / gameSpeed); // Adjust speed based on multiplier
    
    return () => clearInterval(interval);
  }, [isPaused, gameSpeed, currentJob]);
  
  const [currentFeatureInProgress, setCurrentFeatureInProgress] = useState(null);
  const [featureProgress, setFeatureProgress] = useState(0);
  const completingFeatureRef = useRef(null); // Track which feature is completing to prevent double-adds
  const selectedFeaturesCountRef = useRef(0); // Store the count of originally selected features
  
  // Pre-signups (potential customers who commit before launch)
  const [preSignups, setPreSignups] = useState([]);
  const [potentialCustomers, setPotentialCustomers] = useState([]); // 150+ leads that become prospects
  const [targetPreSignups, setTargetPreSignups] = useState(10); // Need 10 to launch
  
  // Awareness & Hype
  const [awareness, setAwareness] = useState(0); // 0-100%, how many people know about your product
  const [hype, setHype] = useState(0); // 0-100%, excitement level
  const [emailList, setEmailList] = useState(0); // Number of email subscribers
  
  // Feature complexity and bugs
  const [featureBugs, setFeatureBugs] = useState([]); // Bugs discovered in features
  
  // Beta Testing Phase
  const [inBetaTesting, setInBetaTesting] = useState(false);
  const [betaTesters, setBetaTesters] = useState([]);
  const [betaFeedback, setBetaFeedback] = useState([]);
  
  // Production Platform Builder (after MVP)
  const [platformBuilt, setPlatformBuilt] = useState(false);
  const [platformFeatures, setPlatformFeatures] = useState([]); // Production-ready features
  const [platformInfrastructure, setPlatformInfrastructure] = useState([]); // Infrastructure components
  const [currentPlatformItem, setCurrentPlatformItem] = useState(null);
  const [platformItemProgress, setPlatformItemProgress] = useState(0);
  
  // Products and market
  const [products, setProducts] = useState([]); // All products being developed/launched
  const [marketSaturation, setMarketSaturation] = useState(0); // 0-100%
  
  // Competitors
  const [competitors, setCompetitors] = useState([]);
  
  // Payment animation
  const [showPaymentAnimation, setShowPaymentAnimation] = useState(false);
  const [lastPaymentAmount, setLastPaymentAmount] = useState(0);
  
  // Time management - hours per week for business
  const [weeklyHoursAvailable, setWeeklyHoursAvailable] = useState(40); // 8 hours/day * 5 days if working full-time job
  const [weeklyHoursUsed, setWeeklyHoursUsed] = useState(0);
  const [prospectsContactedThisWeek, setProspectsContactedThisWeek] = useState(0);
  const [showTimeBreakdown, setShowTimeBreakdown] = useState(false);
  
  // Check if current milestone is complete
  const checkMilestoneComplete = () => {
    if (!checklistItems) return; // Safety check
    if (currentMilestone === 'Delusional Founder') {
      const allComplete = 
        checklistItems.mvpBuilt &&
        checklistItems?.llcSetup &&
        checklistItems?.socialMediaSetup &&
        checklistItems?.strupeSetup &&
        checklistItems?.researchCompleted;
      
      if (allComplete) {
        setCurrentMilestone('Pre-Revenue Founder');
        alert('🎉 Milestone Complete!\n\nYou\'ve graduated from "Delusional Founder" to "Pre-Revenue Founder"!\n\nNext goal: Get your first paying customer.');
      }
    }
  };
  
  // Calculate time breakdown
  const getTimeBreakdown = () => {
    const jobHours = currentJob ? 40 : 0; // 8 hours/day, 5 days/week
    const sleepHours = 56; // 8 hours/day, 7 days/week
    const personalHours = 21; // 3 hours/day for meals, hygiene, etc.
    const businessHours = weeklyHoursUsed;
    const freeTime = 168 - jobHours - sleepHours - personalHours - businessHours;
    
    return {
      job: jobHours,
      sleep: sleepHours,
      personal: personalHours,
      business: businessHours,
      free: Math.max(0, freeTime)
    };
  };
  
  // Quit job function
  const quitJob = () => {
    if (window.confirm('Are you sure you want to quit your job? You will no longer receive a salary, but you\'ll have 128 hours per week for your business.')) {
      setCurrentJob(null);
      setJobLevel(0);
      setGrossMonthlyIncome(0);
      setNetMonthlyIncome(0);
      setWeeksInCurrentRole(0);
      setWeeklyHoursAvailable(128); // 168 - 40 (sleep + personal)
    }
  };
  
  // Time management (40 hours per week for business while working full-time)
  const [hoursAvailable, setHoursAvailable] = useState(40); // Hours per week for business
  const [weeklyProspectsReached, setWeeklyProspectsReached] = useState(0);
  const MAX_PROSPECTS_PER_WEEK = 50;
  
  // Survey data
  const [surveys, setSurveys] = useState([]);
  const [productMarketFit, setProductMarketFit] = useState(0);
  
  // Sales pipeline
  const [prospects, setProspects] = useState([]); // All prospects in pipeline
  const [pipelineStages] = useState(['Outreach', 'Discovery', 'Demo', 'Negotiation', 'Closed Won', 'Closed Lost']);
  
  // Org chart
  const [employees, setEmployees] = useState([]);
  const [orgChart, setOrgChart] = useState({});
  
  // Hiring
  const [jobReqs, setJobReqs] = useState([]);
  const [applicants, setApplicants] = useState([]);
  
  // Marketing
  const [adCampaigns, setAdCampaigns] = useState([]);
  
  // Investments
  const [investments, setInvestments] = useState([]);
  
  // UI state
  const [showJobPicker, setShowJobPicker] = useState(!currentJob);
  const [showStartupCreator, setShowStartupCreator] = useState(false);
  const [selectedIndustry, setSelectedIndustry] = useState(null);
  const [showLoanModal, setShowLoanModal] = useState(false);
  const [showHireModal, setShowHireModal] = useState(false);
  const [showAdModal, setShowAdModal] = useState(false);
  const [showInvestModal, setShowInvestModal] = useState(false);
  const [showStockModal, setShowStockModal] = useState(false);
  const [showTransferModal, setShowTransferModal] = useState(false);

  // Generate names for applicants
  const generateName = () => {
    const first = ['Alex', 'Jamie', 'Morgan', 'Taylor', 'Jordan', 'Casey', 'Riley', 'Avery', 'Quinn', 'Parker'];
    const last = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez'];
    return `${first[Math.floor(Math.random() * first.length)]} ${last[Math.floor(Math.random() * last.length)]}`;
  };

  // Tax calculation (Federal ~22%, State ~5%, FICA ~7.65% = ~34.65% total)
  const calculateTaxes = (grossIncome) => {
    // Pre-tax deductions
    const retirement401k = grossIncome * 0.06; // 6% 401k contribution
    const healthInsurance = 300; // ~$300/month for individual health insurance
    
    const taxableIncome = grossIncome - retirement401k - healthInsurance;
    
    // Taxes on taxable income
    const federalTax = taxableIncome * 0.22;
    const stateTax = taxableIncome * 0.05;
    const ficaTax = taxableIncome * 0.0765;
    const totalTax = federalTax + stateTax + ficaTax;
    
    const afterTaxIncome = taxableIncome - totalTax;
    
    // Post-tax living expenses
    const rent = 1800; // Rent/mortgage
    const food = 500; // Groceries and eating out
    const utilities = 150; // Electric, internet, phone
    const transportation = 200; // Gas, car insurance, maintenance
    const misc = 300; // Entertainment, subscriptions, misc
    
    const totalLivingExpenses = rent + food + utilities + transportation + misc;
    const netSavings = afterTaxIncome - totalLivingExpenses;
    
    return {
      gross: grossIncome,
      retirement401k: retirement401k,
      healthInsurance: healthInsurance,
      federal: federalTax,
      state: stateTax,
      fica: ficaTax,
      totalTax: totalTax,
      afterTax: afterTaxIncome,
      livingExpenses: {
        rent: rent,
        food: food,
        utilities: utilities,
        transportation: transportation,
        misc: misc,
        total: totalLivingExpenses
      },
      net: netSavings // What actually goes to personal cash
    };
  };

  // Format date nicely
  const formatDate = (date) => {
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    return date.toLocaleDateString('en-US', options);
  };

  // Transfer money between accounts
  const transferMoney = (amount, direction) => {
    if (direction === 'toPersonal' && businessCash >= amount) {
      setBusinessCash(prev => prev - amount);
      setPersonalCash(prev => prev + amount);
    } else if (direction === 'toBusiness' && personalCash >= amount) {
      setPersonalCash(prev => prev - amount);
      setBusinessCash(prev => prev + amount);
    }
  };

  // Manual week advancement
  const advanceWeek = (weeksToAdvance = 1) => {
    const startWeek = gameWeek;
    const newWeek = gameWeek + weeksToAdvance;
    
    // Advance time
    setGameWeek(newWeek);
    setWeeksInCurrentRole(prev => prev + weeksToAdvance);
    
    // Advance date (7 days per week)
    const newDate = new Date(currentDate);
    newDate.setDate(newDate.getDate() + (7 * weeksToAdvance));
    setCurrentDate(newDate);
    
    // Process each week individually for certain events
    for (let week = startWeek + 1; week <= newWeek; week++) {
      // Pay from job (every 2 weeks = bi-weekly) - NET income after taxes
      if (currentJob && week % 2 === 0) {
        const biweeklyPay = netMonthlyIncome / 2; // Half of monthly income
        setPersonalCash(prev => prev + biweeklyPay);
        if (week === newWeek) { // Only show animation for the last payment
          setLastPaymentAmount(biweeklyPay);
          setShowPaymentAnimation(true);
          setTimeout(() => setShowPaymentAnimation(false), 3000);
        }
      }
      
      // Collect monthly revenue from customers (every 4 weeks)
      if (hasStartup && customers.length > 0 && week % 4 === 0) {
        const monthlyRevenue = customers.reduce((sum, c) => sum + c.monthlyValue, 0);
        setBusinessCash(prev => prev + monthlyRevenue);
      }
      
      // Deduct monthly no-code platform cost (every 4 weeks)
      if (hasStartup && hasNoCodePlatform && week % 4 === 0) {
        setBusinessCash(prev => prev - noCodeMonthlyCost);
      }
    }
    
    // Reset weekly hours and prospect limits
    setWeeklyHoursAvailable(currentJob ? 40 : 128); // 40 hours if working full-time, 128 if full-time on startup
    setWeeklyHoursUsed(0);
    setProspectsContactedThisWeek(0);
    
    // Advance feature building progress (for MVP)
    if (currentFeatureInProgress && !mvpBuilt) {
      // First, check if feature just completed (before updating progress)
      const shouldComplete = featureProgress >= 95 && featureProgress < 100;
      
      if (shouldComplete) {
        const feature = currentFeatureInProgress;
        
        // Prevent double-completion
        if (completingFeatureRef.current !== feature.name) {
          completingFeatureRef.current = feature.name;
          console.log('🎯 Feature completing:', feature.name);
          
          // Add to built features
          setBuiltFeatures(prevBuilt => {
            if (prevBuilt.some(bf => bf.name === feature.name)) {
              console.log('⚠️ Feature already in array, skipping');
              return prevBuilt;
            }
            
            const newBuilt = [...prevBuilt, feature];
            console.log('✅ ADDED FEATURE:', feature.name);
            console.log('📊 TOTAL BUILT:', newBuilt.length, 'of', selectedFeaturesCountRef.current);
            console.log('📋 BUILT FEATURES:', newBuilt.map(f => f.name).join(', '));
            
            // Check completion inline using the ref (not stale selectedFeatures)
            // Only trigger if: (1) ref is set, (2) we met the goal, (3) we have at least 3 features
            if (selectedFeaturesCountRef.current > 0 && 
                newBuilt.length >= selectedFeaturesCountRef.current && 
                newBuilt.length >= 3) {
              console.log('🎉 ALL FEATURES COMPLETE!');
              setTimeout(() => {
                setFeatureBugs(currentBugs => {
                  const unfixedBugs = currentBugs.filter(b => !b.fixed && (b.severity === 'Critical' || b.severity === 'High')).length;
                  if (unfixedBugs > 0) {
                    alert(`All ${newBuilt.length} features complete! But you have ${unfixedBugs} critical/high bugs to fix before gathering pre-signups.`);
                  } else {
                    alert('All features complete and stable! Now start gathering pre-signups from potential customers.');
                    generatePotentialCustomers();
                  }
                  return currentBugs;
                });
              }, 100);
            }
            
            return newBuilt;
          });
          
          // Generate bugs
          const complexity = feature.hours / 20;
          const bugCount = Math.floor(Math.random() * complexity) + Math.floor(complexity);
          
          if (bugCount > 0) {
            const newBugs = [];
            for (let i = 0; i < bugCount; i++) {
              newBugs.push({
                id: Date.now() + i,
                feature: feature.name,
                severity: ['Critical', 'High', 'Medium', 'Low'][Math.floor(Math.random() * 4)],
                description: [
                  'Crashes under load',
                  'Data loss issue',
                  'Security vulnerability',
                  'Performance bottleneck',
                  'UI breaks on mobile',
                  'Integration fails',
                  'Memory leak detected',
                  'Race condition'
                ][Math.floor(Math.random() * 8)],
                discovered: gameWeek,
                fixed: false
              });
            }
            setFeatureBugs(prev => [...prev, ...newBugs]);
            alert(`⚠️ Feature "${feature.name}" complete! But ${bugCount} bug(s) discovered.`);
          } else {
            alert(`✅ Feature "${feature.name}" complete!`);
          }
          
          // Reset for next feature
          setCurrentFeatureInProgress(null);
          setFeatureProgress(0);
          completingFeatureRef.current = null;
        }
      }
      
      // Then update progress
      setFeatureProgress(prev => {
        let weeklyProgress = 5; // Base 5% per week
        
        // Apply development bonus if founder has it
        if (jobBonus && jobBonus.type === 'development') {
          weeklyProgress = weeklyProgress * (1 + jobBonus.value);
        }
        
        const newProgress = Math.min(prev + weeklyProgress, 100);
        return newProgress;
      });
    }
    
    // Advance platform building progress (for production platform)
    if (currentPlatformItem && mvpBuilt && !platformBuilt) {
      setPlatformItemProgress(prev => {
        let weeklyProgress = 5; // Base 5% per week
        
        // Apply development bonus if founder has it
        if (jobBonus && jobBonus.type === 'development') {
          weeklyProgress = weeklyProgress * (1 + jobBonus.value);
        }
        
        const newProgress = prev + weeklyProgress;
        
        if (newProgress >= 100) {
          const item = currentPlatformItem;
          console.log('Platform item completing:', item.name, item.type);
          
          // Add to appropriate list
          if (item.type === 'feature') {
            setPlatformFeatures(prevFeats => {
              if (prevFeats.some(f => f.name === item.name)) {
                return prevFeats;
              }
              const newFeats = [...prevFeats, item];
              console.log('Platform features:', newFeats.length, 'of', PLATFORM_FEATURES.length);
              return newFeats;
            });
          } else {
            setPlatformInfrastructure(prevInfra => {
              if (prevInfra.some(i => i.name === item.name)) {
                return prevInfra;
              }
              const newInfra = [...prevInfra, item];
              console.log('Platform infrastructure:', newInfra.length, 'of', PLATFORM_INFRASTRUCTURE.length);
              return newInfra;
            });
          }
          
          alert(`✅ ${item.name} complete!`);
          setCurrentPlatformItem(null);
          
          return 0;
        }
        
        return newProgress;
      });
    }
    
    // Advance prospects through sales stages (each stage takes 1-2 weeks)
    if (hasStartup && prospects.length > 0) {
      setProspects(prev => prev.map(prospect => {
        // Don't advance closed deals
        if (prospect.stage === 'Closed Won' || prospect.stage === 'Closed Lost') {
          return prospect;
        }
        
        // Check if prospect should advance (randomly, simulating time passing)
        const weeksSinceLastUpdate = newWeek - prospect.lastUpdated;
        const shouldAdvance = weeksSinceLastUpdate >= 2; // Advance every 2 weeks
        
        if (shouldAdvance) {
          const currentIndex = pipelineStages.indexOf(prospect.stage);
          
          // Random chance to lose the deal at each stage
          let loseChance = currentIndex === 0 ? 0.3 : currentIndex === 1 ? 0.35 : currentIndex === 2 ? 0.4 : 0.45;
          
          // Apply job bonuses to reduce loss chance
          if (jobBonus) {
            // Closing bonus applies to all stages
            if (jobBonus.type === 'closing') {
              loseChance = loseChance * (1 - jobBonus.value); // 10% better = 10% lower loss rate
            }
            // Demo bonus applies specifically to Demo stage (index 2)
            if (jobBonus.type === 'demo' && currentIndex === 2) {
              loseChance = loseChance * (1 - jobBonus.value); // 10% better demo conversion
            }
          }
          
          if (Math.random() < loseChance) {
            const rejectionMessage = getRejectionMessage(prospect.stage);
            return { 
              ...prospect, 
              stage: 'Closed Lost', 
              lastUpdated: newWeek,
              rejectionReason: rejectionMessage
            };
          }
          
          const nextStage = pipelineStages[currentIndex + 1];
          
          // If closing the deal, convert to customer
          if (nextStage === 'Closed Won') {
            const newCustomer = {
              id: prospect.id,
              company: prospect.company,
              contact: prospect.contact,
              contractValue: prospect.contractValue,
              monthlyValue: prospect.monthlyValue,
              startWeek: newWeek,
              renewalWeek: newWeek + 52,
              churnRisk: 'Low',
              totalRevenue: 0,
              acquisitionChannel: prospect.acquisitionChannel,
              productMaturity: prospect.productMaturity
            };
            setCustomers(prev => [...prev, newCustomer]);
            setArr(prev => prev + prospect.contractValue);
          }
          
          return { ...prospect, stage: nextStage, lastUpdated: newWeek };
        }
        
        return prospect;
      }));
    }
    
    // Product-market fit changes dynamically based on market conditions
    if (hasStartup && mvpBuilt) {
      // PMF decreases over time as market evolves (competition, customer needs change)
      const marketShift = Math.random() * 3 - 1.5; // -1.5% to +1.5% change
      const competitorEffect = competitors.length * -0.2; // More competitors = harder PMF
      const saturationEffect = -(marketSaturation / 100) * 2; // High saturation hurts PMF
      
      setProductMarketFit(prev => Math.max(0, Math.min(100, prev + marketShift + competitorEffect + saturationEffect)));
    }
    
    // Pay from job (every 2 weeks = bi-weekly) - NET income after taxes
    if (currentJob && newWeek % 2 === 0) {
      const biweeklyPay = netMonthlyIncome / 2; // Half of monthly income
      setPersonalCash(prev => prev + biweeklyPay);
      setLastPaymentAmount(biweeklyPay);
      setShowPaymentAnimation(true);
      setTimeout(() => setShowPaymentAnimation(false), 3000); // Hide after 3 seconds
    }
    
    // Update market saturation and competitor growth
    if (hasStartup && mvpBuilt) {
      // Market saturation increases slowly
      setMarketSaturation(prev => Math.min(100, prev + 0.5));
      
      // Advance product development
      advanceProductDevelopment();
      
      // Competitors grow their ARR
      setCompetitors(prev => prev.map(comp => ({
        ...comp,
        arr: comp.arr * (1 + (Math.random() * 0.1 - 0.02)) // -2% to +8% growth
      })));
    }
    
    // Update customer churn risk and process renewals
    if (hasStartup && customers.length > 0) {
      setCustomers(prev => prev.map(customer => {
        const weeksSinceStart = newWeek - customer.startWeek;
        const weeksUntilRenewal = customer.renewalWeek - newWeek;
        
        // Calculate churn risk based on various factors
        let churnRisk = customer.churnRisk || 'Low';
        
        // Increase risk if renewal is coming up and no engagement
        if (weeksUntilRenewal <= 4 && weeksUntilRenewal > 0) {
          const random = Math.random();
          if (random < 0.3) churnRisk = 'High';
          else if (random < 0.6) churnRisk = 'Medium';
        }
        
        // Check if renewal date passed - customer may churn
        if (weeksUntilRenewal <= 0) {
          const churnChance = churnRisk === 'High' ? 0.7 : churnRisk === 'Medium' ? 0.3 : 0.1;
          if (Math.random() < churnChance) {
            // Customer churned - remove from list
            return null;
          } else {
            // Customer renewed - reset renewal date
            return {
              ...customer,
              renewalWeek: newWeek + 52, // Renew for another year
              churnRisk: 'Low',
              totalRevenue: customer.totalRevenue + customer.contractValue
            };
          }
        }
        
        return { ...customer, churnRisk };
      }).filter(Boolean)); // Remove churned customers
      
      // Recalculate ARR based on active customers
      const activeArr = customers.reduce((sum, c) => sum + c.contractValue, 0);
      setArr(activeArr);
    }
    
    // Update cash flow displays as MONTHLY RATES
    // Personal Flow = monthly net income (consistent rate)
    setPersonalCashFlow(netMonthlyIncome);
    
    // Business Flow = monthly revenue - monthly burn
    if (hasStartup) {
      const monthlyRevenue = customers.reduce((sum, c) => sum + (c.monthlyValue || 0), 0);
      const monthlyPayroll = employees.reduce((sum, e) => sum + (e.salary / 12), 0);
      const monthlyNoCodeCost = hasNoCodePlatform ? noCodeMonthlyCost : 0;
      const monthlyBurn = monthlyPayroll + monthlyNoCodeCost;
      setBusinessCashFlow(monthlyRevenue - monthlyBurn);
    } else {
      setBusinessCashFlow(0);
    }
    
    // Check for overdraft fees (if any account is negative)
    if (personalCash < 0) {
      const overdraftFee = 35;
      setPersonalCash(prev => prev - overdraftFee);
      setOverdraftFees(prev => prev + overdraftFee);
      alert(`⚠️ Overdraft Fee!\n\nYour Personal Cash went negative.\n\nOverdraft fee: -$${overdraftFee}\n\n💡 Keep your accounts positive to avoid fees!`);
    }
    
    if (businessCash < 0 && hasStartup) {
      const overdraftFee = 50;
      setBusinessCash(prev => prev - overdraftFee);
      setOverdraftFees(prev => prev + overdraftFee);
      alert(`⚠️ Business Overdraft Fee!\n\nYour Business Cash went negative.\n\nOverdraft fee: -$${overdraftFee}\n\n💡 Transfer money or reduce expenses!`);
    }
  };

  const updateStockPrices = () => {
    // Removed - no longer using stocks
  };

  // Generate prospect names
  const generateCompanyName = () => {
    const adjectives = ['Global', 'Digital', 'Smart', 'Innovative', 'Advanced', 'Premier', 'Elite', 'Dynamic', 'Strategic', 'Optimal'];
    const nouns = ['Solutions', 'Systems', 'Technologies', 'Enterprises', 'Industries', 'Corporation', 'Group', 'Partners', 'Ventures', 'Holdings'];
    return `${adjectives[Math.floor(Math.random() * adjectives.length)]} ${nouns[Math.floor(Math.random() * nouns.length)]}`;
  };

  // Customer acquisition channels (how startups actually get first customers)
  const getContractValue = (acquisitionChannel, productMaturity) => {
    // MVPs get low prices, mature products get higher prices
    const baseValues = {
      'Friends & Family': 0, // Free beta users
      'Personal Network': 50 * 12, // $50/month
      'Cold Outreach': 100 * 12, // $100/month  
      'Content Marketing': 75 * 12, // $75/month
      'Paid Ads': 150 * 12, // $150/month
      'Referrals': 125 * 12 // $125/month
    };
    
    // Multiply by product maturity factor (1x for MVP, 5x for mature)
    const maturityMultiplier = productMaturity === 'MVP' ? 1 : 
                               productMaturity === 'Growing' ? 2 :
                               productMaturity === 'Mature' ? 3.5 : 5;
    
    return Math.floor(baseValues[acquisitionChannel] * maturityMultiplier);
  };
  
  // Get first customers through various channels
  const acquireCustomer = (channel, hourCost) => {
    const hoursRemaining = weeklyHoursAvailable - weeklyHoursUsed;
    
    if (hoursRemaining < hourCost) {
      alert(`Not enough time! This requires ${hourCost} hours but you only have ${hoursRemaining.toFixed(1)} hours left this week.`);
      return;
    }
    
    // Can't acquire customers if still in beta testing
    if (inBetaTesting) {
      alert('Complete beta testing first! Get feedback from testers and fix any issues before acquiring paying customers.');
      return;
    }
    
    // Success rate varies by channel
    const successRates = {
      'Friends & Family': 0.8, // 80% will try your product
      'Personal Network': 0.4, // 40% conversion from cold LinkedIn reach out
      'Cold Outreach': 0.05,   // 5% reply rate, typical for cold email
      'Content Marketing': 0.15, // 15% if content is good
      'Paid Ads': 0.02,        // 2% conversion rate (need to pay per click too)
      'Referrals': 0.6         // 60% if referred by happy customer
    };
    
    const success = Math.random() < successRates[channel];
    
    if (!success) {
      alert(`No luck this time! ${channel === 'Cold Outreach' ? 'No responses to your emails.' : channel === 'Friends & Family' ? 'They\'re busy right now.' : 'Didn\'t get any traction.'}`);
      setWeeklyHoursUsed(prev => prev + hourCost);
      return;
    }
    
    // Determine product maturity based on number of products and customers
    let productMaturity = 'MVP';
    if (customers.length > 50 && products.length > 2) productMaturity = 'Enterprise';
    else if (customers.length > 20 && products.length > 1) productMaturity = 'Mature';
    else if (customers.length > 5) productMaturity = 'Growing';
    
    const contractValue = getContractValue(channel, productMaturity);
    
    // Create a prospect that enters the sales pipeline at "Discovery" stage
    // (They've already shown interest from your outreach)
    const newProspect = {
      id: Date.now(),
      company: channel === 'Friends & Family' ? generateName() + "'s Company" : generateCompanyName(),
      contact: generateName(),
      stage: 'Discovery', // Start at Discovery since they responded to outreach
      contractValue: contractValue,
      monthlyValue: contractValue / 12,
      createdWeek: gameWeek,
      lastUpdated: gameWeek,
      acquisitionChannel: channel,
      productMaturity: productMaturity
    };
    
    setProspects(prev => [...prev, newProspect]);
    setWeeklyHoursUsed(prev => prev + hourCost);
    
    // Pay cost for paid ads
    if (channel === 'Paid Ads' && businessCash >= 500) {
      setBusinessCash(prev => prev - 500);
    }
    
    alert(`Success! ${newProspect.company} is interested and wants to learn more. They've entered your sales pipeline at the Discovery stage.`);
  };

  // Rejection messages based on stage
  const getRejectionMessage = (stage) => {
    const rejections = {
      'Outreach': [
        "Not interested right now",
        "We handle this in-house",
        "Budget is frozen this quarter",
        "Already using a competitor",
        "Email went to spam, no response",
        "Wrong person - left the company",
        "Company is downsizing",
        "Not the right time for us"
      ],
      'Discovery': [
        "Doesn't solve our specific problem",
        "Too expensive for what we need",
        "We're going with a different solution",
        "Lost to a competitor",
        "Internal politics - project killed",
        "Can't get buy-in from leadership",
        "Timeline doesn't work for us"
      ],
      'Demo': [
        "Product doesn't have features we need",
        "Competitor has better pricing",
        "Not impressed with the demo",
        "Integration issues with our systems",
        "Decided to build in-house",
        "Security concerns not addressed",
        "Bad timing - restructuring"
      ],
      'Negotiation': [
        "Can't agree on contract terms",
        "Pricing is too high",
        "Lost to competitor's better offer",
        "Budget was reallocated",
        "Decision maker left the company",
        "Legal couldn't approve the terms",
        "Project was cancelled"
      ]
    };
    
    const messages = rejections[stage] || rejections['Outreach'];
    return messages[Math.floor(Math.random() * messages.length)];
  };

  // Generate a new prospect for the sales pipeline
  const generateProspect = () => {
    const industries = ['FinTech', 'HealthTech', 'B2B SaaS', 'E-commerce', 'EdTech', 'Gaming'];
    const industry = industries[Math.floor(Math.random() * industries.length)];
    
    // ARR based on startup maturity
    let arrRange = { min: 5000, max: 25000 }; // Early stage
    if (customers.length > 20) arrRange = { min: 25000, max: 100000 }; // Growing
    if (customers.length > 50) arrRange = { min: 50000, max: 250000 }; // Mature
    
    const contractValue = arrRange.min + Math.random() * (arrRange.max - arrRange.min);
    
    return {
      id: Date.now() + Math.random(), // Ensure unique ID
      company: generateCompanyName(),
      companyName: generateCompanyName(), // For display in new UI
      contact: generateName(),
      contactName: generateName(), // For display in new UI
      industry: industry,
      stage: 'Discovery',
      contractValue: Math.round(contractValue),
      arr: Math.round(contractValue), // For display in new UI
      monthlyValue: Math.round(contractValue / 12),
      closeChance: 30 + Math.floor(Math.random() * 20), // 30-50%
      createdWeek: gameWeek,
      lastUpdated: gameWeek
    };
  };

  // Move prospect to next stage
  const advanceProspect = (prospect) => {
    if (!prospect) return;
    
    const prospectId = prospect.id;
    
    // Calculate hours needed for this stage
    const hoursNeeded = {
      'Outreach': 1,     // 1 hour for discovery call
      'Discovery': 2,    // 2 hours for demo prep and delivery
      'Demo': 3,         // 3 hours for contract negotiation
      'Negotiation': 2,  // 2 hours to close the deal
      'Proposal': 2      // Added Proposal stage
    }[prospect.stage] || 1;
    
    const hoursRemaining = weeklyHoursAvailable - weeklyHoursUsed;
    
    if (hoursRemaining < hoursNeeded) {
      alert(`Not enough time! You need ${hoursNeeded} hours but only have ${hoursRemaining.toFixed(1)} hours available this week.`);
      return;
    }
    
    setProspects(prev => prev.map(p => {
      if (p.id === prospectId) {
        const currentIndex = pipelineStages.indexOf(p.stage);
        
        // Random chance to lose the deal - increases as you progress
        if (currentIndex < 4) { // Not yet closed
          const loseChance = currentIndex === 0 ? 0.3 : currentIndex === 1 ? 0.35 : currentIndex === 2 ? 0.4 : 0.45;
          if (Math.random() < loseChance) {
            const rejectionMessage = getRejectionMessage(p.stage);
            return { 
              ...p, 
              stage: 'Closed Lost', 
              lastUpdated: gameWeek,
              rejectionReason: rejectionMessage
            };
          }
        }
        
        const nextStage = pipelineStages[currentIndex + 1];
        
        // If closing the deal, convert to customer
        if (nextStage === 'Closed Won') {
          const newCustomer = {
            id: p.id,
            company: p.company,
            contact: p.contact,
            contractValue: p.contractValue,
            startWeek: gameWeek,
            renewalWeek: gameWeek + 52, // 1 year contract
            churnRisk: 'Low',
            totalRevenue: p.contractValue
          };
          setCustomers(prev => [...prev, newCustomer]);
          setArr(prev => prev + p.contractValue);
        }
        
        return { ...p, stage: nextStage, lastUpdated: gameWeek };
      }
      return p;
    }));
    
    // Deduct hours
    setWeeklyHoursUsed(prev => prev + hoursNeeded);
  };

  const selectJob = (founderPath) => {
    setFounderType(founderPath);
    setCurrentJob(founderPath);
    const career = FOUNDER_PATHS[founderPath].career;
    setJobBonus(career.bonuses[0]); // Store the founder bonus for level 0
    setJobLevel(0);
    setWeeksInCurrentRole(0);
    const grossSalary = career.base;
    const grossMonthly = grossSalary / 12; // No rounding
    const taxes = calculateTaxes(grossMonthly);
    setGrossMonthlyIncome(grossMonthly);
    setNetMonthlyIncome(taxes.net); // No rounding
    setPersonalCashFlow(taxes.net); // Set monthly cash flow rate
    setShowJobPicker(false);
  };

  const canPromote = () => {
    if (!founderType || jobLevel >= FOUNDER_PATHS[founderType].career.levels.length - 1) return false;
    const weeksNeeded = FOUNDER_PATHS[founderType].career.weeksRequired[jobLevel];
    return weeksInCurrentRole >= weeksNeeded;
  };

  const promoteJob = () => {
    if (canPromote()) {
      const career = FOUNDER_PATHS[founderType].career;
      const newLevel = jobLevel + 1;
      const newGrossMonthly = grossMonthlyIncome * 1.3; // No rounding
      const taxes = calculateTaxes(newGrossMonthly);
      setJobLevel(newLevel);
      setWeeksInCurrentRole(0); // Reset counter for next promotion
      setGrossMonthlyIncome(newGrossMonthly);
      setNetMonthlyIncome(taxes.net); // No rounding
      setPersonalCashFlow(taxes.net); // Update monthly cash flow rate
      
      // Update founder bonus to new level
      setJobBonus(career.bonuses[newLevel]);
      
      alert(`🎉 Promoted to ${career.levels[newLevel]}!\n\n💰 +30% raise\n🚀 Founder bonus upgraded to: ${career.bonuses[newLevel].description}`);
    }
  };

  const createStartup = (idea, name, logo) => {
    setStartupIdea(idea);
    setStartupName(name);
    setStartupLogo(logo);
    setHasStartup(true);
    setShowStartupCreator(false);
    setBusinessCash(0); // Start with $0 - bootstrap from personal savings!
    
    // Generate 3-5 competitors in the same market
    const numCompetitors = Math.floor(Math.random() * 3) + 3;
    const newCompetitors = [];
    for (let i = 0; i < numCompetitors; i++) {
      newCompetitors.push({
        id: Date.now() + i,
        name: generateCompanyName(),
        arr: Math.floor(Math.random() * 50000000) + 1000000, // $1M - $50M ARR
        market: idea.market,
        founded: gameWeek - Math.floor(Math.random() * 260) // Founded 0-5 years ago
      });
    }
    setCompetitors(newCompetitors);
  };

  // Select features to build for MVP
  const selectFeatures = (features) => {
    const totalFeatures = builtFeatures.length + features.length;
    
    if (features.length === 0 && builtFeatures.length < 3) {
      alert(`Please select at least ${3 - builtFeatures.length} more feature(s) to build!`);
      return;
    }
    
    if (totalFeatures < 3) {
      alert(`MVPs need at least 3 core features to be viable! You have ${builtFeatures.length} built and selected ${features.length} new, totaling ${totalFeatures}.`);
      return;
    }
    
    setSelectedFeatures(features);
    if (builtFeatures.length > 0) {
      alert(`Added ${features.length} new feature(s) to your existing ${builtFeatures.length}. Total: ${totalFeatures} features. Start building!`);
    } else {
      alert(`Selected ${features.length} features. Start building them one by one!`);
    }
  };
  
  // Start building a specific feature
  const startFeatureDevelopment = (feature) => {
    const hourCost = 5; // 5 hours to start planning
    const hoursRemaining = weeklyHoursAvailable - weeklyHoursUsed;
    
    if (hoursRemaining < hourCost) {
      alert(`Not enough time! Starting feature development requires ${hourCost} hours but you only have ${hoursRemaining.toFixed(1)} hours left this week.`);
      return;
    }
    
    // Calculate actual weeks based on 5% per week progress (or 5.5% with dev bonus)
    let progressPerWeek = 5;
    if (jobBonus && jobBonus.type === 'development') {
      progressPerWeek = 5.5;
    }
    const estimatedWeeks = Math.ceil(100 / progressPerWeek);
    
    // Determine complexity and cost based on hours
    const complexity = feature.hours >= 35 ? 'Very High' : feature.hours >= 30 ? 'High' : feature.hours >= 25 ? 'Medium' : 'Low';
    const estimatedBugs = feature.hours >= 35 ? '3-5' : feature.hours >= 30 ? '2-4' : feature.hours >= 25 ? '1-3' : '0-2';
    
    // Cost scales with complexity: Low=$1K, Medium=$2K, High=$3K, Very High=$5K
    let featureCost;
    if (feature.hours >= 35) {
      featureCost = 5000; // Very High
    } else if (feature.hours >= 30) {
      featureCost = 3000; // High
    } else if (feature.hours >= 25) {
      featureCost = 2000; // Medium
    } else {
      featureCost = 1000; // Low
    }
    
    if (businessCash >= featureCost) {
      setBusinessCash(prev => prev - featureCost);
      setCurrentFeatureInProgress(feature);
      setFeatureProgress(0);
      setWeeklyHoursUsed(prev => prev + hourCost);
      
      alert(`Started building "${feature.name}"\n\n💰 Cost: $${(featureCost / 1000).toFixed(0)}K\n⏱️ Estimated time: ${estimatedWeeks} weeks\n⚠️ Complexity: ${complexity}\n🐛 Expected bugs: ${estimatedBugs}\n\nMore complex features cost more and generate more bugs!`);
    } else {
      alert(`Not enough cash! "${feature.name}" costs $${(featureCost / 1000).toFixed(0)}K to build.\n\nYou have: $${(businessCash / 1000).toFixed(1)}K\nNeed: $${(featureCost / 1000).toFixed(0)}K`);
    }
  };
  
  // Get a pre-signup from potential customer
  const getPreSignup = () => {
    const hourCost = 4; // 4 hours to pitch and get commitment
    const hoursRemaining = weeklyHoursAvailable - weeklyHoursUsed;
    
    if (hoursRemaining < hourCost) {
      alert(`Not enough time! Getting pre-signups requires ${hourCost} hours but you only have ${hoursRemaining.toFixed(1)} hours left this week.`);
      return;
    }
    
    // Check if all features are built and critical bugs fixed
    const targetFeatureCount = selectedFeaturesCountRef.current > 0 
      ? selectedFeaturesCountRef.current 
      : selectedFeatures.length + builtFeatures.length;
    
    if (builtFeatures.length < 3) {
      alert('Build at least 3 features before gathering pre-signups! MVPs need a minimum viable feature set.');
      return;
    }
    
    if (builtFeatures.length < targetFeatureCount) {
      alert('Finish building all selected features before gathering pre-signups!');
      return;
    }
    
    const criticalBugs = featureBugs.filter(b => !b.fixed && (b.severity === 'Critical' || b.severity === 'High')).length;
    if (criticalBugs > 0) {
      alert(`Fix ${criticalBugs} critical/high bugs before getting pre-signups! Customers won't commit to buggy products.`);
      return;
    }
    
    if (potentialCustomers.length === 0) {
      alert('No potential customers! This should have been generated when features completed.');
      return;
    }
    
    // Success rate based on awareness and hype
    const baseRate = 0.3;
    const awarenessBonus = (awareness / 100) * 0.3;
    const hypeBonus = (hype / 100) * 0.2;
    const successRate = Math.min(0.8, baseRate + awarenessBonus + hypeBonus);
    
    // Pick a potential customer with high interest
    const sortedCustomers = [...potentialCustomers].sort((a, b) => b.interest - a.interest);
    const targetCustomer = sortedCustomers[0];
    
    if (!targetCustomer) {
      alert('No more potential customers to reach out to!');
      return;
    }
    
    if (Math.random() < successRate) {
      const newPreSignup = {
        ...targetCustomer,
        signedUpWeek: gameWeek
      };
      
      setPreSignups(prev => [...prev, newPreSignup]);
      setPotentialCustomers(prev => prev.filter(c => c.id !== targetCustomer.id));
      setWeeklyHoursUsed(prev => prev + hourCost);
      setHype(prev => Math.min(100, prev + 1)); // Small hype boost
      
      alert(`✅ ${newPreSignup.company} pre-signed up! (${preSignups.length + 1}/${targetPreSignups} needed to launch)\nRemaining leads: ${potentialCustomers.length - 1}`);
    } else {
      setPotentialCustomers(prev => prev.filter(c => c.id !== targetCustomer.id));
      setWeeklyHoursUsed(prev => prev + hourCost);
      alert(`❌ ${targetCustomer.company} declined. ${Math.round(successRate * 100)}% success rate. Build more awareness!\nRemaining leads: ${potentialCustomers.length - 1}`);
    }
  };
  
  // Launch MVP once you have enough pre-signups
  const launchMVP = () => {
    if (builtFeatures.length < 3) {
      alert(`You need at least 3 features to launch an MVP. Currently have ${builtFeatures.length} feature(s).`);
      return;
    }
    
    if (preSignups.length < targetPreSignups) {
      alert(`You need ${targetPreSignups} pre-signups to launch. Currently have ${preSignups.length}.`);
      return;
    }
    
    if (!window.confirm(`Launch your MVP with ${builtFeatures.length} features and ${preSignups.length} pre-signed customers? They'll enter your sales pipeline at Discovery stage.`)) {
      return;
    }
    
    // Convert pre-signups to prospects in Discovery stage
    const newProspects = preSignups.map(ps => ({
      id: ps.id,
      company: ps.company,
      contact: ps.contact,
      stage: 'Discovery', // They enter at Discovery, not as customers yet
      contractValue: ps.estimatedValue,
      monthlyValue: ps.estimatedValue / 12,
      createdWeek: gameWeek,
      lastUpdated: gameWeek,
      acquisitionChannel: 'Pre-signup Launch',
      productMaturity: 'MVP'
    }));
    
    setProspects(prev => [...prev, ...newProspects]);
    
    setMvpBuilt(true);
    setInBetaTesting(false);
    
    // Complete checklist task
    setChecklistItems(prev => ({ ...prev, mvpBuilt: true }));
    setTimeout(checkMilestoneComplete, 100);
    
    // Create first product
    const firstProduct = {
      id: Date.now(),
      name: startupIdea.name,
      status: 'Launched',
      progress: 100,
      revenue: 0,
      customers: 0,
      startedWeek: gameWeek,
      launchedWeek: gameWeek,
      features: builtFeatures
    };
    setProducts([firstProduct]);
    
    alert(`🚀 MVP LAUNCHED!\n\n${newProspects.length} pre-signed customers entered your sales pipeline at Discovery stage.\n\nNow work them through: Discovery → Demo → Negotiation → Closed Won!\n\nEach stage takes ~2 weeks. Good luck closing deals!`);
  };
  
  // Build awareness through marketing activities
  const buildAwareness = (channel, cost, hourCost) => {
    const hoursRemaining = weeklyHoursAvailable - weeklyHoursUsed;
    
    if (hoursRemaining < hourCost) {
      alert(`Not enough time! This requires ${hourCost} hours but you only have ${hoursRemaining.toFixed(1)} hours left this week.`);
      return;
    }
    
    if (businessCash >= cost) {
      setBusinessCash(prev => prev - cost);
      setWeeklyHoursUsed(prev => prev + hourCost);
      
      // Different channels have different awareness impacts
      const awarenessGain = {
        'Social Media': 5,
        'Content Marketing': 8,
        'Paid Ads': 12,
        'PR': 15,
        'Launch on Product Hunt': 20
      }[channel] || 5;
      
      const hypeGain = awarenessGain * 0.5; // Hype grows slower
      
      setAwareness(prev => Math.min(100, prev + awarenessGain));
      setHype(prev => Math.min(100, prev + hypeGain));
      
      // Some channels also build email list
      if (channel === 'Content Marketing' || channel === 'Social Media') {
        const emailsGained = Math.floor(Math.random() * 50) + 20;
        setEmailList(prev => prev + emailsGained);
      }
      
      alert(`${channel} campaign complete! Awareness: +${awarenessGain}%, Hype: +${hypeGain.toFixed(1)}%`);
    } else {
      alert(`Not enough cash! ${channel} costs $${cost}.`);
    }
  };
  
  // Generate 150+ potential customers (leads) once all features are built
  const generatePotentialCustomers = () => {
    const customerCount = Math.floor(Math.random() * 50) + 150; // 150-200 potential customers
    const customers = [];
    
    for (let i = 0; i < customerCount; i++) {
      customers.push({
        id: Date.now() + i,
        company: generateCompanyName(),
        contact: generateName(),
        estimatedValue: Math.floor(Math.random() * 30000) + 5000, // $5K-$35K potential annual value
        interest: Math.random() * 100, // Interest level 0-100
        addedWeek: gameWeek
      });
    }
    
    setPotentialCustomers(customers);
    alert(`🎯 Generated ${customerCount} potential customers! These are leads who might be interested in your product.`);
  };
  
  // Fix a bug in a feature
  const fixBug = (bugId) => {
    const hourCost = 8; // 8 hours to fix a bug
    const hoursRemaining = weeklyHoursAvailable - weeklyHoursUsed;
    
    if (hoursRemaining < hourCost) {
      alert(`Not enough time! Fixing bugs requires ${hourCost} hours but you only have ${hoursRemaining.toFixed(1)} hours left this week.`);
      return;
    }
    
    if (businessCash >= 500) {
      setBusinessCash(prev => prev - 500);
      setWeeklyHoursUsed(prev => prev + hourCost);
      setFeatureBugs(prev => prev.map(bug => 
        bug.id === bugId ? { ...bug, fixed: true } : bug
      ));
      alert('Bug fixed! ✅');
    } else {
      alert('Not enough cash! Bug fixes cost $500.');
    }
  };
  
  // Add beta tester
  const addBetaTester = () => {
    const hourCost = 3; // 3 hours to onboard and support beta tester
    const hoursRemaining = weeklyHoursAvailable - weeklyHoursUsed;
    
    if (hoursRemaining < hourCost) {
      alert(`Not enough time! Onboarding a beta tester requires ${hourCost} hours but you only have ${hoursRemaining} hours left this week.`);
      return;
    }
    
    const tester = {
      id: Date.now(),
      name: generateName(),
      addedWeek: gameWeek,
      feedbackGiven: false
    };
    
    setBetaTesters(prev => [...prev, tester]);
    setWeeklyHoursUsed(prev => prev + hourCost);
    
    // Randomly generate feedback after 1 week
    setTimeout(() => {
      const feedback = {
        tester: tester.name,
        type: ['Bug', 'Feature Request', 'UX Issue', 'Performance', 'Confusing'][Math.floor(Math.random() * 5)],
        severity: ['Critical', 'High', 'Medium', 'Low'][Math.floor(Math.random() * 4)],
        description: [
          'Login flow is confusing',
          'Page loads too slowly',
          'Can\'t figure out how to [feature]',
          'Button doesn\'t work on mobile',
          'Would be great if you added [feature]',
          'Crashes when I try to...',
          'Design looks outdated',
          'Missing key functionality'
        ][Math.floor(Math.random() * 8)],
        week: gameWeek + 1
      };
      setBetaFeedback(prev => [...prev, feedback]);
    }, 100);
  };
  
  // Exit beta testing
  const completeBetaTesting = () => {
    if (betaTesters.length < 5) {
      alert('Get at least 5 beta testers before launching to paying customers!');
      return;
    }
    
    const criticalIssues = betaFeedback.filter(f => f.severity === 'Critical' || f.severity === 'High').length;
    if (criticalIssues > 0) {
      if (!window.confirm(`You have ${criticalIssues} critical/high priority issues. Launch anyway? This may affect your product-market fit.`)) {
        return;
      }
      setProductMarketFit(prev => Math.max(0, prev - (criticalIssues * 5))); // Penalty for ignoring issues
    }
    
    setInBetaTesting(false);
    
    // Create first product
    const firstProduct = {
      id: Date.now(),
      name: startupIdea.name,
      status: 'Launched',
      progress: 100,
      revenue: 0,
      customers: 0,
      startedWeek: gameWeek,
      launchedWeek: gameWeek
    };
    setProducts([firstProduct]);
    
    alert('Congratulations! Your MVP is now live. Time to start acquiring customers!');
  };
  
  // Redesign based on feedback
  const redesignMVP = () => {
    const hourCost = 15; // 15 hours to fix issues
    const hoursRemaining = weeklyHoursAvailable - weeklyHoursUsed;
    
    if (hoursRemaining < hourCost) {
      alert(`Not enough time! Redesigning requires ${hourCost} hours but you only have ${hoursRemaining} hours left this week.`);
      return;
    }
    
    if (businessCash >= 2000) {
      setBusinessCash(prev => prev - 2000);
      setWeeklyHoursUsed(prev => prev + hourCost);
      
      // Clear some critical feedback
      setBetaFeedback(prev => prev.filter(f => Math.random() > 0.6)); // Remove ~60% of feedback
      setProductMarketFit(prev => Math.min(100, prev + 15)); // Boost PMF
      
      alert('Redesign complete! You\'ve addressed the most critical feedback.');
    } else {
      alert('Not enough cash! You need $2,000 for redesign work.');
    }
  };

  // Start developing a new product
  const startProductDevelopment = (productName) => {
    const hourCost = 10; // 10 hours to start product planning
    const hoursRemaining = weeklyHoursAvailable - weeklyHoursUsed;
    
    if (hoursRemaining < hourCost) {
      alert(`Not enough time! Starting product development requires ${hourCost} hours but you only have ${hoursRemaining} hours left this week.`);
      return;
    }
    
    if (businessCash >= 50000) {
      setBusinessCash(prev => prev - 50000);
      setWeeklyHoursUsed(prev => prev + hourCost);
      const newProduct = {
        id: Date.now(),
        name: productName,
        status: 'In Development',
        progress: 0,
        revenue: 0,
        customers: 0,
        startedWeek: gameWeek,
        launchedWeek: null
      };
      setProducts(prev => [...prev, newProduct]);
    }
  };

  // Advance product development (call this each week)
  const advanceProductDevelopment = () => {
    setProducts(prev => prev.map(product => {
      if (product.status === 'In Development') {
        // Base progress per week
        let progressPerWeek = 5;
        
        // Bonus if you have product team
        const productTeam = employees.filter(e => e.department === 'Product').length;
        const engineeringTeam = employees.filter(e => e.department === 'Engineering').length;
        progressPerWeek += productTeam * 2 + engineeringTeam * 1.5;
        
        const newProgress = Math.min(100, product.progress + progressPerWeek);
        
        if (newProgress >= 100) {
          return {
            ...product,
            status: 'Launched',
            progress: 100,
            launchedWeek: gameWeek
          };
        }
        
        return { ...product, progress: newProgress };
      }
      return product;
    }));
  };

  // Acquire/Merge with competitor
  const acquireCompetitor = (competitorId) => {
    const competitor = competitors.find(c => c.id === competitorId);
    if (!competitor) return;
    
    // Acquisition cost = 3x ARR
    const acquisitionCost = competitor.arr * 3;
    
    if (businessCash >= acquisitionCost) {
      setBusinessCash(prev => prev - acquisitionCost);
      setArr(prev => prev + competitor.arr);
      
      // Add their customers (estimate based on ARR)
      const estimatedCustomers = Math.floor(competitor.arr / 50000); // Assume avg $50K contract
      for (let i = 0; i < estimatedCustomers; i++) {
        const newCustomer = {
          id: Date.now() + i,
          company: generateCompanyName(),
          contact: generateName(),
          contractValue: 50000,
          startWeek: gameWeek,
          renewalWeek: gameWeek + 52,
          churnRisk: 'Medium', // Acquired customers have higher churn risk initially
          totalRevenue: 0
        };
        setCustomers(prev => [...prev, newCustomer]);
      }
      
      // Remove competitor from market
      setCompetitors(prev => prev.filter(c => c.id !== competitorId));
    }
  };

  const conductSurvey = () => {
    const hourCost = 2; // 2 hours to conduct survey
    const hoursRemaining = weeklyHoursAvailable - weeklyHoursUsed;
    
    if (hoursRemaining < hourCost) {
      alert(`Not enough time! Conducting a survey requires ${hourCost} hours but you only have ${hoursRemaining} hours left this week.`);
      return;
    }
    
    if (businessCash >= 500) {
      setBusinessCash(prev => prev - 500);
      setWeeklyHoursUsed(prev => prev + hourCost);
      const feedback = {
        problem: startupIdea.problem,
        interest: Math.floor(Math.random() * 100),
        willingnessToPay: Math.floor(Math.random() * 500) + 50
      };
      setSurveys(prev => [...prev, feedback]);
      setProductMarketFit(prev => Math.min(100, prev + 10));
    }
  };

  const applyForFunding = () => {
    if (arr >= 100000 && fundingStage === 'Bootstrapped') {
      setFundingStage('Seed');
      setBusinessCash(prev => prev + 500000);
    } else if (arr >= 1000000 && fundingStage === 'Seed') {
      setFundingStage('Series A');
      setBusinessCash(prev => prev + 5000000);
    } else if (arr >= 5000000 && fundingStage === 'Series A') {
      setFundingStage('Series B');
      setBusinessCash(prev => prev + 25000000);
    } else if (arr >= 20000000 && fundingStage === 'Series B') {
      setFundingStage('Series C');
      setBusinessCash(prev => prev + 100000000);
    } else if (arr >= 50000000 && fundingStage === 'Series C') {
      setFundingStage('IPO');
      setBusinessCash(prev => prev + 500000000);
    }
  };

  const createJobReq = (dept, position) => {
    const req = {
      id: Date.now(),
      department: dept,
      position: position,
      applicants: []
    };
    
    // Generate applicants
    for (let i = 0; i < Math.floor(Math.random() * 10) + 5; i++) {
      req.applicants.push({
        name: generateName(),
        experience: Math.floor(Math.random() * 15) + 1,
        skill: Math.floor(Math.random() * 100),
        salary: Math.floor(Math.random() * 100000) + 50000
      });
    }
    
    setJobReqs(prev => [...prev, req]);
  };

  const hireApplicant = (reqId, applicant) => {
    const req = jobReqs.find(r => r.id === reqId);
    if (businessCash >= applicant.salary / 12) {
      const employee = {
        ...applicant,
        department: req.department,
        position: req.position,
        hired: gameWeek
      };
      setEmployees(prev => [...prev, employee]);
      setBusinessCash(prev => prev - applicant.salary / 12);
      setJobReqs(prev => prev.filter(r => r.id !== reqId));
      
      // Update org chart
      setOrgChart(prev => ({
        ...prev,
        [req.department]: [...(prev[req.department] || []), employee]
      }));
    }
  };

  const launchAdCampaign = (budget, platform) => {
    if (businessCash >= budget) {
      setBusinessCash(prev => prev - budget);
      setAdCampaigns(prev => [...prev, {
        platform,
        budget,
        startWeek: gameWeek,
        impressions: 0,
        conversions: 0
      }]);
    }
  };

  const investInCompany = (company, amount) => {
    if (businessCash >= amount) {
      setBusinessCash(prev => prev - amount);
      setInvestments(prev => [...prev, {
        company: company.name,
        amount,
        shares: amount / company.valuation,
        invested: gameWeek
      }]);
    }
  };

  const buyStock = (ticker, shares) => {
    const stock = STOCK_TICKERS.find(s => s.ticker === ticker);
    const cost = stock.price * shares;
    if (personalCash >= cost) {
      setPersonalCash(prev => prev - cost);
      const existingIndex = stockPortfolio.findIndex(s => s.ticker === ticker);
      if (existingIndex >= 0) {
        // Update existing position
        setStockPortfolio(prev => {
          const updated = [...prev];
          const existing = updated[existingIndex];
          const totalShares = existing.shares + shares;
          const totalCost = (existing.avgPrice * existing.shares) + cost;
          updated[existingIndex] = {
            ...existing,
            shares: totalShares,
            avgPrice: totalCost / totalShares
          };
          return updated;
        });
      } else {
        // Create new position
        setStockPortfolio(prev => [...prev, {
          ticker,
          shares,
          avgPrice: stock.price
        }]);
      }
    }
  };

  const upgradeOffice = () => {
    const upgrades = {
      'Basement': { next: 'Co-working Space', cost: 5000 },
      'Co-working Space': { next: 'Small Office', cost: 25000 },
      'Small Office': { next: 'Medium Office', cost: 100000 },
      'Medium Office': { next: 'Large Office', cost: 500000 },
      'Large Office': { next: 'Headquarters', cost: 2000000 }
    };
    
    if (upgrades[office] && businessCash >= upgrades[office].cost) {
      setBusinessCash(prev => prev - upgrades[office].cost);
      setOffice(upgrades[office].next);
    }
  };

  const formatMoney = (amount) => {
    if (amount >= 1000000000) return `$${(amount / 1000000000).toFixed(2)}B`;
    if (amount >= 1000000) return `$${(amount / 1000000).toFixed(2)}M`;
    // Show exact amount with commas, no decimals for whole numbers
    if (Number.isInteger(amount)) {
      return `$${amount.toLocaleString('en-US')}`;
    }
    return `$${amount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  };

  return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #0f172a 0%, #1e293b 100%)',
      color: '#e2e8f0',
      fontFamily: 'Toxigenesis, system-ui, sans-serif',
      padding: '0',
      overflow: 'hidden',
      position: 'relative'
    }}>
      <style>{`
@font-face {
  font-family: 'Toxigenesis';
  src: url(data:font/otf;base64,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AyUANAKyAEcDMgADAY8AhALwAEQCGwBAA1YAJgHyAC8B4gAHArIARANWACYCewAyAbgAJgKyAEQB2gAqAd4ANgE/ACwDegA8ASsAPwExAEoBFQARAfUAKAHiAAcDjgAmA6kAJgQkACYCWQAeA7IACQOyAAkDsgAJA7IACQOyAAkDsgAJBRAACQLsACYDHwBEAx8ARAMfAEQDHwBEAUwACgFMAEQBpP/nAZoAAANrAAIDkABEA1YAJgNWACYDVgAmA1YAJgNWACYCsgBQA1YAJgNMADgDTAA4A0wAOANMADgDMgADA0cARAMnAEACjwAtAo8ALQKPAC0CjwAtAo8ALQKPAC0EDAAtAkQAKAKAACgCgAAoAoAAKAKAACgBMwAMATYAQAHY//oBoAADAsoAKALWAEAClQAoApUAKAKVACgClQAoApUAKAKyAEQClQAoAtAAPgLQAD4C0AA+AtAAPgKsAAkCwABAAqwACQOyAAkCjwAtA7IACQKPAC0DsgAJAo8ALQLsACYCRAAoAuwAJgJEACgC7AAmAlsAKANaAEQDQQAoAsAAKAMfAEQCgAAoAx8ARAKAACgDHwBEAoAAKAMfAEQCgAAoAx8ARAKAACgDIQAmAsAAKAMhACYCwAAoAyEAJgLAACgDbQADAtYAAwGb//EBmf/wAeL//QHh//kBmf/0AaL/+QFS//YBPf/lAUwARAE0AEAD4ABEAoUAQAM8AEQCkQBAAt0ARAE0ADoC3QBEATUAQALdAEQBtQBAAusAAwHMAAADkABEAtYAQAOQAEQC1gBAA5AARALWAEADbQBDAtYAQANWACYClQAoA1YAJgKVACgDVgAmApUAKAUJAEQEJwAoA2QARAGgAD4DZABEAaAAPgNkAEQBx//0Aw8AJQJJAB4DDwAlAkkAHgMPACUCSQAeAusAEQHUABkC6wARAgsAGQLrABEB1AAZA0wAOALQAD4DTAA4AtAAPgNMADgC0AA+A0wAOALQAD4DTAA4AtAAPgSxAAsDcAANAzIAAwKsAAkDMgADAxEAMgJPAC4DEQAyAk8ALgMRADICTwAuAsAAAwNVACYB+QARA7IACQOa/68DnAAmAtkAKAPYADgDLwA+AoAAIALAACgBqv/hAyEAJgLAACgDkABEAtYAQAFR/8MCUQARAi8AIQOWAAMBvwAQAqIACALd/6sCBwAR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ABAANP/wABAANv/BABAAN//YABAAOP/LABAAOf+8ABAAOv/uABAAfP/CABAAff/CABAAfv/CABAAf//CABAAgP/CABAAgf/CABAAgv/CABACZ//mABACa//mABIAFP/wABMADP/uABMADv/uABMAD//SABMAIf/gABMANP/pABMANv/CABMAN//WABMAOf+/ABMAOv/wABMASv/nABMAfP/gABMAff/gABMAfv/gABMAf//gABMAgP/gABMAgf/gABMAgv/gABMCZ//uABMCa//uABQAA/+8ABQAB/+8ABQAFAAQABQAF/++ABQCY/+8ABQCZP+8ABQCZf+8ABQCZv+8ABUABv/uABUADP/mABUADv/mABUAD//PABUAGf/rABUAIf/CABUAKv/qABUAQf/pABUAfP/CABUAff/CABUAfv/CABUAf//CABUAgP/CABUAgf/CABUAgv/CABUAnP/pABUAnv/pABUAn//pABUAoP/pABUAof/pABUAov/pABUCZ//mABUCa//mABYAA//hABYAB//hABYAEf/rABYAGf/qABYCY//hABYCZP/hABYCZf/hABYCZv/hABcADP+YABcADf/VABcADv+YABcAEP/qABcAEQAgABcAFP+pABcAFv/qABcAFwAhABcAI//qABcAJ//qABcAL//qABcAMf/qABcAg//qABcAjv/qABcAj//qABcAkP/qABcAkf/qABcAkv/qABcAlP/qABcBAf/qABcCYf/VABcCYv/VABcCZ/+YABcCa/+YABcChP/qABgADP/uABgADv/uABgAD//SABgAIf/gABgANP/pABgANv/CABgAN//WABgAOf+/ABgAOv/wABgASv/nABgAfP/gABgAff/gABgAfv/gABgAf//gABgAgP/gABgAgf/gABgAgv/gABgCZ//uABgCa//uABkADP/mABkADv/mABkAD//PABkAF//vABkAIf/CABkAKv/qABkANP/wABkANv/BABkAN//YABkAOP/LABkAOf+8ABkAOv/uABkAfP/CABkAff/CABkAfv/CABkAf//CABkAgP/CABkAgf/CABkAgv/CABkCZ//mABkCa//mACAASgAwACEAA/9eACEABv/iACEAB/9eACEADf+4ACEAEP/CACEAFv/CACEAH//RACEAIQAQACEAI//CACEAJ//CACEAKgAQACEAL//CACEAMf/CACEANP99ACEANf/CACEANv9PACEAN/+PACEAOAARACEAOf9sACEAQf/pACEAQ//hACEARP/hACEARf/hACEARv/XACEAR//hACEAT//hACEAUf/hACEAVP+0ACEAVf/TACEAVv+ZACEAV//GACEAWf+jACEAaf/PACEAfAAQACEAfQAQACEAfgAQACEAfwAQACEAgAAQACEAgQAQACEAggAQACEAg//CACEAjv/CACEAj//CACEAkP/CACEAkf/CACEAkv/CACEAlP/CACEAlf/CACEAlv/CACEAl//CACEAmP/CACEAnP/pACEAnv/pACEAn//pACEAoP/pACEAof/pACEAov/pACEAo//hACEApP/hACEApf/hACEApv/hACEAp//hACEArv/hACEAr//hACEAsP/hACEAsf/hACEAsv/hACEAtP/hACEAtf/TACEAtv/TACEAt//TACEAuP/TACEBAf/CACEBAv/hACEBgP/XACECYf+4ACECYv+4ACECY/9eACECZP9eACECZf9eACECZv9eACECbf/PACEChP/CACIADP/uACIADv/uACIAD//SACIAIf/gACIANP/pACIANv/CACIAN//WACIAOf+/ACIAOv/wACIASv/nACIAfP/gACIAff/gACIAfv/gACIAf//gACIAgP/gACIAgf/gACIAgv/gACICZ//uACICa//uACMADf/VACMAQ//sACMARP/sACMARf/sACMARv/mACMAR//sACMAT//sACMAUf/sACMAVP/kACMAVv/jACMAWf/ZACMAo//sACMApP/sACMApf/sACMApv/sACMAp//sACMArv/sACMAr//sACMAsP/sACMAsf/sACMAsv/sACMAtP/sACMBAv/sACMBgP/mACMCYf/VACMCYv/VACQADP/mACQADv/mACQAD//PACQAF//vACQAIf/CACQAKv/qACQANP/wACQANv/BACQAN//YACQAOP/LACQAOf+8ACQAOv/uACQAfP/CACQAff/CACQAfv/CACQAf//CACQAgP/CACQAgf/CACQAgv/CACQCZ//mACQCa//mACYADP+wACYADv+wACYAD/+TACYAIf+cACYAKv+NACYAQf/gACYASv/wACYAfP+cACYAff+cACYAfv+cACYAf/+cACYAgP+cACYAgf+cACYAgv+cACYAnP/gACYAnv/gACYAn//gACYAoP/gACYAof/gACYAov/gACYCZ/+wACYCa/+wACoABv/uACoADP/mACoADv/mACoAD//PACoAGf/rACoAIf/CACoAKv/qACoAQf/pACoAfP/CACoAff/CACoAfv/CACoAf//CACoAgP/CACoAgf/CACoAgv/CACoAnP/pACoAnv/pACoAn//pACoAoP/pACoAof/pACoAov/pACoCZ//mACoCa//mACsAA//iACsABv/fACsAB//iACsADf+wACsAEP/SACsAFv/SACsAI//SACsAJ//SACsAKgAZACsAL//SACsAMf/SACsAQf/uACsAQ//iACsARP/iACsARf/iACsARv/ZACsAR//iACsAT//iACsAUf/iACsAVP/FACsAVf/RACsAVv+8ACsAWf+8ACsAaf/PACsAg//SACsAjv/SACsAj//SACsAkP/SACsAkf/SACsAkv/SACsAlP/SACsAnP/uACsAnv/uACsAn//uACsAoP/uACsAof/uACsAov/uACsAo//iACsApP/iACsApf/iACsApv/iACsAp//iACsArv/iACsAr//iACsAsP/iACsAsf/iACsAsv/iACsAtP/iACsAtf/RACsAtv/RACsAt//RACsAuP/RACsBAf/SACsBAv/iACsBgP/ZACsCYf+wACsCYv+wACsCY//iACsCZP/iACsCZf/iACsCZv/iACsCbf/PACsChP/SACwAA/+kACwAB/+kACwADf/DACwAH//LACwAIQASACwANP9wACwANf/oACwANv9PACwAN/+mACwAOf9pACwAVf/wACwAVv+yACwAWf+yACwAfAASACwAfQASACwAfgASACwAfwASACwAgAASACwAgQASACwAggASACwAlf/oACwAlv/oACwAl//oACwAmP/oACwAtf/wACwAtv/wACwAt//wACwAuP/wACwBAf/xACwCYf/DACwCYv/DACwCY/+kACwCZP+kACwCZf+kACwCZv+kACwChP/xAC8ADP/mAC8ADv/mAC8AD//PAC8AF//vAC8AIf/CAC8AKv/qAC8ANP/wAC8ANv/BAC8AN//YAC8AOP/LAC8AOf+8AC8AOv/uAC8AfP/CAC8Aff/CAC8Afv/CAC8Af//CAC8AgP/CAC8Agf/CAC8Agv/CAC8CZ//mAC8Ca//mADAABv/RADAADP+BADAADv+BADAAD/90ADAAIf+PADAAKv9iADAANv/OADAAOP/BADAAOf/VADAAOv/qADAAQf/HADAAQ//sADAARP/sADAARf/sADAAR//sADAAT//sADAAUf/sADAAUv/sADAAaf/ZADAAfP+PADAAff+PADAAfv+PADAAf/+PADAAgP+PADAAgf+PADAAgv+PADAAnP/HADAAnv/HADAAn//HADAAoP/HADAAof/HADAAov/HADAAo//sADAApP/sADAApf/sADAApv/sADAAp//sADAArv/sADAAr//sADAAsP/sADAAsf/sADAAsv/sADAAtP/sADABAv/sADACZ/+BADACa/+BADACbf/ZADEADP/mADEADv/mADEAD//PADEAF//vADEAIf/CADEAKv/qADEANP/wADEANv/BADEAN//YADEAOP/LADEAOf+8ADEAOv/uADEAfP/CADEAff/CADEAfv/CADEAf//CADEAgP/CADEAgf/CADEAgv/CADECZ//mADECa//mADIADf/pADIAH//qADIANP/mADIANv/BADIAN//MADIAOP/lADIAOf+8ADIARv/wADIAVP/sADIAVf/uADIAtf/uADIAtv/uADIAt//uADIAuP/uADIBgP/wADICYf/pADICYv/pADMAD//jADMAIf/jADMAOP/hADMARv/rADMAVv/iADMAWP/lADMAWf/oADMAfP/jADMAff/jADMAfv/jADMAf//jADMAgP/jADMAgf/jADMAgv/jADMBgP/rADQABv/JADQADP94ADQADf+bADQADv94ADQAD/9qADQAEP/wADQAFv/wADQAHwAPADQAIf93ADQAI//wADQAJ//wADQAKv/aADQAL//wADQAMf/wADQANAAQADQAQf+qADQAQ/+sADQARP+sADQARf+sADQAR/+sADQASv/uADQATf/AADQATv/AADQAT/+sADQAUf+sADQAUv/BADQAU//HADQAVP/iADQAVf/FADQAVv/KADQAWP/oADQAWf/KADQAWv/iADQAaf/jADQAfP93ADQAff93ADQAfv93ADQAf/93ADQAgP93ADQAgf93ADQAgv93ADQAg//wADQAjv/wADQAj//wADQAkP/wADQAkf/wADQAkv/wADQAlP/wADQAnP+qADQAnv+qADQAn/+qADQAoP+qADQAof+qADQAov+qADQAo/+sADQApP+sADQApf+sADQApv+sADQAp/+sADQArf/AADQArv+sADQAr/+sADQAsP+sADQAsf+sADQAsv+sADQAtP+sADQAtf/FADQAtv/FADQAt//FADQAuP/FADQA5v/AADQBAf/wADQBAv+sADQBbP/uADQCYf+bADQCYv+bADQCZ/94ADQCa/94ADQCbf/jADQCbv/jADQChP/wADUABv/uADUADP/mADUADv/mADUAD//PADUAGf/rADUAIf/CADUAKv/qADUAQf/pADUAfP/CADUAff/CADUAfv/CADUAf//CADUAgP/CADUAgf/CADUAgv/CADUAnP/pADUAnv/pADUAn//pADUAoP/pADUAof/pADUAov/pADUCZ//mADUCa//mADYABv+cADYADP+IADYADf+UADYADv+IADYAD/8+ADYAEP/BADYAFv/BADYAIf9PADYAI//BADYAJ//BADYAKv9LADYAL//BADYAMf/BADYAM//aADYAQf+XADYAQ/+GADYARP+GADYARf+GADYARv+8ADYAR/+GADYASv/wADYATf+xADYATv+xADYAT/+GADYAUf+GADYAUv+VADYAU/+aADYAVP++ADYAVf+hADYAVv+8ADYAWP+8ADYAWf+8ADYAWv+yADYAaf+MADYAfP9PADYAff9PADYAfv9PADYAf/9PADYAgP9PADYAgf9PADYAgv9PADYAg//BADYAjv/BADYAj//BADYAkP/BADYAkf/BADYAkv/BADYAlP/BADYAnP+XADYAnv+XADYAn/+XADYAoP+XADYAof+XADYAov+XADYAo/+GADYApP+GADYApf+GADYApv+GADYAp/+GADYArf+xADYArv+GADYAr/+GADYAsP+GADYAsf+GADYAsv+GADYAtP+GADYAtf+hADYAtv+hADYAt/+hADYAuP+hADYA5v+xADYBAf/BADYBAv+GADYBgP+8ADYCYf+UADYCYv+UADYCZ/+IADYCa/+IADYCbf+MADYCbv/GADYChP/BADcABv/DADcADP+yADcADf/FADcADv+yADcAD/+MADcAEP/YADcAFv/YADcAIf+PADcAI//YADcAJ//YADcAKv+EADcAL//YADcAMf/YADcAM//pADcAQf+jADcAQ/+wADcARP+wADcARf+wADcARv/RADcAR/+wADcATf+8ADcATv+8ADcAT/+wADcAUf+wADcAUv+0ADcAU//JADcAVP/cADcAVf/OADcAVv/ZADcAWP/PADcAWf/ZADcAWv/LADcAaf+yADcAfP+PADcAff+PADcAfv+PADcAf/+PADcAgP+PADcAgf+PADcAgv+PADcAg//YADcAjv/YADcAj//YADcAkP/YADcAkf/YADcAkv/YADcAlP/YADcAnP+jADcAnv+jADcAn/+jADcAoP+jADcAof+jADcAov+jADcAo/+wADcApP+wADcApf+wADcApv+wADcAp/+wADcArf+8ADcArv+wADcAr/+wADcAsP+wADcAsf+wADcAsv+wADcAtP+wADcAtf/OADcAtv/OADcAt//OADcAuP/OADcA5v+8ADcBAf/YADcBAv+wADcBgP/RADcCYf/FADcCYv/FADcCZ/+yADcCa/+yADcCbf+yADcChP/YADgAA//qADgABv/QADgAB//qADgADf+qADgAEP/LADgAFv/LADgAIQAQADgAI//LADgAJ//LADgAL//LADgAMf/LADgAQf/dADgAQ//aADgARP/aADgARf/aADgARv/YADgAR//aADgAT//aADgAUf/aADgAVP/CADgAVf/OADgAVv+9ADgAWf+9ADgAaf/PADgAfAAQADgAfQAQADgAfgAQADgAfwAQADgAgAAQADgAgQAQADgAggAQADgAg//LADgAjv/LADgAj//LADgAkP/LADgAkf/LADgAkv/LADgAlP/LADgAnP/dADgAnv/dADgAn//dADgAoP/dADgAof/dADgAov/dADgAo//aADgApP/aADgApf/aADgApv/aADgAp//aADgArv/aADgAr//aADgAsP/aADgAsf/aADgAsv/aADgAtP/aADgAtf/OADgAtv/OADgAt//OADgAuP/OADgBAf/LADgBAv/aADgBgP/YADgCYf+qADgCYv+qADgCY//qADgCZP/qADgCZf/qADgCZv/qADgCbf/PADgChP/LADkAA//nADkABv+iADkAB//nADkADP+SADkADf+GADkADv+SADkAD/9IADkAEP+8ADkAFv+8ADkAIf9sADkAI/+8ADkAJ/+8ADkAKv9IADkAL/+8ADkAMf+8ADkAM//XADkAQf9XADkAQ/9tADkARP9tADkARf9tADkARv+aADkAR/9tADkASv/wADkATf+RADkATv+RADkAT/9tADkAUf9tADkAUv+DADkAU/93ADkAVP+jADkAVf+RADkAVv+jADkAWP+TADkAWf+nADkAWv+fADkAaf+yADkAfP9sADkAff9sADkAfv9sADkAf/9sADkAgP9sADkAgf9sADkAgv9sADkAg/+8ADkAjv+8ADkAj/+8ADkAkP+8ADkAkf+8ADkAkv+8ADkAlP+8ADkAnP9XADkAnv9XADkAn/9XADkAoP9XADkAof9XADkAov9XADkAo/9tADkApP9tADkApf9tADkApv9tADkAp/9tADkArf+RADkArv9tADkAr/9tADkAsP9tADkAsf9tADkAsv9tADkAtP9tADkAtf+RADkAtv+RADkAt/+RADkAuP+RADkA5v+RADkBAf+8ADkBAv9tADkBbP/GADkBgP+aADkCYf+GADkCYv+GADkCY//nADkCZP/nADkCZf/nADkCZv/nADkCZ/+SADkCa/+SADkCbf+yADkCbv+fADkChP+8ADoADf/LADoAEP/tADoAFv/tADoAI//tADoAJ//tADoAL//tADoAMf/tADoAVP/jADoAVf/vADoAVv/dADoAWf/dADoAg//tADoAjv/tADoAj//tADoAkP/tADoAkf/tADoAkv/tADoAlP/tADoAtf/vADoAtv/vADoAt//vADoAuP/vADoBAf/tADoCYf/LADoCYv/LADoChP/tADsASgBOAEEAA//oAEEAB//oAEEAH//ZAEEARv/xAEEAVP/xAEEAVv/VAEEAWf/VAEEBgP/xAEECY//oAEECZP/oAEECZf/oAEECZv/oAEIAA//oAEIAB//oAEIADP/wAEIADv/wAEIAD//ZAEIAH//ZAEIAVv/fAEIAWP/ZAEIAWf/gAEICY//oAEICZP/oAEICZf/oAEICZv/oAEICZ//wAEICa//wAEICbv/tAEMAH//ZAEUAH//eAEUAVv/nAEUAWP/rAEUAWf/nAEUCbv/tAEYADP+5AEYADv+5AEYAQf/WAEYASv/dAEYAnP/WAEYAnv/WAEYAn//WAEYAoP/WAEYAof/WAEYAov/WAEYCZ/+5AEYCa/+5AEcAH//VAEcASgAaAEgAA//oAEgAB//oAEgAH//ZAEgARv/xAEgAVv/VAEgAWf/VAEgBgP/xAEgCY//oAEgCZP/oAEgCZf/oAEgCZv/oAEoASgAbAEsABv/xAEsADf/mAEsAH//sAEsAQ//rAEsARP/rAEsARf/rAEsAR//rAEsAT//rAEsAUf/rAEsAWAAXAEsAaf/pAEsAo//rAEsApP/rAEsApf/rAEsApv/rAEsAp//rAEsArv/rAEsAr//rAEsAsP/rAEsAsf/rAEsAsv/rAEsAtP/rAEsBAv/rAEsCYf/mAEsCYv/mAEsCbf/pAE0AA//oAE0AB//oAE0AH//ZAE0AVP/xAE0AVv/VAE0AWf/VAE0CY//oAE0CZP/oAE0CZf/oAE0CZv/oAE4AA//oAE4AB//oAE4AH//ZAE4ARv/xAE4AVP/xAE4AVv/VAE4AWf/VAE4BgP/xAE4CY//oAE4CZP/oAE4CZf/oAE4CZv/oAE8AA//oAE8AB//oAE8ADP/wAE8ADv/wAE8AD//ZAE8AH//ZAE8AVv/fAE8AWP/ZAE8AWf/gAE8CY//oAE8CZP/oAE8CZf/oAE8CZv/oAE8CZ//wAE8Ca//wAE8Cbv/tAFAAA//oAFAAB//oAFAADP/wAFAADv/wAFAAD//ZAFAAH//ZAFAAVv/fAFAAWP/ZAFAAWf/gAFACY//oAFACZP/oAFACZf/oAFACZv/oAFACZ//wAFACa//wAFACbv/tAFIADP+7AFIADv+7AFIAH//tAFIAQf/qAFIAUv/qAFIAnP/qAFIAnv/qAFIAn//qAFIAoP/qAFIAof/qAFIAov/qAFICZ/+7AFICa/+7AFMAH//jAFYABv/PAFYADP+8AFYADv+8AFYAD/+fAFYAH//jAFYAQf/bAFYAQ//SAFYARP/SAFYARf/SAFYAR//SAFYAT//SAFYAUf/SAFYAUv/gAFYAaf/ZAFYAnP/bAFYAnv/bAFYAn//bAFYAoP/bAFYAof/bAFYAov/bAFYAo//SAFYApP/SAFYApf/SAFYApv/SAFYAp//SAFYArv/SAFYAr//SAFYAsP/SAFYAsf/SAFYAsv/SAFYAtP/SAFYBAv/SAFYCZ/+8AFYCa/+8AFYCbf/ZAFgADf/hAFgAH//tAFgAQ//aAFgARP/aAFgARf/aAFgAR//aAFgAT//aAFgAUf/aAFgAaf/ZAFgAo//aAFgApP/aAFgApf/aAFgApv/aAFgAp//aAFgArv/aAFgAr//aAFgAsP/aAFgAsf/aAFgAsv/aAFgAtP/aAFgBAv/aAFgCYf/hAFgCYv/hAFgCbf/ZAFkABv/PAFkADP+8AFkADv+8AFkAD/+fAFkAH//jAFkAQf/bAFkAQ//SAFkARP/SAFkARf/SAFkAR//SAFkAT//SAFkAUf/SAFkAUv/gAFkAaf/ZAFkAnP/bAFkAnv/bAFkAn//bAFkAoP/bAFkAof/bAFkAov/bAFkAo//SAFkApP/SAFkApf/SAFkApv/SAFkAp//SAFkArv/SAFkAr//SAFkAsP/SAFkAsf/SAFkAsv/SAFkAtP/SAFkBAv/SAFkCZ/+8AFkCa/+8AFkCbf/ZAFoAH//RAFoAaf/uAFoCbf/uAFsASgBEAHcAIf/jAHcANP+7AHcANv+MAHcAN/+8AHcAOP/OAHcAOf+MAHcAVv/ZAHcAWf/gAHcAfP/jAHcAff/jAHcAfv/jAHcAf//jAHcAgP/jAHcAgf/jAHcAgv/jAIMADf/VAIMAQ//sAIMARP/sAIMARf/sAIMARv/mAIMAR//sAIMAT//sAIMAUf/sAIMAVP/kAIMAVv/jAIMAWf/ZAIMAo//sAIMApP/sAIMApf/sAIMApv/sAIMAp//sAIMArv/sAIMAr//sAIMAsP/sAIMAsf/sAIMAsv/sAIMAtP/sAIMBAv/sAIMBgP/mAIMCYf/VAIMCYv/VAI4ADP/mAI4ADv/mAI4AD//PAI4AF//vAI4AIf/CAI4AKv/qAI4ANP/wAI4ANv/BAI4AN//YAI4AOP/LAI4AOf+8AI4AOv/uAI4AfP/CAI4Aff/CAI4Afv/CAI4Af//CAI4AgP/CAI4Agf/CAI4Agv/CAI4CZ//mAI4Ca//mAI8ADP/mAI8ADv/mAI8AD//PAI8AF//vAI8AIf/CAI8AKv/qAI8ANP/wAI8ANv/BAI8AN//YAI8AOP/LAI8AOf+8AI8AOv/uAI8AfP/CAI8Aff/CAI8Afv/CAI8Af//CAI8AgP/CAI8Agf/CAI8Agv/CAI8CZ//mAI8Ca//mAJAADP/mAJAADv/mAJAAD//PAJAAF//vAJAAIf/CAJAAKv/qAJAANP/wAJAANv/BAJAAN//YAJAAOP/LAJAAOf+8AJAAOv/uAJAAfP/CAJAAff/CAJAAfv/CAJAAf//CAJAAgP/CAJAAgf/CAJAAgv/CAJACZ//mAJACa//mAJEADP/mAJEADv/mAJEAD//PAJEAF//vAJEAIf/CAJEAKv/qAJEANP/wAJEANv/BAJEAN//YAJEAOP/LAJEAOf+8AJEAOv/uAJEAfP/CAJEAff/CAJEAfv/CAJEAf//CAJEAgP/CAJEAgf/CAJEAgv/CAJECZ//mAJECa//mAJIADP/mAJIADv/mAJIAD//PAJIAF//vAJIAIf/CAJIAKv/qAJIANP/wAJIANv/BAJIAN//YAJIAOP/LAJIAOf+8AJIAOv/uAJIAfP/CAJIAff/CAJIAfv/CAJIAf//CAJIAgP/CAJIAgf/CAJIAgv/CAJICZ//mAJICa//mAJQADP/mAJQADv/mAJQAD//PAJQAF//vAJQAIf/CAJQAKv/qAJQANP/wAJQANv/BAJQAN//YAJQAOP/LAJQAOf+8AJQAOv/uAJQAfP/CAJQAff/CAJQAfv/CAJQAf//CAJQAgP/CAJQAgf/CAJQAgv/CAJQCZ//mAJQCa//mAJUABv/uAJUADP/mAJUADv/mAJUAD//PAJUAGf/rAJUAIf/CAJUAKv/qAJUAQf/pAJUAfP/CAJUAff/CAJUAfv/CAJUAf//CAJUAgP/CAJUAgf/CAJUAgv/CAJUAnP/pAJUAnv/pAJUAn//pAJUAoP/pAJUAof/pAJUAov/pAJUCZ//mAJUCa//mAJYABv/uAJYADP/mAJYADv/mAJYAD//PAJYAGf/rAJYAIf/CAJYAKv/qAJYAQf/pAJYAfP/CAJYAff/CAJYAfv/CAJYAf//CAJYAgP/CAJYAgf/CAJYAgv/CAJYAnP/pAJYAnv/pAJYAn//pAJYAoP/pAJYAof/pAJYAov/pAJYCZ//mAJYCa//mAJcABv/uAJcADP/mAJcADv/mAJcAD//PAJcAGf/rAJcAIf/CAJcAKv/qAJcAQf/pAJcAfP/CAJcAff/CAJcAfv/CAJcAf//CAJcAgP/CAJcAgf/CAJcAgv/CAJcAnP/pAJcAnv/pAJcAn//pAJcAoP/pAJcAof/pAJcAov/pAJcCZ//mAJcCa//mAJgABv/uAJgADP/mAJgADv/mAJgAD//PAJgAGf/rAJgAIf/CAJgAKv/qAJgAQf/pAJgAfP/CAJgAff/CAJgAfv/CAJgAf//CAJgAgP/CAJgAgf/CAJgAgv/CAJgAnP/pAJgAnv/pAJgAn//pAJgAoP/pAJgAof/pAJgAov/pAJgCZ//mAJgCa//mAJsAA//oAJsAB//oAJsADP/wAJsADv/wAJsAD//ZAJsAH//ZAJsAVv/fAJsAWP/ZAJsAWf/gAJsCY//oAJsCZP/oAJsCZf/oAJsCZv/oAJsCZ//wAJsCa//wAJsCbv/tAJwAA//oAJwAB//oAJwAH//ZAJwARv/xAJwAVv/VAJwAWf/VAJwCY//oAJwCZP/oAJwCZf/oAJwCZv/oAJ0AA//oAJ0AB//oAJ0AH//ZAJ0AVv/VAJ0AWf/VAJ0CY//oAJ0CZP/oAJ0CZf/oAJ0CZv/oAJ4AA//oAJ4AB//oAJ4AH//ZAJ4AVv/VAJ4AWf/VAJ4CY//oAJ4CZP/oAJ4CZf/oAJ4CZv/oAJ8AA//oAJ8AB//oAJ8AH//ZAJ8AVv/VAJ8AWf/VAJ8BgP/xAJ8CY//oAJ8CZP/oAJ8CZf/oAJ8CZv/oAKAAA//oAKAAB//oAKAAH//ZAKAARv/xAKAAVP/xAKAAVv/VAKAAWf/VAKABgP/xAKACY//oAKACZP/oAKACZf/oAKACZv/oAKEAA//oAKEAB//oAKEAH//ZAKEARv/xAKEAVP/xAKEAVv/VAKEAWf/VAKEBgP/xAKECY//oAKECZP/oAKECZf/oAKECZv/oAKIAH//eAKIAVv/nAKIAWP/rAKIAWf/nAKICbv/tAKMAH//ZAKQAH//eAKQAVv/nAKQAWP/rAKQAWf/nAKQCbv/tAKUAH//eAKUAVv/nAKUAWP/rAKUAWf/nAKUCbv/tAKYAH//eAKYAVv/nAKYAWP/rAKYAWf/nAKYCbv/tAKcAH//eAKcAVv/nAKcAWP/rAKcAWf/nAKcCbv/tAK0AA//oAK0AB//oAK0AH//ZAK0AVv/VAK0AWf/VAK0CY//oAK0CZP/oAK0CZf/oAK0CZv/oAK4AA//oAK4AB//oAK4ADP/wAK4ADv/wAK4AD//ZAK4AH//ZAK4AVv/fAK4AWP/ZAK4AWf/gAK4CY//oAK4CZP/oAK4CZf/oAK4CZv/oAK4CZ//wAK4Ca//wAK4Cbv/tAK8AA//oAK8AB//oAK8ADP/wAK8ADv/wAK8AD//ZAK8AH//ZAK8AVv/fAK8AWP/ZAK8AWf/gAK8CY//oAK8CZP/oAK8CZf/oAK8CZv/oAK8CZ//wAK8Ca//wAK8Cbv/tALAAA//oALAAB//oALAADP/wALAADv/wALAAD//ZALAAH//ZALAAVv/fALAAWP/ZALAAWf/gALACY//oALACZP/oALACZf/oALACZv/oALACZ//wALACa//wALACbv/tALEAA//oALEAB//oALEADP/wALEADv/wALEAD//ZALEAH//ZALEAVv/fALEAWP/ZALEAWf/gALECY//oALECZP/oALECZf/oALECZv/oALECZ//wALECa//wALECbv/tALIAA//oALIAB//oALIADP/wALIADv/wALIAD//ZALIAH//ZALIAVv/fALIAWP/ZALIAWf/gALICY//oALICZP/oALICZf/oALICZv/oALICZ//wALICa//wALICbv/tALQAA//oALQAB//oALQADP/wALQADv/wALQAD//ZALQAH//ZALQAVv/fALQAWP/ZALQAWf/gALQCY//oALQCZP/oALQCZf/oALQCZv/oALQCZ//wALQCa//wALQCbv/tALsABv/PALsADP+8ALsADv+8ALsAD/+fALsAH//jALsAQf/bALsAQ//SALsARP/SALsARf/SALsAR//SALsAT//SALsAUf/SALsAUv/gALsAaf/ZALsAnP/bALsAnv/bALsAn//bALsAoP/bALsAof/bALsAov/bALsAo//SALsApP/SALsApf/SALsApv/SALsAp//SALsArv/SALsAr//SALsAsP/SALsAsf/SALsAsv/SALsAtP/SALsBAv/SALsCZ/+8ALsCa/+8ALsCbf/ZAQIAH//eAQIAVv/nAQIAWP/rAQIAWf/nAQICbv/tAWwANP/uAWwAOf/GAmEADf/SAmEAD//GAmEAEf+9AmEAEv/dAmEAFAASAmEAF/+CAmEAGf/rAmEAIf+4AmEAKv/cAmEAM//vAmEANP+FAmEANv+UAmEAN//FAmEAOP+qAmEAOf+GAmEAOv/pAmEASv/xAmEAWP/hAmEAWv/uAmEAfP+4AmEAff+4AmEAfv+4AmEAf/+4AmEAgP+4AmEAgf+4AmEAgv+4AmECYf/SAmECYv/SAmIADf/SAmIAD//GAmIAEf+9AmIAEv/dAmIAFAASAmIAF/+CAmIAGf/rAmIAIf+4AmIAKv/cAmIAM//vAmIANP+FAmIANv+UAmIAN//FAmIAOP+qAmIAOf+GAmIAOv/pAmIASv/xAmIAWP/hAmIAWv/uAmIAfP+4AmIAff+4AmIAfv+4AmIAf/+4AmIAgP+4AmIAgf+4AmIAgv+4AmICYf/SAmICYv/SAmMADP/ZAmMADv/ZAmMAD/+fAmMAFP+oAmMAGP/vAmMAIf9MAmMAKv94AmMAQf/BAmMAQ//KAmMARP/KAmMARf/KAmMAR//KAmMAT//KAmMAUf/KAmMAU//kAmMAWv/qAmMAfP9MAmMAff9MAmMAfv9MAmMAf/9MAmMAgP9MAmMAgf9MAmMAgv9MAmMAnP/BAmMAnv/BAmMAn//BAmMAoP/BAmMAof/BAmMAov/BAmMAo//KAmMApP/KAmMApf/KAmMApv/KAmMAp//KAmMArv/KAmMAr//KAmMAsP/KAmMAsf/KAmMAsv/KAmMAtP/KAmMBAv/KAmMCZ//ZAmMCa//ZAmQADP/ZAmQADv/ZAmQAD/+fAmQAFP+oAmQAGP/vAmQAIf9MAmQAKv94AmQAQf/BAmQAQ//KAmQARP/KAmQARf/KAmQAR//KAmQAT//KAmQAUf/KAmQAU//kAmQAWv/qAmQAfP9MAmQAff9MAmQAfv9MAmQAf/9MAmQAgP9MAmQAgf9MAmQAgv9MAmQAnP/BAmQAnv/BAmQAn//BAmQAoP/BAmQAof/BAmQAov/BAmQAo//KAmQApP/KAmQApf/KAmQApv/KAmQAp//KAmQArv/KAmQAr//KAmQAsP/KAmQAsf/KAmQAsv/KAmQAtP/KAmQBAv/KAmQCZ//ZAmQCa//ZAmUADP/ZAmUADv/ZAmUAD/+fAmUAFP+oAmUAGP/vAmUAIf9MAmUAKv94AmUAQf/BAmUAQ//KAmUARP/KAmUARf/KAmUAR//KAmUAT//KAmUAUf/KAmUAU//kAmUAWv/qAmUAfP9MAmUAff9MAmUAfv9MAmUAf/9MAmUAgP9MAmUAgf9MAmUAgv9MAmUAnP/BAmUAnv/BAmUAn//BAmUAoP/BAmUAof/BAmUAov/BAmUAo//KAmUApP/KAmUApf/KAmUApv/KAmUAp//KAmUArv/KAmUAr//KAmUAsP/KAmUAsf/KAmUAsv/KAmUAtP/KAmUBAv/KAmUCZ//ZAmUCa//ZAmYADP/ZAmYADv/ZAmYAD/+fAmYAFP+oAmYAGP/vAmYAIf9MAmYAKv94AmYAQf/BAmYAQ//KAmYARP/KAmYARf/KAmYAR//KAmYAT//KAmYAUf/KAmYAU//kAmYAWv/qAmYAfP9MAmYAff9MAmYAfv9MAmYAf/9MAmYAgP9MAmYAgf9MAmYAgv9MAmYAnP/BAmYAnv/BAmYAn//BAmYAoP/BAmYAof/BAmYAov/BAmYAo//KAmYApP/KAmYApf/KAmYApv/KAmYAp//KAmYArv/KAmYAr//KAmYAsP/KAmYAsf/KAmYAsv/KAmYAtP/KAmYBAv/KAmYCZ//ZAmYCa//ZAmcAA//ZAmcAB//ZAmcAEP/mAmcAEf+1AmcAFP/sAmcAFv/mAmcAF/+yAmcAGP/wAmcAGf/YAmcAI//mAmcAJ//mAmcAL//mAmcAMf/mAmcANP92AmcANf/mAmcANv+IAmcAN/+yAmcAOf+SAmcAQ//wAmcARP/wAmcARf/wAmcARv/PAmcAR//wAmcASv/wAmcAT//wAmcAUf/wAmcAVP/JAmcAVf/xAmcAVv+8AmcAWf+8AmcAg//mAmcAjv/mAmcAj//mAmcAkP/mAmcAkf/mAmcAkv/mAmcAlP/mAmcAlf/mAmcAlv/mAmcAl//mAmcAmP/mAmcAo//wAmcApP/wAmcApf/wAmcApv/wAmcAp//wAmcArv/wAmcAr//wAmcAsP/wAmcAsf/wAmcAsv/wAmcAtP/wAmcBAf/mAmcBAv/wAmcBgP/PAmcCY//ZAmcCZP/ZAmcCZf/ZAmcCZv/ZAmcChP/mAmsAA//ZAmsAB//ZAmsAEP/mAmsAEf+1AmsAFP/sAmsAFv/mAmsAF/+yAmsAGP/wAmsAGf/YAmsAI//mAmsAJ//mAmsAL//mAmsAMf/mAmsANP92AmsANf/mAmsANv+IAmsAN/+yAmsAOf+SAmsAQ//wAmsARP/wAmsARf/wAmsARv/PAmsAR//wAmsASv/wAmsAT//wAmsAUf/wAmsAVP/JAmsAVv+8AmsAWf+8AmsAg//mAmsAjv/mAmsAj//mAmsAkP/mAmsAkf/mAmsAkv/mAmsAlP/mAmsAlf/mAmsAlv/mAmsAl//mAmsAmP/mAmsAo//wAmsApP/wAmsApf/wAmsApv/wAmsAp//wAmsArv/wAmsAr//w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ABL/9AAX/+8AGf/zAB//+wAq/+oANv/BAEr/+AF8/9MBrP//AAgABv/RAA//dAAf//UAKv9iADb/zgBK//gBeP/vAXz/2QALAA//zwAR//sAEv/0ABf/7wAZ//MAH//7ACr/6gA2/8EASv/4AXz/0wGs//8AAwAf/+oANv/BAEr/+gADAA//4wAq//8BrP/jAAoABv/JAA//agAfAA8AKv/aADYACABK/+4BbP/uAXr/9AGs//ECbv/jAAYABv/uAA//zwAV//wAGf/rACr/6gBK//gABgAG/5wAD/8+ACr/SwA2AAgASv/wAm7/xgAFAAb/wwAP/4wAKv+EADYACABK//YAAwAG/9ABeP/uAXr/2AALAAb/ogAP/0gAKv9IADYACABK//ABbP/GAXj//AF6/8MBfP/jAaz/sgJu/58AAgAG//YBev/6AAEASgBOAAMAH//ZAEr//QG9//MABAAP/9kAH//ZAXz/2QJu/+0AAQAf/9kAAwAf/94ASv/8Am7/7QADAB8ABwBK/90CbgAJAAIAH//VAEoAGgADAB//2QBK//0Bvf/zAAEASgAbAAQABv/xAB//7AF8ABABvf/ZAAMAH//ZAEr//QG9//MAAwAf/9kASv/9Ab3/8wAEAA//2QAf/9kBfP/ZAm7/7QAEAA//2QAf/9kBfP/ZAm7/7QAEAB//7QBK//QBfP/WAm4ADAACAB//4wBK//QAAgAf//wASv/6AAUABv/PAA//nwAf/+MASv/0AXz/rwABAB//7QAFAAb/zwAP/58AH//jAEr/9AF8/68AAQAf/9EAAQBKAEQAAgA2/4wBrP/uAAEABv/6AAsAD//PABH/+wAS//QAF//vABn/8wAf//sAKv/qADb/wQBK//gBfP/TAaz//wALAA//zwAR//sAEv/0ABf/7wAZ//MAH//7ACr/6gA2/8EASv/4AXz/0wGs//8ACwAP/88AEf/7ABL/9AAX/+8AGf/zAB//+wAq/+oANv/BAEr/+AF8/9MBrP//AAsAD//PABH/+wAS//QAF//vABn/8wAf//sAKv/qADb/wQBK//gBfP/TAaz//wALAA//zwAR//sAEv/0ABf/7wAZ//MAH//7ACr/6gA2/8EASv/4AXz/0wGs//8ACwAP/88AEf/7ABL/9AAX/+8AGf/zAB//+wAq/+oANv/BAEr/+AF8/9MBrP//AAsAD//PABH/+wAS//QAF//vABn/8wAf//sAKv/qADb/wQBK//gBfP/TAaz//wAGAAb/7gAP/88AFf/8ABn/6wAq/+oASv/4AAYABv/uAA//zwAV//wAGf/rACr/6gBK//gABgAG/+4AD//PABX//AAZ/+sAKv/qAEr/+AAGAAb/7gAP/88AFf/8ABn/6wAq/+oASv/4AAsABv+iAA//SAAq/0gANgAIAEr/8AFs/8YBeP/8AXr/wwF8/+MBrP+yAm7/nwALAA//zwAR//sAEv/0ABf/7wAZ//MAH//7ACr/6gA2/8EASv/4AXz/0wGs//8ABAAP/9kAH//ZAXz/2QJu/+0AAwAf/9kASv/9Ab3/8wADAB//2QBK//0Bvf/zAAMAH//ZAEr//QG9//MAAwAf/9kASv/9Ab3/8wADAB//2QBK//0Bvf/zAAMAH//ZAEr//QG9//MAAwAf/94ASv/8Am7/7QABAB//2QADAB//3gBK//wCbv/tAAMAH//eAEr//AJu/+0AAwAf/94ASv/8Am7/7QADAB//3gBK//wCbv/tAAEBfP/NAAMAH//ZAEr//QG9//MABAAP/9kAH//ZAXz/2QJu/+0ABAAP/9kAH//ZAXz/2QJu/+0ABAAP/9kAH//ZAXz/2QJu/+0ABAAP/9kAH//ZAXz/2QJu/+0ABAAP/9kAH//ZAXz/2QJu/+0ABAAP/9kAH//ZAXz/2QJu/+0ABQAG/88AD/+fAB//4wBK//QBfP+vAAQAD//ZAB//2QF8/9kCbv/tAAUABv/PAA//nwAf/+MASv/0AXz/rwADAB//2QBK//0Bvf/zAAMAH//ZAEr//QG9//MAAwAf/9kASv/9Ab3/8wABAAb/+gABAB//2QABAAb/+gABAB//2QABAAb/+gABAB//2QALAA//zwAR//sAEv/0ABf/7wAZ//MAH//7ACr/6gA2/8EASv/4AXz/0wGs//8AAwAf/94ASv/8Am7/7QADAB//3gBK//wCbv/tAAMAH//eAEr//AJu/+0AAwAf/94ASv/8Am7/7QADAB//3gBK//wCbv/tAAMAH//ZAEr//QG9//MABgAG/+4AD//PABX//AAZ/+sAKv/qAEr/+AACAAb/3wAqABkABAAG//EAH//sAXwAEAG9/9kABAAG//wAH//LACoACwA2/08ABAAG//wAH//LACoACwA2/08ABAAG//wAH//LACoACwA2/08AAwAf/9kASv/9Ab3/8wADAB//2QBK//0Bvf/zAAMAH//ZAEr//QG9//MAAwAf/9kASv/9Ab3/8wALAA//zwAR//sAEv/0ABf/7wAZ//MAH//7ACr/6gA2/8EASv/4AXz/0wGs//8ABAAP/9kAH//ZAXz/2QJu/+0ACwAP/88AEf/7ABL/9AAX/+8AGf/zAB//+wAq/+oANv/BAEr/+AF8/9MBrP//AAQAD//ZAB//2QF8/9kCbv/tAAsAD//PABH/+wAS//QAF//vABn/8wAf//sAKv/qADb/wQBK//gBfP/TAaz//wAEAA//2QAf/9kBfP/ZAm7/7QADAB//3gBK//wCbv/tAAMAH//qADb/wQBK//oABAAf/+0ASv/0AXz/1gJuAAwAAwAf/+oANv/BAEr/+gAEAB//7QBK//QBfP/WAm4ADAADAB//6gA2/8EASv/6AAQAH//tAEr/9AF8/9YCbgAMAAMAD//jACr//wGs/+MAAgAf/+MASv/0AAMAD//jACr//wGs/+MAAgAf/+MASv/0AAMAD//jACr//wGs/+MAAgAf/+MASv/0AAoABv/JAA//agAfAA8AKv/aADYACABK/+4BbP/uAXr/9AGs//ECbv/jAAIAH//8AEr/+gAKAAb/yQAP/2oAHwAPACr/2gA2AAgASv/uAWz/7gF6//QBrP/xAm7/4wAGAAb/7gAP/88AFf/8ABn/6wAq/+oASv/4AAYABv/uAA//zwAV//wAGf/rACr/6gBK//gABgAG/+4AD//PABX//AAZ/+sAKv/qAEr/+AAGAAb/7gAP/88AFf/8ABn/6wAq/+oASv/4AAYABv/uAA//zwAV//wAGf/rACr/6gBK//gABQAG/8MAD/+MACr/hAA2AAgASv/2AAsABv+iAA//SAAq/0gANgAIAEr/8AFs/8YBeP/8AXr/wwF8/+MBrP+yAm7/nwAFAAb/zwAP/58AH//jAEr/9AF8/68AAgAG//YBev/6AAEAH//RAAIABv/2AXr/+gABAB//0QACAAb/9gF6//oAAQAf/9EACwAP/88AEf/7ABL/9AAX/+8AGf/zAB//+wAq/+oANv/BAEr/+AF8/9MBrP//AAQAD//ZAB//2QF8/9kCbv/tAAMAH//ZAEr//QG9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Aij/4wIq/+MCLP/jAi7/4wIw/+MCMv/jAjj/4wI6/+MCPP/jAj7/4wJA/+MCQv/jAkT/4wJG/+MCSP/jAkr/4wJM/+MCTv/jAlD/7gJS/+4CVP/uAlb/7gJY/+4CWv/uAlz/7gJd/4kCX/+JAmH/+wJi//sBBAAN/8YAEP/PABb/zwAh/zQAI//PACf/zwAv/88AMf/PADP/2QBB/24AQ/+MAET/jABF/4wARv/ZAEf/jABN/58ATv+fAE//jABR/4wAU/+gAFT/xgBV/58AVv/GAFj/qQBZ/8YAWv+fAHz/NAB9/zQAfv80AH//NACA/zQAgf80AIL/NACD/88Ajv/PAI//zwCQ/88Akf/PAJL/zwCU/88AnP9uAJ7/bgCf/24AoP9uAKH/bgCi/24Ao/+MAKT/jACl/4wApv+MAKf/jACs/58Arf+fAK7/jACv/4wAsP+MALH/jACy/4wAtP+MALX/nwC2/58At/+fALj/nwC5/8YAvP80AL3/bgC+/zQAv/9uAMD/NADB/24Awv/PAMP/jADE/88Axf+MAMb/zwDH/4wAyf+MAMr/jADM/4wAzv+MAND/jADS/4wA1P+MANX/zwDW/4wA1//PANj/jADZ/88A2v+MAOb/nwD0/58A9v+fAPj/nwD6/58A+//PAPz/jAD9/88A/v+MAP//zwEA/4wBAf/PAQL/jAEJ/9kBCv+gAQv/2QEM/6ABDf/ZAQ7/oAEQ/8YBEv/GARb/nwEY/58BGv+fARz/nwEe/58BIv/GASX/nwEn/58BKf+fASv/zwEv/88BMP+MATL/nwEz/4wBNP+MATf/jAE5/58BQP+fAWb/NAFn/88BaP80AW7/jAFw/9kBcf+fAXP/jAF5/9kBe/+fAX3/nwGA/9kBgv+MAYP/jAGE/6wBiP+fAYv/jAGN/58Bkf9iAZr/YgGf/2IBov/PAa3/nwGu/58Br/+fAbH/qQGz/58Btf+fAbf/nwG4/58Buf+fAbr/rAG7/4wBvP+fAb7/nwG//58BwP+sAcH/nwHC/58BxP+fAcf/nwHI/4wByv+fAcz/nwHN/58Bz/+fAdH/nwHV/6kB2f+fAd3/nwHe/88B3/+MAeD/xgHk/6kB6f+fAev/nwHs/88B7f+MAfD/YgH0/4wB9v+MAfz/nwH+/58CAv/GAgr/nwIL/zQCDP9uAg3/NAIO/24CD/80AhD/bgIR/zQCEv9uAhP/NAIU/24CFf80Ahb/bgIX/zQCGP9uAhn/NAIa/24CG/80Ahz/bgId/zQCHv9uAh//NAIg/24CIf80AiL/bgIk/4wCJv+MAij/jAIq/4wCLP+MAi7/jAIw/4wCMv+MAjf/zwI4/4wCOf/PAjr/jAI7/88CPP+MAj3/zwI+/4wCP//PAkD/jAJB/88CQv+MAkP/zwJE/4wCRf/PAkb/jAJH/88CSP+MAkn/zwJK/4wCS//PAkz/jAJN/88CTv+MAlD/nwJS/58CVP+fAlb/nwJY/58CWv+fAlz/nwJe/8YCYP/GAmH/xgJi/8YChP/PAC0ADf/6ABD/+gAW//oAI//6ACf/+gAv//oAMf/6AIP/+gCO//oAj//6AJD/+gCR//oAkv/6AJT/+gDC//oAxP/6AMb/+gDV//oA1//6ANn/+gD7//oA/f/6AP//+gEB//oBK//6AS//+gFn//oBov/6Ad7/+gHs//oCN//6Ajn/+gI7//oCPf/6Aj//+gJB//oCQ//6AkX/+gJH//oCSf/6Akv/+gJN//oCYf/6AmL/+gKE//oADQAD/7wAB/+8AAz/9AANAAgADv/0AmEACAJiAAgCY/+8AmT/vAJl/7wCZv+8Amf/9AJr//QACgAD/+EAB//hAAz/9QAO//UCY//hAmT/4QJl/+ECZv/hAmf/9QJr//UAMQAM/5gADf/VAA7/mAAQ/+oAFv/qACP/6gAn/+oAL//qADH/6gCD/+oAjv/qAI//6gCQ/+oAkf/qAJL/6gCU/+oAwv/qAMT/6gDG/+oA1f/qANf/6gDZ/+oA+//qAP3/6gD//+oBAf/qASv/6gEv/+oBZ//qAaL/6gHe/+oB7P/qAjf/6gI5/+oCO//qAj3/6gI//+oCQf/qAkP/6gJF/+oCR//qAkn/6gJL/+oCTf/qAmH/1QJi/9UCZ/+YAmv/mAKE/+oBEwAD/14AB/9eAA3/uAAQ/8IAFv/CACEAEAAj/8IAJ//CAC//wgAx/8IANP99ADX/wgA3/48AOAARADn/bABB/+kAQ//hAET/4QBF/+EARv/XAEf/4QBP/+EAUf/hAFT/tABV/9MAVv+ZAFf/xgBYAAsAWf+jAGn/zwB8ABAAfQAQAH4AEAB/ABAAgAAQAIEAEACCABAAg//CAI7/wgCP/8IAkP/CAJH/wgCS/8IAlP/CAJX/wgCW/8IAl//CAJj/wgCZ/2wAnP/pAJ7/6QCf/+kAoP/pAKH/6QCi/+kAo//hAKT/4QCl/+EApv/hAKf/4QCs/9MArv/hAK//4QCw/+EAsf/hALL/4QC0/+EAtf/TALb/0wC3/9MAuP/TALn/owC8ABAAvf/pAL4AEAC//+kAwAAQAMH/6QDC/8IAw//hAMT/wgDF/+EAxv/CAMf/4QDJ/+EAyv/hAMz/4QDO/+EA0P/hANL/4QDU/+EA1f/CANb/4QDX/8IA2P/hANn/wgDa/+EA+//CAPz/4QD9/8IA/v/hAP//wgEA/+EBAf/CAQL/4QEP/30BEP+0ARH/fQES/7QBFf/CARb/0wEX/8IBGP/TARn/wgEa/9MBG//CARz/0wEd/8IBHv/TAR//jwEg/8YBIf9sASL/owEr/8IBL//CATD/4QEx/8IBMv/TATP/4QE0/+EBN//hAWYAEAFn/8IBaAAQAWv/aAFu/+EBcP/XAXH/0wFz/+EBdf/EAXn/1wF7/9MBfv/EAYD/1wGC/+EBg//hAYT/lAGF/9kBhv/EAYf/2QGI/9MBi//hAYz/2QGN/9MBjv99AZEAEQGT/30Blv/ZAZoAEQGbABEBnwARAaH/2QGi/8IBpP9oAaf/fQGt/9MBsQALAbr/lAG7/+EBwP+UAcj/4QHUABEB1QALAdr/fQHe/8IB3//hAeD/mQHjABEB5AALAez/wgHt/+EB7v/ZAfAAEQH0/+EB9v/hAgH/fQIC/7QCA/+PAgT/xgIF/48CBv/GAgf/jwII/8YCCwAQAgz/6QINABACDv/pAg8AEAIQ/+kCEQAQAhL/6QITABACFP/pAhUAEAIW/+kCFwAQAhj/6QIZABACGv/pAhsAEAIc/+kCHQAQAh7/6QIfABACIP/pAiEAEAIi/+kCJP/hAib/4QIo/+ECKv/hAiz/4QIu/+ECMP/hAjL/4QI3/8ICOP/hAjn/wgI6/+ECO//CAjz/4QI9/8ICPv/hAj//wgJA/+ECQf/CAkL/4QJD/8ICRP/hAkX/wgJG/+ECR//CAkj/4QJJ/8ICSv/hAkv/wgJM/+ECTf/CAk7/4QJP/8ICUP/TAlH/wgJS/9MCU//CAlT/0wJV/8ICVv/TAlf/wgJY/9MCWf/CAlr/0wJb/8ICXP/TAl3/bAJe/6MCX/9sAmD/owJh/7gCYv+4AmP/XgJk/14CZf9eAmb/XgJt/88ChP/CALQADP+wAA7/sAAQ//8AFv//ACH/nAAj//8AJ///AC///wAx//8AM//8AEH/4ABD//QARP/0AEX/9ABH//QAT//0AFH/9ABY//oAWf/8AFr/+AB8/5wAff+cAH7/nAB//5wAgP+cAIH/nACC/5wAg///AI7//wCP//8AkP//AJH//wCS//8AlP//AJz/4ACe/+AAn//gAKD/4ACh/+AAov/gAKP/9ACk//QApf/0AKb/9ACn//QArv/0AK//9ACw//QAsf/0ALL/9AC0//QAuf/8ALz/nAC9/+AAvv+cAL//4ADA/5wAwf/gAML//wDD//QAxP//AMX/9ADG//8Ax//0AMn/9ADK//QAzP/0AM7/9ADQ//QA0v/0ANT/9ADV//8A1v/0ANf//wDY//QA2f//ANr/9AD7//8A/P/0AP3//wD+//QA////AQD/9AEB//8BAv/0AQn//AEL//wBDf/8ASL//AEl//gBJ//4ASn/+AEr//8BL///ATD/9AEz//QBNP/0ATf/9AFm/5wBZ///AWj/nAFu//QBc//0AYL/9AGD//QBi//0AaL//wGx//oBu//0Acj/9AHV//oB3v//Ad//9AHk//oB7P//Ae3/9AH0//QB9v/0Agr/+AIL/5wCDP/gAg3/nAIO/+ACD/+cAhD/4AIR/5wCEv/gAhP/nAIU/+ACFf+cAhb/4AIX/5wCGP/gAhn/nAIa/+ACG/+cAhz/4AId/5wCHv/gAh//nAIg/+ACIf+cAiL/4AIk//QCJv/0Aij/9AIq//QCLP/0Ai7/9AIw//QCMv/0Ajf//wI4//QCOf//Ajr/9AI7//8CPP/0Aj3//wI+//QCP///AkD/9AJB//8CQv/0AkP//wJE//QCRf//Akb/9AJH//8CSP/0Akn//wJK//QCS///Akz/9AJN//8CTv/0Al7//AJg//wCZ/+wAmv/sAKE//8A0QAM/4EADf/8AA7/gQAQ//8AFv//ACH/jwAj//8AJ///AC///wAx//8ANP/2ADf/+gA4/8EAOf/VADr/6gBB/8cAQ//sAET/7ABF/+wAR//sAE//7ABR/+wAUv/sAGn/2QB8/48Aff+PAH7/jwB//48AgP+PAIH/jwCC/48Ag///AI7//wCP//8AkP//AJH//wCS//8AlP//AJn/1QCc/8cAnv/HAJ//xwCg/8cAof/HAKL/xwCj/+wApP/sAKX/7ACm/+wAp//sAK7/7ACv/+wAsP/sALH/7ACy/+wAtP/sALz/jwC9/8cAvv+PAL//xwDA/48Awf/HAML//wDD/+wAxP//AMX/7ADG//8Ax//sAMn/7ADK/+wAzP/sAM7/7ADQ/+wA0v/sANT/7ADV//8A1v/sANf//wDY/+wA2f//ANr/7AD7//8A/P/sAP3//wD+/+wA////AQD/7AEB//8BAv/sAQT/7AEG/+wBCP/sAQ//9gER//YBH//6ASH/1QEk/+oBJv/qASj/6gEr//8BL///ATD/7AEz/+wBNP/sATf/7AFm/48BZ///AWj/jwFu/+wBc//sAYH/7AGC/+wBg//sAYv/7AGO//YBkf+HAZP/9gGW/94Bmv+HAZv/wQGc//cBn/+HAaH/3gGi//8Bp//2Aar/9wG7/+wByP/sAdT/wQHW//cB2v/2Ad7//wHf/+wB4//BAez//wHt/+wB7v/eAfD/hwH0/+wB9v/sAgD/7AIB//YCA//6AgX/+gIH//oCC/+PAgz/xwIN/48CDv/HAg//jwIQ/8cCEf+PAhL/xwIT/48CFP/HAhX/jwIW/8cCF/+PAhj/xwIZ/48CGv/HAhv/jwIc/8cCHf+PAh7/xwIf/48CIP/HAiH/jwIi/8cCJP/sAib/7AIo/+wCKv/sAiz/7AIu/+wCMP/sAjL/7AI3//8COP/sAjn//wI6/+wCO///Ajz/7AI9//8CPv/sAj///wJA/+wCQf//AkL/7AJD//8CRP/sAkX//wJG/+wCR///Akj/7AJJ//8CSv/sAkv//wJM/+wCTf//Ak7/7AJd/9UCX//VAmH//AJi//wCZ/+BAmv/gQJt/9kChP//ARsADP+IAA3/lAAO/4gAEP/BABb/wQAh/08AI//BACf/wQAv/8EAMf/BADP/2gA0AAgANwAIADkACABB/5cAQ/+GAET/hgBF/4YARv+8AEf/hgBN/7EATv+xAE//hgBR/4YAUv+VAFP/mgBU/74AVf+hAFb/vABY/7wAWf+8AFr/sgBp/4wAfP9PAH3/TwB+/08Af/9PAID/TwCB/08Agv9PAIP/wQCO/8EAj//BAJD/wQCR/8EAkv/BAJT/wQCZAAgAnP+XAJ7/lwCf/5cAoP+XAKH/lwCi/5cAo/+GAKT/hgCl/4YApv+GAKf/hgCs/6EArf+xAK7/hgCv/4YAsP+GALH/hgCy/4YAtP+GALX/oQC2/6EAt/+hALj/oQC5/7wAvP9PAL3/lwC+/08Av/+XAMD/TwDB/5cAwv/BAMP/hgDE/8EAxf+GAMb/wQDH/4YAyf+GAMr/hgDM/4YAzv+GAND/hgDS/4YA1P+GANX/wQDW/4YA1//BANj/hgDZ/8EA2v+GAOb/sQD0/7EA9v+xAPj/sQD6/7EA+//BAPz/hgD9/8EA/v+GAP//wQEA/4YBAf/BAQL/hgEE/5UBBv+VAQj/lQEJ/9oBCv+aAQv/2gEM/5oBDf/aAQ7/mgEPAAgBEP++AREACAES/74BFv+hARj/oQEa/6EBHP+hAR7/oQEfAAgBIQAIASL/vAEl/7IBJ/+yASn/sgEr/8EBL//BATD/hgEy/6EBM/+GATT/hgE3/4YBOf+xAUD/sQFm/08BZ//BAWj/TwFu/4YBcP+8AXH/oQFz/4YBef+8AXv/oQF9/7EBgP+8AYH/lQGC/4YBg/+GAYj/oQGL/4YBjf+hAY4ACAGTAAgBov/BAacACAGt/6EBrv+xAa//sQGx/7wBs/+xAbX/sQG3/7EBuP+xAbn/sQG7/4YBvP+xAb7/sQG//7EBwf+xAcL/sQHE/7EBx/+xAcj/hgHK/7EBzP+xAc3/sQHP/7EB0f+xAdX/vAHZ/7EB2gAIAd3/sQHe/8EB3/+GAeD/vAHk/7wB6f+xAev/sQHs/8EB7f+GAfT/hgH2/4YB/P+xAf7/sQIA/5UCAQAIAgL/vgIDAAgCBQAIAgcACAIK/7ICC/9PAgz/lwIN/08CDv+XAg//TwIQ/5cCEf9PAhL/lwIT/08CFP+XAhX/TwIW/5cCF/9PAhj/lwIZ/08CGv+XAhv/TwIc/5cCHf9PAh7/lwIf/08CIP+XAiH/TwIi/5cCJP+GAib/hgIo/4YCKv+GAiz/hgIu/4YCMP+GAjL/hgI3/8ECOP+GAjn/wQI6/4YCO//BAjz/hgI9/8ECPv+GAj//wQJA/4YCQf/BAkL/hgJD/8ECRP+GAkX/wQJG/4YCR//BAkj/hgJJ/8ECSv+GAkv/wQJM/4YCTf/BAk7/hgJQ/6ECUv+hAlT/oQJW/6ECWP+hAlr/oQJc/6ECXQAIAl7/vAJfAAgCYP+8AmH/lAJi/5QCZ/+IAmv/iAJt/4wChP/BAHQADP+5AA3/+AAO/7kAQf/WAEP//ABE//wARf/8AEYACABH//wAT//8AFH//ABS//wAU//9AFQACACc/9YAnv/WAJ//1gCg/9YAof/WAKL/1gCj//wApP/8AKX//ACm//wAp//8AK7//ACv//wAsP/8ALH//ACy//wAtP/8AL3/1gC//9YAwf/WAMP//ADF//wAx//8AMn//ADK//wAzP/8AM7//ADQ//wA0v/8ANT//ADW//wA2P/8ANr//AD8//wA/v/8AQD//AEC//wBBP/8AQb//AEI//wBCv/9AQz//QEO//0BEAAIARIACAEw//wBM//8ATT//AE3//wBbv/8AXAACAFz//wBeQAIAYAACAGB//wBgv/8AYP//AGL//wBu//8Acj//AHf//wB7f/8AfT//AH2//wCAP/8AgIACAIM/9YCDv/WAhD/1gIS/9YCFP/WAhb/1gIY/9YCGv/WAhz/1gIe/9YCIP/WAiL/1gIk//wCJv/8Aij//AIq//wCLP/8Ai7//AIw//wCMv/8Ajj//AI6//wCPP/8Aj7//AJA//wCQv/8AkT//AJG//wCSP/8Akr//AJM//wCTv/8AmH/+AJi//gCZ/+5Amv/uQAEAEYADQFwAA0BeQANAYAADQAYAFX/7ACs/+wAtf/sALb/7AC3/+wAuP/sARb/7AEY/+wBGv/sARz/7AEe/+wBMv/sAXH/7AF7/+wBiP/sAY3/7AGt/+wCUP/sAlL/7AJU/+wCVv/sAlj/7AJa/+wCXP/sABoAVf/lAKz/5QC1/+UAtv/lALf/5QC4/+UBFv/lARj/5QEa/+UBHP/lAR7/5QEy/+UBb//sAXH/5QF3/+wBe//lAYj/5QGN/+UBrf/lAlD/5QJS/+UCVP/lAlb/5QJY/+UCWv/lAlz/5QACAW//6gF3/+oAjAAh/2gAOP/tAEP/0gBE/9IARf/SAEf/0gBN/+wATv/sAE//0gBR/9IAUv/QAHz/aAB9/2gAfv9oAH//aACA/2gAgf9oAIL/aACj/9IApP/SAKX/0gCm/9IAp//SAK3/7ACu/9IAr//SALD/0gCx/9IAsv/SALT/0gC8/2gAvv9oAMD/aADD/9IAxf/SAMf/0gDJ/9IAyv/SAMz/0gDO/9IA0P/SANL/0gDU/9IA1v/SANj/0gDa/9IA5v/sAPT/7AD2/+wA+P/sAPr/7AD8/9IA/v/SAQD/0gEC/9IBBP/QAQb/0AEI/9ABMP/SATP/0gE0/9IBN//SATn/7AFA/+wBZv9oAWj/aAFu/9IBc//SAX3/7AGB/9ABgv/SAYP/0gGL/9IBm//tAa7/7AGv/+wBs//sAbX/7AG3/+wBuP/sAbn/7AG7/9IBvP/sAb7/7AG//+wBwf/sAcL/7AHE/+wBx//sAcj/0gHK/+wBzP/sAc3/7AHP/+wB0f/sAdT/7QHZ/+wB3f/sAd//0gHj/+0B6f/sAev/7AHt/9IB9P/SAfb/0gH8/+wB/v/sAgD/0AIL/2gCDf9oAg//aAIR/2gCE/9oAhX/aAIX/2gCGf9oAhv/aAId/2gCH/9oAiH/aAIk/9ICJv/SAij/0gIq/9ICLP/SAi7/0gIw/9ICMv/SAjj/0gI6/9ICPP/SAj7/0gJA/9ICQv/SAkT/0gJG/9ICSP/SAkr/0gJM/9ICTv/SAA8ANP/uADn/xgCZ/8YBD//uARH/7gEh/8YBa//2AY7/7gGT/+4BpP/2Aaf/7gHa/+4CAf/uAl3/xgJf/8YAAwF1//QBfv/0AYb/9AADAXX/7QF+/+0Bhv/tAAYAUv/9AQT//QEG//0BCP/9AYH//QIA//0AawBD/9QARP/UAEX/1ABG/+0AR//UAE//1ABR/9QAVf/GAFb/ugCj/9QApP/UAKX/1ACm/9QAp//UAKz/xgCu/9QAr//UALD/1ACx/9QAsv/UALT/1AC1/8YAtv/GALf/xgC4/8YAw//UAMX/1ADH/9QAyf/UAMr/1ADM/9QAzv/UAND/1ADS/9QA1P/UANb/1ADY/9QA2v/UAPz/1AD+/9QBAP/UAQL/1AEW/8YBGP/GARr/xgEc/8YBHv/GATD/1AEy/8YBM//UATT/1AE3/9QBbv/UAW//2QFw/+0Bcf/GAXP/1AF3/9kBef/tAXv/xgGA/+0Bgv/UAYP/1AGE/7oBhf/BAYf/wQGI/8YBi//UAYz/wQGN/8YBrf/GAbr/ugG7/9QBwP+6Acj/1AHf/9QB4P+6Ae3/1AH0/9QB9v/UAiT/1AIm/9QCKP/UAir/1AIs/9QCLv/UAjD/1AIy/9QCOP/UAjr/1AI8/9QCPv/UAkD/1AJC/9QCRP/UAkb/1AJI/9QCSv/UAkz/1AJO/9QCUP/GAlL/xgJU/8YCVv/GAlj/xgJa/8YCXP/GAAIBb//2AXf/9gB0AAP/nwAH/58AQ//ZAET/2QBF/9kARv/xAEf/2QBP/9kAUf/ZAFX/3gBW/7QAo//ZAKT/2QCl/9kApv/ZAKf/2QCs/94Arv/ZAK//2QCw/9kAsf/ZALL/2QC0/9kAtf/eALb/3gC3/94AuP/eAMP/2QDF/9kAx//ZAMn/2QDK/9kAzP/ZAM7/2QDQ/9kA0v/ZANT/2QDW/9kA2P/ZANr/2QD8/9kA/v/ZAQD/2QEC/9kBFv/eARj/3gEa/94BHP/eAR7/3gEw/9kBMv/eATP/2QE0/9kBN//ZAW7/2QFv//ABcP/xAXH/3gFz/9kBdf/YAXf/8AF5//EBe//eAX7/2AGA//EBgv/ZAYP/2QGE/7IBhf/LAYb/2AGH/8sBiP/eAYv/2QGM/8sBjf/eAa3/3gG6/7IBu//ZAcD/sgHI/9kB3//ZAeD/tAHt/9kB9P/ZAfb/2QIk/9kCJv/ZAij/2QIq/9kCLP/ZAi7/2QIw/9kCMv/ZAjj/2QI6/9kCPP/ZAj7/2QJA/9kCQv/ZAkT/2QJG/9kCSP/ZAkr/2QJM/9kCTv/ZAlD/3gJS/94CVP/eAlb/3gJY/94CWv/eAlz/3gJj/58CZP+fAmX/nwJm/58AYgBD/9QARP/UAEX/1ABH/9QAT//UAFH/1ABV/9kAo//UAKT/1ACl/9QApv/UAKf/1ACs/9kArv/UAK//1ACw/9QAsf/UALL/1AC0/9QAtf/ZALb/2QC3/9kAuP/ZAMP/1ADF/9QAx//UAMn/1ADK/9QAzP/UAM7/1ADQ/9QA0v/UANT/1ADW/9QA2P/UANr/1AD8/9QA/v/UAQD/1AEC/9QBFv/ZARj/2QEa/9kBHP/ZAR7/2QEw/9QBMv/ZATP/1AE0/9QBN//UAW7/1AFv/84Bcf/ZAXP/1AF3/84Be//ZAYL/1AGD/9QBhf/PAYf/zwGI/9kBi//UAYz/zwGN/9kBrf/ZAbv/1AHI/9QB3//UAe3/1AH0/9QB9v/UAiT/1AIm/9QCKP/UAir/1AIs/9QCLv/UAjD/1AIy/9QCOP/UAjr/1AI8/9QCPv/UAkD/1AJC/9QCRP/UAkb/1AJI/9QCSv/UAkz/1AJO/9QCUP/ZAlL/2QJU/9kCVv/ZAlj/2QJa/9kCXP/ZAEUAQ//7AET/+wBF//sAR//7AE//+wBR//sAo//7AKT/+wCl//sApv/7AKf/+wCu//sAr//7ALD/+wCx//sAsv/7ALT/+wDD//sAxf/7AMf/+wDJ//sAyv/7AMz/+wDO//sA0P/7ANL/+wDU//sA1v/7ANj/+wDa//sA/P/7AP7/+wEA//sBAv/7ATD/+wEz//sBNP/7ATf/+wFu//sBc//7AYL/+wGD//sBi//7Abv/+wHI//sB3//7Ae3/+wH0//sB9v/7AiT/+wIm//sCKP/7Air/+wIs//sCLv/7AjD/+wIy//sCOP/7Ajr/+wI8//sCPv/7AkD/+wJC//sCRP/7Akb/+wJI//sCSv/7Akz/+wJO//sARwBD/88ARP/PAEX/zwBH/88AT//PAFH/zwCj/88ApP/PAKX/zwCm/88Ap//PAK7/zwCv/88AsP/PALH/zwCy/88AtP/PAMP/zwDF/88Ax//PAMn/zwDK/88AzP/PAM7/zwDQ/88A0v/PANT/zwDW/88A2P/PANr/zwD8/88A/v/PAQD/zwEC/88BMP/PATP/zwE0/88BN//PAW7/zwFv/80Bc//PAXf/zQGC/88Bg//PAYv/zwG7/88ByP/PAd//zwHt/88B9P/PAfb/zwIk/88CJv/PAij/zwIq/88CLP/PAi7/zwIw/88CMv/PAjj/zwI6/88CPP/PAj7/zwJA/88CQv/PAkT/zwJG/88CSP/PAkr/zwJM/88CTv/PAA0AWP/8AFn/6QC5/+kBIv/pAbD/+wGx//wBtv/7Acn/+wHV//wB5P/8AfH/+wJe/+kCYP/pAAoAVv/kAFn/4QC5/+EBIv/hAYT/+wG6//sBwP/7AeD/5AJe/+ECYP/hABAAWP/vAFn/1gC5/9YBIv/WAYT/+wGw//wBsf/vAbb//AG6//sBwP/7Acn//AHV/+8B5P/vAfH//AJe/9YCYP/WAJgAIQAKADT/4wA3/+MAOf/GAEH/5wBD/+0ARP/tAEX/7QBGABEAR//tAE//7QBR/+0AVgASAFkACgB8AAoAfQAKAH4ACgB/AAoAgAAKAIEACgCCAAoAmf/GAJz/5wCe/+cAn//nAKD/5wCh/+cAov/nAKP/7QCk/+0Apf/tAKb/7QCn/+0Arv/tAK//7QCw/+0Asf/tALL/7QC0/+0AuQAKALwACgC9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AdkB2gHcAd0B3gHfAeAB4wHkAeUB5gHoAewB7QHuAe8B8wH1AfgB+QH8Af4B/wIAAgECAgIDAgUCBwIKAgwCDgIQAhICFAIWAhgCGgIcAh4CIAIiAiQCJgIoAioCLAIuAjACMgI3AjgCOQI6AjsCPAI9Aj4CPwJAAkECQgJDAkQCTwJRAl0CXgJfAmACYQJiAmMCZAJlAmYCZwJrAm0CbgABAB4ABgAPABIAFAAWABcAIQAmADAANgBGAGkBXQFmAWgBawFsAXEBdAF2AXgBegF8AX8BggGGAa0BrgGyAm0AAQEkAAMABwAMAA0ADgAQABMAFQAYABkAIgAjACQAKgArACwALwAxADIAMwA0ADUANwA4ADkAOgBBAEIAQwBFAEgASwBNAE4ATwBQAFIAUwBUAFYAWABZAFoAdwCDAIwAjgCPAJAAkQCSAJQAlQCWAJcAmACZAJoAmwCcAJ0AngCfAKAAoQCiAKMApAClAKYApwCsAK0ArgCvALAAsQCyALQAuQC6ALsAvQC/AMEAwgDDAMQAxQDGAMcAyADMAM4A0ADSANQA3ADnAOkA6gDrAO0A8QD0APYA+AD6APsA/AD9AP4A/wEAAQIBAwEEAQUBBgEHAQgBCQEKAQsBDAENAQ4BDwEQAREBFQEXARkBGwEdAR8BIQEiASQBJQEmAScBKAEpASsBMwE5AUABYgFnAWoBbgFwAXMBdQF5AXsBfQF+AYABgQGDAYQBhQGHAYgBiwGMAY0BjwGQAZEBkgGUAZYBmAGZAZoBmwGcAaEBogGjAaYBpwGpAaoBqwGvAbABsQG1AboBuwG8Ab8BwAHCAcMBxAHGAccByAHJAcoBzAHOAdAB0QHUAdUB1gHYAdkB2gHcAd0B3gHfAeAB4wHkAeUB5gHoAewB7QHuAe8B8wH1AfgB+QH8Af4B/wIAAgECAgIDAgUCBwIKAgwCDgIQAhICFAIWAhgCGgIcAh4CIAIiAiQCJgIoAioCLAIuAjACMgI3AjgCOQI6AjsCPAI9Aj4CPwJAAkECQgJDAkQCTwJRAl0CXgJfAmACYQJiAmMCZAJlAmYCZwJrAm4AAQADAmwAIAAAAAAAAAAgAAAAAAAAAAAAHwAhAB8AAAAEAAAAAAAAAAAACAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAEABAAAAAAAAAAAAAAACAACAAMAAAAAAAQAAAAEAAUABgAHAAgAAAAJAAoACwAMAAAAAAAAAAAAAAAAABAAEQANAAAADgAAAAAAEAAAAAAADwAAABAAEAARABEAAAASABMAFAAAABUAAAAWABUAFwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAQAAAAEAAQABAAEAAQAAAAEAAgACAAIAAgACwAEABEAEAAQABAAEAAQABAADgANAA4ADgAOAA4AAAAAAAAAAAAeABAAEQARABEAEQARAAAAEQAAAAAAAAAAABUAEQAVAAAAEAAAABAAAAAQAAEADQABAA0AAQANAAQAAAAAAAAADgAAAA4AAAAOAAAADgAAAA4AAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAIADwADAAAAAwAAAAAAAAADAAAAAAAQAAAAEAAAABAAAAAQAAQAEQAEABEABAARAAAADgAFABIABQASAAUAEgAGABMABgATAAYAEwAHABQABwAAAAAAAAAIAAAACAAAAAgAAAAIAAAACAAAAAkAAAALABUAAAAMABcADAAXAAwAFwAAAAQAAAAAAAAAAAAAAAAAAAARAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAQAAAAAAAEAAAAAAAAAGAAAABAAAAAAABgAAAAVAAAAAAAAABAAAAAYAAAAGAAVAAAAFAARAAAAEgASAB4AAAAeAB4AAAAAABEAHgAeAAAABwABABwAHAAAAAIAAAAaAAAAHAAHABsACgAAAAAAAAAAAAAAGgAEABsAAAAAABsAHAAAABwABAAEAAAAAAAAABkAIwAWAAAAAAAAAA8AAAAAAAAAAAAZABEAIwAAAAAAIwAdAAAAHQARABEAAAAQABkADQAdAB0AAAAPAAAAFQAAAAcAGQAAAAAAGwAjAAAAAAAbACMAAgAAABsAIwABAA0AFQAAAAAAGwAjABsAIwAAAAIAAAAAAAAABAARABoAFQAAAAAAAAAEAAAABAAAAAAAEAADAAAAAAAQAAAAEAAFABIABwAUAAkAAAAJAAAACQAAAAAAFwAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAAA4AAAAOAAAADgAAAA4AAAAOAAAADgAAAA4AAAAOAAAAAAAAAAAABAARAAQAEQAEABEABAARAAQAEQAEABEABAARAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAsAFQALABUAIQAhACAAIAAgACAAHwAAAAAAAAAfAAAAAAAiAAEAAwKCAAoAAAAAAAAACgAAAAAAAAAAAAEACwABAAAAGQAAAAAAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAAZAAAAAAAAABkAAAAAAAAAAAAAAAAAAAAZAAAAGQAAAB8AAwAbAAAABAAMAAUABgAAAAAAAAAAAAAAAAAIAAAAFQAVABUABwAVAAAAAAAAAAAAAAAgACAAFQAAABUAIQAQAA8AFgARABoADQAXAB0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgACAAIAAgACAAIAAgAZAAAAAAAAAAAAAAAAAAAAAAAAAAAAGQAZABkAGQAZAAAAGQAbABsAGwAbAAUAAAAAAAgAAAAIAAgACAAIAAgAFQAVABUAFQAVAAAAAAAAAAAAFgAgABUAFQAVABUAFQAAABUAFgAWABYAFgAXAAAAAAACAAgAAgAIAAIACAAZABUAGQAVABkAFQAAABUAFQAAABUAAAAVAAAAFQAAABUAAAAVABkAFQAZABUAGQAVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAACAAAAAgAAAAIAAZABUAGQAVABkAFQAZABUAAAAhAAAAIQAAACEAHwAQAB8AEAAfABAAAwAPAAMADwAAAAAAGwAWABsAFgAbABYAGwAWABsAFgAEABoABQAXAAAABgAdAAYAHQAGAB0AAAAZAAAAAAAAABkAFQAbABYAFQAVAAAAAAAVAAAAIAAAAAAAAAAAAAAAAAAg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ByAHJwcuBzUHPAdDB0oHUQdYB18HZgdtB3QHeweCB4kHkAeXB54HpQesB7MHugfBB8gHzwfWB90H5AfrB/IH+QgACAcIDggVCBwIIwgqCDEIOAg/CEYITQhUCFsIYghpCHAIdwh+CIUIjAiTCJoIoQioCK8Itgi9CMMIyQjPCNUI3gjnCO4I9Qj8CQMJCgkRCRgJHwkmCS0JNAk7CUIJSQlQCVcJXgllCWwJcwl6CYEJiAmPCZYJnQmkCasJsgm5CcAJxwnOCdUJ3AnjCeoJ8Qn4Cf8KBgoNChQKGwoiCikKMAo3Cj4KRQpMClMKWgphCmgKbwp2Cn0KhAqLCpIKmQqgCqcKrgq1CrwKwwrKCtEK2ArfCuYK7Qr0CvsLAgsJCxALFwseCyULLAszCzkLPwtGC00LVAtbC18LYwtqC3ELeAt/C4YLjQuUC5sLogupC7ALtQu8C8MLygvRC9gL3wvmC+0L+Av/DAgMDwwXDB8MKgwyDDsMRwxODFsMaAx4DIUMkgygDLIMvwzTDN8M8Az1DPcNFw0pDTdBbWFjcm9uYW1hY3JvbkFicmV2ZWFicmV2ZUFvZ29uZWthb2dvbmVrQ2FjdXRlY2FjdXRlQ2RvdGFjY2VudGNkb3RhY2NlbnRDY2Fyb25jY2Fyb25EY2Fyb25kY2Fyb25kbWFjcm9uRW1hY3JvbmVtYWNyb25FYnJldmVlYnJldmVFZG90YWNjZW50ZWRvdGFjY2VudEVvZ29uZWtlb2dvbmVrRWNhcm9uZWNhcm9uR2JyZXZlZ2JyZXZlR2RvdGFjY2VudGdkb3RhY2NlbnRHY29tbWFhY2NlbnRnY29tbWFhY2NlbnRIYmFyaGJhckl0aWxkZWl0aWxkZUltYWNyb25pbWFjcm9uSWJyZXZlaWJyZXZlSW9nb25la2lvZ29uZWtJZG90YWNjZW50SUppaktjb21tYWFjY2VudGtjb21tYWFjY2VudExhY3V0ZWxhY3V0ZUxjb21tYWFjY2VudGxjb21tYWFjY2VudExjYXJvbmxjYXJvbk5hY3V0ZW5hY3V0ZU5jb21tYWFjY2VudG5jb21tYWFjY2VudE5jYXJvbm5jYXJvbkVuZ2VuZ09tYWNyb25vbWFjcm9uT2JyZXZlb2JyZXZlT2h1bmdhcnVtbGF1dG9odW5nYXJ1bWxhdXRSYWN1dGVyYWN1dGVSY29tbWFhY2NlbnRyY29tbWFhY2NlbnRSY2Fyb25yY2Fyb25TYWN1dGVzYWN1dGVTY2VkaWxsYXNjZWRpbGxhVGNlZGlsbGF0Y2VkaWxsYVRjYXJvbnRjYXJvblRiYXJ0YmFyVXRpbGRldXRpbGRlVW1hY3JvbnVtYWNyb25VcmluZ3VyaW5nVWh1bmdhcnVtbGF1dHVodW5nYXJ1bWxhdXRVb2dvbmVrdW9nb25la1djaXJjdW1mbGV4d2NpcmN1bWZsZXhZY2lyY3VtZmxleHljaXJjdW1mbGV4WmFjdXRlemFjdXRlWmRvdGFjY2VudHpkb3RhY2NlbnR1bmkwMTgwdW5pMDE4RnVuaTAxOTR1bmkwMTlEdW5pMDFBMHVuaTAxQTF1bmkwMUFGdW5pMDFCMHVuaTAxRER1bmkwMUU3dW5pMDFGMHVuaTAxRjR1bmkwMUY1dW5pMDFGOHVuaTAxRjlkb3RsZXNzanVuaTAyNDF1bmkwMjQydW5pMDI0Q3VuaTAyNER1bmkwMjYzdW5pMDI3MmdyYXZlY29tYmFjdXRlY29tYnVuaTAzMDJ0aWxkZWNvbWJ1bmkwMzA0dW5pMDMwNnVuaTAzMDd1bmkwMzA4aG9va2Fib3ZlY29tYnVuaTAzMEF1bmkwMzBCdW5pMDMwQ3VuaTAzMTN1bmkwMzFCZG90YmVsb3djb21idW5pMDMyNnVuaTAzMjh1bmkwMzJEdG9ub3NkaWVyZXNpc3Rvbm9zQWxwaGF0b25vc2Fub3RlbGVpYUVwc2lsb250b25vc0V0YXRvbm9zSW90YXRvbm9zT21pY3JvbnRvbm9zVXBzaWxvbnRvbm9zT21lZ2F0b25vc2lvdGFkaWVyZXNpc3Rvbm9zRGVsdGFUaGV0YUxhbWJkYVhpU2lnbWFQc2lPbWVnYVVwc2lsb25kaWVyZXNpc2FscGhhdG9ub3NlcHNpbG9udG9ub3NldGF0b25vc2lvdGF0b25vc3Vwc2lsb25kaWVyZXNpc3Rvbm9zYWxwaGFiZXRhZ2FtbWFkZWx0YWVwc2lsb256ZXRhZXRhdGhldGFpb3RhbGFtYmRhbnV4aXBpcmhvc2lnbWExc2lnbWF0YXV1cHNpbG9uY2hpcHNpb21lZ2Fpb3RhZGllcmVzaXN1cHNpbG9uZGllcmVzaXNvbWljcm9udG9ub3N1cHNpbG9udG9ub3NvbWVnYXRvbm9zdW5pMDQwMnVuaTA0MDN1bmkwNDA0dW5pMDQwOXVuaTA0MEF1bmkwNDBCdW5pMDQwQ3VuaTA0MER1bmkwNDBFdW5pMDQwRnVuaTA0MTF1bmkwNDEzdW5pMDQxNHVuaTA0MTZ1bmkwNDE3dW5pMDQxOHVuaTA0MTl1bmkwNDFCdW5pMDQxRnVuaTA0MjN1bmkwNDI0dW5pMDQyNnVuaTA0Mjd1bmkwNDI4dW5pMDQyOXVuaTA0MkF1bmkwNDJCdW5pMDQyQ3VuaTA0MkR1bmkwNDJFdW5pMDQyRnVuaTA0MzF1bmkwNDMydW5pMDQzM3VuaTA0MzR1bmkwNDM2dW5pMDQzN3VuaTA0Mzh1bmkwNDM5dW5pMDQzQXVuaTA0M0J1bmkwNDNDdW5pMDQzRHVuaTA0M0Z1bmkwNDQydW5pMDQ0NHVuaTA0NDZ1bmkwNDQ3dW5pMDQ0OHVuaTA0NDl1bmkwNDRBdW5pMDQ0QnVuaTA0NEN1bmkwNDREdW5pMDQ0RXVuaTA0NEZ1bmkwNDUydW5pMDQ1M3VuaTA0NTR1bmkwNDU5dW5pMDQ1QXVuaTA0NUJ1bmkwNDVDdW5pMDQ1RHVuaTA0NUV1bmkwNDVGdW5pMDQ5MHVuaTA0OTF1bmkwNDkydW5pMDQ5M3VuaTA0OTZ1bmkwNDk3dW5pMDQ5OHVuaTA0OTl1bmkwNDlBdW5pMDQ5QnVuaTA0QTB1bmkwNEExdW5pMDRBMnVuaTA0QTN1bmkwNEFBdW5pMDRBQnVuaTA0QUZ1bmkwNEIwdW5pMDRCMXVuaTA0QjJ1bmkwNEIzdW5pMDRCNnVuaTA0Qjd1bmkwNEJBdW5pMDRDM3VuaTA0QzR1bmkwNEM3dW5pMDRDOHVuaTA0RTh1bmkwNEU5dW5pMDRFRXVuaTA0RUZ1bmkwNTEydW5pMDUxM3VuaTA1OEZ1bmkxRTBDdW5pMUUwRHVuaTFFMTJ1bmkxRTEzdW5pMUUyNHVuaTFFMjV1bmkxRTNDdW5pMUUzRHVuaTFFNDR1bmkxRTQ1dW5pMUU0QXVuaTFFNEJ1bmkxRTVBdW5pMUU1QnVuaTFFNkN1bmkxRTZEV2dyYXZld2dyYXZlV2FjdXRld2FjdXRlV2RpZXJlc2lzd2RpZXJlc2lzdW5pMUU5MnVuaTFFOTN1bmkxRUEwdW5pMUVBMXVuaTFFQTJ1bmkxRUEzdW5pMUVBNHVuaTFFQTV1bmkxRUE2dW5pMUVBN3VuaTFFQTh1bmkxRUE5dW5pMUVBQXVuaTFFQUJ1bmkxRUFDdW5pMUVBRHVuaTFFQUV1bmkxRUFGdW5pMUVCMHVuaTFFQjF1bmkxRUIydW5pMUVCM3VuaTFFQjR1bmkxRUI1dW5pMUVCNnVuaTFFQjd1bmkxRUI4dW5pMUVCOXVuaTFFQkF1bmkxRUJCdW5pMUVCQ3VuaTFFQkR1bmkxRUJFdW5pMUVCRnVuaTFFQzB1bmkxRUMxdW5pMUVDMnVuaTFFQzN1bmkxRUM0dW5pMUVDNXVuaTFFQzZ1bmkxRUM3dW5pMUVDOHVuaTFFQzl1bmkxRUNBdW5pMUVDQnVuaTFFQ0N1bmkxRUNEdW5pMUVDRXVuaTFFQ0Z1bmkxRUQwdW5pMUVEMXVuaTFFRDJ1bmkxRUQzdW5pMUVENHVuaTFFRDV1bmkxRUQ2dW5pMUVEN3VuaTFFRDh1bmkxRUQ5dW5pMUVEQXVuaTFFREJ1bmkxRURDdW5pMUVERHVuaTFFREV1bmkxRURGdW5pMUVFMHVuaTFFRTF1bmkxRUUydW5pMUVFM3VuaTFFRTR1bmkxRUU1dW5pMUVFNnVuaTFFRTd1bmkxRUU4dW5pMUVFOXVuaTFFRUF1bmkxRUVCdW5pMUVFQ3VuaTFFRUR1bmkxRUVFdW5pMUVFRnVuaTFFRjB1bmkxRUYxWWdyYXZleWdyYXZldW5pMUVGNnVuaTFFRjd1bmkyMEE5dW5pMjBBQWRvbmdFdXJvdW5pMjBBRHVuaTIwQUV1bmkyMEIxdW5pMjBCMnVuaTIwQjR1bmkyMEI4dW5pMjBCOXVuaTIwQkF1bmkyMEJDdW5pMjBCRHVuaTIwQkVsaXRyZXVuaTIxMTZ1bmkyMTE3dW5pMjE1NXVuaTIxNTZ1bmkyMTU3dW5pMjE1OHVuaTIxNTl1bmkyMTVBcGFydGlhbGRpZmZwcm9kdWN0c3VtbWF0aW9ucmFkaWNhbGluZmluaXR5aW50ZWdyYWxhcHByb3hlcXVhbG5vdGVxdWFsbGVzc2VxdWFsZ3JlYXRlcmVxdWFsbG96ZW5nZWdyYXZlY29tYi5jYXBhY3V0ZWNvbWIuY2FwZGllcmVzaXNjb21iLmNh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) format('opentype');
  font-weight: normal;
  font-style: normal;
}

        
        @keyframes slideIn {
          from {
            opacity: 0;
            transform: translateX(-20px);
          }
          to {
            opacity: 1;
            transform: translateX(0);
          }
        }
        @keyframes fadeOut {
          from {
            opacity: 1;
          }
          to {
            opacity: 0;
          }
        }
      `}</style>
      
      {/* Top Bar - Compact */}
      <div style={{
        background: 'rgba(30, 41, 59, 0.95)',
        backdropFilter: 'blur(10px)',
        borderBottom: '2px solid rgba(59, 130, 246, 0.3)',
        padding: '0.75rem 1.5rem',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        boxShadow: '0 4px 6px rgba(0,0,0,0.3)',
        position: 'relative',
        zIndex: 100
      }}>
        <div style={{ display: 'flex', gap: '1.5rem', alignItems: 'center' }}>
          {hasStartup && (
            <>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <div style={{ fontSize: '1.5rem' }}>{startupLogo?.icon}</div>
                <div>
                  <div style={{ fontSize: '1rem', fontWeight: '700', color: '#fff' }}>{startupName}</div>
                  <div style={{ fontSize: '0.65rem', color: '#94a3b8' }}>{office}</div>
                </div>
              </div>
            </>
          )}
          
          {!hasStartup && (
            <div style={{ fontSize: '1.25rem', fontWeight: '700', color: '#fff' }}>
              💼 Startup Tycoon
            </div>
          )}
        </div>
        
        <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
          {/* Clock Time Display */}
          <div style={{ fontSize: '1.25rem', fontWeight: '700', color: '#fff', fontFamily: 'monospace' }}>
            {String(gameHour === 0 ? 12 : gameHour > 12 ? gameHour - 12 : gameHour).padStart(2, '0')}:
            {String(gameMinute).padStart(2, '0')} {gameHour >= 12 ? 'PM' : 'AM'}
          </div>
          
          <div style={{ fontSize: '0.875rem', fontWeight: '600', color: '#fff' }}>
            {formatDate(currentDate)}
          </div>
          
          {/* Speed Controls */}
          <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'center' }}>
            <button
              onClick={() => setIsPaused(!isPaused)}
              style={{
                padding: '0.5rem 1rem',
                background: isPaused ? 'linear-gradient(135deg, #10b981 0%, #059669 100%)' : 'linear-gradient(135deg, #ef4444 0%, #dc2626 100%)',
                border: 'none',
                borderRadius: '0.5rem',
                color: '#fff',
                fontWeight: '600',
                cursor: 'pointer',
                fontSize: '0.75rem'
              }}
            >
              {isPaused ? '▶ Play' : '⏸ Pause'}
            </button>
            
            <div style={{ fontSize: '0.75rem', color: '#94a3b8', fontWeight: '600' }}>
              Speed:
            </div>
            {[0.5, 1, 2, 4].map(speed => (
              <button
                key={speed}
                onClick={() => setGameSpeed(speed)}
                style={{
                  padding: '0.5rem 0.75rem',
                  background: gameSpeed === speed ? '#3b82f6' : '#1e293b',
                  border: '2px solid ' + (gameSpeed === speed ? '#3b82f6' : '#334155'),
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '600',
                  cursor: 'pointer',
                  fontSize: '0.7rem'
                }}
              >
                {speed}x
              </button>
            ))}
          </div>
          
          {/* Action Buttons */}
          <div style={{ height: '30px', width: '1px', background: '#475569', margin: '0 0.5rem' }} />
          
          {!currentJob ? (
            <button
              onClick={() => setActivePanel('job')}
              style={{
                padding: '0.5rem 1rem',
                background: 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)',
                border: 'none',
                borderRadius: '0.5rem',
                color: '#fff',
                fontWeight: '700',
                cursor: 'pointer',
                fontSize: '0.75rem'
              }}
            >
              💼 Get a Job
            </button>
          ) : !hasStartup ? (
            <button
              onClick={() => setActivePanel('startup-create')}
              style={{
                padding: '0.5rem 1rem',
                background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
                border: 'none',
                borderRadius: '0.5rem',
                color: '#fff',
                fontWeight: '700',
                cursor: 'pointer',
                fontSize: '0.75rem'
              }}
            >
              🚀 Create Startup
            </button>
          ) : (
            <>
              <button
                onClick={() => setActivePanel(activePanel === 'mvp' ? null : 'mvp')}
                style={{
                  padding: '0.5rem 1rem',
                  background: activePanel === 'mvp' ? 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)' : 'rgba(59, 130, 246, 0.2)',
                  border: activePanel === 'mvp' ? '2px solid #3b82f6' : '2px solid rgba(59, 130, 246, 0.3)',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer',
                  fontSize: '0.75rem'
                }}
              >
                🛠️ MVP
              </button>
              
              {mvpBuilt && (
                <button
                  onClick={() => setActivePanel(activePanel === 'platform' ? null : 'platform')}
                  style={{
                    padding: '0.5rem 1rem',
                    background: activePanel === 'platform' ? 'linear-gradient(135deg, #10b981 0%, #059669 100%)' : 'rgba(16, 185, 129, 0.2)',
                    border: activePanel === 'platform' ? '2px solid #10b981' : '2px solid rgba(16, 185, 129, 0.3)',
                    borderRadius: '0.5rem',
                    color: '#fff',
                    fontWeight: '700',
                    cursor: 'pointer',
                    fontSize: '0.75rem'
                  }}
                >
                  🏗️ Platform
                </button>
              )}
              
              <button
                onClick={() => setActivePanel(activePanel === 'sales' ? null : 'sales')}
                style={{
                  padding: '0.5rem 1rem',
                  background: activePanel === 'sales' ? 'linear-gradient(135deg, #10b981 0%, #059669 100%)' : 'rgba(16, 185, 129, 0.2)',
                  border: activePanel === 'sales' ? '2px solid #10b981' : '2px solid rgba(16, 185, 129, 0.3)',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer',
                  fontSize: '0.75rem'
                }}
              >
                💰 Sales ({prospects.length})
              </button>
              
              <button
                onClick={() => setActivePanel(activePanel === 'team' ? null : 'team')}
                style={{
                  padding: '0.5rem 1rem',
                  background: activePanel === 'team' ? 'linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%)' : 'rgba(139, 92, 246, 0.2)',
                  border: activePanel === 'team' ? '2px solid #8b5cf6' : '2px solid rgba(139, 92, 246, 0.3)',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer',
                  fontSize: '0.75rem'
                }}
              >
                👥 Team ({employees.length + 1})
              </button>
              
              <button
                onClick={() => setActivePanel(activePanel === 'money' ? null : 'money')}
                style={{
                  padding: '0.5rem 1rem',
                  background: activePanel === 'money' ? 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)' : 'rgba(245, 158, 11, 0.2)',
                  border: activePanel === 'money' ? '2px solid #f59e0b' : '2px solid rgba(245, 158, 11, 0.3)',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer',
                  fontSize: '0.75rem'
                }}
              >
                💸 Money
              </button>
              
              <button
                onClick={() => setActivePanel(activePanel === 'checklist' ? null : 'checklist')}
                style={{
                  padding: '0.5rem 1rem',
                  background: activePanel === 'checklist' ? 'linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%)' : 'rgba(139, 92, 246, 0.2)',
                  border: activePanel === 'checklist' ? '2px solid #8b5cf6' : '2px solid rgba(139, 92, 246, 0.3)',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer',
                  fontSize: '0.75rem'
                }}
              >
                ✅ Checklist
              </button>
              
              {currentJob && (
                <button
                  onClick={() => setActivePanel(activePanel === 'job' ? null : 'job')}
                  style={{
                    padding: '0.5rem 1rem',
                    background: activePanel === 'job' ? 'linear-gradient(135deg, #ef4444 0%, #dc2626 100%)' : 'rgba(239, 68, 68, 0.2)',
                    border: activePanel === 'job' ? '2px solid #ef4444' : '2px solid rgba(239, 68, 68, 0.3)',
                    borderRadius: '0.5rem',
                    color: '#fff',
                    fontWeight: '700',
                    cursor: 'pointer',
                    fontSize: '0.75rem'
                  }}
                >
                  💼 Job
                </button>
              )}
            </>
          )}
        </div>
      </div>
      {/* Main Game View - Game Dev Tycoon Style */}
      <div style={{ position: 'relative', height: 'calc(100vh - 60px)', overflow: 'hidden' }}>
        
        {/* Top-Left Corner - Money Stats */}
        <div style={{
          position: 'absolute',
          top: '1rem',
          left: '1rem',
          background: 'rgba(30, 41, 59, 0.95)',
          backdropFilter: 'blur(10px)',
          padding: '1rem',
          borderRadius: '0.75rem',
          border: '2px solid rgba(59, 130, 246, 0.3)',
          minWidth: '380px',
          boxShadow: '0 8px 16px rgba(0,0,0,0.4)',
          zIndex: 50
        }}>
          <div style={{ display: 'flex', gap: '1.5rem' }}>
            {/* Cash Balances */}
            <div style={{ flex: 1 }}>
              <div style={{ marginBottom: '0.75rem' }}>
                <div style={{ fontSize: '0.7rem', color: '#94a3b8', marginBottom: '0.25rem' }}>💵 Personal Cash</div>
                <div style={{ 
                  fontSize: '1.25rem', 
                  fontWeight: '700', 
                  color: personalCash >= 0 ? '#10b981' : '#ef4444' 
                }}>
                  {formatMoney(personalCash)}
                </div>
              </div>
              {hasStartup && (
                <div>
                  <div style={{ fontSize: '0.7rem', color: '#94a3b8', marginBottom: '0.25rem' }}>🏢 Business Cash</div>
                  <div style={{ 
                    fontSize: '1.25rem', 
                    fontWeight: '700', 
                    color: businessCash >= 0 ? '#10b981' : '#ef4444' 
                  }}>
                    {formatMoney(businessCash)}
                  </div>
                </div>
              )}
            </div>
            
            {/* Cash Flow */}
            <div style={{ flex: 1, borderLeft: '1px solid rgba(148, 163, 184, 0.2)', paddingLeft: '1rem' }}>
              <div style={{ marginBottom: '0.75rem' }}>
                <div style={{ fontSize: '0.7rem', color: '#94a3b8', marginBottom: '0.25rem' }}>📈 Personal/mo</div>
                <div style={{ 
                  fontSize: '1.1rem', 
                  fontWeight: '700', 
                  color: personalCashFlow >= 0 ? '#10b981' : '#ef4444' 
                }}>
                  {personalCashFlow >= 0 ? '+' : ''}{formatMoney(personalCashFlow)}
                </div>
              </div>
              {hasStartup && (
                <div>
                  <div style={{ fontSize: '0.7rem', color: '#94a3b8', marginBottom: '0.25rem' }}>📈 Business/mo</div>
                  <div style={{ 
                    fontSize: '1.1rem', 
                    fontWeight: '700', 
                    color: businessCashFlow >= 0 ? '#10b981' : '#ef4444' 
                  }}>
                    {businessCashFlow >= 0 ? '+' : ''}{formatMoney(businessCashFlow)}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
        
        {/* Top-Right Corner - Key Metrics */}
        {hasStartup && (
          <div style={{
            position: 'absolute',
            top: '1rem',
            right: '1rem',
            background: 'rgba(30, 41, 59, 0.95)',
            backdropFilter: 'blur(10px)',
            padding: '1rem',
            borderRadius: '0.75rem',
            border: '2px solid rgba(59, 130, 246, 0.3)',
            minWidth: '200px',
            boxShadow: '0 8px 16px rgba(0,0,0,0.4)',
            zIndex: 50
          }}>
            <div style={{ marginBottom: '0.75rem' }}>
              <div style={{ fontSize: '0.7rem', color: '#94a3b8', marginBottom: '0.25rem' }}>📊 ARR</div>
              <div style={{ fontSize: '1.25rem', fontWeight: '700', color: '#10b981' }}>{formatMoney(arr)}</div>
            </div>
            <div style={{ marginBottom: '0.75rem' }}>
              <div style={{ fontSize: '0.7rem', color: '#94a3b8', marginBottom: '0.25rem' }}>👥 Customers</div>
              <div style={{ fontSize: '1rem', fontWeight: '700', color: '#fff' }}>{customers.length}</div>
            </div>
            <div>
              <div style={{ fontSize: '0.7rem', color: '#94a3b8', marginBottom: '0.25rem' }}>🎯 PMF</div>
              <div style={{ fontSize: '1rem', fontWeight: '700', color: '#f59e0b' }}>{productMarketFit.toFixed(0)}%</div>
            </div>
          </div>
        )}
        
        {/* Bottom-Left Corner - Startup Checklist */}
        {hasStartup && checklistItems && currentMilestone && (
          <div style={{
            position: 'absolute',
            bottom: '1rem',
            left: '1rem',
            background: 'rgba(30, 41, 59, 0.95)',
            backdropFilter: 'blur(10px)',
            padding: '1rem',
            borderRadius: '0.75rem',
            border: '2px solid rgba(59, 130, 246, 0.3)',
            minWidth: '280px',
            maxWidth: '320px',
            boxShadow: '0 8px 16px rgba(0,0,0,0.4)',
            zIndex: 50
          }}>
            <div style={{ fontSize: '0.9rem', fontWeight: '700', color: '#3b82f6', marginBottom: '0.5rem' }}>
              📋 Startup Checklist
            </div>
            <div style={{ fontSize: '0.7rem', color: '#fbbf24', marginBottom: '0.75rem', fontStyle: 'italic' }}>
              Current: {currentMilestone || 'Getting Started'}
            </div>
            
            <div style={{ fontSize: '0.75rem', color: '#94a3b8', marginBottom: '0.5rem' }}>
              Complete to level up:
            </div>
            
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
              {/* Build MVP */}
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <div style={{ 
                  fontSize: '1rem', 
                  color: checklistItems?.mvpBuilt ? '#10b981' : '#64748b' 
                }}>
                  {checklistItems?.mvpBuilt ? '✅' : '⬜'}
                </div>
                <div style={{ 
                  fontSize: '0.75rem', 
                  color: checklistItems?.mvpBuilt ? '#10b981' : '#94a3b8',
                  textDecoration: checklistItems?.mvpBuilt ? 'line-through' : 'none'
                }}>
                  Build an MVP
                </div>
              </div>
              
              {/* Set up LLC */}
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <div style={{ 
                  fontSize: '1rem', 
                  color: checklistItems?.llcSetup ? '#10b981' : '#64748b' 
                }}>
                  {checklistItems?.llcSetup ? '✅' : '⬜'}
                </div>
                <div style={{ 
                  fontSize: '0.75rem', 
                  color: checklistItems?.llcSetup ? '#10b981' : '#94a3b8',
                  textDecoration: checklistItems?.llcSetup ? 'line-through' : 'none'
                }}>
                  Set up LLC ($800)
                </div>
                {!checklistItems?.llcSetup && (
                  <button
                    onClick={() => {
                      setShowLLCWebsite(true);
                    }}
                    style={{
                      marginLeft: 'auto',
                      padding: '0.25rem 0.5rem',
                      fontSize: '0.65rem',
                      background: '#3b82f6',
                      border: 'none',
                      borderRadius: '0.25rem',
                      color: '#fff',
                      cursor: 'pointer'
                    }}
                  >
                    File (2h)
                  </button>
                )}
              </div>
              
              {/* Set up LinkedInOut */}
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <div style={{ 
                  fontSize: '1rem', 
                  color: linkedInOut.hasAccount ? '#10b981' : '#64748b' 
                }}>
                  {linkedInOut.hasAccount ? '✅' : '⬜'}
                </div>
                <div style={{ 
                  fontSize: '0.75rem', 
                  color: linkedInOut.hasAccount ? '#10b981' : '#94a3b8',
                  textDecoration: linkedInOut.hasAccount ? 'line-through' : 'none'
                }}>
                  Set up LinkedInOut {linkedInOut.hasAccount ? `(${linkedInOut.followers} followers)` : ''}
                </div>
                {!linkedInOut.hasAccount && (
                  <button
                    onClick={() => {
                      setLinkedInOut(prev => ({
                        ...prev,
                        hasAccount: true,
                        followers: 50 // Start with 50 followers (friends & family)
                      }));
                      setChecklistItems(prev => ({ ...prev, socialMediaSetup: true }));
                      setTimeout(checkMilestoneComplete, 100);
                      alert('✅ LinkedInOut Account Created!\n\nYou now have 50 followers (friends & family).\n\nPost regularly to grow your audience and generate inbound leads.');
                    }}
                    style={{
                      marginLeft: 'auto',
                      padding: '0.25rem 0.5rem',
                      fontSize: '0.65rem',
                      background: '#0a66c2',
                      border: 'none',
                      borderRadius: '0.25rem',
                      color: '#fff',
                      cursor: 'pointer'
                    }}
                  >
                    Sign Up (30m)
                  </button>
                )}
              </div>
              
              {/* Set up Strupe */}
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <div style={{ 
                  fontSize: '1rem', 
                  color: checklistItems?.strupeSetup ? '#10b981' : '#64748b' 
                }}>
                  {checklistItems?.strupeSetup ? '✅' : '⬜'}
                </div>
                <div style={{ 
                  fontSize: '0.75rem', 
                  color: checklistItems?.strupeSetup ? '#10b981' : '#94a3b8',
                  textDecoration: checklistItems?.strupeSetup ? 'line-through' : 'none'
                }}>
                  Set up Strupe Payments
                </div>
                {!checklistItems?.strupeSetup && (
                  <button
                    onClick={() => {
                      setShowStrupeWebsite(true);
                    }}
                    style={{
                      marginLeft: 'auto',
                      padding: '0.25rem 0.5rem',
                      fontSize: '0.65rem',
                      background: '#3b82f6',
                      border: 'none',
                      borderRadius: '0.25rem',
                      color: '#fff',
                      cursor: 'pointer'
                    }}
                  >
                    Setup (1h)
                  </button>
                )}
              </div>
              
              {/* Research */}
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <div style={{ 
                  fontSize: '1rem', 
                  color: checklistItems?.researchCompleted ? '#10b981' : '#64748b' 
                }}>
                  {checklistItems?.researchCompleted ? '✅' : '⬜'}
                </div>
                <div style={{ 
                  fontSize: '0.75rem', 
                  color: checklistItems?.researchCompleted ? '#10b981' : '#94a3b8',
                  textDecoration: checklistItems?.researchCompleted ? 'line-through' : 'none'
                }}>
                  Research startup basics
                </div>
                {!checklistItems?.researchCompleted ? (
                  researchProgress > 0 && researchProgress < 100 ? (
                    <div style={{ marginLeft: 'auto', fontSize: '0.65rem', color: '#3b82f6' }}>
                      {Math.floor(researchProgress)}%
                    </div>
                  ) : (
                    <button
                      onClick={() => {
                        if (weeklyHoursUsed + 4 > weeklyHoursAvailable) {
                          alert('Not enough hours this week! Need 4 hours.');
                          return;
                        }
                        setWeeklyHoursUsed(prev => prev + 4);
                        setResearchProgress(1);
                      }}
                      style={{
                        marginLeft: 'auto',
                        padding: '0.25rem 0.5rem',
                        fontSize: '0.65rem',
                        background: weeklyHoursUsed + 4 <= weeklyHoursAvailable ? '#3b82f6' : '#475569',
                        border: 'none',
                        borderRadius: '0.25rem',
                        color: '#fff',
                        cursor: weeklyHoursUsed + 4 <= weeklyHoursAvailable ? 'pointer' : 'not-allowed'
                      }}
                    >
                      Research (4h)
                    </button>
                  )
                ) : null}
              </div>
            </div>
          </div>
        )}
        
        {/* Central Office View - FULLSCREEN */}
        <div style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          zIndex: 1,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center'
        }}>
          {hasStartup ? (
            <div style={{ width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <IsometricOffice 
                office={office}
                employees={employees}
                startupName={startupName}
                startupLogo={startupLogo}
              />
            </div>
          ) : (
            <button
              onClick={() => {
                if (!currentJob) {
                  setActivePanel('job');
                } else {
                  setActivePanel('startup-create');
                }
              }}
              style={{
                textAlign: 'center',
                padding: '3rem',
                background: 'rgba(30, 41, 59, 0.8)',
                backdropFilter: 'blur(10px)',
                borderRadius: '1rem',
                border: '2px solid rgba(59, 130, 246, 0.3)',
                cursor: 'pointer',
                transition: 'all 0.3s',
                color: '#e2e8f0'
              }}
              onMouseEnter={e => {
                e.currentTarget.style.transform = 'scale(1.05)';
                e.currentTarget.style.borderColor = '#3b82f6';
              }}
              onMouseLeave={e => {
                e.currentTarget.style.transform = 'scale(1)';
                e.currentTarget.style.borderColor = 'rgba(59, 130, 246, 0.3)';
              }}
            >
              <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>💼</div>
              <div style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '0.5rem' }}>
                Start Your Journey
              </div>
              <div style={{ fontSize: '0.875rem', color: '#94a3b8' }}>
                {!currentJob ? 'Click to select a job' : 'Click to create your startup'}
              </div>
            </button>
          )}
        </div>
        
        
        {/* Floating Panels - Show based on activePanel */}
        {activePanel && (
          <div style={{
            position: 'absolute',
            top: '50%',
            left: '50%',
            transform: 'translate(-50%, -50%)',
            background: 'rgba(30, 41, 59, 0.98)',
            backdropFilter: 'blur(20px)',
            padding: '2rem',
            borderRadius: '1rem',
            border: '2px solid rgba(59, 130, 246, 0.5)',
            minWidth: '700px',
            maxWidth: '90vw',
            maxHeight: '90vh',
            overflowY: 'auto',
            boxShadow: '0 20px 40px rgba(0,0,0,0.6)',
            zIndex: 200
          }}>
            {/* Close Button */}
            <button
              onClick={() => setActivePanel(null)}
              style={{
                position: 'absolute',
                top: '1rem',
                right: '1rem',
                background: 'rgba(239, 68, 68, 0.2)',
                border: '1px solid #ef4444',
                borderRadius: '0.5rem',
                color: '#fff',
                padding: '0.5rem 1rem',
                cursor: 'pointer',
                fontWeight: '600',
                fontSize: '0.875rem'
              }}
            >
              ✕ Close
            </button>
            
            {/* Panel Content */}
            <div style={{ marginTop: '2rem' }}>
              {activePanel === 'job' && (
                <div>
                  {!currentJob ? (
                    <div>
                      <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '0.5rem', textAlign: 'center' }}>
                        What kind of founder do you want to be?
                      </h2>
                      <p style={{ color: '#94a3b8', marginBottom: '2rem', fontSize: '0.875rem', textAlign: 'center' }}>
                        Choose your path - this will shape your journey and unlock different capabilities
                      </p>
                      
                      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '1.5rem' }}>
                        {Object.keys(FOUNDER_PATHS).map(path => {
                          const pathData = FOUNDER_PATHS[path];
                          return (
                            <button
                              key={path}
                              onClick={() => {
                                selectJob(path);
                                setActivePanel(null);
                              }}
                              style={{
                                padding: '1.5rem',
                                background: 'linear-gradient(135deg, #334155 0%, #1e293b 100%)',
                                border: '2px solid #475569',
                                borderRadius: '1rem',
                                color: '#fff',
                                cursor: 'pointer',
                                textAlign: 'left',
                                transition: 'all 0.2s'
                              }}
                              onMouseEnter={e => {
                                e.currentTarget.style.borderColor = path === 'Technical' ? '#3b82f6' : '#10b981';
                                e.currentTarget.style.transform = 'translateY(-4px)';
                              }}
                              onMouseLeave={e => {
                                e.currentTarget.style.borderColor = '#475569';
                                e.currentTarget.style.transform = 'translateY(0)';
                              }}
                            >
                              <div style={{ fontSize: '1.25rem', fontWeight: '700', marginBottom: '0.75rem', color: path === 'Technical' ? '#3b82f6' : '#10b981' }}>
                                {path === 'Technical' ? '💻' : '💼'} {path} Founder
                              </div>
                              
                              <div style={{ fontSize: '0.8rem', color: '#94a3b8', marginBottom: '1rem', lineHeight: '1.4' }}>
                                {pathData.description}
                              </div>
                              
                              <div style={{ fontSize: '0.75rem', color: '#10b981', marginBottom: '0.5rem', fontWeight: '600' }}>
                                ✓ Advantages:
                              </div>
                              {pathData.advantages.slice(0, 3).map((adv, i) => (
                                <div key={i} style={{ fontSize: '0.7rem', color: '#94a3b8', marginLeft: '0.75rem', marginBottom: '0.25rem' }}>
                                  • {adv}
                                </div>
                              ))}
                              
                              <div style={{ fontSize: '0.75rem', color: '#ef4444', marginTop: '0.75rem', marginBottom: '0.5rem', fontWeight: '600' }}>
                                ⚠ Trade-offs:
                              </div>
                              {pathData.disadvantages.slice(0, 2).map((dis, i) => (
                                <div key={i} style={{ fontSize: '0.7rem', color: '#94a3b8', marginLeft: '0.75rem', marginBottom: '0.25rem' }}>
                                  • {dis}
                                </div>
                              ))}
                              
                              <div style={{ marginTop: '1rem', paddingTop: '1rem', borderTop: '1px solid #475569' }}>
                                <div style={{ fontSize: '0.7rem', color: '#64748b', marginBottom: '0.25rem' }}>
                                  Starting salary: {formatMoney(pathData.career.base)}/year
                                </div>
                                <div style={{ fontSize: '0.7rem', color: '#64748b' }}>
                                  Career levels: {pathData.career.levels.length}
                                </div>
                              </div>
                            </button>
                          );
                        })}
                      </div>
                    </div>
                  ) : (
                    <div>
                      <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '1rem' }}>💼 Your Career</h2>
                      <div style={{ padding: '1rem', background: '#0f172a', borderRadius: '0.5rem', marginBottom: '1rem' }}>
                        <div style={{ fontSize: '1.1rem', fontWeight: '700', color: founderType === 'Technical' ? '#3b82f6' : '#10b981', marginBottom: '0.5rem' }}>
                          {founderType} Founder
                        </div>
                        <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '0.5rem' }}>
                          {founderType && FOUNDER_PATHS[founderType] ? FOUNDER_PATHS[founderType].career.levels[jobLevel] : 'Loading...'}
                        </div>
                        {jobBonus && (
                          <div style={{ fontSize: '0.75rem', color: '#10b981', padding: '0.5rem', background: 'rgba(16, 185, 129, 0.1)', borderRadius: '0.25rem', marginTop: '0.5rem' }}>
                            🚀 Founder Bonus: {jobBonus.description}
                          </div>
                        )}
                      </div>
                      
                      <div style={{ padding: '1rem', background: '#0f172a', borderRadius: '0.5rem', marginBottom: '1rem' }}>
                        <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '0.5rem' }}>
                          💰 Gross Salary: <span style={{ color: '#fff', fontWeight: '600' }}>{formatMoney(grossMonthlyIncome)}/month</span>
                        </div>
                        <div style={{ fontSize: '0.75rem', color: '#64748b', marginLeft: '1rem', marginBottom: '0.25rem' }}>
                          - 401k (6%): -{formatMoney(calculateTaxes(grossMonthlyIncome).retirement401k)}
                        </div>
                        <div style={{ fontSize: '0.75rem', color: '#64748b', marginLeft: '1rem', marginBottom: '0.25rem' }}>
                          - Health Insurance: -{formatMoney(calculateTaxes(grossMonthlyIncome).healthInsurance)}
                        </div>
                        <div style={{ fontSize: '0.75rem', color: '#64748b', marginLeft: '1rem', marginBottom: '0.25rem' }}>
                          - Federal Tax: -{formatMoney(calculateTaxes(grossMonthlyIncome).federal)}
                        </div>
                        <div style={{ fontSize: '0.75rem', color: '#64748b', marginLeft: '1rem', marginBottom: '0.25rem' }}>
                          - State Tax: -{formatMoney(calculateTaxes(grossMonthlyIncome).state)}
                        </div>
                        <div style={{ fontSize: '0.75rem', color: '#64748b', marginLeft: '1rem', marginBottom: '0.5rem' }}>
                          - FICA: -{formatMoney(calculateTaxes(grossMonthlyIncome).fica)}
                        </div>
                        <div style={{ height: '1px', background: '#334155', margin: '0.5rem 0' }} />
                        <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '0.25rem' }}>
                          💵 Take-home: <span style={{ color: '#10b981', fontWeight: '700' }}>{formatMoney(calculateTaxes(grossMonthlyIncome).net)}/month</span>
                        </div>
                        <div style={{ fontSize: '0.75rem', color: '#64748b', marginLeft: '1rem', marginBottom: '0.25rem' }}>
                          - Rent: -{formatMoney(calculateTaxes(grossMonthlyIncome).livingExpenses.rent)}
                        </div>
                        <div style={{ fontSize: '0.75rem', color: '#64748b', marginLeft: '1rem', marginBottom: '0.25rem' }}>
                          - Food: -{formatMoney(calculateTaxes(grossMonthlyIncome).livingExpenses.food)}
                        </div>
                        <div style={{ fontSize: '0.75rem', color: '#64748b', marginLeft: '1rem', marginBottom: '0.25rem' }}>
                          - Utilities: -{formatMoney(calculateTaxes(grossMonthlyIncome).livingExpenses.utilities)}
                        </div>
                        <div style={{ fontSize: '0.75rem', color: '#64748b', marginLeft: '1rem', marginBottom: '0.5rem' }}>
                          - Other: -{formatMoney(calculateTaxes(grossMonthlyIncome).livingExpenses.transportation + calculateTaxes(grossMonthlyIncome).livingExpenses.misc)}
                        </div>
                        <div style={{ height: '1px', background: '#334155', margin: '0.5rem 0' }} />
                        <div style={{ fontSize: '0.875rem', color: '#10b981', fontWeight: '700' }}>
                          💰 Net Savings: {formatMoney(netMonthlyIncome)}/month
                        </div>
                      </div>
                      
                      <div style={{ fontSize: '0.75rem', color: '#64748b', fontStyle: 'italic', textAlign: 'center' }}>
                        Paid bi-weekly on Fridays
                      </div>
                    </div>
                  )}
                </div>
              )}
              {activePanel === 'startup-create' && (
                <div>
                  <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '1.5rem' }}>
                    🚀 Create Your Startup
                  </h2>
                  
                  {/* Step 1: Industry Selection */}
                  {!selectedIndustry && (
                    <div style={{ marginBottom: '1.5rem' }}>
                      <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: '600', color: '#94a3b8', marginBottom: '0.5rem' }}>
                        Choose Your Industry
                      </label>
                      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '0.75rem' }}>
                        {INDUSTRIES.map((industry, idx) => (
                          <button
                            key={idx}
                            onClick={() => setSelectedIndustry(industry)}
                            style={{
                              padding: '1rem',
                              background: '#0f172a',
                              border: '2px solid #334155',
                              borderRadius: '0.5rem',
                              color: '#fff',
                              cursor: 'pointer',
                              textAlign: 'center',
                              transition: 'all 0.2s',
                              fontSize: '0.8rem',
                              fontWeight: '600'
                            }}
                            onMouseEnter={e => e.currentTarget.style.borderColor = '#3b82f6'}
                            onMouseLeave={e => e.currentTarget.style.borderColor = '#334155'}
                          >
                            {industry}
                          </button>
                        ))}
                      </div>
                    </div>
                  )}
                  
                  {/* Step 2: Idea Selection */}
                  {selectedIndustry && (
                    <>
                      <div style={{ marginBottom: '1rem' }}>
                        <button
                          onClick={() => setSelectedIndustry(null)}
                          style={{
                            padding: '0.5rem 1rem',
                            background: '#334155',
                            border: 'none',
                            borderRadius: '0.5rem',
                            color: '#94a3b8',
                            cursor: 'pointer',
                            fontSize: '0.875rem',
                            marginBottom: '0.5rem'
                          }}
                        >
                          ← Back to Industries
                        </button>
                        <div style={{ fontSize: '1rem', fontWeight: '600', color: '#3b82f6' }}>
                          {selectedIndustry}
                        </div>
                      </div>
                      
                      <div style={{ marginBottom: '1.5rem' }}>
                        <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: '600', color: '#94a3b8', marginBottom: '0.5rem' }}>
                          Choose Your Idea
                        </label>
                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '0.75rem' }}>
                          {STARTUP_IDEAS_BY_INDUSTRY[selectedIndustry].map((idea, idx) => (
                            <button
                              key={idx}
                              onClick={() => setStartupIdea({ ...idea, market: selectedIndustry })}
                              style={{
                                padding: '0.75rem',
                                background: startupIdea?.name === idea.name ? '#334155' : '#0f172a',
                                border: startupIdea?.name === idea.name ? '2px solid #3b82f6' : '2px solid #334155',
                                borderRadius: '0.5rem',
                                color: '#fff',
                                cursor: 'pointer',
                                textAlign: 'left',
                                transition: 'all 0.2s'
                              }}
                            >
                              <div style={{ fontSize: '0.75rem', fontWeight: '700', marginBottom: '0.25rem' }}>{idea.name}</div>
                              <div style={{ fontSize: '0.65rem', color: '#94a3b8', marginBottom: '0.25rem' }}>{idea.problem}</div>
                              <div style={{ fontSize: '0.65rem', color: '#64748b' }}>TAM: ${idea.tam}B</div>
                            </button>
                          ))}
                        </div>
                      </div>
                    </>
                  )}

                  {startupIdea && (
                    <>
                      <div style={{ marginBottom: '1.5rem' }}>
                        <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: '600', color: '#94a3b8', marginBottom: '0.5rem' }}>
                          Company Name
                        </label>
                        <input
                          type="text"
                          value={startupName}
                          onChange={e => setStartupName(e.target.value)}
                          placeholder="Enter your company name..."
                          style={{
                            width: '100%',
                            padding: '0.75rem',
                            background: '#0f172a',
                            border: '2px solid #334155',
                            borderRadius: '0.5rem',
                            color: '#fff',
                            fontSize: '1rem',
                            outline: 'none'
                          }}
                        />
                      </div>

                      <div style={{ marginBottom: '1.5rem' }}>
                        <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: '600', color: '#94a3b8', marginBottom: '0.5rem' }}>
                          Choose Your Logo
                        </label>
                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: '0.75rem' }}>
                          {LOGOS.map((logo, idx) => (
                            <button
                              key={idx}
                              onClick={() => setStartupLogo(logo)}
                              style={{
                                padding: '1rem',
                                background: startupLogo === logo ? logo.color : '#0f172a',
                                border: startupLogo === logo ? `2px solid ${logo.color}` : '2px solid #334155',
                                borderRadius: '0.5rem',
                                fontSize: '2rem',
                                cursor: 'pointer',
                                transition: 'all 0.2s',
                                aspectRatio: '1'
                              }}
                            >
                              {logo.icon}
                            </button>
                          ))}
                        </div>
                      </div>
                      
                      <button
                        onClick={() => {
                          if (startupIdea && startupName && startupLogo) {
                            createStartup(startupIdea, startupName, startupLogo);
                            setSelectedIndustry(null);
                            setActivePanel(null);
                          }
                        }}
                        disabled={!startupIdea || !startupName || !startupLogo}
                        style={{
                          width: '100%',
                          padding: '1rem',
                          background: startupIdea && startupName && startupLogo ? 'linear-gradient(135deg, #10b981 0%, #059669 100%)' : '#475569',
                          border: 'none',
                          borderRadius: '0.5rem',
                          color: '#fff',
                          fontWeight: '700',
                          cursor: startupIdea && startupName && startupLogo ? 'pointer' : 'not-allowed',
                          fontSize: '1rem'
                        }}
                      >
                        Create Startup
                      </button>
                    </>
                  )}
                </div>
              )}
              {activePanel === 'mvp' && (
                <div style={{ maxHeight: '70vh', overflowY: 'auto' }}>
                  <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '1rem' }}>🛠️ MVP Builder</h2>
                  
                  {!startupIdea ? (
                    <div style={{ padding: '2rem', textAlign: 'center', color: '#94a3b8' }}>
                      Create a startup first to start building your MVP
                    </div>
                  ) : founderType === 'Non-Technical' && !hasNoCodePlatform ? (
                    // Non-technical founders must buy no-code platform first
                    <div>
                      <div style={{ 
                        padding: '1.5rem', 
                        background: 'rgba(239, 68, 68, 0.1)', 
                        border: '2px solid #ef4444',
                        borderRadius: '0.75rem',
                        marginBottom: '1.5rem'
                      }}>
                        <div style={{ fontSize: '1rem', fontWeight: '700', color: '#ef4444', marginBottom: '0.5rem' }}>
                          ⚠️ No-Code Platform Required
                        </div>
                        <div style={{ fontSize: '0.875rem', color: '#94a3b8', lineHeight: '1.5' }}>
                          As a non-technical founder, you need a no-code platform to build your MVP. Technical founders can code it themselves.
                        </div>
                      </div>

                      <div style={{ 
                        padding: '1.5rem', 
                        background: '#0f172a', 
                        border: '2px solid #334155',
                        borderRadius: '0.75rem',
                        marginBottom: '1.5rem'
                      }}>
                        <div style={{ fontSize: '1.1rem', fontWeight: '700', color: '#fff', marginBottom: '1rem' }}>
                          💻 Purchase No-Code Platform
                        </div>
                        
                        <div style={{ marginBottom: '1rem' }}>
                          <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '0.5rem' }}>
                            Platform includes:
                          </div>
                          <div style={{ fontSize: '0.75rem', color: '#94a3b8', marginLeft: '1rem', marginBottom: '0.25rem' }}>
                            • Visual drag-and-drop builder
                          </div>
                          <div style={{ fontSize: '0.75rem', color: '#94a3b8', marginLeft: '1rem', marginBottom: '0.25rem' }}>
                            • Pre-built components & templates
                          </div>
                          <div style={{ fontSize: '0.75rem', color: '#94a3b8', marginLeft: '1rem', marginBottom: '0.25rem' }}>
                            • Database & API integrations
                          </div>
                          <div style={{ fontSize: '0.75rem', color: '#94a3b8', marginLeft: '1rem', marginBottom: '0.25rem' }}>
                            • AI-powered code generation
                          </div>
                        </div>

                        <div style={{ 
                          padding: '1rem', 
                          background: 'rgba(59, 130, 246, 0.1)', 
                          borderRadius: '0.5rem',
                          marginBottom: '1rem'
                        }}>
                          <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '0.5rem' }}>
                            Monthly costs:
                          </div>
                          <div style={{ fontSize: '0.75rem', color: '#94a3b8', marginLeft: '1rem', marginBottom: '0.25rem' }}>
                            • Platform subscription: <span style={{ color: '#fff', fontWeight: '600' }}>$200/mo</span>
                          </div>
                          <div style={{ fontSize: '0.75rem', color: '#94a3b8', marginLeft: '1rem', marginBottom: '0.5rem' }}>
                            • AI tokens (GPT-4, Claude): <span style={{ color: '#fff', fontWeight: '600' }}>$50-150/mo</span>
                          </div>
                          <div style={{ height: '1px', background: '#334155', margin: '0.5rem 0' }} />
                          <div style={{ fontSize: '0.875rem', color: '#ef4444', fontWeight: '700' }}>
                            Total: $250-350/month recurring
                          </div>
                          <div style={{ fontSize: '0.7rem', color: '#64748b', marginTop: '0.25rem', fontStyle: 'italic' }}>
                            This will be deducted from Business Cash Flow monthly
                          </div>
                        </div>

                        <button
                          onClick={() => {
                            if (businessCash >= 250) {
                              setBusinessCash(prev => prev - 250);
                              setHasNoCodePlatform(true);
                              const aiTokenCost = Math.floor(Math.random() * 100) + 50; // $50-150
                              setNoCodeMonthlyCost(200 + aiTokenCost);
                              alert(`✅ No-Code Platform Activated!\n\n💰 First month: $${250}\n📅 Monthly recurring: $${200 + aiTokenCost}/mo\n\nThis will be deducted from your Business Cash Flow every month.`);
                            } else {
                              alert('❌ Insufficient funds!\n\nYou need $250 to purchase the no-code platform.\n\nTransfer money from Personal Cash or get a job to save up.');
                            }
                          }}
                          disabled={businessCash < 250}
                          style={{
                            width: '100%',
                            padding: '1rem',
                            background: businessCash >= 250 ? 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)' : '#475569',
                            border: 'none',
                            borderRadius: '0.5rem',
                            color: '#fff',
                            fontSize: '1rem',
                            fontWeight: '700',
                            cursor: businessCash >= 250 ? 'pointer' : 'not-allowed',
                            transition: 'all 0.2s'
                          }}
                        >
                          {businessCash >= 250 ? '💳 Purchase Platform ($250)' : '🔒 Need $250 in Business Cash'}
                        </button>
                        
                        {businessCash < 250 && (
                          <div style={{ 
                            marginTop: '1rem', 
                            padding: '0.75rem', 
                            background: 'rgba(251, 191, 36, 0.1)',
                            borderRadius: '0.5rem',
                            fontSize: '0.75rem',
                            color: '#fbbf24'
                          }}>
                            💡 Tip: Transfer money from Personal Cash using the Money panel
                          </div>
                        )}
                      </div>
                    </div>
                  ) : selectedFeatures.length === 0 && builtFeatures.length === 0 ? (
                    // Phase 1: Feature Selection
                    <div>
                      <p style={{ color: '#94a3b8', marginBottom: '1rem', fontSize: '0.875rem' }}>
                        Select 3-10 features to build your MVP
                      </p>
                      <div style={{ display: 'grid', gap: '0.5rem', marginBottom: '1rem' }}>
                        {FEATURES_BY_INDUSTRY[startupIdea.market].slice(0, 10).map((feature, idx) => {
                          const isSelected = selectedFeatures.some(f => f.name === feature.name);
                          const isBuilt = builtFeatures.some(f => f.name === feature.name);
                          return (
                            <div
                              key={idx}
                              onClick={() => {
                                if (isBuilt) {
                                  // Can't select already-built features
                                  return;
                                }
                                if (isSelected) {
                                  setSelectedFeatures(prev => prev.filter(f => f.name !== feature.name));
                                } else if (selectedFeatures.length < 10) {
                                  setSelectedFeatures(prev => [...prev, feature]);
                                }
                              }}
                              style={{
                                padding: '0.75rem',
                                background: isBuilt ? 'rgba(16, 185, 129, 0.1)' : isSelected ? '#334155' : '#0f172a',
                                border: isBuilt ? '2px solid #10b981' : isSelected ? '2px solid #3b82f6' : '2px solid #334155',
                                borderRadius: '0.5rem',
                                cursor: isBuilt ? 'not-allowed' : 'pointer',
                                opacity: isBuilt ? 0.6 : 1,
                                transition: 'all 0.2s'
                              }}
                            >
                              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                <div style={{ flex: 1 }}>
                                  <div style={{ fontSize: '0.875rem', fontWeight: '600', marginBottom: '0.25rem', color: isBuilt ? '#10b981' : '#fff' }}>
                                    {isBuilt ? '✅ ' : isSelected ? '✓ ' : ''}{feature.name}
                                  </div>
                                  <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>
                                    {feature.hours}h • ${feature.hours >= 35 ? '5K' : feature.hours >= 30 ? '3K' : feature.hours >= 25 ? '2K' : '1K'}
                                  </div>
                                </div>
                                <div style={{ fontSize: '0.7rem', padding: '0.25rem 0.5rem', background: 'rgba(59, 130, 246, 0.2)', borderRadius: '0.25rem' }}>
                                  {feature.hours < 25 ? '✓ Low' : feature.hours < 30 ? '⚙️ Med' : feature.hours < 35 ? '⚠️ High' : '⚠️ V.High'}
                                </div>
                              </div>
                            </div>
                          );
                        })}
                      </div>
                      {builtFeatures.length > 0 && (
                        <div style={{ fontSize: '0.875rem', color: '#10b981', marginBottom: '0.5rem' }}>
                          ✅ Already built: {builtFeatures.length} feature(s)
                        </div>
                      )}
                      <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '1rem' }}>
                        Selected: {selectedFeatures.length} / 10 {builtFeatures.length > 0 ? `(${builtFeatures.length + selectedFeatures.length} total, minimum 3)` : '(minimum 3)'}
                      </div>
                      <button
                        onClick={() => {
                          if (selectedFeatures.length < 3 - builtFeatures.length) {
                            alert(`Select at least ${3 - builtFeatures.length} more features!`);
                          } else {
                            // Store the TOTAL count (built + selected)
                            selectedFeaturesCountRef.current = builtFeatures.length + selectedFeatures.length;
                            console.log('📌 LOCKED IN TOTAL FEATURE COUNT:', selectedFeaturesCountRef.current, '(', builtFeatures.length, 'built +', selectedFeatures.length, 'selected)');
                            // Confirmed - this will move to Phase 2 automatically
                            // because builtFeatures.length (0) < selectedFeatures.length (3+)
                            alert(`✓ ${selectedFeatures.length} features confirmed! Click "Build Next Feature" to start development.`);
                          }
                        }}
                        disabled={builtFeatures.length + selectedFeatures.length < 3}
                        style={{
                          width: '100%',
                          padding: '1rem',
                          background: (builtFeatures.length + selectedFeatures.length >= 3) ? 'linear-gradient(135deg, #10b981 0%, #059669 100%)' : '#475569',
                          border: 'none',
                          borderRadius: '0.5rem',
                          color: '#fff',
                          fontWeight: '700',
                          cursor: (builtFeatures.length + selectedFeatures.length >= 3) ? 'pointer' : 'not-allowed'
                        }}
                      >
                        Confirm {selectedFeatures.length} Features ({builtFeatures.length + selectedFeatures.length} total)
                      </button>
                    </div>
                  ) : builtFeatures.length < selectedFeatures.length ? (
                    // Phase 2: Building Features
                    <div>
                      <div style={{ marginBottom: '1rem' }}>
                        <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '0.5rem' }}>
                          Progress: {builtFeatures.length} / {selectedFeaturesCountRef.current > 0 ? selectedFeaturesCountRef.current : selectedFeatures.length + builtFeatures.length} features complete
                        </div>
                        <div style={{ height: '8px', background: '#334155', borderRadius: '999px', overflow: 'hidden' }}>
                          <div style={{
                            height: '100%',
                            width: `${selectedFeaturesCountRef.current > 0 
                              ? (builtFeatures.length / selectedFeaturesCountRef.current) * 100 
                              : (builtFeatures.length / (selectedFeatures.length + builtFeatures.length)) * 100}%`,
                            background: 'linear-gradient(90deg, #10b981 0%, #059669 100%)',
                            transition: 'width 0.3s'
                          }} />
                        </div>
                      </div>
                      
                      {currentFeatureInProgress && (
                        <div style={{ padding: '1rem', background: '#f97316', borderRadius: '0.5rem', marginBottom: '1rem' }}>
                          <div style={{ fontSize: '0.875rem', fontWeight: '700', marginBottom: '0.5rem' }}>
                            🔨 Building: {currentFeatureInProgress.name}
                          </div>
                          <div style={{ height: '6px', background: 'rgba(0,0,0,0.2)', borderRadius: '999px', overflow: 'hidden', marginBottom: '0.5rem' }}>
                            <div style={{
                              height: '100%',
                              width: `${featureProgress}%`,
                              background: '#fff',
                              transition: 'width 0.3s'
                            }} />
                          </div>
                          <div style={{ fontSize: '0.75rem' }}>{featureProgress.toFixed(0)}% complete</div>
                        </div>
                      )}
                      
                      {builtFeatures.length > 0 && (
                        <div style={{ marginBottom: '1rem' }}>
                          <div style={{ fontSize: '0.875rem', fontWeight: '600', color: '#10b981', marginBottom: '0.5rem' }}>
                            ✅ Completed Features:
                          </div>
                          {builtFeatures.map((f, i) => (
                            <div key={i} style={{ fontSize: '0.75rem', color: '#94a3b8', marginLeft: '1rem' }}>
                              • {f.name}
                            </div>
                          ))}
                        </div>
                      )}
                      
                      {!currentFeatureInProgress && (
                        <button
                          onClick={() => {
                            console.log('🔵 BUILD NEXT FEATURE CLICKED');
                            console.log('📋 Selected features:', selectedFeatures.map(f => f.name));
                            console.log('✅ Built features:', builtFeatures.map(f => f.name));
                            console.log('📊 Built count:', builtFeatures.length);
                            
                            const nextFeature = selectedFeatures.find(f => !builtFeatures.some(bf => bf.name === f.name));
                            console.log('🎯 Next feature to build:', nextFeature?.name || 'NONE');
                            
                            if (nextFeature) {
                              // Check if user has enough total features
                              const totalFeatures = selectedFeatures.length + builtFeatures.length;
                              if (totalFeatures < 3) {
                                alert(`⚠️ MVPs need at least 3 features!\n\nYou currently have ${totalFeatures} feature(s).\n\nSelect ${3 - totalFeatures} more feature(s) before building.`);
                                return;
                              }
                              
                              const cost = nextFeature.hours >= 35 ? 5000 : nextFeature.hours >= 30 ? 3000 : nextFeature.hours >= 25 ? 2000 : 1000;
                              console.log('💰 Cost:', cost, '| Business Cash:', businessCash);
                              
                              if (businessCash >= cost) {
                                // Set the ref if not already set AND user has selected enough features
                                if (selectedFeaturesCountRef.current === 0 && totalFeatures >= 3) {
                                  selectedFeaturesCountRef.current = totalFeatures;
                                  console.log('📌 AUTO-LOCKED FEATURE COUNT:', selectedFeaturesCountRef.current);
                                }
                                
                                setBusinessCash(prev => prev - cost);
                                setCurrentFeatureInProgress(nextFeature);
                                setFeatureProgress(0);
                                console.log('✅ Started building:', nextFeature.name);
                              } else {
                                alert(`Not enough cash! Need $${cost.toLocaleString()} to build "${nextFeature.name}"`);
                              }
                            } else {
                              console.log('❌ No more features to build');
                              alert('All features are already built!');
                            }
                          }}
                          disabled={selectedFeatures.filter(f => !builtFeatures.some(bf => bf.name === f.name)).length === 0}
                          style={{
                            width: '100%',
                            padding: '1rem',
                            background: selectedFeatures.filter(f => !builtFeatures.some(bf => bf.name === f.name)).length > 0 
                              ? 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)' 
                              : '#475569',
                            border: 'none',
                            borderRadius: '0.5rem',
                            color: '#fff',
                            fontWeight: '700',
                            cursor: selectedFeatures.filter(f => !builtFeatures.some(bf => bf.name === f.name)).length > 0 
                              ? 'pointer' 
                              : 'not-allowed',
                            opacity: selectedFeatures.filter(f => !builtFeatures.some(bf => bf.name === f.name)).length > 0 
                              ? 1 
                              : 0.5
                          }}
                        >
                          Build Next Feature ({selectedFeatures.filter(f => !builtFeatures.some(bf => bf.name === f.name)).length} remaining)
                        </button>
                      )}
                    </div>
                  ) : builtFeatures.length < 3 ? (
                    // Need more features
                    <div style={{ textAlign: 'center', padding: '2rem' }}>
                      <div style={{ fontSize: '1.5rem', marginBottom: '1rem' }}>⚠️</div>
                      <div style={{ fontSize: '1rem', fontWeight: '600', marginBottom: '0.5rem' }}>
                        Not Enough Features
                      </div>
                      <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '1rem' }}>
                        You've built {builtFeatures.length} feature(s). MVPs need at least 3.
                      </div>
                      <button
                        onClick={() => {
                          // Don't reset built features - we're adding MORE features, not starting over
                          console.log('➕ ADD MORE FEATURES - Keeping', builtFeatures.length, 'built features');
                          setSelectedFeatures([]);
                          setCurrentFeatureInProgress(null);
                          setFeatureProgress(0);
                          // Don't reset the ref yet - we'll update it when they confirm more features
                        }}
                        style={{
                          padding: '1rem',
                          background: '#3b82f6',
                          border: 'none',
                          borderRadius: '0.5rem',
                          color: '#fff',
                          cursor: 'pointer',
                          fontWeight: '600'
                        }}
                      >
                        + Add More Features
                      </button>
                    </div>
                  ) : (
                    // Phase 3: Pre-signups & Launch
                    <div>
                      <div style={{ padding: '1rem', background: 'rgba(16, 185, 129, 0.1)', borderRadius: '0.5rem', marginBottom: '1rem' }}>
                        <div style={{ fontSize: '1rem', fontWeight: '700', color: '#10b981', marginBottom: '0.5rem' }}>
                          ✅ All {builtFeatures.length} Features Complete!
                        </div>
                        <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>
                          Ready to gather pre-signups and launch
                        </div>
                      </div>
                      
                      <div style={{ marginBottom: '1rem' }}>
                        <div style={{ fontSize: '0.875rem', fontWeight: '600', marginBottom: '0.5rem' }}>
                          Awareness: {awareness}%
                        </div>
                        <div style={{ display: 'grid', gap: '0.5rem', marginBottom: '1rem' }}>
                          <button
                            onClick={() => {
                              if (businessCash >= 200 && weeklyHoursUsed + 3 <= weeklyHoursAvailable) {
                                setBusinessCash(prev => prev - 200);
                                setWeeklyHoursUsed(prev => prev + 3);
                                setAwareness(prev => Math.min(100, prev + 5));
                              } else {
                                alert('Not enough cash or hours!');
                              }
                            }}
                            style={{
                              padding: '0.75rem',
                              background: '#3b82f6',
                              border: 'none',
                              borderRadius: '0.5rem',
                              color: '#fff',
                              cursor: 'pointer',
                              fontSize: '0.875rem'
                            }}
                          >
                            📱 Social Media (+5% awareness, $200, 3h)
                          </button>
                          <button
                            onClick={() => {
                              if (businessCash >= 2000 && weeklyHoursUsed + 3 <= weeklyHoursAvailable) {
                                setBusinessCash(prev => prev - 2000);
                                setWeeklyHoursUsed(prev => prev + 3);
                                setAwareness(prev => Math.min(100, prev + 12));
                              } else {
                                alert('Not enough cash or hours!');
                              }
                            }}
                            style={{
                              padding: '0.75rem',
                              background: '#10b981',
                              border: 'none',
                              borderRadius: '0.5rem',
                              color: '#fff',
                              cursor: 'pointer',
                              fontSize: '0.875rem'
                            }}
                          >
                            💰 Paid Ads (+12% awareness, $2K, 3h)
                          </button>
                        </div>
                      </div>
                      
                      <div style={{ marginBottom: '1rem' }}>
                        <div style={{ fontSize: '0.875rem', fontWeight: '600', marginBottom: '0.5rem' }}>
                          Pre-signups: {preSignups.length} / 10
                        </div>
                        <button
                          onClick={() => {
                            if (weeklyHoursUsed + 4 <= weeklyHoursAvailable) {
                              setWeeklyHoursUsed(prev => prev + 4);
                              if (Math.random() * 100 < awareness) {
                                setPreSignups(prev => [...prev, { acquired: new Date() }]);
                              } else {
                                alert('No signup this time. Increase awareness!');
                              }
                            } else {
                              alert('Not enough hours this week!');
                            }
                          }}
                          disabled={preSignups.length >= 10}
                          style={{
                            width: '100%',
                            padding: '0.75rem',
                            background: preSignups.length < 10 ? '#8b5cf6' : '#475569',
                            border: 'none',
                            borderRadius: '0.5rem',
                            color: '#fff',
                            cursor: preSignups.length < 10 ? 'pointer' : 'not-allowed',
                            fontSize: '0.875rem'
                          }}
                        >
                          Get Pre-signup (4h)
                        </button>
                      </div>
                      
                      <button
                        onClick={() => {
                          if (builtFeatures.length >= 3) {
                            launchMVP();
                            setActivePanel(null);
                          }
                        }}
                        style={{
                          width: '100%',
                          padding: '1rem',
                          background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
                          border: 'none',
                          borderRadius: '0.5rem',
                          color: '#fff',
                          fontWeight: '700',
                          cursor: 'pointer',
                          fontSize: '1rem'
                        }}
                      >
                        🚀 LAUNCH MVP ({builtFeatures.length} features, {preSignups.length} pre-signups)
                      </button>
                    </div>
                  )}
                </div>
              )}
              {activePanel === 'platform' && (
                <div style={{ maxHeight: '70vh', overflowY: 'auto' }}>
                  <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '1rem' }}>🏗️ Production Platform Builder</h2>
                  
                  {!mvpBuilt ? (
                    <div style={{ padding: '2rem', textAlign: 'center', color: '#94a3b8' }}>
                      Build and launch your MVP first
                    </div>
                  ) : (
                    <div>
                      <div style={{ padding: '1rem', background: 'rgba(251, 191, 36, 0.1)', border: '2px solid #fbbf24', borderRadius: '0.75rem', marginBottom: '1.5rem' }}>
                        <div style={{ fontSize: '0.875rem', fontWeight: '700', color: '#fbbf24', marginBottom: '0.5rem' }}>
                          ⚠️ MVP vs Production Platform
                        </div>
                        <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>
                          Your MVP was for validation & pre-signups. Now build a production-ready platform with advanced features and infrastructure to handle real customers and sales.
                        </div>
                      </div>

                      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
                        {/* Features Column */}
                        <div>
                          <div style={{ fontSize: '1rem', fontWeight: '700', color: '#3b82f6', marginBottom: '1rem' }}>
                            💻 Production Features
                          </div>
                          <div style={{ fontSize: '0.75rem', color: '#94a3b8', marginBottom: '0.75rem' }}>
                            Built: {platformFeatures.length} / {PLATFORM_FEATURES.length}
                          </div>
                          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                            {PLATFORM_FEATURES.map((feature, idx) => {
                              const isBuilt = platformFeatures.some(f => f.name === feature.name);
                              const isBuilding = currentPlatformItem?.name === feature.name && currentPlatformItem?.type === 'feature';
                              return (
                                <div
                                  key={idx}
                                  style={{
                                    padding: '0.75rem',
                                    background: isBuilt ? 'rgba(16, 185, 129, 0.1)' : '#0f172a',
                                    border: isBuilt ? '2px solid #10b981' : '2px solid #334155',
                                    borderRadius: '0.5rem',
                                    opacity: isBuilt ? 0.6 : 1
                                  }}
                                >
                                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
                                    <div style={{ fontSize: '0.875rem', fontWeight: '600', color: isBuilt ? '#10b981' : '#fff' }}>
                                      {isBuilt ? '✅' : '⬜'} {feature.name}
                                    </div>
                                    <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>
                                      ${(feature.cost / 1000).toFixed(0)}K
                                    </div>
                                  </div>
                                  <div style={{ fontSize: '0.7rem', color: '#64748b', marginBottom: '0.5rem' }}>
                                    {feature.description}
                                  </div>
                                  {isBuilding && (
                                    <div>
                                      <div style={{ height: '4px', background: '#334155', borderRadius: '999px', overflow: 'hidden' }}>
                                        <div style={{
                                          height: '100%',
                                          width: `${platformItemProgress}%`,
                                          background: '#3b82f6',
                                          transition: 'width 0.3s'
                                        }} />
                                      </div>
                                      <div style={{ fontSize: '0.65rem', color: '#64748b', marginTop: '0.25rem' }}>
                                        {platformItemProgress.toFixed(0)}% complete
                                      </div>
                                    </div>
                                  )}
                                  {!isBuilt && !isBuilding && !currentPlatformItem && (
                                    <button
                                      onClick={() => {
                                        if (businessCash >= feature.cost) {
                                          setBusinessCash(prev => prev - feature.cost);
                                          setCurrentPlatformItem({ ...feature, type: 'feature' });
                                          setPlatformItemProgress(0);
                                        } else {
                                          alert(`Need $${feature.cost.toLocaleString()} to build ${feature.name}`);
                                        }
                                      }}
                                      style={{
                                        width: '100%',
                                        padding: '0.5rem',
                                        background: businessCash >= feature.cost ? '#3b82f6' : '#475569',
                                        border: 'none',
                                        borderRadius: '0.25rem',
                                        color: '#fff',
                                        fontSize: '0.7rem',
                                        fontWeight: '600',
                                        cursor: businessCash >= feature.cost ? 'pointer' : 'not-allowed'
                                      }}
                                    >
                                      Build ({feature.hours}h)
                                    </button>
                                  )}
                                </div>
                              );
                            })}
                          </div>
                        </div>

                        {/* Infrastructure Column */}
                        <div>
                          <div style={{ fontSize: '1rem', fontWeight: '700', color: '#10b981', marginBottom: '1rem' }}>
                            🏗️ Infrastructure
                          </div>
                          <div style={{ fontSize: '0.75rem', color: '#94a3b8', marginBottom: '0.75rem' }}>
                            Built: {platformInfrastructure.length} / {PLATFORM_INFRASTRUCTURE.length}
                          </div>
                          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                            {PLATFORM_INFRASTRUCTURE.map((infra, idx) => {
                              const isBuilt = platformInfrastructure.some(i => i.name === infra.name);
                              const isBuilding = currentPlatformItem?.name === infra.name && currentPlatformItem?.type === 'infrastructure';
                              return (
                                <div
                                  key={idx}
                                  style={{
                                    padding: '0.75rem',
                                    background: isBuilt ? 'rgba(16, 185, 129, 0.1)' : '#0f172a',
                                    border: isBuilt ? '2px solid #10b981' : '2px solid #334155',
                                    borderRadius: '0.5rem',
                                    opacity: isBuilt ? 0.6 : 1
                                  }}
                                >
                                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
                                    <div style={{ fontSize: '0.875rem', fontWeight: '600', color: isBuilt ? '#10b981' : '#fff' }}>
                                      {isBuilt ? '✅' : '⬜'} {infra.name}
                                    </div>
                                    <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>
                                      ${(infra.cost / 1000).toFixed(0)}K
                                    </div>
                                  </div>
                                  <div style={{ fontSize: '0.7rem', color: '#64748b', marginBottom: '0.5rem' }}>
                                    {infra.description}
                                  </div>
                                  {isBuilding && (
                                    <div>
                                      <div style={{ height: '4px', background: '#334155', borderRadius: '999px', overflow: 'hidden' }}>
                                        <div style={{
                                          height: '100%',
                                          width: `${platformItemProgress}%`,
                                          background: '#10b981',
                                          transition: 'width 0.3s'
                                        }} />
                                      </div>
                                      <div style={{ fontSize: '0.65rem', color: '#64748b', marginTop: '0.25rem' }}>
                                        {platformItemProgress.toFixed(0)}% complete
                                      </div>
                                    </div>
                                  )}
                                  {!isBuilt && !isBuilding && !currentPlatformItem && (
                                    <button
                                      onClick={() => {
                                        if (businessCash >= infra.cost) {
                                          setBusinessCash(prev => prev - infra.cost);
                                          setCurrentPlatformItem({ ...infra, type: 'infrastructure' });
                                          setPlatformItemProgress(0);
                                        } else {
                                          alert(`Need $${infra.cost.toLocaleString()} to build ${infra.name}`);
                                        }
                                      }}
                                      style={{
                                        width: '100%',
                                        padding: '0.5rem',
                                        background: businessCash >= infra.cost ? '#10b981' : '#475569',
                                        border: 'none',
                                        borderRadius: '0.25rem',
                                        color: '#fff',
                                        fontSize: '0.7rem',
                                        fontWeight: '600',
                                        cursor: businessCash >= infra.cost ? 'pointer' : 'not-allowed'
                                      }}
                                    >
                                      Build ({infra.hours}h)
                                    </button>
                                  )}
                                </div>
                              );
                            })}
                          </div>
                        </div>
                      </div>

                      {platformFeatures.length + platformInfrastructure.length >= 10 && !platformBuilt && (
                        <button
                          onClick={() => {
                            setPlatformBuilt(true);
                            alert('🎉 Production Platform Complete!\n\nYour platform is now ready to handle real customers and sales. Start selling!');
                          }}
                          style={{
                            width: '100%',
                            padding: '1rem',
                            background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
                            border: 'none',
                            borderRadius: '0.5rem',
                            color: '#fff',
                            fontWeight: '700',
                            fontSize: '1rem',
                            cursor: 'pointer',
                            marginTop: '1.5rem'
                          }}
                        >
                          🚀 Launch Production Platform
                        </button>
                      )}
                    </div>
                  )}
                </div>
              )}
              {activePanel === 'sales' && (
                <div style={{ maxHeight: '70vh', overflowY: 'auto' }}>
                  <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '1rem' }}>💰 Sales Pipeline</h2>
                  
                  {!mvpBuilt ? (
                    <div style={{ padding: '2rem', textAlign: 'center', color: '#94a3b8' }}>
                      Launch your MVP first to start selling
                    </div>
                  ) : !platformBuilt ? (
                    <div style={{ padding: '2rem', textAlign: 'center' }}>
                      <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>🏗️</div>
                      <div style={{ fontSize: '1rem', fontWeight: '600', color: '#fbbf24', marginBottom: '0.5rem' }}>
                        Production Platform Required
                      </div>
                      <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '1rem' }}>
                        Your MVP was for validation. Build a production-ready platform (Features + Infrastructure) before selling to real customers.
                      </div>
                      <button
                        onClick={() => setActivePanel('platform')}
                        style={{
                          padding: '1rem 2rem',
                          background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
                          border: 'none',
                          borderRadius: '0.5rem',
                          color: '#fff',
                          fontWeight: '700',
                          cursor: 'pointer'
                        }}
                      >
                        Go to Platform Builder
                      </button>
                    </div>
                  ) : prospects.length === 0 ? (
                    <div style={{ padding: '2rem', textAlign: 'center' }}>
                      <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>📞</div>
                      <div style={{ fontSize: '1rem', fontWeight: '600', marginBottom: '0.5rem' }}>
                        No Active Prospects
                      </div>
                      <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '1rem' }}>
                        Start by identifying potential customers
                      </div>
                      <button
                        onClick={() => {
                          if (weeklyHoursUsed + 2 <= weeklyHoursAvailable && prospectsContactedThisWeek < 10) {
                            const newProspect = generateProspect();
                            setProspects(prev => [...prev, newProspect]);
                            setWeeklyHoursUsed(prev => prev + 2);
                            setProspectsContactedThisWeek(prev => prev + 1);
                          } else {
                            alert(prospectsContactedThisWeek >= 10 ? 'Max 10 prospects per week!' : 'Not enough hours!');
                          }
                        }}
                        style={{
                          padding: '1rem 2rem',
                          background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
                          border: 'none',
                          borderRadius: '0.5rem',
                          color: '#fff',
                          fontWeight: '700',
                          cursor: 'pointer'
                        }}
                      >
                        📞 Identify New Prospect (2h)
                      </button>
                    </div>
                  ) : (
                    <div>
                      <div style={{ marginBottom: '1rem', fontSize: '0.875rem', color: '#94a3b8' }}>
                        {prospects.length} active prospect{prospects.length !== 1 ? 's' : ''} • {prospectsContactedThisWeek}/10 contacted this week
                      </div>
                      
                      <div style={{ display: 'grid', gap: '0.75rem', marginBottom: '1rem' }}>
                        {prospects.slice(0, 10).map((prospect, idx) => (
                          <div
                            key={idx}
                            style={{
                              padding: '1rem',
                              background: '#0f172a',
                              border: '2px solid #334155',
                              borderRadius: '0.5rem'
                            }}
                          >
                            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem' }}>
                              <div>
                                <div style={{ fontSize: '0.875rem', fontWeight: '700' }}>{prospect.companyName}</div>
                                <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>{prospect.industry}</div>
                              </div>
                              <div style={{
                                fontSize: '0.75rem',
                                fontWeight: '600',
                                padding: '0.25rem 0.5rem',
                                borderRadius: '0.25rem',
                                background: prospect.stage === 'Discovery' ? 'rgba(59, 130, 246, 0.2)' :
                                           prospect.stage === 'Demo' ? 'rgba(139, 92, 246, 0.2)' :
                                           prospect.stage === 'Proposal' ? 'rgba(245, 158, 11, 0.2)' :
                                           prospect.stage === 'Negotiation' ? 'rgba(239, 68, 68, 0.2)' :
                                           'rgba(16, 185, 129, 0.2)',
                                color: prospect.stage === 'Discovery' ? '#3b82f6' :
                                       prospect.stage === 'Demo' ? '#8b5cf6' :
                                       prospect.stage === 'Proposal' ? '#f59e0b' :
                                       prospect.stage === 'Negotiation' ? '#ef4444' :
                                       '#10b981'
                              }}>
                                {prospect.stage}
                              </div>
                            </div>
                            
                            <div style={{ fontSize: '0.75rem', color: '#94a3b8', marginBottom: '0.5rem' }}>
                              ARR: ${(prospect.arr / 1000).toFixed(0)}K • Close: {prospect.closeChance}%
                            </div>
                            
                            <button
                              onClick={() => {
                                if (weeklyHoursUsed + 3 <= weeklyHoursAvailable) {
                                  advanceProspect(prospect);
                                  setWeeklyHoursUsed(prev => prev + 3);
                                } else {
                                  alert('Not enough hours this week!');
                                }
                              }}
                              style={{
                                width: '100%',
                                padding: '0.5rem',
                                background: '#3b82f6',
                                border: 'none',
                                borderRadius: '0.5rem',
                                color: '#fff',
                                fontSize: '0.75rem',
                                fontWeight: '600',
                                cursor: 'pointer'
                              }}
                            >
                              Advance Deal (3h)
                            </button>
                          </div>
                        ))}
                      </div>
                      
                      {prospectsContactedThisWeek < 10 && (
                        <button
                          onClick={() => {
                            if (weeklyHoursUsed + 2 <= weeklyHoursAvailable) {
                              const newProspect = generateProspect();
                              setProspects(prev => [...prev, newProspect]);
                              setWeeklyHoursUsed(prev => prev + 2);
                              setProspectsContactedThisWeek(prev => prev + 1);
                            } else {
                              alert('Not enough hours this week!');
                            }
                          }}
                          style={{
                            width: '100%',
                            padding: '1rem',
                            background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
                            border: 'none',
                            borderRadius: '0.5rem',
                            color: '#fff',
                            fontWeight: '700',
                            cursor: 'pointer'
                          }}
                        >
                          📞 Identify New Prospect (2h)
                        </button>
                      )}
                    </div>
                  )}
                </div>
              )}
              {activePanel === 'team' && (
                <div style={{ maxHeight: '70vh', overflowY: 'auto' }}>
                  <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '1rem' }}>👥 Team Management</h2>
                  
                  <div style={{ marginBottom: '1rem' }}>
                    <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '0.5rem' }}>
                      Team Size: {employees.length + 1} (You + {employees.length} employee{employees.length !== 1 ? 's' : ''})
                    </div>
                  </div>
                  
                  {/* Founder */}
                  <div style={{
                    padding: '1rem',
                    background: 'linear-gradient(135deg, #1e293b 0%, #334155 100%)',
                    border: '2px solid #3b82f6',
                    borderRadius: '0.5rem',
                    marginBottom: '1rem'
                  }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <div>
                        <div style={{ fontSize: '1rem', fontWeight: '700', marginBottom: '0.25rem' }}>
                          You (Founder & CEO)
                        </div>
                        <div style={{ fontSize: '0.75rem', color: founderType === 'Technical' ? '#3b82f6' : '#10b981', fontWeight: '600' }}>
                          {founderType ? FOUNDER_PATHS[founderType].career.levels[jobLevel] : 'Full-time Founder'}
                        </div>
                        {jobBonus && (
                          <div style={{ fontSize: '0.7rem', color: '#10b981', marginTop: '0.25rem' }}>
                            🚀 {jobBonus.description}
                          </div>
                        )}
                      </div>
                      <div style={{ fontSize: '2rem' }}>👤</div>
                    </div>
                  </div>
                  
                  {/* Employees */}
                  {employees.length > 0 && (
                    <div style={{ marginBottom: '1rem' }}>
                      <div style={{ fontSize: '0.875rem', fontWeight: '600', marginBottom: '0.5rem' }}>
                        Team Members:
                      </div>
                      <div style={{ display: 'grid', gap: '0.5rem' }}>
                        {employees.map((emp, idx) => (
                          <div
                            key={idx}
                            style={{
                              padding: '0.75rem',
                              background: '#0f172a',
                              border: '1px solid #334155',
                              borderRadius: '0.5rem'
                            }}
                          >
                            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                              <div style={{ flex: 1 }}>
                                <div style={{ fontSize: '0.875rem', fontWeight: '600' }}>{emp.name}</div>
                                <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>{emp.department}</div>
                              </div>
                              <div style={{ textAlign: 'right' }}>
                                <div style={{ fontSize: '0.75rem', color: '#10b981' }}>
                                  ${(emp.salary / 1000).toFixed(0)}K/yr
                                </div>
                                <div style={{ fontSize: '0.7rem', color: '#64748b' }}>
                                  +{emp.productivityBonus}% productivity
                                </div>
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                  
                  {/* Monthly Burn */}
                  <div style={{
                    padding: '1rem',
                    background: 'rgba(239, 68, 68, 0.1)',
                    border: '1px solid rgba(239, 68, 68, 0.3)',
                    borderRadius: '0.5rem',
                    marginBottom: '1rem'
                  }}>
                    <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '0.25rem' }}>
                      Monthly Burn (Payroll):
                    </div>
                    <div style={{ fontSize: '1.25rem', fontWeight: '700', color: '#ef4444' }}>
                      ${(employees.reduce((sum, e) => sum + e.salary, 0) / 12).toFixed(0)}/month
                    </div>
                  </div>
                  
                  {/* Hire Button */}
                  <button
                    onClick={() => {
                      setShowHireModal(true);
                      setActivePanel(null);
                    }}
                    style={{
                      width: '100%',
                      padding: '1rem',
                      background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
                      border: 'none',
                      borderRadius: '0.5rem',
                      color: '#fff',
                      fontWeight: '700',
                      cursor: 'pointer'
                    }}
                  >
                    + Hire Employee
                  </button>
                </div>
              )}
              {activePanel === 'money' && (
                <div>
                  <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '1rem' }}>💸 Money Management</h2>
                  <div style={{marginBottom: '1.5rem'}}>
                    <div style={{padding: '1rem', background: 'rgba(16, 185, 129, 0.1)', borderRadius: '0.5rem', marginBottom: '1rem'}}>
                      <div style={{fontSize: '0.75rem', color: '#94a3b8'}}>Personal Cash</div>
                      <div style={{fontSize: '1.5rem', fontWeight: '700', color: '#10b981'}}>{formatMoney(personalCash)}</div>
                    </div>
                    <div style={{padding: '1rem', background: 'rgba(59, 130, 246, 0.1)', borderRadius: '0.5rem'}}>
                      <div style={{fontSize: '0.75rem', color: '#94a3b8'}}>Business Cash</div>
                      <div style={{fontSize: '1.5rem', fontWeight: '700', color: '#3b82f6'}}>{formatMoney(businessCash)}</div>
                    </div>
                  </div>
                  <button onClick={() => setShowTransferModal(true)} style={{padding: '1rem', background: '#f59e0b', border: 'none', borderRadius: '0.5rem', color: '#fff', cursor: 'pointer', width: '100%', marginBottom: '0.5rem'}}>
                    💸 Transfer Money
                  </button>
                  <button onClick={() => { setActivePanel(null); setActiveTab('investments'); }} style={{padding: '1rem', background: 'rgba(245, 158, 11, 0.2)', border: '1px solid #f59e0b', borderRadius: '0.5rem', color: '#fff', cursor: 'pointer', width: '100%'}}>
                    View Investments
                  </button>
                </div>
              )}
              
              {activePanel === 'checklist' && (
                <div style={{ maxHeight: '70vh', overflowY: 'auto' }}>
                  <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '0.5rem' }}>✅ Startup Checklist</h2>
                  
                  {/* Current Level */}
                  <div style={{ 
                    padding: '1rem', 
                    background: 'linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%)',
                    borderRadius: '0.75rem',
                    marginBottom: '1.5rem'
                  }}>
                    <div style={{ fontSize: '0.75rem', color: 'rgba(255,255,255,0.8)', marginBottom: '0.25rem' }}>
                      Current Level
                    </div>
                    <div style={{ fontSize: '1.25rem', fontWeight: '700', color: '#fff', marginBottom: '0.5rem' }}>
                      {startupLevel}
                    </div>
                    <div style={{ fontSize: '0.8rem', color: 'rgba(255,255,255,0.9)' }}>
                      {STARTUP_LEVELS[startupLevel].description}
                    </div>
                  </div>
                  
                  {/* Tasks */}
                  <div style={{ marginBottom: '1rem' }}>
                    <div style={{ fontSize: '0.875rem', fontWeight: '600', color: '#94a3b8', marginBottom: '0.75rem' }}>
                      Complete these tasks to reach: {STARTUP_LEVELS[startupLevel].nextLevel}
                    </div>
                    
                    {STARTUP_LEVELS[startupLevel].tasks.map((task, idx) => {
                      const isCompleted = completedTasks[task.id] || false;
                      
                      // Show action buttons for incomplete tasks
                      let actionButton = null;
                      if (!isCompleted) {
                        if (task.id === 'setup_llc') {
                          actionButton = (
                            <button
                              onClick={() => {
                                if (businessCash >= 800) {
                                  setBusinessCash(prev => prev - 800);
                                  setHasLLC(true);
                                  setCompletedTasks(prev => ({ ...prev, setup_llc: true }));
                                  alert('✅ LLC Established!\n\nYour business is now a legal entity.');
                                } else {
                                  alert('❌ Need $800 in Business Cash to file LLC');
                                }
                              }}
                              disabled={businessCash < 800}
                              style={{
                                padding: '0.5rem 1rem',
                                background: businessCash >= 800 ? '#3b82f6' : '#475569',
                                border: 'none',
                                borderRadius: '0.25rem',
                                color: '#fff',
                                fontSize: '0.7rem',
                                cursor: businessCash >= 800 ? 'pointer' : 'not-allowed',
                                marginTop: '0.5rem'
                              }}
                            >
                              💼 File LLC ($800)
                            </button>
                          );
                        } else if (task.id === 'setup_social') {
                          actionButton = (
                            <button
                              onClick={() => {
                                setHasSocialMedia(true);
                                setCompletedTasks(prev => ({ ...prev, setup_social: true }));
                                alert('✅ Social Media Set Up!\n\nCreated Twitter, LinkedIn, and Instagram accounts.');
                              }}
                              style={{
                                padding: '0.5rem 1rem',
                                background: '#3b82f6',
                                border: 'none',
                                borderRadius: '0.25rem',
                                color: '#fff',
                                fontSize: '0.7rem',
                                cursor: 'pointer',
                                marginTop: '0.5rem'
                              }}
                            >
                              📱 Create Accounts (Free)
                            </button>
                          );
                        } else if (task.id === 'setup_strupe') {
                          actionButton = (
                            <button
                              onClick={() => {
                                setHasStrupe(true);
                                setCompletedTasks(prev => ({ ...prev, setup_strupe: true }));
                                alert('✅ Strupe Connected!\n\nYou can now accept payments from customers.');
                              }}
                              style={{
                                padding: '0.5rem 1rem',
                                background: '#3b82f6',
                                border: 'none',
                                borderRadius: '0.25rem',
                                color: '#fff',
                                fontSize: '0.7rem',
                                cursor: 'pointer',
                                marginTop: '0.5rem'
                              }}
                            >
                              💳 Set up Strupe (Free)
                            </button>
                          );
                        } else if (task.id === 'research_startup') {
                          actionButton = (
                            <button
                              onClick={() => {
                                setHasResearched(true);
                                setCompletedTasks(prev => ({ ...prev, research_startup: true }));
                                alert('✅ Research Complete!\n\nYou learned about:\n• Tax obligations (EIN, quarterly taxes)\n• Business insurance basics\n• Founder equity splits\n• Terms of service & privacy policy');
                              }}
                              style={{
                                padding: '0.5rem 1rem',
                                background: '#3b82f6',
                                border: 'none',
                                borderRadius: '0.25rem',
                                color: '#fff',
                                fontSize: '0.7rem',
                                cursor: 'pointer',
                                marginTop: '0.5rem'
                              }}
                            >
                              🔍 Research (2 hours)
                            </button>
                          );
                        }
                      }
                      
                      return (
                        <div
                          key={idx}
                          style={{
                            padding: '0.75rem',
                            background: isCompleted ? 'rgba(16, 185, 129, 0.1)' : '#0f172a',
                            border: isCompleted ? '2px solid #10b981' : '2px solid #334155',
                            borderRadius: '0.5rem',
                            marginBottom: '0.5rem',
                            opacity: isCompleted ? 0.7 : 1
                          }}
                        >
                          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                            <div style={{ 
                              fontSize: '1.25rem',
                              color: isCompleted ? '#10b981' : '#64748b'
                            }}>
                              {isCompleted ? '✅' : '⬜'}
                            </div>
                            <div style={{ flex: 1 }}>
                              <div style={{ 
                                fontSize: '0.875rem', 
                                fontWeight: '600',
                                color: isCompleted ? '#10b981' : '#fff',
                                textDecoration: isCompleted ? 'line-through' : 'none'
                              }}>
                                {task.name}
                              </div>
                              {actionButton}
                            </div>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                  
                  {/* Progress */}
                  <div style={{ 
                    padding: '1rem',
                    background: '#0f172a',
                    borderRadius: '0.5rem',
                    border: '1px solid #334155'
                  }}>
                    <div style={{ fontSize: '0.75rem', color: '#94a3b8', marginBottom: '0.5rem' }}>
                      Progress
                    </div>
                    <div style={{ 
                      width: '100%', 
                      height: '8px', 
                      background: '#1e293b',
                      borderRadius: '4px',
                      overflow: 'hidden',
                      marginBottom: '0.5rem'
                    }}>
                      <div style={{
                        width: `${(Object.values(completedTasks).filter(Boolean).length / STARTUP_LEVELS[startupLevel].tasks.length) * 100}%`,
                        height: '100%',
                        background: 'linear-gradient(90deg, #8b5cf6 0%, #7c3aed 100%)',
                        transition: 'width 0.3s'
                      }} />
                    </div>
                    <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>
                      {Object.values(completedTasks).filter(Boolean).length} / {STARTUP_LEVELS[startupLevel].tasks.length} tasks completed
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}
      </div>


      {/* Modals */}
      {showStartupCreator && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'rgba(0,0,0,0.8)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 1000,
          padding: '2rem'
        }}>
          <div style={{
            background: '#1e293b',
            borderRadius: '1rem',
            padding: '2rem',
            maxWidth: '600px',
            width: '100%',
            maxHeight: '90vh',
            overflowY: 'auto',
            border: '2px solid #3b82f6'
          }}>
            <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '1.5rem', color: '#fff' }}>
              Create Your Startup
            </h2>
            
            {/* Step 1: Industry Selection */}
            {!selectedIndustry && (
              <div style={{ marginBottom: '1.5rem' }}>
                <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: '600', color: '#94a3b8', marginBottom: '0.5rem' }}>
                  Choose Your Industry
                </label>
                <div style={{ display: 'grid', gap: '0.75rem' }}>
                  {INDUSTRIES.map((industry, idx) => (
                    <button
                      key={idx}
                      onClick={() => setSelectedIndustry(industry)}
                      style={{
                        padding: '1rem',
                        background: '#0f172a',
                        border: '2px solid #334155',
                        borderRadius: '0.5rem',
                        color: '#fff',
                        cursor: 'pointer',
                        textAlign: 'left',
                        transition: 'all 0.2s',
                        fontSize: '1rem',
                        fontWeight: '600'
                      }}
                      onMouseEnter={e => e.currentTarget.style.borderColor = '#3b82f6'}
                      onMouseLeave={e => e.currentTarget.style.borderColor = '#334155'}
                    >
                      {industry}
                    </button>
                  ))}
                </div>
              </div>
            )}
            
            {/* Step 2: Idea Selection */}
            {selectedIndustry && (
              <>
                <div style={{ marginBottom: '1rem' }}>
                  <button
                    onClick={() => setSelectedIndustry(null)}
                    style={{
                      padding: '0.5rem 1rem',
                      background: '#334155',
                      border: 'none',
                      borderRadius: '0.5rem',
                      color: '#94a3b8',
                      cursor: 'pointer',
                      fontSize: '0.875rem',
                      marginBottom: '0.5rem'
                    }}
                  >
                    ← Back to Industries
                  </button>
                  <div style={{ fontSize: '1rem', fontWeight: '600', color: '#3b82f6' }}>
                    {selectedIndustry}
                  </div>
                </div>
                
                <div style={{ marginBottom: '1.5rem' }}>
                  <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: '600', color: '#94a3b8', marginBottom: '0.5rem' }}>
                    Choose Your Idea
                  </label>
                  <div style={{ display: 'grid', gap: '0.75rem' }}>
                    {STARTUP_IDEAS_BY_INDUSTRY[selectedIndustry].map((idea, idx) => (
                      <button
                        key={idx}
                        onClick={() => setStartupIdea({ ...idea, market: selectedIndustry })}
                        style={{
                          padding: '1rem',
                          background: startupIdea?.name === idea.name ? '#334155' : '#0f172a',
                          border: startupIdea?.name === idea.name ? '2px solid #3b82f6' : '2px solid #334155',
                          borderRadius: '0.5rem',
                          color: '#fff',
                          cursor: 'pointer',
                          textAlign: 'left',
                          transition: 'all 0.2s'
                        }}
                      >
                        <div style={{ fontSize: '0.875rem', fontWeight: '700', marginBottom: '0.25rem' }}>{idea.name}</div>
                        <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>{idea.problem}</div>
                        <div style={{ fontSize: '0.75rem', color: '#64748b', marginTop: '0.25rem' }}>TAM: ${idea.tam}B</div>
                      </button>
                    ))}
                  </div>
                </div>
              </>
            )}

            {startupIdea && (
              <>
                <div style={{ marginBottom: '1.5rem' }}>
                  <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: '600', color: '#94a3b8', marginBottom: '0.5rem' }}>
                    Company Name
                  </label>
                  <input
                    type="text"
                    value={startupName}
                    onChange={e => setStartupName(e.target.value)}
                    placeholder="Enter your company name..."
                    style={{
                      width: '100%',
                      padding: '0.75rem',
                      background: '#0f172a',
                      border: '2px solid #334155',
                      borderRadius: '0.5rem',
                      color: '#fff',
                      fontSize: '1rem',
                      outline: 'none'
                    }}
                  />
                </div>

                <div style={{ marginBottom: '1.5rem' }}>
                  <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: '600', color: '#94a3b8', marginBottom: '0.5rem' }}>
                    Choose Your Logo
                  </label>
                  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: '0.75rem' }}>
                    {LOGOS.map((logo, idx) => (
                      <button
                        key={idx}
                        onClick={() => setStartupLogo(logo)}
                        style={{
                          padding: '1rem',
                          background: startupLogo === logo ? logo.color : '#0f172a',
                          border: startupLogo === logo ? `2px solid ${logo.color}` : '2px solid #334155',
                          borderRadius: '0.5rem',
                          fontSize: '2rem',
                          cursor: 'pointer',
                          transition: 'all 0.2s',
                          aspectRatio: '1'
                        }}
                      >
                        {logo.icon}
                      </button>
                    ))}
                  </div>
                </div>
              </>
            )}

            <div style={{ display: 'flex', gap: '1rem' }}>
              <button
                onClick={() => {
                  setShowStartupCreator(false);
                  setSelectedIndustry(null);
                }}
                style={{
                  flex: 1,
                  padding: '0.75rem',
                  background: '#475569',
                  border: 'none',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer'
                }}
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  if (startupIdea && startupName && startupLogo) {
                    createStartup(startupIdea, startupName, startupLogo);
                    setSelectedIndustry(null);
                  }
                }}
                disabled={!startupIdea || !startupName || !startupLogo}
                style={{
                  flex: 1,
                  padding: '0.75rem',
                  background: startupIdea && startupName && startupLogo ? 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)' : '#475569',
                  border: 'none',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: startupIdea && startupName && startupLogo ? 'pointer' : 'not-allowed'
                }}
              >
                Create Startup
              </button>
            </div>
          </div>
        </div>
      )}

      {showHireModal && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'rgba(0,0,0,0.8)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 1000,
          padding: '2rem'
        }}>
          <div style={{
            background: '#1e293b',
            borderRadius: '1rem',
            padding: '2rem',
            maxWidth: '500px',
            width: '100%',
            border: '2px solid #3b82f6'
          }}>
            <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '1.5rem', color: '#fff' }}>
              Create Job Requisition
            </h2>
            
            <div style={{ marginBottom: '1.5rem' }}>
              <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: '600', color: '#94a3b8', marginBottom: '0.5rem' }}>
                Department
              </label>
              <select
                id="dept-select"
                style={{
                  width: '100%',
                  padding: '0.75rem',
                  background: '#0f172a',
                  border: '2px solid #334155',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontSize: '1rem'
                }}
              >
                {DEPARTMENTS.map(dept => (
                  <option key={dept} value={dept}>{dept}</option>
                ))}
              </select>
            </div>

            <div style={{ marginBottom: '1.5rem' }}>
              <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: '600', color: '#94a3b8', marginBottom: '0.5rem' }}>
                Position
              </label>
              <select
                id="pos-select"
                style={{
                  width: '100%',
                  padding: '0.75rem',
                  background: '#0f172a',
                  border: '2px solid #334155',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontSize: '1rem'
                }}
              >
                {POSITIONS[document.getElementById('dept-select')?.value || 'Engineering'].map(pos => (
                  <option key={pos} value={pos}>{pos}</option>
                ))}
              </select>
            </div>

            <div style={{ display: 'flex', gap: '1rem' }}>
              <button
                onClick={() => setShowHireModal(false)}
                style={{
                  flex: 1,
                  padding: '0.75rem',
                  background: '#475569',
                  border: 'none',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer'
                }}
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  const dept = document.getElementById('dept-select').value;
                  const pos = document.getElementById('pos-select').value;
                  createJobReq(dept, pos);
                  setShowHireModal(false);
                }}
                style={{
                  flex: 1,
                  padding: '0.75rem',
                  background: 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)',
                  border: 'none',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer'
                }}
              >
                Post Job
              </button>
            </div>
          </div>
        </div>
      )}

      {showAdModal && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'rgba(0,0,0,0.8)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 1000,
          padding: '2rem'
        }}>
          <div style={{
            background: '#1e293b',
            borderRadius: '1rem',
            padding: '2rem',
            maxWidth: '500px',
            width: '100%',
            border: '2px solid #ec4899'
          }}>
            <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '1.5rem', color: '#fff' }}>
              Launch Marketing Campaign
            </h2>
            
            <div style={{ marginBottom: '1.5rem' }}>
              <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: '600', color: '#94a3b8', marginBottom: '0.5rem' }}>
                Platform
              </label>
              <select
                id="platform-select"
                style={{
                  width: '100%',
                  padding: '0.75rem',
                  background: '#0f172a',
                  border: '2px solid #334155',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontSize: '1rem'
                }}
              >
                <option value="Google Ads">Google Ads</option>
                <option value="Facebook Ads">Facebook Ads</option>
                <option value="LinkedIn Ads">LinkedIn Ads</option>
                <option value="Twitter Ads">Twitter Ads</option>
                <option value="TikTok Ads">TikTok Ads</option>
              </select>
            </div>

            <div style={{ marginBottom: '1.5rem' }}>
              <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: '600', color: '#94a3b8', marginBottom: '0.5rem' }}>
                Budget
              </label>
              <input
                type="number"
                id="budget-input"
                placeholder="Enter budget..."
                style={{
                  width: '100%',
                  padding: '0.75rem',
                  background: '#0f172a',
                  border: '2px solid #334155',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontSize: '1rem'
                }}
              />
            </div>

            <div style={{ display: 'flex', gap: '1rem' }}>
              <button
                onClick={() => setShowAdModal(false)}
                style={{
                  flex: 1,
                  padding: '0.75rem',
                  background: '#475569',
                  border: 'none',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer'
                }}
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  const platform = document.getElementById('platform-select').value;
                  const budget = parseFloat(document.getElementById('budget-input').value);
                  if (budget) {
                    launchAdCampaign(budget, platform);
                    setShowAdModal(false);
                  }
                }}
                style={{
                  flex: 1,
                  padding: '0.75rem',
                  background: 'linear-gradient(135deg, #ec4899 0%, #db2777 100%)',
                  border: 'none',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer'
                }}
              >
                Launch
              </button>
            </div>
          </div>
        </div>
      )}
      
      {showTransferModal && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'rgba(0,0,0,0.8)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 1000,
          padding: '2rem'
        }}>
          <div style={{
            background: '#1e293b',
            borderRadius: '1rem',
            padding: '2rem',
            maxWidth: '500px',
            width: '100%',
            border: '2px solid #8b5cf6'
          }}>
            <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '1.5rem', color: '#fff' }}>
              Transfer Money
            </h2>
            
            <div style={{ marginBottom: '1.5rem' }}>
              <div style={{
                background: '#0f172a',
                padding: '1rem',
                borderRadius: '0.5rem',
                marginBottom: '1rem',
                border: '1px solid #334155'
              }}>
                <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '0.5rem' }}>
                  Personal Account
                </div>
                <div style={{ fontSize: '1.5rem', fontWeight: '700', color: '#f59e0b' }}>
                  {formatMoney(personalCash)}
                </div>
              </div>
              
              <div style={{
                background: '#0f172a',
                padding: '1rem',
                borderRadius: '0.5rem',
                border: '1px solid #334155'
              }}>
                <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '0.5rem' }}>
                  Business Account
                </div>
                <div style={{ fontSize: '1.5rem', fontWeight: '700', color: '#3b82f6' }}>
                  {formatMoney(businessCash)}
                </div>
              </div>
            </div>

            <div style={{ marginBottom: '1.5rem' }}>
              <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: '600', color: '#94a3b8', marginBottom: '0.5rem' }}>
                Amount
              </label>
              <input
                type="number"
                id="transfer-amount"
                placeholder="Enter amount..."
                style={{
                  width: '100%',
                  padding: '0.75rem',
                  background: '#0f172a',
                  border: '2px solid #334155',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontSize: '1rem'
                }}
              />
            </div>

            <div style={{ display: 'flex', gap: '1rem', marginBottom: '1rem' }}>
              <button
                onClick={() => {
                  const amount = parseFloat(document.getElementById('transfer-amount').value);
                  if (amount) {
                    transferMoney(amount, 'toBusiness');
                    setShowTransferModal(false);
                  }
                }}
                style={{
                  flex: 1,
                  padding: '0.75rem',
                  background: 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)',
                  border: 'none',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer'
                }}
              >
                Personal → Business
              </button>
              <button
                onClick={() => {
                  const amount = parseFloat(document.getElementById('transfer-amount').value);
                  if (amount) {
                    transferMoney(amount, 'toPersonal');
                    setShowTransferModal(false);
                  }
                }}
                style={{
                  flex: 1,
                  padding: '0.75rem',
                  background: 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)',
                  border: 'none',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer'
                }}
              >
                Business → Personal
              </button>
            </div>
            
            <button
              onClick={() => setShowTransferModal(false)}
              style={{
                width: '100%',
                padding: '0.75rem',
                background: '#475569',
                border: 'none',
                borderRadius: '0.5rem',
                color: '#fff',
                fontWeight: '700',
                cursor: 'pointer'
              }}
            >
              Cancel
            </button>
          </div>
        </div>
      )}
      
      {/* LLC Filing Website Modal */}
      {showLLCWebsite && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'rgba(0, 0, 0, 0.8)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 1000
        }}>
          <div style={{
            background: '#1e293b',
            border: '2px solid #3b82f6',
            borderRadius: '1rem',
            padding: '2rem',
            maxWidth: '600px',
            width: '90%',
            maxHeight: '80vh',
            overflowY: 'auto'
          }}>
            <div style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '1rem', color: '#fff' }}>
              🏛️ LegalZoom - LLC Formation
            </div>
            
            <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '1.5rem' }}>
              Form your Limited Liability Company online. Protect your personal assets and establish your business legally.
            </div>
            
            <div style={{ marginBottom: '1.5rem' }}>
              <div style={{ fontSize: '0.875rem', fontWeight: '600', color: '#fff', marginBottom: '0.5rem' }}>
                Select Your State:
              </div>
              <select
                id="llcState"
                style={{
                  width: '100%',
                  padding: '0.75rem',
                  background: '#0f172a',
                  border: '2px solid #334155',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontSize: '0.875rem'
                }}
              >
                {Object.keys(LLC_STATE_FEES).map(state => (
                  <option key={state} value={state}>{state}</option>
                ))}
              </select>
            </div>
            
            <div id="llcStateInfo" style={{
              padding: '1rem',
              background: '#0f172a',
              borderRadius: '0.5rem',
              marginBottom: '1.5rem'
            }}>
              {(() => {
                const selectedState = document.getElementById('llcState')?.value || 'Delaware';
                const fees = LLC_STATE_FEES[selectedState];
                return (
                  <>
                    <div style={{ fontSize: '0.75rem', color: '#94a3b8', marginBottom: '0.5rem' }}>Filing Fee:</div>
                    <div style={{ fontSize: '1.25rem', fontWeight: '700', color: '#10b981', marginBottom: '1rem' }}>
                      ${fees.fee}
                    </div>
                    <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>
                      Annual Tax/Fee: ${fees.annualTax}<br/>
                      Processing Time: {fees.processingTime}
                    </div>
                  </>
                );
              })()}
            </div>
            
            <div style={{ display: 'flex', gap: '1rem' }}>
              <button
                onClick={() => {
                  const state = document.getElementById('llcState').value;
                  const fees = LLC_STATE_FEES[state];
                  const totalCost = fees.fee;
                  
                  if (weeklyHoursUsed + 2 > weeklyHoursAvailable) {
                    alert('Not enough hours this week! Filing LLC takes 2 hours.');
                    return;
                  }
                  
                  if (businessCash >= totalCost) {
                    setBusinessCash(prev => prev - totalCost);
                    setWeeklyHoursUsed(prev => prev + 2);
                    setChecklistItems(prev => ({ ...prev, llcSetup: true }));
                    setTimeout(checkMilestoneComplete, 100);
                    setShowLLCWebsite(false);
                    alert(`✅ LLC Filed in ${state}!\n\nFiling Fee: $${totalCost}\nAnnual Tax: $${fees.annualTax}\n\nYour business is now a legal entity. Processing will take ${fees.processingTime}.`);
                  } else {
                    alert(`❌ Insufficient funds!\n\nNeed $${totalCost} in Business Cash to file LLC in ${state}.`);
                  }
                }}
                style={{
                  flex: 1,
                  padding: '1rem',
                  background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
                  border: 'none',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer'
                }}
              >
                File LLC (2 hours)
              </button>
              
              <button
                onClick={() => setShowLLCWebsite(false)}
                style={{
                  flex: 1,
                  padding: '1rem',
                  background: '#475569',
                  border: 'none',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer'
                }}
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
      
      {/* Strupe Payments Website Modal */}
      {showStrupeWebsite && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'rgba(0, 0, 0, 0.8)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 1000
        }}>
          <div style={{
            background: '#1e293b',
            border: '2px solid #635bff',
            borderRadius: '1rem',
            padding: '2rem',
            maxWidth: '700px',
            width: '90%',
            maxHeight: '80vh',
            overflowY: 'auto'
          }}>
            <div style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '1rem', color: '#635bff' }}>
              Strupe Payments
            </div>
            
            <div style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '1.5rem' }}>
              Accept payments online. Get started in minutes with industry-leading payment processing.
            </div>
            
            <div style={{ display: 'grid', gap: '1rem', marginBottom: '1.5rem' }}>
              {Object.entries(STREEP_PRICING).map(([key, plan]) => (
                <div key={key} style={{
                  padding: '1.5rem',
                  background: '#0f172a',
                  border: '2px solid #334155',
                  borderRadius: '0.75rem'
                }}>
                  <div style={{ fontSize: '1.25rem', fontWeight: '700', color: '#fff', marginBottom: '0.5rem' }}>
                    {plan.name}
                  </div>
                  <div style={{ fontSize: '0.75rem', color: '#94a3b8', marginBottom: '1rem' }}>
                    {plan.description}
                  </div>
                  <div style={{ fontSize: '2rem', fontWeight: '700', color: '#10b981', marginBottom: '0.5rem' }}>
                    {plan.transactionFee}% + ${plan.flatFee}
                  </div>
                  <div style={{ fontSize: '0.875rem', color: '#94a3b8' }}>
                    per transaction
                    {plan.monthlyFee > 0 && ` + $${plan.monthlyFee}/month`}
                  </div>
                </div>
              ))}
            </div>
            
            <div style={{ padding: '1rem', background: 'rgba(99, 91, 255, 0.1)', borderRadius: '0.5rem', marginBottom: '1.5rem' }}>
              <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>
                ℹ️ Most startups begin with Standard pricing. You can upgrade to Plus later when processing $10K+/month to save on fees.
              </div>
            </div>
            
            <div style={{ display: 'flex', gap: '1rem' }}>
              <button
                onClick={() => {
                  if (weeklyHoursUsed + 1 > weeklyHoursAvailable) {
                    alert('Not enough hours this week! Strupe setup takes 1 hour.');
                    return;
                  }
                  
                  setWeeklyHoursUsed(prev => prev + 1);
                  setChecklistItems(prev => ({ ...prev, strupeSetup: true }));
                  setTimeout(checkMilestoneComplete, 100);
                  setShowStrupeWebsite(false);
                  alert('✅ Strupe Payments Connected!\n\nYou can now accept customer payments.\n\nPricing: 2.9% + $0.30 per transaction (Standard)');
                }}
                style={{
                  flex: 1,
                  padding: '1rem',
                  background: 'linear-gradient(135deg, #635bff 0%, #5145e5 100%)',
                  border: 'none',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer'
                }}
              >
                Get Started (1 hour)
              </button>
              
              <button
                onClick={() => setShowStrupeWebsite(false)}
                style={{
                  flex: 1,
                  padding: '1rem',
                  background: '#475569',
                  border: 'none',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  fontWeight: '700',
                  cursor: 'pointer'
                }}
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
