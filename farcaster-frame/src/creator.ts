import { ethers } from 'ethers';
import { contractABI, contractAddress } from './contractConfig';

// Initialize the contract
const provider = new ethers.BrowserProvider(window.ethereum);
let signer: ethers.Signer;
let contract: ethers.Contract;

async function initializeContract() {
    signer = await provider.getSigner();
    contract = new ethers.Contract(contractAddress, contractABI, signer);
}

async function fetchCreatorQuestions(): Promise<void> {
    if (!signer || !contract) {
        await initializeContract();
    }
    // Fetch questions for the logged-in creator
    const questions = await contract.getQuestionsForCreator(await signer.getAddress());
    
    displayQuestions(questions);
}

function displayQuestions(questions: any[]): void {
    const questionList = document.getElementById('questionList');
    if (questionList) {
        questionList.innerHTML = questions.map(q => `
            <div class="mb-4 p-4 border rounded">
                <p>Amount: ${q.amount} Moxie tokens</p>
                <p>Question: ${decryptQuestion(q.encryptedQuestion)}</p>
                <button onclick="answerQuestion('${q.questionId}')" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
                    Answer
                </button>
            </div>
        `).join('');
    }
}

async function answerQuestion(questionId: string): Promise<void> {
    if (!contract) {
        await initializeContract();
    }
    await contract.answerQuestion(questionId);
    console.log('Question answered:', questionId);
    fetchCreatorQuestions(); // Refresh the question list
}

function decryptQuestion(encryptedQuestion: string): string {
    // Implement decryption logic here
    // This should use the creator's private key to decrypt the question
    return 'decrypted_question_placeholder';
}
