const { GoogleGenerativeAI } = require("@google/generative-ai");
const OpenAI = require("openai");
require("dotenv").config();

// Configuration
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "";
const GROQ_API_KEY = process.env.GROQ_API_KEY || "";

// Initialize Gemini
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
const geminiModel = genAI.getGenerativeModel({
    model: "gemini-1.5-flash",
});

// Initialize Groq (OpenAI Compatible)
const groq = GROQ_API_KEY ? new OpenAI({
    apiKey: GROQ_API_KEY,
    baseURL: "https://api.groq.com/openai/v1",
}) : null;

const systemInstruction = `You are zedoxhelper, a Minecraft bot. 
CRITICAL: EVERY response involving an action MUST start with a [COMMAND].
COMMANDS: [FOLLOW], [STOP], [STATUS], [GOTO:x,y,z], [COLLECT:item], [DEFEND], [BRIDGE], [DIG], [TP:player], [CMD:command], [INVENTORY], [SLEEP], [GIVE:item], [FARM], [BAMBOO_FARM], [SUGARCANE_FARM], [IRON_FARM], [CRAFT:item].

STRICT RULES:
1. NO LONG EXPLANATIONS.
2. ALWAYS prepend [COMMAND] for actions.
3. If unsure of an action, use [STATUS] or ask for clarification briefly.
4. You are in-game. Be concise.`;

async function getAIResponse(prompt, history = [], context = "") {
    const fullPrompt = `SYSTEM: ${systemInstruction}\n\nCONTEXT: ${context}\n\nUSER: ${prompt}`;
    // 1. Try Groq first (extremely fast and reliable)
    if (groq) {
        try {
            const response = await groq.chat.completions.create({
                messages: [
                    { role: "system", content: systemInstruction },
                    ...history,
                    { role: "user", content: fullPrompt }
                ],
                model: "llama-3.3-70b-versatile",
                max_tokens: 150,
            });
            return response.choices[0].message.content;
        } catch (error) {
            console.warn("Groq API Error:", error.message);
            console.warn("Trying Gemini...");
        }
    }

    // 2. Try Gemini
    if (GEMINI_API_KEY) {
        try {
            const chat = geminiModel.startChat({
                history: history,
                generationConfig: { maxOutputTokens: 150 },
            });
            const result = await chat.sendMessage(fullPrompt);
            const response = await result.response;
            return response.text();
        } catch (error) {
            console.error("Gemini API Error:", error.message);
        }
    }

    // 3. Final Fallback (Local Brain)
    const lower = prompt.toLowerCase();
    if (lower.includes("follow")) return "[FOLLOW] On it! I'm following you.";
    if (lower.includes("stop") || lower.includes("stay")) return "[STOP] Stopping.";
    if (lower.includes("bridge")) return "[BRIDGE] Building a bridge!";
    if (lower.includes("dig") || lower.includes("hole")) return "[DIG] Digging hole!";
    if (lower.includes("defend")) return "[DEFEND] Defending!";

    return "I'm zedoxhelper! I'm having trouble with my cloud brain, but I can still follow your basic commands!";
}

module.exports = { getAIResponse };
