const jwt = require('jsonwebtoken');
const { JWT_SECRET } = require('./config');
const { loadData, saveData } = require('./loaders');

// Middleware to guard endpoints with token authentication
const authGuardMiddleware = (req, res, next) => {
    const tokenHeader = req.headers['authorization'];
    if (!tokenHeader) {
        return res.status(403).send('Token not provided');
    }

    // Remove "Bearer " from the token header
    const token = tokenHeader.replace('Bearer ', '');

    // Load token data from the database
    let tokenData = loadData('tokens');

    // Remove expired tokens
    tokenData = tokenData.filter(token => {
        try {
            jwt.verify(token, JWT_SECRET);
            return true;
        } catch (error) {
            return false;
        }
    });

    // Save cleaned token data back to the database
    saveData('tokens', tokenData);

    // Check if the current token exists in the cleaned tokenData
    if (!tokenData.includes(token)) {
        return res.status(401).send('Token has been revoked or expired');
    }

    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) {
            console.log(err)
            return res.status(401).send('Invalid token');
        }
        req.user = decoded;
        next();
    });
};

module.exports = {
    authGuardMiddleware,
};