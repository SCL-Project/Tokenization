const path = require('path');
const fs = require('fs');

// Function to load data from JSON file
const loadData = (fileName) => {
    const filePath = path.join(__dirname, 'database', fileName + '.json');
    try {
        const data = fs.readFileSync(filePath, 'utf8');
        // If data is an array, return it, otherwise return an empty array
        return Array.isArray(JSON.parse(data)) ? JSON.parse(data) : [];
    } catch (error) {
        console.error('Error loading data from file:', error);
        return [];
    }
};

// Function to save data to JSON file
const saveData = (fileName, data) => {
    const filePath = path.join(__dirname, 'database', fileName + '.json');
    try {
        fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
    } catch (error) {
        console.error('Error saving data to file:', error);
    }
};

module.exports = {
    loadData,
    saveData,
};