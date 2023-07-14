import Balance from './Balance';
import UserPurchaseBox from './UserPurchaseBox';
import useWeb3 from '../hooks/useWeb3';
import { useEffect, useState } from 'react';

const UserParent = () => {
    const { web3, account, contract } = useWeb3();
    const [tokenBalance, setTokenBalance] = useState(0);
  
    useEffect(() => {
      const fetchTokenBalance = async () => {
        if (!account || !contract) return;
  
        try {
          const balance = await contract.methods.balanceOf(account).call();
          const tokenBal = balance / 10 ** 18;
          setTokenBalance(tokenBal);
        } catch (error) {
          console.error('Error fetching token balance:', error);
        }
      };
  
      fetchTokenBalance();
    }, [account, contract]);
  
    return (
      <>
        <UserPurchaseBox tokenBalance={tokenBalance} setTokenBalance={setTokenBalance} />
        <Balance web3={web3} account={account} contract={contract} />
      </>
    );
  };

export default UserParent;