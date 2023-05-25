// EthereumAddressContext.js
import { createContext, useContext, useState } from 'react';

const EthereumAddressContext = createContext(null);

export function useEthereumAddress() {
  return useContext(EthereumAddressContext);
}

export function EthereumAddressProvider({ children }) {
  const [ethereumAddress, setEthereumAddress] = useState(null);

  return (
    <EthereumAddressContext.Provider value={{ ethereumAddress, setEthereumAddress }}>
      {children}
    </EthereumAddressContext.Provider>
  );
}
