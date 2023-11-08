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

export default function BasicTable({ web3, account, contract, tokenBalance, shareBalance, fractionsBalance }) { 
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
                <TableCell align="right">Balance</TableCell>
                <TableCell align="right">Shares</TableCell>
                <TableCell align="right">Fractions</TableCell>
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

