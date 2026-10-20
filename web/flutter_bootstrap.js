{{flutter_js}}
{{flutter_build_config}}

const config = {canvasKitBaseUrl: 'canvaskit/'};
// Keep the JavaScript fallback directly testable, including on Wasm browsers.
if (new URLSearchParams(location.search).get('renderer') === 'canvaskit') {
  config.renderer = 'canvaskit';
}
_flutter.loader.load({config});
