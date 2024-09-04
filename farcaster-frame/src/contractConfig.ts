export const contractAddress = "YOUR_CONTRACT_ADDRESS_HERE";
export const contractABI = [
  {
    "inputs": [
      {"internalType": "bytes32", "name": "_commitment", "type": "bytes32"},
      {"internalType": "uint256", "name": "_amount", "type": "uint256"},
      {"internalType": "uint256", "name": "_delay", "type": "uint256"}
    ],
    "name": "scheduleTransfer",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "uint[2]", "name": "a", "type": "uint[2]"},
      {"internalType": "uint[2][2]", "name": "b", "type": "uint[2][2]"},
      {"internalType": "uint[2]", "name": "c", "type": "uint[2]"},
      {"internalType": "uint[2]", "name": "input", "type": "uint[2]"},
      {"internalType": "bytes32", "name": "_commitment", "type": "bytes32"}
    ],
    "name": "withdraw",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "_creator", "type": "address"},
      {"internalType": "uint256", "name": "_amount", "type": "uint256"},
      {"internalType": "string", "name": "_encryptedQuestion", "type": "string"},
      {"internalType": "bytes32", "name": "_commitment", "type": "bytes32"}
    ],
    "name": "askQuestion",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{"internalType": "bytes32", "name": "_questionId", "type": "bytes32"}],
    "name": "answerQuestion",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];
