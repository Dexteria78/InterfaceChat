const express = require('express');
const cors = require('cors');
const WebSocket = require('ws');
const http = require('http');
const axios = require('axios');
const promClient = require('prom-client');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const PORT = process.env.PORT || 5000;
const OLLAMA_URL = process.env.OLLAMA_URL || 'http://ollama:11434';

// Prometheus metrics
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const messageCounter = new promClient.Counter({
  name: 'chat_messages_total',
  help: 'Total chat messages',
  labelNames: ['type'],
  registers: [register]
});

const responseTime = new promClient.Histogram({
  name: 'ollama_response_duration_seconds',
  help: 'Ollama response duration',
  registers: [register]
});

app.use(cors());
app.use(express.json());

let messages = [];

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString(), ollama: OLLAMA_URL });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.get('/api/messages', (req, res) => {
  res.json({ messages });
});

app.post('/api/messages', async (req, res) => {
  const { text, user } = req.body;
  
  if (!text || !user) {
    return res.status(400).json({ error: 'Text and user required' });
  }

  const message = {
    id: Date.now().toString(),
    text,
    user,
    timestamp: new Date().toISOString()
  };

  messages.push(message);
  messageCounter.inc({ type: 'user' });

  wss.clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify({ type: 'new_message', message }));
    }
  });

  // Call Ollama AI
  try {
    const end = responseTime.startTimer();
    
    // Créer un prompt optimisé et court
    const optimizedPrompt = `Tu es un assistant de chat amical et concis. Réponds en français de manière courte et naturelle (maximum 2-3 phrases).

Question: ${text}

Réponse:`;

    const ollamaResponse = await axios.post(`${OLLAMA_URL}/api/generate`, {
      model: 'tinyllama',
      prompt: optimizedPrompt,
      stream: false,
      options: {
        temperature: 0.7,
        top_p: 0.9,
        max_tokens: 150,  // Limiter la longueur
        stop: ["\n\n", "Question:", "User:"]  // Arrêter aux marqueurs
      }
    }, { timeout: 30000 });

    end();

    // Nettoyer et raccourcir la réponse
    let responseText = ollamaResponse.data.response || "Je n'ai pas pu générer de réponse.";
    responseText = responseText.trim();
    
    // Limiter à 3 phrases maximum
    const sentences = responseText.split(/[.!?]+/).filter(s => s.trim().length > 0);
    if (sentences.length > 3) {
      responseText = sentences.slice(0, 3).join('. ') + '.';
    }

    const botResponse = {
      id: (Date.now() + 1).toString(),
      text: responseText,
      user: 'TinyLlama AI',
      timestamp: new Date().toISOString()
    };

    messages.push(botResponse);
    messageCounter.inc({ type: 'bot' });

    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({ type: 'new_message', message: botResponse }));
      }
    });

  } catch (error) {
    console.error('Ollama error:', error.message);
    
    // Réponse de fallback en français et plus courte
    const fallback = {
      id: (Date.now() + 1).toString(),
      text: `Désolé, je ne peux pas répondre pour le moment. (Ollama: ${error.message.substring(0, 50)})`,
      user: 'Bot (Erreur)',
      timestamp: new Date().toISOString()
    };

    messages.push(fallback);
    messageCounter.inc({ type: 'bot_fallback' });

    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({ type: 'new_message', message: fallback }));
      }
    });
  }

  res.status(201).json({ message });
});

wss.on('connection', (ws) => {
  console.log('✓ WebSocket client connected');
  ws.send(JSON.stringify({ type: 'history', messages }));
  
  ws.on('close', () => console.log('✗ WebSocket client disconnected'));
});

server.listen(PORT, () => {
  console.log(`🚀 Server on port ${PORT}`);
  console.log(`🤖 Ollama: ${OLLAMA_URL}`);
});
