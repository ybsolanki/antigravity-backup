const mineflayer = require('mineflayer');
const { pathfinder, Movements, goals } = require('mineflayer-pathfinder');
const pvp = require('mineflayer-pvp').plugin;
const collectBlock = require('mineflayer-collectblock').plugin;
require('dotenv').config();
const { getAIResponse } = require('./ai');

const OWNER = 'ZEDOX';
let chatHistory = [];
let followTarget = null;
let defending = false;
let panicMode = false;

const bot = mineflayer.createBot({
    host: process.env.MC_HOST || 'localhost',
    port: parseInt(process.env.MC_PORT) || 25565,
    username: process.env.MC_USERNAME || 'zedoxhelper',
    version: process.env.MC_VERSION === 'false' ? false : process.env.MC_VERSION,
});

bot.loadPlugin(pathfinder);
bot.loadPlugin(pvp);
bot.loadPlugin(collectBlock);

bot.on('spawn', () => {
    console.log(`Bot spawned as ${bot.username}`);
    bot.chat("Hello! I'm zedoxhelper, your Minecraft helper bot. How can I help you today?");

    const mcData = require('minecraft-data')(bot.version);
    const defaultMovements = new Movements(bot, mcData);
    defaultMovements.allowDoors = true;
    defaultMovements.allowParkour = true;
    bot.pathfinder.setMovements(defaultMovements);

    // Mob Sensing & Self-Defense
    setInterval(() => {
        if (panicMode) return;

        const filter = e => e.type === 'mob' && e.position.distanceTo(bot.entity.position) < 8 &&
            (e.kind === 'Hostile' || ['zombie', 'skeleton', 'creeper', 'spider', 'enderman'].includes(e.name));

        const nearbyMob = bot.nearestEntity(filter);
        if (nearbyMob && !defending) {
            bot.chat(`Hostile ${nearbyMob.name} nearby! Running away!`);
            const escapePos = bot.entity.position.offset(
                (bot.entity.position.x - nearbyMob.position.x) * 2,
                0,
                (bot.entity.position.z - nearbyMob.position.z) * 2
            );
            bot.pathfinder.setGoal(new goals.GoalNear(escapePos.x, escapePos.y, escapePos.z, 2));
        }
    }, 3000);

    bot.on('entityHurt', (entity) => {
        if (entity.username === bot.username) {
            const attacker = bot.nearestEntity(e => e.type === 'player' && e.position.distanceTo(bot.entity.position) < 5);
            if (attacker && attacker.username !== OWNER) {
                bot.chat(`HELP! I'm being attacked by ${attacker.username}! Teleporting to ${OWNER}!`);
                bot.chat(`/tp ${OWNER}`);
                panicMode = true;
                setTimeout(() => { panicMode = false; }, 5000);
            }
        }
    });
});

