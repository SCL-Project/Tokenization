# Starting the backend
Open two terminals. 

For one navigate into the p2p-backend directory  ->  
install npm (npm install) and all the dependencies (npm i ... )  ->  
use ``node index.js`` to start the backend. It will run on port 4000


For the other navigate into the p2p-frontend-poc directory  ->  
install npm (npm install) and all the dependencies (npm i ... )  ->  
use ``npm start`` to run the frontend. It will run on port 3000 or 3001


# Change to Database login System
Copy the code in the index.js file with the code from the databaseIndex.js file.
To connect the backend to the database you must have downloaded XAMPP and Apache and MySQL must be running and there must be a table called users in your p2p_lending Database.

To run the application just start the backend as usual.

# Implement the frontend into the backend
Go to p2p-frontend-poc/src/auth and open the register.js file. 

### Frontend: 
In the register file you can add more fields in the return area, just copy a already existing "FormGroup" and change the name of the field. 
Important is to add the data that is created by the new field to the Register function. 
Therefore add the name of the field to the other variables on line 13. 

### Backend:
open the databaseIndex.js file. 
on line 82, in the register route, add the new created value to the const. 
on line 102 and 105 the Database Query has to be adjusted. (dont forget to make sure, that there is a column for the new entry in the Database)


The personal login page can be found under the following path: p2p-frontend-poc/src/portal/home/home.js
customise as desired
