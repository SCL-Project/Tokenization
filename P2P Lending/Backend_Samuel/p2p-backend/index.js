const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql');
const cors = require('cors'); // Import cors middleware
const { authGuardMiddleware } = require('./middleware');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { JWT_SECRET } = require('./config');
const { loadData, saveData } = require('./loaders');


const app = express();
const PORT = process.env.PORT || 4000;

const db = mysql.createConnection({
    host: "localhost",
    user: 'root',
    password:'',
    database: 'p2p_lending'
})



// Middleware
app.use(cors({ origin: 'http://localhost:3000'})); // Allow requests from localhost:3001
app.use(bodyParser.urlencoded({
    extended: true
}));
app.use(bodyParser.json());

// Load token data
let tokenData = loadData('tokens');

// Login route
app.post('/login', (req, res) => {
    const { email, password } = req.body;
    // const user = userData.find(user => user.email === email);

    const sql = "SELECT * FROM users WHERE email = ?";
    db.query(sql, [email], (error, results) => {
        if(error) {
            return results.json(error);
        }

        if(results.length === 0) {
            return res.status(404).send('User not found');
        }

        const user = results[0];

        bcrypt.compare(password, user.password, (err, result) => {
            if (err || !result) {
                return res.status(401).send('Invalid email or password');
            }
    
            // Generate JWT token
            const token = jwt.sign({ email: user.email }, JWT_SECRET, { expiresIn: '1h' });
            // Save token to tokenData
            tokenData.push(token);
            saveData('tokens', tokenData);
    
            res.json({ token });
        });
    });
});

// Logout route
app.post('/logout', authGuardMiddleware, (req, res) => {
    // Invalidate the token
    const tokenHeader = req.headers['authorization'];
    const token = tokenHeader.replace('Bearer ', '');
    tokenData = tokenData.filter(t => t !== token);
    console.log(tokenData)
    saveData('tokens', tokenData);

    res.send('Logout successful');
});

// Register route with input validation
app.post('/register', (req, res) => {
    // Load the variables
    const { email, password, firstname, lastname } = req.body;

    // Check if user already exists
    db.query('SELECT email FROM users WHERE email = ?', [email], (error, results) => {
        if (error) {
            return res.status(500).send('Database error');
        }

        if (results.length > 0) {
            return res.status(400).send('User already exists');
        }


        // Hash the password
        bcrypt.hash(password, 10, (err, hash) => {
            if (err) {
                return res.status(500).send('Error hashing password');
            }

            // Prepare SQL to insert the new user
            const sql = 'INSERT INTO users (email, password, firstname, lastname) VALUES (?, ?, ?, ?)';
                
            // Execute the SQL to insert the user data into the database
            db.query(sql, [email, hash, firstname, lastname], (error) => {
                if (error) {
                    return res.status(500).send('Error saving user');
                }

                res.send('User registered successfully');
            });
        });
    });
});

// Hello World endpoint with authentication guard and token refresh
app.get('/hello', authGuardMiddleware, (req, res) => {
    res.send('Hello, World!');
});

// User endpoint
app.get('/user', authGuardMiddleware, (req, res) => {
    // Get user details from token
    const tokenHeader = req.headers['authorization'];
    const token = tokenHeader.replace('Bearer ', '');
    const decodedToken = jwt.verify(token, JWT_SECRET);
    const userEmail = decodedToken.email;

    const sql = "SELECT * FROM users WHERE email = ?";
    db.query(sql, [userEmail], (error, results) => {
        if(error) {
            return results.json(error);
        }

        if(results.length === 0) {
            return res.status(404).send('User not found');
        }

        const user = results[0];
        

        res.json({
            email: user.email,
            firstname: user.firstname,
            lastname: user.lastname
        });
    });
});


app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