bot.on('chat', async (username, message) => {
    if (username === bot.username) return;

    const isMentioned = message.toLowerCase().includes(bot.username.toLowerCase());
    const isPrefix = message.startsWith(',');

    if (!isPrefix && !isMentioned) return;

    // 1. Direct Commands (Only for prefix)
    if (isPrefix) {
        const args = message.slice(1).split(' ');
        const command = args[0].toLowerCase();

        switch (command) {
            case 'follow':
                const player = bot.players[username];
                if (!player || !player.entity) {
                    bot.chat("I can't see you!");
                    return;
                }
                followTarget = player.entity;
                bot.chat(`Following ${username}!`);
                startFollowing();
                return;
            case 'stop':
                followTarget = null;
                defending = false;
                bot.pathfinder.setGoal(null);
                bot.chat("Stopped everything.");
                return;
            case 'goto':
                const x = parseInt(args[1]);
                const y = parseInt(args[2]);
                const z = parseInt(args[3]);
                if (isNaN(x) || isNaN(y) || isNaN(z)) {
                    bot.chat("Usage: ,goto <x> <y> <z>");
                    return;
                }
                bot.chat(`Going to ${x}, ${y}, ${z}...`);
                bot.pathfinder.setGoal(new goals.GoalBlock(x, y, z));
                return;
            case 'status':
                bot.chat(`Health: ${Math.round(bot.health)} | Food: ${Math.round(bot.food)}`);
                return;
            case 'bridge':
                bot.chat("Building a 5-block bridge...");
                buildBridge(5);
                return;
            case 'dig':
                bot.chat("Digging a 3x3 hole...");
                digHole(3, 3);
                return;
        }
    }

    // 2. AI Response (Mentioned OR unknown prefix command)
    const cleanMessage = isPrefix ? message.slice(1) : message;

    // Gather Context
    const inventory = bot.inventory.items().map(i => `${i.count}x ${i.name}`).join(', ') || 'Empty';
    const hasHoe = bot.inventory.items().some(i => i.name.includes('hoe'));
    const hasSeeds = bot.inventory.items().some(i => i.name.includes('seeds'));
    const hasWater = bot.inventory.items().some(i => i.name === 'water_bucket');
    const context = `Health: ${Math.round(bot.health)}, Food: ${Math.round(bot.food)}, Pos: ${Math.round(bot.entity.position.x)}, ${Math.round(bot.entity.position.y)}, ${Math.round(bot.entity.position.z)}, Inventory: [${inventory}], Can Farm: ${hasHoe && hasSeeds && hasWater ? 'Yes' : 'Missing tools'}`;

    // AI Response
    const response = await getAIResponse(cleanMessage, chatHistory, context);
    console.log(`AI Raw Response: ${response}`);

    let finalResponse = response;
    if (response === "Sorry, my brain is feeling a bit foggy right now.") {
        // Fallback: Check for simple keywords if AI is down
        if (cleanMessage.toLowerCase().includes("follow")) {
            const player = bot.players[username];
            if (player && player.entity) {
                followTarget = player.entity;
                startFollowing();
                finalResponse = "AI is down, but I'm following you anyway!";
            }
        } else if (cleanMessage.toLowerCase().includes("stop") || cleanMessage.toLowerCase().includes("stay")) {
            followTarget = null;
            defending = false;
            bot.pathfinder.setGoal(null);
            finalResponse = "AI is down, but I stopped all actions.";
        }
    }

    // Add to history
    chatHistory.push({ role: 'user', content: cleanMessage });
    chatHistory.push({ role: 'assistant', content: response });
    if (chatHistory.length > 10) chatHistory.splice(0, 2);

    // Command extraction from AI response
    if (response.match(/\[\s*FOLLOW\s*\]/i)) {
        const player = bot.players[username];
        if (player && player.entity) {
            followTarget = player.entity;
            startFollowing();
        }
    } else if (response.match(/\[\s*STOP\s*\]/i)) {
        followTarget = null;
        defending = false;
        bot.pathfinder.setGoal(null);
    } else if (response.match(/\[\s*STATUS\s*\]/i)) {
        // AI handles it
    } else if (response.includes('[GOTO:')) {
        const match = response.match(/\[\s*GOTO\s*:\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*\]/i);
        if (match) {
            const x = parseInt(match[1]);
            const y = parseInt(match[2]);
            const z = parseInt(match[3]);
            bot.pathfinder.setGoal(new goals.GoalBlock(x, y, z));
        }
    } else if (response.includes('[COLLECT:')) {
        const match = response.match(/\[\s*COLLECT\s*:\s*(.+?)\s*\]/i);
        if (match) {
            const blockType = match[1].toLowerCase().replace(/ /g, '_');
            const mcData = require('minecraft-data')(bot.version);
            const block = bot.findBlock({
                matching: mcData.blocksByName[blockType]?.id || mcData.blocksByName[blockType + '_ore']?.id,
                maxDistance: 64
            });
            if (block) {
                bot.collectBlock.collect(block, err => {
                    if (err) bot.chat(`I couldn't collect that: ${err.message}`);
                });
            } else {
                bot.chat(`I can't find any ${blockType} nearby!`);
            }
        }
    } else if (response.match(/\[\s*DEFEND\s*\]/i)) {
        const player = bot.players[username];
        if (player && player.entity) {
            bot.chat("Defend mode activated! I'll protect you from mobs.");
            defending = true;
            startDefending(player.entity);
        }
    } else if (response.match(/\[\s*BRIDGE\s*\]/i)) {
        bot.chat("I'll build a bridge for you!");
        buildBridge(5);
    } else if (response.match(/\[\s*DIG\s*\]/i)) {
        bot.chat("I'll dig a hole for you!");
        digHole(3, 3);
    } else if (response.includes('[TP:')) {
        const match = response.match(/\[\s*TP\s*:\s*(.+?)\s*\]/i);
        if (match) {
            bot.chat(`/tp ${match[1].trim()}`);
        }
    } else if (response.includes('[CMD:')) {
        const match = response.match(/\[\s*CMD\s*:\s*(.+?)\s*\]/i);
        if (match) {
            bot.chat(match[1].trim());
        }
    } else if (response.match(/\[\s*INVENTORY\s*\]/i)) {
        bot.chat(`My Inventory: ${inventory}`);
    } else if (response.match(/\[\s*SLEEP\s*\]/i)) {
        const mcData = require('minecraft-data')(bot.version);
        const bed = bot.findBlock({
            matching: (block) => mcData.blocksByName[block.name]?.name?.includes('bed'),
            maxDistance: 32
        });
        if (bed) {
            bot.sleep(bed).catch(err => bot.chat(`I can't sleep now: ${err.message}`));
        } else {
            bot.chat("I can't find a bed nearby!");
        }
    } else if (response.includes('[GIVE:')) {
        const match = response.match(/\[\s*GIVE\s*:\s*(.+?)\s*\]/i);
        if (match) {
            const itemName = match[1].toLowerCase().replace(/ /g, '_');
            const item = bot.inventory.items().find(i => i.name.includes(itemName));
            if (item) {
                bot.tossStack(item);
            } else {
                bot.chat(`I don't have any ${itemName} to give!`);
            }
        }
    } else if (response.match(/\[\s*FARM\s*\]/i)) {
        bot.chat("Building a 9x9 crop farm! I'll need a hoe, water, and seeds.");
        buildFarm();
    } else if (response.match(/\[\s*BAMBOO_FARM\s*\]/i)) {
        buildBambooFarm();
    } else if (response.match(/\[\s*SUGARCANE_FARM\s*\]/i)) {
        buildSugarcaneFarm();
    } else if (response.match(/\[\s*IRON_FARM\s*\]/i)) {
        buildIronFarmShell();
    } else if (response.includes('[CRAFT:')) {
        const match = response.match(/\[\s*CRAFT\s*:\s*(.+?)\s*\]/i);
        if (match) {
            autoCraft(match[1].trim().toLowerCase().replace(/ /g, '_'), 1);
        }
    }

    bot.chat(finalResponse.replace(/\[.*?\]/g, '').trim());
});

