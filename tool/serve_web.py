from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from functools import partial

class Handler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        self.send_header('Cache-Control', 'no-cache')
        super().end_headers()

ThreadingHTTPServer(('127.0.0.1', 8080), partial(Handler, directory='build/web')).serve_forever()
