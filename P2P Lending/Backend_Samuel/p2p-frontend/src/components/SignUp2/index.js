import Stack from '@mui/material/Stack';
import React, { useState } from 'react';
import { TextField } from '@mui/material';
import Tabs from '@mui/joy/Tabs';
import TabList from '@mui/joy/TabList';
import Tab from '@mui/joy/Tab';
import {Container1, FormWrap, Icon,} from './SignUp2Elements'



const SignUp2 = () => {

// State to keep track of the active tab
  const [activeTab, setActiveTab] = useState('lender');

// Function to change the active tab
    const handleChange = (event, newValue) => {
    setActiveTab(newValue);
  };

  const lenderContent = (
    <div>
      <Stack spacing={2} >
        <TextField id="outlined-basic" label="Name" variant="outlined"/>
        <TextField id="outlined-basic" label="Surname" variant="outlined" />
        <TextField id="outlined-basic" label="Adress" variant="outlined" />
        <TextField id="outlined-basic" label="City" variant="outlined" />
        <TextField id="outlined-basic" label="PLZ" variant="outlined" />
        <TextField id="outlined-basic" label="Email" variant="outlined" />
       </Stack>
    </div>
  )
  const studentContent = (
    <div>
      <Stack spacing={2} >
        <TextField id="outlined-basic" label="Name" variant="outlined" />
        <TextField id="outlined-basic" label="Surname" variant="outlined" />
        <TextField id="outlined-basic" label="Adress" variant="outlined" />
        <TextField id="outlined-basic" label="City" variant="outlined" />
        <TextField id="outlined-basic" label="PLZ" variant="outlined" />
        <TextField id="outlined-basic" label="Email" variant="outlined"/>
       </Stack>
    </div>
  );



  return (
    <Container1>
        <FormWrap>
            <Icon to="/">P2P-Lending</Icon> 
                 <Stack spacing={2} 
                     direction="column" 
                     justifyContent="center" 
                     alignItems="center" 
                     sx={{ width: '100%', height: '100vh' }}>
                         <Tabs value={activeTab} onChange={handleChange} aria-label="Lender or Student">
                            <TabList  tabFlex={1}>
                              <Tab value="lender">Lender</Tab>
                              <Tab value="student">Student</Tab>
                            </TabList>
                         </Tabs>
                         {activeTab === 'lender' ? lenderContent : studentContent}
                 </Stack>
        </FormWrap> 
</Container1>
  )
}

export default SignUp2

