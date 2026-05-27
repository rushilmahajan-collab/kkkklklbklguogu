import React, { useState } from 'react';
import { performAction, getAvailableActions, buyBusiness, sellBusiness, growBusiness, hireManager } from '../gameState';
import { PortfolioCard } from './PortfolioCard';
import { BusinessesCard } from './BusinessesCard';
import { BusinessBrowser } from './BusinessBrowser';
import { BusinessActionsModal } from './BusinessActionsModal';

export const MainGameScreen = ({ state, onAdvanceYear, onStateChange }) => {
  const [showBusinessBrowser, setShowBusinessBrowser] = useState(false);
  const [selectedBusiness, setSelectedBusiness] = useState(null);

  const availableActions = getAvailableActions(state);
  const canAct = state.actionsUsed < state.actionSlots;
  const slotsRemaining = state.actionSlots - state.actionsUsed;

  const handleAction = (actionId) => {
    if (actionId === 'buyBusiness') {
      setShowBusinessBrowser(true);
      return;
    }
    if (actionId === 'sellBusiness') {
      // This is handled per-business via the BusinessesCard
      return;
    }
    const newState = performAction(state, actionId);
    onStateChange(newState);
  };

  const handleBuyBusiness = (business) => {
    const newState = buyBusiness(state, business);
    onStateChange(newState);
  };

  const handleSellBusiness = (businessId) => {
    const newState = sellBusiness(state, businessId);
    onStateChange(newState);
  };

  const handleGrowBusiness = (amount) => {
    const newState = growBusiness(state, selectedBusiness.id, amount);
    onStateChange(newState);
    setSelectedBusiness(null);
  };

  const handleHireManager = () => {
    const newState = hireManager(state, selectedBusiness.id);
    onStateChange(newState);
    setSelectedBusiness(null);
  };

  const handleSelectBusiness = (business) => {
    setSelectedBusiness(business);
  };

  const handleAdvanceYear = () => {
    onAdvanceYear();
  };

  const handleRetire = () => {
    onStateChange({ ...state, bankrupt: false, age: 101 });
  };

  const formatMoney = (num) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
    }).format(num);
  };

  const netWorthDelta = state.netWorth - (state.lastNetWorth || state.netWorth);
  const deltaClass = netWorthDelta > 0 ? 'positive' : netWorthDelta < 0 ? 'negative' : 'neutral';

  return (
    <div className="min-h-screen bg-dark-bg p-4 pb-20">
      <div className="max-w-md mx-auto">
        {/* Top Bar */}
        <div className="flex justify-between items-center mb-6 text-sm">
          <div>Age <span className="number">{state.age}</span></div>
          <div>Year <span className="number">{state.year}</span></div>
          <div>Cash <span className="number positive">{formatMoney(state.cash)}</span></div>
        </div>

        {/* Net Worth */}
        <div className="card mb-4 border-green-600/50">
          <div className="text-xs text-gray-400">Net Worth</div>
          <div className="flex items-baseline gap-2 mt-1">
            <div className="number text-2xl">{formatMoney(state.netWorth)}</div>
            <div className={`text-xs ${deltaClass}`}>
              {netWorthDelta > 0 ? '+' : ''}{formatMoney(netWorthDelta)}
            </div>
          </div>
        </div>

        {/* Life Event */}
        {state.currentEvent && (
          <div className="card mb-4 border-amber-600/30 bg-amber-950/20">
            <div className="text-sm font-semibold mb-2">{state.currentEvent.name}</div>
            <div className="text-xs text-gray-300">{state.currentEvent.flavor}</div>
          </div>
        )}

        {/* Stats */}
        <div className="card mb-4 space-y-3">
          {[
            { label: 'Stress', value: state.stress, color: 'bg-red-600' },
            { label: 'Hustle', value: state.hustle, color: 'bg-purple-600' },
            { label: 'Connections', value: state.connections, color: 'bg-blue-600' },
            { label: 'Reputation', value: state.reputation, color: 'bg-amber-600' },
            { label: 'Happiness', value: state.happiness, color: 'bg-green-600' },
          ].map((stat) => (
            <div key={stat.label}>
              <div className="flex justify-between text-xs mb-1">
                <span className="text-gray-400">{stat.label}</span>
                <span className="number">{stat.value}</span>
              </div>
              <div className="stat-bar">
                <div
                  className={`stat-fill ${stat.color}`}
                  style={{ width: `${stat.value}%` }}
                />
              </div>
            </div>
          ))}
        </div>

        {/* Portfolio */}
        <PortfolioCard
          portfolio={state.portfolio}
          clcIndex={state.clcIndex}
          lastClcValue={state.lastClcValue}
          marketHistory={state.marketHistory}
          marketNews={state.marketNews}
          lastMarketReturn={state.lastMarketReturn}
        />

        {/* Businesses */}
        <BusinessesCard
          businesses={state.businesses}
          onSellBusiness={handleSellBusiness}
          onSelectBusiness={handleSelectBusiness}
        />

        {/* Status */}
        <div className="card mb-4 text-xs">
          <div className="mb-2">
            {state.employed ? (
              <div>
                <div className="text-gray-400">Position</div>
                <div className="font-semibold">{state.career}</div>
                <div className="text-gray-500 mt-1">
                  Salary: <span className="number">{formatMoney(state.salary)}</span>/yr
                </div>
              </div>
            ) : (
              <div className="text-amber-400">Unemployed — find a job or go entrepreneur</div>
            )}
          </div>
        </div>

        {/* Actions */}
        <div className="card mb-4">
          <div className="text-xs text-gray-400 mb-3">
            Action Slots: <span className="number">{slotsRemaining}/{state.actionSlots}</span>
          </div>

          {!canAct ? (
            <div className="text-xs text-gray-500 mb-4">
              No action slots remaining. End the year to continue.
            </div>
          ) : null}

          <div className="grid grid-cols-2 gap-2">
            {availableActions.map((action) => (
              <button
                key={action.id}
                onClick={() => handleAction(action.id)}
                disabled={!canAct}
                className="btn btn-secondary text-xs py-2 disabled:opacity-50"
                title={action.desc}
              >
                {action.label}
              </button>
            ))}
          </div>
        </div>

        {/* End Year Button */}
        <div className="flex gap-2">
          <button
            onClick={handleAdvanceYear}
            className="btn btn-primary flex-1 py-3 font-bold"
          >
            End Year →
          </button>
          {!state.employed && (
            <button
              onClick={handleRetire}
              className="btn btn-secondary flex-1 py-3 font-bold"
              title="End the game and see your score"
            >
              Retire
            </button>
          )}
        </div>
      </div>

      {showBusinessBrowser && (
        <BusinessBrowser
          state={state}
          onBuyBusiness={handleBuyBusiness}
          onClose={() => setShowBusinessBrowser(false)}
        />
      )}

      {selectedBusiness && (
        <BusinessActionsModal
          business={selectedBusiness}
          onGrow={handleGrowBusiness}
          onHireManager={handleHireManager}
          onClose={() => setSelectedBusiness(null)}
        />
      )}
    </div>
  );
};
