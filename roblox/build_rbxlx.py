#!/opt/homebrew/bin/python3.14
# builds GessoGhostDogs.rbxlx: a Roblox place with the server script in ServerScriptService and the client script in
# StarterPlayerScripts. Everything else (terrain, plates, dogs, ink, HUD) is built by those scripts when the place runs.
import os
from xml.sax.saxutils import escape
here = os.path.dirname(os.path.abspath(__file__))
server = open(os.path.join(here, 'GessoWorld.server.lua')).read()
client = open(os.path.join(here, 'GessoClient.client.lua')).read()
def item(cls, name, children='', props='', ref=None):
    return (f'<Item class="{cls}" referent="RBX{ref or abs(hash(cls + name)) % 100000}"><Properties><string name="Name">{escape(name)}</string>{props}</Properties>{children}</Item>')
def script(cls, name, src):
    return item(cls, name, props=f'<bool name="Disabled">false</bool><ProtectedString name="Source">{escape(src)}</ProtectedString>')
doc = ('<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
       'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">'
       '<Meta name="ExplicitAutoJoints">true</Meta>'
       + item('Workspace', 'Workspace', children=item('Terrain', 'Terrain'), props='<bool name="StreamingEnabled">false</bool>')
       + item('Lighting', 'Lighting')
       + item('ReplicatedStorage', 'ReplicatedStorage')
       + item('ServerScriptService', 'ServerScriptService', children=script('Script', 'GessoWorld', server))
       + item('StarterPlayer', 'StarterPlayer', children=item('StarterPlayerScripts', 'StarterPlayerScripts', children=script('LocalScript', 'GessoClient', client)) + item('StarterCharacterScripts', 'StarterCharacterScripts'))
       + item('StarterGui', 'StarterGui') + item('StarterPack', 'StarterPack') + item('Players', 'Players') + item('SoundService', 'SoundService')
       + '</roblox>')
out = os.path.join(here, 'GessoGhostDogs.rbxlx')
open(out, 'w').write(doc)
print(out, len(doc))
