import React, { useState, useEffect } from 'react';
import { generateBusinessOffer, calculateMonthlyProfit } from '../businesses';
import { buyBusiness } from '../gameState';

export const BusinessBrowser = ({ state, onBuyBusiness, onClose }) => {
  const [businesses, setBusinesses] = useState([]);
  const [selectedBusiness, setSelectedBusiness] = useState(null);

  useEffect(() => {
    const generated = Array.from({ length: 5 }, () => generateBusinessOffer());
    setBusinesses(generated);
  }, []);

  const handleBuy = (business) => {
    onBuyBusiness(business);
    onClose();
  };

  const formatMoney = (num) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
    }).format(num);
  };

  const canAfford = (business) => state.cash >= business.buyPrice;

  return (
    <div className="fixed inset-0 bg-black/70 flex items-end z-50">
      <div className="w-full bg-dark-card rounded-t-2xl max-w-md mx-auto max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-dark-card border-b border-dark-border p-4 flex justify-between items-center">
          <h2 className="font-bold">Available Businesses</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-white">✕</button>
        </div>

        <div className="p-4 space-y-3">
          {businesses.map((business) => {
            const monthlyProfit = calculateMonthlyProfit(business);
            const affordable = canAfford(business);

            return (
              <div
                key={business.id}
                className={`card border-l-4 cursor-pointer transition-all ${
                  affordable ? 'border-green-600 hover:bg-dark-border/50' : 'border-red-600 opacity-60'
                }`}
                onClick={() => setSelectedBusiness(selectedBusiness === business.id ? null : business.id)}
              >
                <div className="flex justify-between items-start mb-2">
                  <div>
                    <div className="font-semibold text-sm">{business.name}</div>
                    <div className="text-xs text-gray-500">{business.category}</div>
                  </div>
                  <div className="text-right">
                    <div className="number text-sm text-amber-400">{formatMoney(business.buyPrice)}</div>
                  </div>
                </div>

                {selectedBusiness === business.id && (
                  <div className="mt-3 pt-3 border-t border-dark-border space-y-2 text-xs">
                    <div className="grid grid-cols-2 gap-2">
                      <div>
                        <span className="text-gray-400">Annual Revenue:</span>
                        <div className="number">{formatMoney(business.annualRevenue)}</div>
                      </div>
                      <div>
                        <span className="text-gray-400">Monthly Profit:</span>
                        <div className="number positive">{formatMoney(monthlyProfit)}</div>
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-2">
                      <div>
                        <span className="text-gray-400">Net Margin:</span>
                        <div className="number">{(business.netMargin * 100).toFixed(0)}%</div>
                      </div>
                      <div>
                        <span className="text-gray-400">Passive:</span>
                        <div className="number">{(business.passiveCoeff * 100).toFixed(0)}%</div>
                      </div>
                    </div>

                    <div className="text-gray-400 mt-2">{business.flavor}</div>

                    <button
                      onClick={() => handleBuy(business)}
                      disabled={!affordable}
                      className="btn btn-primary w-full mt-3 text-xs py-2 disabled:opacity-50"
                    >
                      {affordable ? 'Buy Now' : 'Not Enough Cash'}
                    </button>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};
