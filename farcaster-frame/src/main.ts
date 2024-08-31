import './style.css'
import { ethers } from 'ethers';
import { contractABI, contractAddress } from './contractConfig';

declare global {
    interface Window {
        ethereum: any;
    }
}
// Initialize the contract
const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();
const contract = new ethers.Contract(contractAddress, contractABI, signer);

async function generateCommitment(recipient: string, amount: number): Promise<string> {
    // Implementation depends on the specific zk-SNARK library you're using
    console.log('Generating proof for recipient:', recipient, 'with amount:', amount);
    return 'commitment'
}

async function generateProof(commitment: string): Promise<string> {
    // Implementation depends on the specific zk-SNARK library you're using
    console.log('Generating proof for commitment:', commitment);
    return 'proof'
}

async function sendAnonymously(recipient: string, amount: number): Promise<void> {
    const commitment = await generateCommitment(recipient, amount)
    const proof = await generateProof(commitment)
    
    // Call your contract's scheduleTransfer function with the commitment
    // Store the proof securely for later withdrawal
    console.log('Sending anonymously:', { recipient, amount, commitment, proof })
}

async function askAnonymousQuestion(creator: string, amount: number, question: string): Promise<void> {
    const encryptedQuestion = await encryptQuestion(question, creator);
    const commitment = await generateCommitment(creator, amount);
    
    // Call your contract's askQuestion function
    await contract.askQuestion(creator, amount, encryptedQuestion, commitment);
    
    console.log('Anonymous question asked:', { creator, amount, commitment });
}

async function encryptQuestion(question: string, creatorPublicKey: string): Promise<string> {
    // Simple placeholder encryption (replace with actual encryption logic)
    const encryptedQuestion = btoa(question);
    console.log(`Encrypting question for creator: ${creatorPublicKey}`);
    return encryptedQuestion;
}

 // Add UI elements for asking questions
document.addEventListener('DOMContentLoaded', () => {
    const app = document.getElementById('app')
    if (app) {
        app.innerHTML += `
        <div class="mt-8">
            <h2 class="text-xl font-bold mb-4">Ask Anonymous Question</h2>
            <input id="creatorAddress" placeholder="Creator's Address" class="mb-2 p-2 border rounded">
            <input id="questionAmount" type="number" placeholder="Amount (in Moxie tokens)" class="mb-2 p-2 border rounded">
            <textarea id="questionText" placeholder="Your question" class="mb-2 p-2 border rounded"></textarea>
            <button id="askQuestionButton" class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded">
                Ask Question
            </button>
        </div>
    `;

        const sendButton = document.getElementById('sendButton')
        if (sendButton) {
            sendButton.addEventListener('click', () => {
                sendAnonymously('0x1234...', 100)
                    .then(() => console.log('Transaction initiated'))
                    .catch(console.error)
            })
        }
    }
    
   
   

    const askQuestionButton = document.getElementById('askQuestionButton');
    if (askQuestionButton) {
        askQuestionButton.addEventListener('click', () => {
            const creatorAddress = (document.getElementById('creatorAddress') as HTMLInputElement).value;
            const amount = parseInt((document.getElementById('questionAmount') as HTMLInputElement).value);
            const question = (document.getElementById('questionText') as HTMLTextAreaElement).value;
            
            askAnonymousQuestion(creatorAddress, amount, question)
                .then(() => console.log('Question asked successfully'))
                .catch(console.error);
        });
    }
})