bot.on('playerJoined', (player) => {
    if (player.username !== bot.username) {
        setTimeout(() => {
            bot.chat(`Welcome to the Zedox Server, ${player.username}! I am zedoxhelper, let me know if you need any help.`);
        }, 2000);
    }
});

function startDefending(targetPlayer) {
    if (!defending) return;
    const filter = e => e.type === 'mob' && e.position.distanceTo(targetPlayer.position) < 16 &&
        (e.kind === 'Hostile' || e.mobType === 'Zombie' || e.mobType === 'Skeleton' || e.mobType === 'Creeper');

    const entity = bot.nearestEntity(filter);
    if (entity) {
        bot.pvp.attack(entity);
    }

    setTimeout(() => {
        if (bot.pvp.target) return; // Still fighting
        startDefending(targetPlayer);
    }, 1000);
}

function startFollowing() {
    if (!followTarget) return;

    const goal = new goals.GoalFollow(followTarget, 2);
    bot.pathfinder.setGoal(goal, true);

    // Periodically update goal if target moves
    setTimeout(() => {
        if (followTarget) startFollowing();
    }, 1000);
}

bot.on('error', console.log);

async function buildBridge(length) {
    const mcData = require('minecraft-data')(bot.version);
    for (let i = 0; i < length; i++) {
        const referenceBlock = bot.blockAt(bot.entity.position.offset(0, -1, i));
        const jumpPos = bot.entity.position.offset(0, 0, i);

        // Find a block to place (dirt, cobble, etc.)
        const item = bot.inventory.items().find(item => item.name.includes('dirt') || item.name.includes('cobblestone') || item.name.includes('planks'));
        if (!item) {
            bot.chat("I need blocks (dirt/cobble/planks) to build!");
            return;
        }

        await bot.equip(item, 'hand');
        try {
            await bot.placeBlock(referenceBlock, { x: 0, y: 1, z: 0 });
        } catch (e) {
            // Ignore placement errors
        }
    }
    bot.chat("Bridge building complete!");
}

