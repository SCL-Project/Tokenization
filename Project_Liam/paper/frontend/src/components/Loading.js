import * as React from 'react';
import CircularProgress from '@mui/material/CircularProgress';
import Box from '@mui/material/Box';

function Loading() {
    return (
        <Box sx={{
            display: 'flex',
            justifyContent: 'center', // Center horizontally
            alignItems: 'center', // Center vertically
            height: '100vh', // Set the height of the box to full viewport height
          }}>
            <CircularProgress />
        </Box>
    );
}

export default Loading;
