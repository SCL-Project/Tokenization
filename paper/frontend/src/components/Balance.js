import * as React from 'react';
import { useEffect, useState } from 'react';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';

function createData(name, token, share, fractions) {
  return { name, token, share, fractions };
}

export default function BasicTable({ web3, account, contract }) {
    const [tokenBalance, setTokenBalance] = useState(0);
    const [shareBalance, setShareBalance] = useState(0);
    const [fractionsBalance, setFractionsBalance] = useState(0);


    useEffect(() => {
        let eventSubscription;
    
        const fetchTokenBalance = async () => {
          if (!account || !contract) return;
    
          try {
            const balance = await contract.methods.balanceOf(account).call();
            const tokenBal = balance / 10 ** 18;
            const shareBal = Math.floor(tokenBal);
            const fractionsBal = parseFloat((tokenBal - shareBal).toFixed(4));
                  
            setTokenBalance(tokenBal);
            setShareBalance(shareBal);
            setFractionsBalance(fractionsBal);
          } catch (error) {
            console.error('Error fetching token balance:', error);
          }
        };
    
        if (contract && account) {
            fetchTokenBalance();
    
            eventSubscription = contract.events.Transfer({
                filter: {to: account},
                fromBlock: 0
                }, (error, event) => {
                    if (error) console.error('Error on event', error);
                    else fetchTokenBalance();
            });
        }
    
        return () => {
          if (eventSubscription) {
            eventSubscription.unsubscribe((error, success) => {
              if (error) console.error('Failed to unsubscribe', error);
              else console.log('Unsubscribed successfully', success);
            });
          }
        }
    }, [account, contract]);
    

    const truncateAddress = (address) => {
        if (!address) return '';
        return address.slice(0, 6) + '...' + address.slice(-4);
    };

    const rows = [
        createData(truncateAddress(account), tokenBalance, shareBalance, fractionsBalance),
    ];

    return (
    <TableContainer component={Paper} sx={{ mb: 1 }}>
        <Table sx={{ minWidth: 450 }} aria-label="simple table">
        <TableHead>
            <TableRow>
                <TableCell>Address</TableCell>
                <TableCell align="right">Token Balance</TableCell>
                <TableCell align="right">Share Balance</TableCell>
                <TableCell align="right">Fractional Part Of Token Balance</TableCell>
            </TableRow>
        </TableHead>
        <TableBody>
            {rows.map((row) => (
            <TableRow
                key={row.name}
                sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
            >
                <TableCell component="th" scope="row">
                {row.name}
                </TableCell>
                <TableCell align="right">{row.token}</TableCell>
                <TableCell align="right">{row.share}</TableCell>
                <TableCell align="right">{row.fractions}</TableCell>
            </TableRow>
            ))}
        </TableBody>
        </Table>
    </TableContainer>
    );
}

