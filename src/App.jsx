import React, { useState } from 'react';
import { createInitialState, advanceYear, calculateNetWorth } from './gameState';
import { CharacterCreationScreen } from './components/CharacterCreationScreen';
import { MainGameScreen } from './components/MainGameScreen';
import { GameOverScreen } from './components/GameOverScreen';
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

  const handlePlayAgain = () => {
    setGameState(null);
    setScreen('character');
  };

  // Check for game over conditions
  const isGameOver = gameState && (gameState.bankrupt || gameState.age > 99);

  return (
    <>
      {screen === 'character' && (
        <CharacterCreationScreen onStartGame={handleStartGame} />
      )}
      {screen === 'game' && gameState && !isGameOver && (
        <MainGameScreen
          state={gameState}
          onAdvanceYear={handleAdvanceYear}
          onStateChange={handleStateChange}
        />
      )}
      {screen === 'game' && gameState && isGameOver && (
        <GameOverScreen state={gameState} onPlayAgain={handlePlayAgain} />
      )}
    </>
  );
}
