'use strict';
const fs=require('fs'),path=require('path'),os=require('os'),http=require('http'),crypto=require('crypto');
const {Controller}=require('./controller.cjs');
const {chromium}=require('/Users/jeanclaudebrucher/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root=path.join(os.homedir(),'Library/Application Support/ABAK-WebPS-DV1-Michel');
fs.mkdirSync(root,{recursive:true,mode:0o700});
const c=new Controller(root,chromium),token=crypto.randomBytes(32).toString('hex');
const server=http.createServer(async(req,res)=>{
 res.setHeader('Content-Type','application/json');res.setHeader('Cache-Control','no-store');
 if(req.headers.authorization!=='Bearer '+token||req.headers.origin){res.writeHead(403);res.end('{}');return;}
 try{
 if(req.method==='GET'&&req.url==='/state'){}
 else if(req.method==='POST'&&['/open/dashboard','/open/patient'].includes(req.url))c.reserve(req.url.split('/').pop(),req.headers['x-abak-confirmation']);
 else if(req.method==='POST'&&req.url==='/close')await c.close();
 else{res.writeHead(404);res.end('{}');return;}
 res.end(JSON.stringify(c.snapshot()));
 }catch{res.writeHead(409);res.end(JSON.stringify(c.snapshot()));}
});
server.listen(0,'127.0.0.1',()=>{
 const file=path.join(root,'Connexion_ABAK_WebPS_DV1.json');
 fs.writeFileSync(file,JSON.stringify({mode:'webps-dv1',port:server.address().port,token}),{mode:0o600});
 console.log('Préparation Web-PS DV1 — aucun navigateur ouvert au démarrage.\nFichier à sélectionner dans ABAK : '+file+'\nUne confirmation dans ABAK sera requise avant toute ouverture réelle avec la CPS de Michel.');
});
async function stop(){await c.close();server.close(()=>process.exit());}
process.on('SIGINT',stop);process.on('SIGTERM',stop);
