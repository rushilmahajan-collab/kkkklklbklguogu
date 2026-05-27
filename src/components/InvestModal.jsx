import React, { useState } from 'react';

export const InvestModal = ({ state, onInvest, onClose }) => {
  const [investAmount, setInvestAmount] = useState(10000);

  const formatMoney = (num) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
    }).format(num);
  };

  const canAfford = state.cash >= investAmount;

  return (
    <div className="fixed inset-0 bg-black/70 flex items-end z-50">
      <div className="w-full bg-dark-card rounded-t-2xl max-w-md mx-auto">
        <div className="sticky top-0 bg-dark-card border-b border-dark-border p-4 flex justify-between items-center">
          <h2 className="font-bold">Invest in Market</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-white">✕</button>
        </div>

        <div className="p-4 space-y-4">
          <div className="bg-blue-950/30 border border-blue-600/50 rounded-lg p-3">
            <div className="text-xs text-gray-400 mb-2">CLC Index Fund</div>
            <div className="text-sm text-gray-300">
              Passive investing in the market. ~8% avg annual return. Your money works while you sleep.
            </div>
            <div className="text-xs text-gray-500 mt-2">Current CLC: {state.clcIndex.toLocaleString()}</div>
          </div>

          <div>
            <label className="text-xs text-gray-400 mb-2 block">Investment Amount</label>
            <input
              type="number"
              value={investAmount}
              onChange={(e) => setInvestAmount(Math.max(1000, parseInt(e.target.value) || 0))}
              className="w-full bg-dark-border border border-dark-border rounded-lg px-3 py-2 text-white monospace focus:outline-none focus:border-blue-600"
              min="1000"
              step="1000"
            />
          </div>

          <div className="flex gap-2">
            {[10000, 25000, 50000].map((amt) => (
              <button
                key={amt}
                onClick={() => setInvestAmount(amt)}
                className={`flex-1 py-2 rounded text-xs font-medium ${
                  investAmount === amt
                    ? 'bg-blue-600'
                    : 'bg-dark-border hover:bg-gray-700'
                }`}
              >
                {formatMoney(amt)}
              </button>
            ))}
          </div>

          <div className="border-t border-dark-border pt-3">
            <div className="flex justify-between text-xs mb-2">
              <span className="text-gray-400">Available Cash:</span>
              <span className="number">{formatMoney(state.cash)}</span>
            </div>
            <div className="flex justify-between text-xs">
              <span className="text-gray-400">After Investment:</span>
              <span className="number">{formatMoney(Math.max(0, state.cash - investAmount))}</span>
            </div>
          </div>

          <button
            onClick={() => {
              onInvest(investAmount);
              onClose();
            }}
            disabled={!canAfford}
            className="btn btn-primary w-full py-3 disabled:opacity-50"
          >
            {canAfford ? `Invest ${formatMoney(investAmount)}` : 'Not Enough Cash'}
          </button>
        </div>
      </div>
    </div>
  );
};
