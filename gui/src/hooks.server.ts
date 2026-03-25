export async function handle({ event, resolve }) {
	const response = await resolve(event);
	
	// Inject API config into the HTML if it's a text/html response
	if (response.headers.get('content-type')?.includes('text/html')) {
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
		
		const originalText = await response.text();
		
		// Replace the API_CONFIG placeholder or existing assignment
		// The build output has: window.API_CONFIG = {"port":3000,...};
		// We need to replace the entire assignment with our dynamic script
		const modifiedText = originalText.replace(
			/window\.API_CONFIG\s*=\s*["']?\{\{API_CONFIG\}\}["']?|window\.API_CONFIG\s*=\s*\{[\s\S]*?\}\s*;?/,
			apiConfigScript
		);
		
		return new Response(modifiedText, {
			status: response.status,
			statusText: response.statusText,
			headers: response.headers,
		});
	}
	
	return response;
}
