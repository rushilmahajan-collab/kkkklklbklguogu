import React, { useState } from 'react';

const CAREERS = {
  'Software Engineer': { salary: '$85,000', stress: 'Medium', growth: 'High' },
  'Management Consultant': { salary: '$95,000', stress: 'High', growth: 'High' },
  'Marketing Coordinator': { salary: '$52,000', stress: 'Low', growth: 'Medium' },
  'Financial Analyst': { salary: '$75,000', stress: 'Medium', growth: 'High' },
  'Sales Rep': { salary: '$55,000', stress: 'Medium', growth: 'Medium' },
  'Operations Associate': { salary: '$58,000', stress: 'Low', growth: 'Low' },
};

export const CharacterCreationScreen = ({ onStartGame }) => {
  const [playerName, setPlayerName] = useState('');
  const [selectedCareer, setSelectedCareer] = useState(null);

  const handleStart = () => {
    if (playerName.trim() && selectedCareer) {
      onStartGame(playerName, selectedCareer);
    }
  };

  return (
    <div className="min-h-screen bg-dark-bg flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold mb-2">CorpLife</h1>
          <p className="text-gray-400">Corporate to Empire</p>
          <p className="text-sm text-gray-500 mt-2">
            You are 22 years old. Fresh out of college. The world is yours.
          </p>
        </div>

        <div className="card mb-6">
          <label className="block text-sm text-gray-400 mb-2">Your Name</label>
          <input
            type="text"
            value={playerName}
            onChange={(e) => setPlayerName(e.target.value)}
            placeholder="Enter your name"
            className="w-full bg-dark-border border border-dark-border rounded-lg px-3 py-2 text-white placeholder-gray-500 focus:outline-none focus:border-green-600"
          />
        </div>

        <div className="mb-6">
          <h2 className="text-sm font-bold text-gray-300 mb-3">Choose Your Starting Career</h2>
          <div className="space-y-2">
            {Object.entries(CAREERS).map(([career, stats]) => (
              <button
                key={career}
                onClick={() => setSelectedCareer(career)}
                className={`w-full p-3 rounded-lg text-left transition-all ${
                  selectedCareer === career
                    ? 'bg-green-600 border border-green-500'
                    : 'card hover:border-green-500/50'
                }`}
              >
                <div className="font-semibold text-sm">{career}</div>
                <div className="text-xs text-gray-400 mt-1">
                  {stats.salary} • Stress: {stats.stress} • Growth: {stats.growth}
                </div>
              </button>
            ))}
          </div>
        </div>

        <button
          onClick={handleStart}
          disabled={!playerName.trim() || !selectedCareer}
          className="btn btn-primary w-full py-3 font-bold disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Start Your Life →
        </button>
      </div>
    </div>
  );
};
