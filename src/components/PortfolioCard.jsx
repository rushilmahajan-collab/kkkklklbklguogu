import React, { useState } from 'react';

export const PortfolioCard = ({ portfolio, clcIndex, lastClcValue, marketHistory, marketNews, lastMarketReturn }) => {
  const [expanded, setExpanded] = useState(false);

  const calculatePortfolioValue = () => {
    let total = portfolio.indexFund;
    Object.values(portfolio.stocks).forEach(v => total += v);
    Object.values(portfolio.bonds).forEach(v => total += v);
    total += portfolio.crypto;
    Object.values(portfolio.pennies).forEach(v => total += v);
    return total;
  };

  const portfolioValue = calculatePortfolioValue();
  const indexFundValue = portfolio.indexFund;
  const clcChange = ((clcIndex - lastClcValue) / lastClcValue) * 100;
  const clcChangeClass = clcChange > 0 ? 'positive' : clcChange < 0 ? 'negative' : 'neutral';

  const formatMoney = (num) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
    }).format(num);
  };

  return (
    <div className="card mb-4">
      <button
        onClick={() => setExpanded(!expanded)}
        className="w-full text-left"
      >
        <div className="flex justify-between items-center">
          <div>
            <div className="text-xs text-gray-400">📈 Portfolio</div>
            <div className="number text-lg mt-1">{formatMoney(portfolioValue)}</div>
          </div>
          <div className="text-right">
            <div className={`text-sm ${clcChangeClass}`}>
              CLC {clcChange > 0 ? '+' : ''}{clcChange.toFixed(1)}%
            </div>
            <div className="number text-xs text-gray-500">{clcIndex.toLocaleString()}</div>
          </div>
        </div>
      </button>

      {expanded && (
        <div className="mt-4 pt-4 border-t border-dark-border space-y-3">
          {indexFundValue > 0 && (
            <div className="flex justify-between text-xs">
              <span>Index Fund</span>
              <span className="number">{formatMoney(indexFundValue)}</span>
            </div>
          )}

          {Object.entries(portfolio.stocks).length > 0 && (
            <div>
              <div className="text-xs text-gray-400 mb-2">Stocks ({Object.entries(portfolio.stocks).length})</div>
              {Object.entries(portfolio.stocks).map(([ticker, value]) => (
                <div key={ticker} className="flex justify-between text-xs ml-2">
                  <span>{ticker}</span>
                  <span className="number">{formatMoney(value)}</span>
                </div>
              ))}
            </div>
          )}

          {Object.entries(portfolio.bonds).length > 0 && (
            <div>
              <div className="text-xs text-gray-400 mb-2">Bonds ({Object.entries(portfolio.bonds).length})</div>
              {Object.entries(portfolio.bonds).map(([name, value]) => (
                <div key={name} className="flex justify-between text-xs ml-2">
                  <span>{name}</span>
                  <span className="number">{formatMoney(value)}</span>
                </div>
              ))}
            </div>
          )}

          {portfolio.crypto > 0 && (
            <div className="flex justify-between text-xs">
              <span>Crypto</span>
              <span className="number positive">{formatMoney(portfolio.crypto)}</span>
            </div>
          )}

          {Object.entries(portfolio.pennies).length > 0 && (
            <div>
              <div className="text-xs text-gray-400 mb-2">Penny Stocks ({Object.entries(portfolio.pennies).length})</div>
              {Object.entries(portfolio.pennies).map(([ticker, value]) => (
                <div key={ticker} className="flex justify-between text-xs ml-2">
                  <span>{ticker}</span>
                  <span className="number">{formatMoney(value)}</span>
                </div>
              ))}
            </div>
          )}

          <div className="mt-4 pt-4 border-t border-dark-border">
            <div className="text-xs text-gray-400 mb-2">Market News</div>
            <div className="text-xs text-gray-300">{marketNews}</div>
          </div>

          <div className="mt-3">
            <div className="text-xs text-gray-400 mb-2">CLC Performance (10Y)</div>
            <div className="flex gap-1 h-6 items-end">
              {marketHistory.map((val, i) => {
                const minVal = Math.min(...marketHistory);
                const maxVal = Math.max(...marketHistory);
                const range = maxVal - minVal || 1;
                const height = ((val - minVal) / range) * 100;
                const isPositive = val > (marketHistory[i - 1] || val);
                return (
                  <div
                    key={i}
                    className={`flex-1 ${isPositive ? 'bg-green-600' : 'bg-red-600'}`}
                    style={{ height: `${Math.max(10, height)}%` }}
                  />
                );
              })}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
