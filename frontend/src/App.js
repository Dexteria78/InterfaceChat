import React, { useState, useEffect, useRef } from 'react';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';
const WS_URL = process.env.REACT_APP_WS_URL || 'ws://localhost:5000';

function App() {
  const [messages, setMessages] = useState([]);
  const [inputText, setInputText] = useState('');
  const [username, setUsername] = useState('');
  const [isConnected, setIsConnected] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => scrollToBottom(), [messages]);

  useEffect(() => {
    fetch(`${API_URL}/api/messages`)
      .then(res => res.json())
      .then(data => setMessages(data.messages || []))
      .catch(err => console.error('Error loading messages:', err));

    const websocket = new WebSocket(WS_URL);

    websocket.onopen = () => {
      console.log('WebSocket connected');
      setIsConnected(true);
    };

    websocket.onmessage = (event) => {
      const data = JSON.parse(event.data);
      if (data.type === 'new_message') {
        setMessages(prev => [...prev, data.message]);
        setIsLoading(false);
      } else if (data.type === 'history') {
        setMessages(data.messages || []);
      }
    };

    websocket.onclose = () => {
      console.log('WebSocket disconnected');
      setIsConnected(false);
    };

    return () => websocket.close();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!inputText.trim() || !username.trim()) return;

    const messageText = inputText;
    setInputText('');
    setIsLoading(true);

    try {
      await fetch(`${API_URL}/api/messages`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: messageText, user: username })
      });
    } catch (err) {
      console.error('Error sending message:', err);
      setIsLoading(false);
    }
  };

  const formatTime = (timestamp) => {
    return new Date(timestamp).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' });
  };

  return (
    <div className="App">
      <div className="chat-container">
        <div className="chat-header">
          <h1>💬 Chat DevOps</h1>
          <div className="connection-status">
            <span className={`status-indicator ${isConnected ? 'connected' : 'disconnected'}`}></span>
            {isConnected ? 'Connecté' : 'Déconnecté'}
          </div>
        </div>

        {!username ? (
          <div className="username-prompt">
            <h2>Bienvenue !</h2>
            <p>Entrez votre nom</p>
            <form onSubmit={(e) => {
              e.preventDefault();
              if (inputText.trim()) {
                setUsername(inputText.trim());
                setInputText('');
              }
            }}>
              <input
                type="text"
                value={inputText}
                onChange={(e) => setInputText(e.target.value)}
                placeholder="Votre nom..."
                className="username-input"
                autoFocus
              />
              <button type="submit" className="username-button">Commencer</button>
            </form>
          </div>
        ) : (
          <>
            <div className="messages-container">
              {messages.length === 0 ? (
                <div className="empty-state"><p>Aucun message. Commencez !</p></div>
              ) : (
                messages.map((msg) => (
                  <div key={msg.id} className={`message ${msg.user === username ? 'own-message' : 'other-message'}`}>
                    <div className="message-header">
                      <span className="message-user">{msg.user}</span>
                      <span className="message-time">{formatTime(msg.timestamp)}</span>
                    </div>
                    <div className="message-text">{msg.text}</div>
                  </div>
                ))
              )}
              {isLoading && (
                <div className="message other-message">
                  <div className="message-text loading-message">
                    <span className="typing-indicator">
                      <span></span><span></span><span></span>
                    </span>
                    TinyLlama réfléchit...
                  </div>
                </div>
              )}
              <div ref={messagesEndRef} />
            </div>

            <form onSubmit={handleSubmit} className="input-form">
              <input
                type="text"
                value={inputText}
                onChange={(e) => setInputText(e.target.value)}
                placeholder="Votre message..."
                className="message-input"
                autoFocus
              />
              <button type="submit" className="send-button" disabled={!inputText.trim() || isLoading}>
                {isLoading ? 'Envoi...' : 'Envoyer'}
              </button>
            </form>
          </>
        )}
      </div>
    </div>
  );
}

export default App;