async function autoCraft(itemName, count) {
    const mcData = require('minecraft-data')(bot.version);
    const item = mcData.itemsByName[itemName];
    if (!item) {
        bot.chat(`I don't know how to craft ${itemName}.`);
        return;
    }

    const recipe = bot.recipesFor(item.id, null, count, true)[0];
    if (recipe) {
        bot.chat(`Crafting ${count}x ${itemName}...`);
        try {
            await bot.craft(recipe, count, null);
            bot.chat(`Done crafting ${itemName}!`);
        } catch (err) {
            bot.chat(`Crafting failed: ${err.message}`);
        }
    } else {
        bot.chat(`I don't have the materials to craft ${itemName}. Check my [INVENTORY].`);
    }
}

async function buildFromBlueprint(blueprint) {
    bot.chat(`Starting build sequence (${blueprint.length} blocks)...`);
    for (const b of blueprint) {
        const targetPos = bot.entity.position.floored().offset(b.x, b.y, b.z);
        const block = bot.blockAt(targetPos);

        if (block && block.name === b.name) continue; // Already placed

        let item = bot.inventory.items().find(i => i.name === b.name || (b.name === 'grass_block' && i.name === 'dirt'));

        // Try to craft if missing
        if (!item) {
            await autoCraft(b.name, 1);
            item = bot.inventory.items().find(i => i.name === b.name);
        }

        if (!item) {
            bot.chat(`Still missing: ${b.name}! Please provide it.`);
            return false;
        }

        if (block && block.name !== 'air') {
            await bot.dig(block);
        }

        await bot.equip(item, 'hand');
        try {
            const ref = bot.blockAt(targetPos.offset(0, -1, 0));
            await bot.placeBlock(ref, { x: 0, y: 1, z: 0 });
        } catch (e) {
            try {
                const ref = bot.blockAt(targetPos.offset(0, 0, -1));
                await bot.placeBlock(ref, { x: 0, y: 0, z: 1 });
            } catch (e2) { }
        }
    }
    bot.chat("Build sequence complete!");
    return true;
}

async function buildBambooFarm() {
    bot.chat("Building 1 tile of an automated Bamboo farm...");
    const blueprint = [
        { x: 1, y: -1, z: 1, name: 'mud' },
        { x: 1, y: 0, z: 1, name: 'bamboo' },
        { x: 1, y: 1, z: 2, name: 'piston' },
        { x: 1, y: 2, z: 2, name: 'observer' },
        { x: 1, y: 1, z: 3, name: 'cobblestone' },
        { x: 1, y: 2, z: 3, name: 'redstone_dust' }
    ];
    await buildFromBlueprint(blueprint);
}

