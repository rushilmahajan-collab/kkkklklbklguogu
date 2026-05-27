import React from 'react';

export const GameOverScreen = ({ state, onPlayAgain }) => {
  const formatMoney = (num) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
    }).format(num);
  };

  const getGrade = (netWorth) => {
    if (netWorth >= 10000000) return 'S';
    if (netWorth >= 5000000) return 'A';
    if (netWorth >= 1000000) return 'B';
    if (netWorth >= 250000) return 'C';
    if (netWorth >= 0) return 'D';
    return 'F';
  };

  const grade = getGrade(state.netWorth);
  const isBankrupt = state.bankrupt;

  return (
    <div className="min-h-screen bg-dark-bg flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <div className={`text-6xl font-bold mb-4 ${isBankrupt ? 'text-red-500' : 'text-green-500'}`}>
            {grade}
          </div>
          <h1 className="text-3xl font-bold mb-2">
            {isBankrupt ? 'Game Over' : 'Congratulations!'}
          </h1>
          <p className="text-gray-400">
            {isBankrupt
              ? 'You went bankrupt. Better luck next time!'
              : `You survived ${state.year} years and built an empire!`}
          </p>
        </div>

        <div className="card mb-6 space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <div className="text-xs text-gray-400">Years</div>
              <div className="number text-2xl">{state.year}</div>
            </div>
            <div>
              <div className="text-xs text-gray-400">Age</div>
              <div className="number text-2xl">{state.age}</div>
            </div>
          </div>

          <div className="border-t border-dark-border pt-4">
            <div className="text-xs text-gray-400 mb-1">Final Net Worth</div>
            <div className={`number text-3xl ${state.netWorth > 0 ? 'positive' : 'negative'}`}>
              {formatMoney(state.netWorth)}
            </div>
          </div>

          <div className="border-t border-dark-border pt-4">
            <div className="text-xs text-gray-400 mb-2">Summary</div>
            <div className="space-y-1 text-xs">
              <div className="flex justify-between">
                <span>Cash</span>
                <span className="number">{formatMoney(state.cash)}</span>
              </div>
              <div className="flex justify-between">
                <span>Businesses Owned</span>
                <span className="number">{state.businesses.length}</span>
              </div>
              <div className="flex justify-between">
                <span>Final Stress</span>
                <span className="number">{state.stress}</span>
              </div>
              <div className="flex justify-between">
                <span>Final Happiness</span>
                <span className="number">{state.happiness}</span>
              </div>
            </div>
          </div>
        </div>

        <button
          onClick={onPlayAgain}
          className="btn btn-primary w-full py-3 font-bold"
        >
          Play Again →
        </button>
      </div>
    </div>
  );
};
