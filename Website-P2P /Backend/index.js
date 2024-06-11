const express = require('express')
const bodyParser = require('body-parser')
const cors = require('cors') // Import cors middleware
const { authGuardMiddleware } = require('./middleware')
const bcrypt = require('bcrypt')
const jwt = require('jsonwebtoken')
const { JWT_SECRET } = require('./config')
const { loadData, saveData } = require('./loaders')

const app = express()
const PORT = process.env.PORT || 4000

// Middleware
app.use(cors({ origin: 'http://localhost:3000' })) // Allow requests from localhost:3001
app.use(
	bodyParser.urlencoded({
		extended: true,
	})
)
app.use(bodyParser.json())

// Load user data
let userData = loadData('users')

// Load token data
let tokenData = loadData('tokens')

// Login route
app.post('/login', (req, res) => {
	const { email, password } = req.body
	const user = userData.find(user => user.email === email)

	if (!user) {
		return res.status(404).send('User not found')
	}

	bcrypt.compare(password, user.password, (err, result) => {
		if (err || !result) {
			return res.status(401).send('Invalid email or password')
		}

		// Generate JWT token
		const token = jwt.sign({ email: user.email }, JWT_SECRET, { expiresIn: '1h' })
		// Save token to tokenData
		tokenData.push(token)
		saveData('tokens', tokenData)

		res.json({ token })
	})
})

// Logout route
app.post('/logout', authGuardMiddleware, (req, res) => {
	// Invalidate the token
	const tokenHeader = req.headers['authorization']
	const token = tokenHeader.replace('Bearer ', '')
	tokenData = tokenData.filter(t => t !== token)
	console.log(tokenData)
	saveData('tokens', tokenData)

	res.send('Logout successful')
})

// Register route with input validation
app.post('/register', (req, res) => {
	// Load the variables
	const { email, password, firstname, lastname, address, city, plz, ahv_number } = req.body

	// Check if user already exists
	if (userData.find(user => user.email === email)) {
		return res.status(400).send('User already exists')
	}

	// Hash the password
	bcrypt.hash(password, 10, (err, hash) => {
		if (err) {
			return res.status(500).send('Error hashing password')
		}

		// Save user data with firstname and lastname
		// userData.push({ email, password: hash, firstname, lastname }); // Storing hash instead of plaintext password
		userData.push({ email, password: hash, firstname, lastname, address, city, plz, ahv_number }) // Storing hash instead of plaintext password

		saveData('users', userData)

		res.send('User registered successfully')
	})
})

// Hello World endpoint with authentication guard and token refresh
app.get('/hello', authGuardMiddleware, (req, res) => {
	res.send('Hello, World!')
})

// User endpoint
app.get('/user', authGuardMiddleware, (req, res) => {
	// Get user details from token
	const tokenHeader = req.headers['authorization']
	const token = tokenHeader.replace('Bearer ', '')
	const decodedToken = jwt.verify(token, JWT_SECRET)
	const userEmail = decodedToken.email

	// Find user by email
	const user = userData.find(user => user.email === userEmail)

	if (!user) {
		return res.status(404).send('User not found')
	}

	// Return user details
	res.json({
		email: user.email,
		firstname: user.firstname,
		lastname: user.lastname,
	})
})

app.listen(PORT, () => {
	console.log(`Server is running on port ${PORT}`)
})
