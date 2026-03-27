import type { Handle } from '@sveltejs/kit';

export const handle: Handle = async ({ event, resolve }) => {
	const response = await resolve(event);
	
	// Inject API config into the HTML if it's a text/html response
	const contentType = response.headers.get('content-type') || '';
	if (!contentType.includes('text/html')) {
		return response;
	}
	
	// Clone the response to read its body without consuming the original
	const responseClone = response.clone();
	const originalText = await responseClone.text();
	
	const port = parseInt(process.env.VITE_API_PORT || '3000', 10);
	const externalPort = parseInt(process.env.VITE_API_EXTERNAL_PORT || String(port), 10);
	
	// In dev mode, inject a script that reads host from browser's location
	// This ensures it works regardless of how the user accesses the GUI
	const apiConfigScript = `(function() {
		var host = window.location.hostname;
		var protocol = window.location.protocol === 'https:' ? 'https' : 'http';
		window.API_CONFIG = {
			port: ${port},
			externalPort: ${externalPort},
			host: host,
			url: protocol + '://' + host + ':' + ${externalPort}
		};
	})();`;
	
	// Replace the API_CONFIG placeholder or existing assignment
	// Handle the placeholder "{{API_CONFIG}}" in app.html
	let modifiedText = originalText.replace(
		/window\.API_CONFIG\s*=\s*["']\{\{API_CONFIG\}\}["']/,
		apiConfigScript
	);
	
	// If no replacement happened (e.g., placeholder not found or already replaced),
	// try to inject before the closing </head> tag
	if (modifiedText === originalText) {
		// Check if API_CONFIG is already set by a previous injection
		if (!modifiedText.includes('window.API_CONFIG')) {
			// Inject the script before </head>
			modifiedText = modifiedText.replace(
				'</head>',
				`<script>${apiConfigScript}</script></head>`
			);
		}
	}
	
	// Create new headers based on the original response
	const newHeaders = new Headers(response.headers);
	// Update or remove content-length since we modified the body
	newHeaders.delete('content-length');
	
	return new Response(modifiedText, {
		status: response.status,
		statusText: response.statusText,
		headers: newHeaders,
	});
};
