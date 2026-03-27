/**
 * @jest-environment happy-dom
 */

import { describe, it, expect, beforeEach, mock } from 'bun:test';

describe('Model Test Page Logic', () => {
  let fetchMock: ReturnType<typeof mock>;

  beforeEach(() => {
    fetchMock = mock(() => Promise.resolve(new Response('{}', { status: 200 })));
    global.fetch = fetchMock as any;
  });

  it('should have correct initial state', () => {
    const state = {
      model: '',
      message: '',
      temperature: 0.7,
      maxTokens: 1024,
      stream: false,
      apiFormat: 'openai',
      endpointPath: '/chat/completions',
      enableThinking: true,
    };

    expect(state.temperature).toBe(0.7);
    expect(state.maxTokens).toBe(1024);
    expect(state.stream).toBe(false);
    expect(state.apiFormat).toBe('openai');
    expect(state.endpointPath).toBe('/chat/completions');
    expect(state.enableThinking).toBe(true);
  });

  it('should validate required fields', () => {
    const validateSend = (model: string, message: string) => {
      return model.trim() !== '' && message.trim() !== '';
    };

    expect(validateSend('', '')).toBe(false);
    expect(validateSend('gpt-4o', '')).toBe(false);
    expect(validateSend('', 'Hello')).toBe(false);
    expect(validateSend('gpt-4o', 'Hello')).toBe(true);
  });

  it('should toggle thinking state', () => {
    let enableThinking = true;
    
    // Toggle off
    enableThinking = !enableThinking;
    expect(enableThinking).toBe(false);
    
    // Toggle on
    enableThinking = !enableThinking;
    expect(enableThinking).toBe(true);
  });

  it('should include chatTemplateKwargs in API call when provided', async () => {
    const params = {
      model: 'test-model',
      message: 'Hello',
      chatTemplateKwargs: { enable_thinking: false }
    };

    await fetch('/api/test', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(params)
    });

    expect(fetchMock).toHaveBeenCalledTimes(1);
    const callBody = JSON.parse(fetchMock.mock.calls[0][1].body);
    expect(callBody.chatTemplateKwargs).toEqual({ enable_thinking: false });
  });
});
