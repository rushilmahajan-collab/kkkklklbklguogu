import React, { useState } from 'react';
import { createInitialState, advanceYear, calculateNetWorth } from './gameState';
import { CharacterCreationScreen } from './components/CharacterCreationScreen';
import { MainGameScreen } from './components/MainGameScreen';
import './index.css';

export default function App() {
  const [screen, setScreen] = useState('character');
  const [gameState, setGameState] = useState(null);

  const handleStartGame = (playerName, career) => {
    const initialState = createInitialState(playerName, career);
    setGameState(initialState);
    setScreen('game');
  };

  const handleAdvanceYear = () => {
    setGameState(prevState => {
      const lastNetWorth = prevState.netWorth;
      const newState = advanceYear(prevState);
      return {
        ...newState,
        lastNetWorth,
      };
    });
  };

  const handleStateChange = (newState) => {
    setGameState(newState);
  };

  return (
    <>
      {screen === 'character' && (
        <CharacterCreationScreen onStartGame={handleStartGame} />
      )}
      {screen === 'game' && gameState && (
        <MainGameScreen
          state={gameState}
          onAdvanceYear={handleAdvanceYear}
          onStateChange={handleStateChange}
        />
      )}
    </>
  );
}
