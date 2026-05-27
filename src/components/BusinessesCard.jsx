import React, { useState } from 'react';
import { calculateMonthlyProfit, calculateSalePrice } from '../businesses';

export const BusinessesCard = ({ businesses, onSellBusiness, onSelectBusiness }) => {
  const [expanded, setExpanded] = useState(false);

  const formatMoney = (num) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
    }).format(num);
  };

  const totalMonthlyProfit = businesses.reduce((sum, b) => sum + calculateMonthlyProfit(b), 0);
  const totalAnnualProfit = totalMonthlyProfit * 12;

  if (businesses.length === 0) {
    return (
      <div className="card mb-4 text-gray-500 text-sm">
        No businesses owned yet. Time to build your empire.
      </div>
    );
  }

  return (
    <div className="card mb-4">
      <button
        onClick={() => setExpanded(!expanded)}
        className="w-full text-left"
      >
        <div className="flex justify-between items-center">
          <div>
            <div className="text-xs text-gray-400">💼 Businesses ({businesses.length})</div>
            <div className="number text-lg mt-1 positive">{formatMoney(totalMonthlyProfit)}/month</div>
          </div>
        </div>
      </button>

      {expanded && (
        <div className="mt-4 pt-4 border-t border-dark-border space-y-3">
          {businesses.map((business) => {
            const monthlyProfit = calculateMonthlyProfit(business);
            const salePrice = calculateSalePrice(business);

            return (
              <div key={business.id} className="border border-dark-border rounded-lg p-3">
                <div className="flex justify-between items-start mb-2">
                  <div>
                    <div className="font-semibold text-sm">{business.name}</div>
                    <div className="text-xs text-gray-500">{business.category}</div>
                  </div>
                  <div className="text-right text-xs">
                    <div className="text-gray-400">Monthly</div>
                    <div className="number positive">{formatMoney(monthlyProfit)}</div>
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-2 text-xs mb-3">
                  <div>
                    <span className="text-gray-500">Condition</span>
                    <div className="stat-bar mt-1">
                      <div
                        className="stat-fill bg-blue-600"
                        style={{ width: `${business.condition}%` }}
                      />
                    </div>
                  </div>
                  <div>
                    <span className="text-gray-500">Margin</span>
                    <div className="number mt-1">{(business.netMargin * 100).toFixed(0)}%</div>
                  </div>
                  <div>
                    <span className="text-gray-500">Passive</span>
                    <div className="number mt-1">{(business.passiveCoeff * 100).toFixed(0)}%</div>
                  </div>
                </div>

                {business.manager && (
                  <div className="text-xs text-gray-400 mb-2">Manager on staff</div>
                )}

                <div className="flex gap-2">
                  <button
                    onClick={() => onSelectBusiness(business)}
                    className="btn btn-secondary flex-1 text-xs py-1"
                  >
                    Manage
                  </button>
                  <button
                    onClick={() => onSellBusiness(business.id)}
                    className="btn btn-danger flex-1 text-xs py-1"
                  >
                    Sell {formatMoney(salePrice)}
                  </button>
                </div>
              </div>
            );
          })}

          <div className="mt-4 pt-4 border-t border-dark-border">
            <div className="text-xs text-gray-400">Annual Profit</div>
            <div className="number text-lg positive">{formatMoney(totalAnnualProfit)}</div>
          </div>
        </div>
      )}
    </div>
  );
};
