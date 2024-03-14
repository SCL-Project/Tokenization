document.addEventListener('DOMContentLoaded', function () {
    // Check if Web3 has been injected by the browser (e.g., MetaMask)
    if (typeof window.ethereum !== 'undefined') {
        console.log('MetaMask is installed!');
        const web3 = new Web3(window.ethereum);

        // Your contract's ABI and address
        const contractABI = [/* ABI array here */];
        const contractAddress = '0x...'; // Replace with your contract's address

        // Creating a contract object
        const myContract = new web3.eth.Contract(contractABI, contractAddress);

        // Example read function
        document.getElementById('readData').addEventListener('click', function() {
            myContract.methods.yourReadMethodName().call()
            .then(function(result){
                console.log('Read method result:', result);
                // Handle the result here (e.g., update UI)
            })
            .catch(console.error);
        });

        // Example write function
        document.getElementById('writeData').addEventListener('click', function() {
            // Request account access if needed
            ethereum.request({method: 'eth_requestAccounts'}).then(function(accounts) {
                const account = accounts[0]; // Using the first account

                // Using the first account to send a transaction
                myContract.methods.yourWriteMethodName(/* parameters */).send({from: account})
                .on('receipt', function(receipt){
                    console.log('Transaction receipt:', receipt);
                    // Handle the transaction receipt here (e.g., update UI)
                })
                .on('error', console.error); // If there's an error
            });
        });

    } else {
        console.log('MetaMask is not installed. Please consider installing it.');
    }
});
