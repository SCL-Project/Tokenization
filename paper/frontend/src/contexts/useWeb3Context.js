import React, { createContext, useContext, useMemo } from 'react';
import useWeb3 from './hooks/useWeb3';

// Create a context
const Web3Context = createContext();

// Create a provider component
export const Web3Provider = ({ children }) => {
  const web3Data = useWeb3();
  
  // Use useMemo to prevent unnecessary re-computations
  const memoizedWeb3Data = useMemo(() => web3Data, [web3Data]);

  return (
    <Web3Context.Provider value={memoizedWeb3Data}>
      {children}
    </Web3Context.Provider>
  );
};

// Create a custom hook for accessing the web3 context
export const useWeb3Context = () => useContext(Web3Context);
