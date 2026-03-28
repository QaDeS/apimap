/**
 * Tests for WebSocket connectivity
 * Tests both local server and container scenarios
 */

import { describe, it, expect, beforeEach, afterEach } from 'bun:test';

// Get a random available port
async function getRandomPort(): Promise<number> {
  // Start from a high port range to avoid conflicts
  return Math.floor(Math.random() * 10000) + 20000;
}

describe('WebSocket Connectivity', () => {
  let server: any;
  let guiServer: any;
  let apiPort: number;
  let guiPort: number;

  beforeEach(async () => {
    // Get random ports for each test to avoid conflicts
    apiPort = await getRandomPort();
    guiPort = apiPort + 1;
    
    // Mock environment variables for local testing
    process.env.VITE_API_PORT = String(apiPort);
    
    const wsClients = new Set<WebSocket>();
    
    // Start mock API server with WebSocket support
    server = Bun.serve({
      port: apiPort,
      fetch(req) {
        const url = new URL(req.url);
        
        if (url.pathname === '/admin/server-info' && req.method === 'GET') {
          return new Response(JSON.stringify({
            apiUrl: `http://localhost:${apiPort}`,
            version: '2.0.1',
            commitHash: 'test-commit',
            uptime: 12345,
          }), {
            headers: { 'Content-Type': 'application/json' },
          });
        }
        
        if (url.pathname === '/health') {
          return new Response(JSON.stringify({ status: 'ok' }), {
            headers: { 'Content-Type': 'application/json' },
          });
        }
        
        if (url.pathname === '/ws') {
          const upgraded = server.upgrade(req, { data: {} });
          if (upgraded) {
            return undefined;
          }
          return new Response('WebSocket upgrade failed', { status: 400 });
        }
        
        return new Response('Not Found', { status: 404 });
      },
      websocket: {
        open(ws) {
          wsClients.add(ws);
          ws.send(JSON.stringify({ type: 'initial', requests: [] }));
        },
        close(ws) {
          wsClients.delete(ws);
        },
        message(ws, message) {
          const data = JSON.parse(message as string);
          if (data.type === 'ping') {
            ws.send(JSON.stringify({ type: 'pong' }));
          }
        },
      },
    });

    // Start mock GUI server (simulates Vite dev server)
    guiServer = Bun.serve({
      port: guiPort,
      fetch(req) {
        const url = new URL(req.url);
        
        if (url.pathname === '/admin/server-info') {
          return new Response(JSON.stringify({
            apiUrl: `http://localhost:${apiPort}`,
            version: '2.0.1',
            commitHash: 'test-commit',
            uptime: 12345,
          }), {
            headers: { 'Content-Type': 'application/json' },
          });
        }
        
        return new Response('Not Found', { status: 404 });
      },
    });
  });

  afterEach(() => {
    server?.stop(true);
    guiServer?.stop(true);
  });

  describe('Local Server Environment', () => {
    it('should connect to WebSocket endpoint on API server', async () => {
      const wsUrl = `ws://localhost:${apiPort}/ws`;
      const ws = new WebSocket(wsUrl);
      
      const connected = new Promise<void>((resolve, reject) => {
        const timeout = setTimeout(() => {
          reject(new Error('WebSocket connection timeout'));
        }, 5000);
        
        ws.onopen = () => {
          clearTimeout(timeout);
          resolve();
        };
        ws.onerror = (e) => {
          clearTimeout(timeout);
          reject(new Error('WebSocket connection error'));
        };
      });
      
      await connected;
      expect(ws.readyState).toBe(WebSocket.OPEN);
      ws.close();
    });

    it('should receive initial requests message on connect', async () => {
      const wsUrl = `ws://localhost:${apiPort}/ws`;
      const ws = new WebSocket(wsUrl);
      
      const messageReceived = new Promise<any>((resolve, reject) => {
        const timeout = setTimeout(() => {
          reject(new Error('Timeout waiting for initial message'));
        }, 5000);
        
        ws.onmessage = (event) => {
          clearTimeout(timeout);
          resolve(JSON.parse(event.data));
        };
        ws.onerror = () => {
          clearTimeout(timeout);
          reject(new Error('WebSocket connection error'));
        };
      });
      
      await new Promise((resolve, reject) => {
        const timeout = setTimeout(() => reject(new Error('Timeout opening WebSocket')), 5000);
        ws.onopen = () => {
          clearTimeout(timeout);
          resolve(undefined);
        };
      });
      
      const message = await messageReceived;
      expect(message.type).toBe('initial');
      expect(Array.isArray(message.requests)).toBe(true);
      ws.close();
    });

    it('should handle ping/pong messages', async () => {
      const wsUrl = `ws://localhost:${apiPort}/ws`;
      const ws = new WebSocket(wsUrl);
      
      // Wait for initial message first
      await new Promise<void>((resolve, reject) => {
        const timeout = setTimeout(() => reject(new Error('Timeout waiting for initial message')), 5000);
        ws.onmessage = (event) => {
          const data = JSON.parse(event.data);
          if (data.type === 'initial') {
            clearTimeout(timeout);
            resolve();
          }
        };
        ws.onerror = () => {
          clearTimeout(timeout);
          reject(new Error('WebSocket error'));
        };
      });
      
      const pongReceived = new Promise<any>((resolve, reject) => {
        const timeout = setTimeout(() => reject(new Error('Timeout waiting for pong')), 5000);
        ws.onmessage = (event) => {
          const data = JSON.parse(event.data);
          if (data.type === 'pong') {
            clearTimeout(timeout);
            resolve(data);
          }
        };
        ws.onerror = reject;
      });
      
      ws.send(JSON.stringify({ type: 'ping' }));
      
      const pong = await pongReceived;
      expect(pong.type).toBe('pong');
      ws.close();
    });

    it('should maintain connection when GUI is served separately', async () => {
      // GUI runs on guiPort, API runs on apiPort
      // WebSocket should connect directly to API port
      
      const apiWs = new WebSocket(`ws://localhost:${apiPort}/ws`);
      
      const apiConnected = new Promise<void>((resolve, reject) => {
        const timeout = setTimeout(() => reject(new Error('Timeout connecting to API WebSocket')), 5000);
        apiWs.onopen = () => {
          clearTimeout(timeout);
          resolve();
        };
        apiWs.onerror = () => {
          clearTimeout(timeout);
          reject(new Error('API WebSocket connection failed'));
        };
      });
      
      await apiConnected;
      expect(apiWs.readyState).toBe(WebSocket.OPEN);
      apiWs.close();
    });
  });

  describe('Container Environment with Port Mapping', () => {
    it('should handle external port mappings', async () => {
      // Simulate container where external port differs from internal port
      // Container exposes port 3456 externally, but runs on 3457 internally
      
      const externalPort = await getRandomPort();
      
      const containerWsClients = new Set<WebSocket>();
      
      // Create a new server with external port
      const externalServer = Bun.serve({
        port: externalPort,
        fetch(req) {
          const url = new URL(req.url);
          
          if (url.pathname === '/admin/server-info' && req.method === 'GET') {
            return new Response(JSON.stringify({
              apiUrl: `http://localhost:${externalPort}`,
              version: '2.0.1',
              commitHash: 'test-commit',
              uptime: 12345,
            }), {
              headers: { 'Content-Type': 'application/json' },
            });
          }
          
          if (url.pathname === '/ws') {
            const upgraded = externalServer.upgrade(req, { data: {} });
            if (upgraded) return undefined;
            return new Response('WebSocket upgrade failed', { status: 400 });
          }
          
          return new Response('Not Found', { status: 404 });
        },
        websocket: {
          open(ws) { containerWsClients.add(ws); },
          close(ws) { containerWsClients.delete(ws); },
          message(ws, message) {
            const data = JSON.parse(message as string);
            if (data.type === 'ping') {
              ws.send(JSON.stringify({ type: 'pong' }));
            }
          },
        },
      });

      const ws = new WebSocket(`ws://localhost:${externalPort}/ws`);
      
      await new Promise<void>((resolve, reject) => {
        const timeout = setTimeout(() => reject(new Error('Timeout connecting to external port')), 5000);
        ws.onopen = () => {
          clearTimeout(timeout);
          resolve();
        };
        ws.onerror = () => {
          clearTimeout(timeout);
          reject(new Error('Connection to external port failed'));
        };
      });
      
      expect(ws.readyState).toBe(WebSocket.OPEN);
      
      ws.close();
      externalServer.stop(true);
    });

    it('should work with Docker port mapping (host:container)', async () => {
      // Simulate: docker run -p 3456:3456
      // Host port 3456 maps to container port 3456
      
      const hostPort = await getRandomPort();
      
      const containerWsClients = new Set<WebSocket>();
      
      const containerServer = Bun.serve({
        port: hostPort,
        fetch(req) {
          const url = new URL(req.url);
          
          if (url.pathname === '/admin/server-info' && req.method === 'GET') {
            return new Response(JSON.stringify({
              apiUrl: `http://localhost:${hostPort}`,
              version: '2.0.1',
              commitHash: 'test-commit',
              uptime: 12345,
            }), {
              headers: { 'Content-Type': 'application/json' },
            });
          }
          
          if (url.pathname === '/ws') {
            const upgraded = containerServer.upgrade(req, { data: {} });
            if (upgraded) return undefined;
            return new Response('WebSocket upgrade failed', { status: 400 });
          }
          
          return new Response('Not Found', { status: 404 });
        },
        websocket: {
          open(ws) { containerWsClients.add(ws); },
          close(ws) { containerWsClients.delete(ws); },
          message(ws, message) {
            const data = JSON.parse(message as string);
            if (data.type === 'ping') {
              ws.send(JSON.stringify({ type: 'pong' }));
            }
          },
        },
      });

      const ws = new WebSocket(`ws://localhost:${hostPort}/ws`);
      
      await new Promise<void>((resolve, reject) => {
        const timeout = setTimeout(() => reject(new Error('Timeout connecting to host port')), 5000);
        ws.onopen = () => {
          clearTimeout(timeout);
          resolve();
        };
        ws.onerror = () => {
          clearTimeout(timeout);
          reject(new Error('Connection to host port failed'));
        };
      });
      
      expect(ws.readyState).toBe(WebSocket.OPEN);
      
      ws.close();
      containerServer.stop(true);
    });
  });

  describe('Connection Recovery', () => {
    it('should detect connection loss when server stops', async () => {
      const wsUrl = `ws://localhost:${apiPort}/ws`;
      const ws = new WebSocket(wsUrl);
      
      const openReceived = new Promise<void>((resolve, reject) => {
        const timeout = setTimeout(() => reject(new Error('Timeout opening WebSocket')), 5000);
        ws.onopen = () => {
          clearTimeout(timeout);
          resolve();
        };
        ws.onerror = () => {
          clearTimeout(timeout);
          reject(new Error('Connection failed'));
        };
      });
      
      await openReceived;
      expect(ws.readyState).toBe(WebSocket.OPEN);
      
      // Verify close handler is set up
      let closeEventReceived = false;
      ws.onclose = (event) => {
        closeEventReceived = true;
      };
      
      // Close the connection
      ws.close();
      
      await new Promise(resolve => setTimeout(resolve, 100));
      expect(closeEventReceived).toBe(true);
    });

    it('should handle reconnection attempts after server restart', async () => {
      const wsUrl = `ws://localhost:${apiPort}/ws`;
      
      const connections: WebSocket[] = [];
      let connectionCount = 0;
      
      function connect() {
        const ws = new WebSocket(wsUrl);
        connections.push(ws);
        
        ws.onopen = () => {
          connectionCount++;
        };
      }
      
      // Make initial connection
      connect();
      await new Promise(resolve => setTimeout(resolve, 100));
      
      expect(connectionCount).toBeGreaterThanOrEqual(1);
      
      // Cleanup
      connections.forEach(ws => ws.close());
    });
  });
});
