import * as React from 'react';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import IconButton from '@mui/material/IconButton';
import Typography from '@mui/material/Typography';
import Menu from '@mui/material/Menu';
import MenuIcon from '@mui/icons-material/Menu';
import Container from '@mui/material/Container';
import Button from '@mui/material/Button';
import MenuItem from '@mui/material/MenuItem';
import styles from '../styles/header.module.css';
import Link from 'next/link';
import useWeb3 from '../hooks/useWeb3';
import { createTheme, ThemeProvider } from '@mui/material/styles';

const theme = createTheme({
    palette: {
      primary: {
        main: '#05503C',
      },
    },
});

const pages = ['Investors', 'Companies', 'Register'];
const pagesNonAdmin = ['Investors', 'Register'];

function ResponsiveAppBar() {
    const { web3, account, contract, owners } = useWeb3();


    // Function to truncate the address for better readability
    const truncateAddress = (account) => {
        if (!account) return '';
        return account.slice(0, 6) + '...' + account.slice(-4);
    };

    const [anchorElNav, setAnchorElNav] = React.useState(null);
    const [anchorElUser, setAnchorElUser] = React.useState(null);

    const handleOpenNavMenu = (event) => {
        setAnchorElNav(event.currentTarget);
    };
    const handleOpenUserMenu = (event) => {
        setAnchorElUser(event.currentTarget);
    };

    const handleCloseNavMenu = () => {
        setAnchorElNav(null);
    };

    const handleCloseUserMenu = () => {
        setAnchorElUser(null);
    };

    // check if user is contract owner, is boolean
    const isOwner = owners && owners.includes(account);
    
    if (!isOwner) {
        return (
            <ThemeProvider theme={theme}>
            <AppBar position="static" color='primary'>
                <Container maxWidth="xl">
                    <Toolbar disableGutters>
                        <img
                            src="/SCLLogo.svg" 
                            alt="logo"
                            className={styles.logo}
                        />
                        <Box sx={{ flexGrow: 1, display: { xs: 'flex', md: 'none' } }}>
                            <IconButton
                            size="large"
                            aria-label="account of current user"
                            aria-controls="menu-appbar"
                            aria-haspopup="true"
                            onClick={handleOpenNavMenu}
                            color="inherit"
                            >
                            <MenuIcon sx={{ color: "white"}} />
                            </IconButton>
                            <Menu
                            id="menu-appbar"
                            anchorEl={anchorElNav}
                            anchorOrigin={{
                                vertical: 'bottom',
                                horizontal: 'left',
                            }}
                            keepMounted
                            transformOrigin={{
                                vertical: 'top',
                                horizontal: 'left',
                            }}
                            open={Boolean(anchorElNav)}
                            onClose={handleCloseNavMenu}
                            sx={{
                                display: { xs: 'block', md: 'none' }
                            }}
                            >
                            {pages.map((page) => (
                                <Link key={page} href={`/${page.toLowerCase()}`} passHref>
                                    <MenuItem key={page} onClick={handleCloseNavMenu}>
                                    <Typography textAlign="center" sx={{color: 'black', textDecoration: 'none' }}>   
                                        {page}
                                    </Typography>
                                    </MenuItem>
                                </Link>
                            ))}
                            </Menu>
                        </Box>
                        <Box sx={{ flexGrow: 1, display: { xs: 'none', md: 'flex' } }}>
                            {pagesNonAdmin.map((page) => (
                                <Link key={page} href={`/${page.toLowerCase()}`} passHref>
                                <Button
                                    onClick={handleCloseNavMenu}
                                    sx={{ my: 2, color: 'white', display: 'block' }}
                                >
                                    {page}
                                </Button>
                                </Link>
                            ))}
                        </Box>
                        <Box sx={{ flexGrow: 0 }}>                        
                            <IconButton sx={{ p: 0 }}>
                                <Typography sx={{ color: 'white' }}>{truncateAddress(account)}</Typography>                
                            </IconButton>
                        </Box>
                    </Toolbar>
                </Container>
            </AppBar>   
            </ThemeProvider>        
        )
    } else {
        return (
            <ThemeProvider theme={theme}>
            <AppBar position="static" color="primary">
                <Container maxWidth="xl">
                    <Toolbar disableGutters>
                        <img
                            src="/SCLLogo.svg" 
                            alt="logo"
                            className={styles.logo}
                        />
                        <Box sx={{ flexGrow: 1, display: { xs: 'flex', md: 'none' } }}>
                            <IconButton
                            size="large"
                            aria-label="account of current user"
                            aria-controls="menu-appbar"
                            aria-haspopup="true"
                            onClick={handleOpenNavMenu}
                            color="inherit"
                            >
                            <MenuIcon sx={{ color: "white"}} />
                            </IconButton>
                            <Menu
                            id="menu-appbar"
                            anchorEl={anchorElNav}
                            anchorOrigin={{
                                vertical: 'bottom',
                                horizontal: 'left',
                            }}
                            keepMounted
                            transformOrigin={{
                                vertical: 'top',
                                horizontal: 'left',
                            }}
                            open={Boolean(anchorElNav)}
                            onClose={handleCloseNavMenu}
                            sx={{
                                display: { xs: 'block', md: 'none' }
                            }}
                            >
                            {pages.map((page) => (
                                <Link key={page} href={`/${page.toLowerCase()}`} passHref>
                                    <MenuItem key={page} onClick={handleCloseNavMenu}>
                                    <Typography textAlign="center" sx={{color: 'black', textDecoration: 'none' }}>   
                                        {page}
                                    </Typography>
                                    </MenuItem>
                                </Link>
                            ))}
                            </Menu>
                        </Box>
                        <Box sx={{ flexGrow: 1, display: { xs: 'none', md: 'flex' } }}>
                            {pages.map((page) => (
                                <Link key={page} href={`/${page.toLowerCase()}`} passHref>
                                <Button
                                    onClick={handleCloseNavMenu}
                                    sx={{ my: 2, color: 'white', display: 'block' }}
                                >
                                    {page}
                                </Button>
                                </Link>
                            ))}
                        </Box>
                        <Box sx={{ flexGrow: 0 }}>                        
                            <IconButton sx={{ p: 0 }}>
                                <Typography sx={{ color: 'white' }}>{truncateAddress(account)}</Typography>                
                            </IconButton>
                        </Box>
                    </Toolbar>
                </Container>
            </AppBar>
            </ThemeProvider>
        );
    }    
}
export default ResponsiveAppBar;