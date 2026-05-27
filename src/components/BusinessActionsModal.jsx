import React, { useState } from 'react';
import { calculateMonthlyProfit } from '../businesses';

export const BusinessActionsModal = ({ business, onGrow, onHireManager, onClose }) => {
  const [growAmount, setGrowAmount] = useState(5000);

  const formatMoney = (num) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
    }).format(num);
  };

  const monthlyProfit = calculateMonthlyProfit(business);

  return (
    <div className="fixed inset-0 bg-black/70 flex items-end z-50">
      <div className="w-full bg-dark-card rounded-t-2xl max-w-md mx-auto">
        <div className="sticky top-0 bg-dark-card border-b border-dark-border p-4 flex justify-between items-center">
          <h2 className="font-bold">{business.name}</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-white">✕</button>
        </div>

        <div className="p-4 space-y-4">
          <div className="border border-dark-border rounded-lg p-3">
            <div className="text-xs text-gray-400 mb-2">Condition</div>
            <div className="stat-bar">
              <div
                className="stat-fill bg-blue-600"
                style={{ width: `${business.condition}%` }}
              />
            </div>
            <div className="text-xs mt-2">{business.condition.toFixed(0)}%</div>
          </div>

          <div>
            <div className="text-xs text-gray-400 mb-3">Grow This Business</div>
            <div className="flex gap-2 mb-3">
              {[5000, 10000, 25000].map((amount) => (
                <button
                  key={amount}
                  onClick={() => setGrowAmount(amount)}
                  className={`flex-1 py-2 rounded text-xs font-medium ${
                    growAmount === amount
                      ? 'bg-green-600'
                      : 'bg-dark-border hover:bg-gray-700'
                  }`}
                >
                  {formatMoney(amount)}
                </button>
              ))}
            </div>
            <p className="text-xs text-gray-400 mb-3">
              Invest to improve condition and boost revenue +5%
            </p>
            <button
              onClick={() => {
                onGrow(growAmount);
                onClose();
              }}
              className="btn btn-primary w-full py-2 text-xs"
            >
              Invest {formatMoney(growAmount)}
            </button>
          </div>

          {!business.manager && (
            <div className="border-t border-dark-border pt-4">
              <div className="text-xs text-gray-400 mb-3">Hire a Manager</div>
              <p className="text-xs text-gray-300 mb-3">
                Manager will handle day-to-day operations. Costs {Math.round(business.managerCost * 100)}% of revenue annually.
              </p>
              <button
                onClick={() => {
                  onHireManager();
                  onClose();
                }}
                className="btn btn-secondary w-full py-2 text-xs"
              >
                Hire Manager
              </button>
            </div>
          )}

          {business.manager && (
            <div className="bg-green-950/30 border border-green-600/50 rounded-lg p-3 text-xs">
              <div className="text-green-400 font-semibold">✓ Manager on staff</div>
              <div className="text-gray-400 mt-1">
                Handles operations. Cost: {formatMoney(Math.floor(business.annualRevenue * business.managerCost) / 12)}/month
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