async function buildSugarcaneFarm() {
    bot.chat("Building 1 tile of an automated Sugarcane farm...");
    const blueprint = [
        { x: 1, y: -1, z: 0, name: 'water_bucket' }, // Bot logic handles buckets differently but for now...
        { x: 1, y: -1, z: 1, name: 'sand' },
        { x: 1, y: 0, z: 1, name: 'sugarcane' },
        { x: 1, y: 1, z: 2, name: 'piston' },
        { x: 1, y: 2, z: 2, name: 'observer' }
    ];
    await buildFromBlueprint(blueprint);
}

async function buildIronFarmShell() {
    bot.chat("Building the Iron Farm skeleton (Day-1 design)...");
    bot.chat("Note: You must bring 3 villagers and 1 zombie yourself!");
    // Simplified shell: 3x3 platform and walls
    const blueprint = [];
    for (let x = -1; x <= 1; x++) {
        for (let z = -1; z <= 1; z++) {
            blueprint.push({ x: x + 3, y: 5, z: z, name: 'cobblestone' }); // Platform
        }
    }
    // (Adding walls, beds, etc. would be a larger list)
    await buildFromBlueprint(blueprint);
}

async function buildFarm() {
    const mcData = require('minecraft-data')(bot.version);
    const startPos = bot.entity.position.floored().clone();

    bot.chat("Clearing a 9x9 area...");
    for (let x = -4; x <= 4; x++) {
        for (let z = -4; z <= 4; z++) {
            const targetPos = startPos.offset(x, -1, z);
            const block = bot.blockAt(targetPos);
            if (block && block.name !== 'dirt' && block.name !== 'grass_block' && block.name !== 'farmland') {
                const dirtItem = bot.inventory.items().find(i => i.name.includes('dirt') || i.name.includes('grass'));
                if (dirtItem) {
                    await bot.dig(block);
                    await bot.equip(dirtItem, 'hand');
                    await bot.placeBlock(bot.blockAt(targetPos.offset(0, -1, 0)), { x: 0, y: 1, z: 0 });
                }
            }
        }
    }

    const waterBucket = bot.inventory.items().find(i => i.name === 'water_bucket');
    if (waterBucket) {
        await bot.equip(waterBucket, 'hand');
        const center = startPos.offset(0, -1, 0);
        await bot.dig(bot.blockAt(center));
        await bot.activateItem();
    } else {
        bot.chat("I don't have a water bucket, skipping water...");
    }

    const hoe = bot.inventory.items().find(i => i.name.includes('hoe'));
    const seeds = bot.inventory.items().find(i => i.name.includes('seeds'));

    if (hoe) {
        await bot.equip(hoe, 'hand');
        for (let x = -4; x <= 4; x++) {
            for (let z = -4; z <= 4; z++) {
                if (x === 0 && z === 0) continue;
                const targetPos = startPos.offset(x, -1, z);
                const block = bot.blockAt(targetPos);
                if (block && (block.name === 'dirt' || block.name === 'grass_block')) {
                    await bot.activateBlock(block);
                }

                if (seeds) {
                    const farmBlock = bot.blockAt(targetPos);
                    if (farmBlock && farmBlock.name === 'farmland') {
                        await bot.equip(seeds, 'hand');
                        await bot.placeBlock(farmBlock, { x: 0, y: 1, z: 0 });
                    }
                }
            }
        }
        bot.chat("Farm building complete!");
    } else {
        bot.chat("I don't have a hoe to till the land!");
    }
}

async function digHole(width, depth) {
    const mcData = require('minecraft-data')(bot.version);
    const startPos = bot.entity.position.floored().clone();

    for (let d = 0; d < depth; d++) {
        for (let x = -Math.floor(width / 2); x <= Math.floor(width / 2); x++) {
            for (let z = -Math.floor(width / 2); z <= Math.floor(width / 2); z++) {
                const targetPos = startPos.offset(x, -d, z);
                const block = bot.blockAt(targetPos);
                if (block && block.name !== 'air') {
                    await bot.dig(block);
                }
            }
        }
    }
    bot.chat("Digging complete!");
}
