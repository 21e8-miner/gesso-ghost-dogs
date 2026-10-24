# tiny receiver: POST "name|data:...;base64,..." -> out/name
import http.server, base64, os
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out')
class H(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        body = self.rfile.read(int(self.headers['Content-Length'])).decode(); name, data = body.split('|', 1)
        open(os.path.join(OUT, os.path.basename(name)), 'wb').write(base64.b64decode(data.split(',', 1)[1]))
        self.send_response(200); self.send_header('Access-Control-Allow-Origin', '*'); self.end_headers(); self.wfile.write(b'ok')
    def log_message(self, *a): pass
http.server.ThreadingHTTPServer(('127.0.0.1', 8804), H).serve_forever()
