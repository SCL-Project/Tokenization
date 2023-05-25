import '@/styles/globals.css'
import { EthereumAddressProvider } from '@/contexts/EthereumAddressContext';

export default function App({ Component, pageProps }) {
  return (
    <EthereumAddressProvider>
      <Component {...pageProps} />
    </EthereumAddressProvider>
  );
}
