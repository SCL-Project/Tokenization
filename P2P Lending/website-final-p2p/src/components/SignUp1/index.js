/*import React from 'react';
import { TextField} from '@mui/material';
import { Container, TextWrap, Icon} from './SignUp1Elements';
import Tabs from '@mui/joy/Tabs';
import TabList from '@mui/joy/TabList';
import Tab, { tabClasses } from '@mui/joy/Tab';

const SignUp1= () => {
  return (
    <>
        <Container fixed>
        <Icon to="/">P2P-Lending</Icon> 
        <Tabs aria-label="tabs" defaultValue={0} sx={{ bgcolor: 'transparent' }}>
        <TabList
        disableUnderline
        sx={{
          p: 0.5,
          gap: 0.5,
          borderRadius: 'xl',
          bgcolor: 'background.level1',
          [`& .${tabClasses.root}[aria-selected="true"]`]: {
            boxShadow: 'sm',
            bgcolor: 'background.surface',
          },
        }}
      >
        <Tab disableIndicator>Lender</Tab>
        <Tab disableIndicator>Student</Tab>
      </TabList>
            <TextWrap>
                <TextField id="outlined-basic" label="Name" variant="outlined" />
                <TextField id="outlined-basic" label="Surname" variant="outlined" />
                <TextField id="outlined-basic" label="Adress" variant="outlined" />
                <TextField id="outlined-basic" label="City" variant="outlined" />
                <TextField id="outlined-basic" label="PLZ" variant="outlined" />
            </TextWrap>
        </Tabs>
        </Container>
    </>
  )
}

export default SignUp1*/

import React, { useState } from 'react';
import Tabs from '@mui/joy/Tabs';
import TabList from '@mui/joy/TabList';
import Tab from '@mui/joy/Tab';
import { TextField} from '@mui/material';
import { Container, TextWrap, Icon} from './SignUp1Elements';
// ... andere Importe

const SignUp1 = () => {
  // Erstellen eines State-Hooks, um den aktiven Tab zu verfolgen
  const [activeTab, setActiveTab] = useState('lender');

  // Eine Funktion, um den aktiven Tab zu ändern, basierend auf dem, was ausgewählt wurde
  const handleChange = (event, newValue) => {
    setActiveTab(newValue);
  };

  return (
    <Container fixed>
    <Icon to="/">P2P-Lending</Icon> 
      <Tabs value={activeTab} onChange={handleChange} aria-label="Lender or Student">
        <TabList className={{ width: 'var(--tab-width)', margin: '0 auto' }}>
          <Tab value="lender" label="Lender" />
          <Tab value="student" label="Student" />
        </TabList>
      </Tabs>
      {activeTab === 'student' && ( // Diese Zeile prüft, ob der aktive Tab "student" ist
        <TextWrap>
          {/* Die folgenden Felder werden nur angezeigt, wenn der Tab "student" aktiv ist */}
          <TextField id="outlined-basic" label="Name" variant="outlined" />
          <TextField id="outlined-basic" label="Surname" variant="outlined" />
          <TextField id="outlined-basic" label="Adress" variant="outlined" />
          <TextField id="outlined-basic" label="City" variant="outlined" />
          <TextField id="outlined-basic" label="PLZ" variant="outlined" />
        </TextWrap>
      )}
      {/* Hier könnten Sie weitere Inhalte hinzufügen, die angezeigt werden sollen, wenn andere Tabs ausgewählt sind */}
    </Container>
  );
};

export default SignUp1;

