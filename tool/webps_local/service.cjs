'use strict';
const fs=require('fs'),path=require('path'),os=require('os'),http=require('http'),crypto=require('crypto');
const {pathToFileURL}=require('url');
const {chromium}=require('/Users/jeanclaudebrucher/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root=process.env.ABAK_WEBPS_TEST_ROOT||path.join(os.homedir(),'Library/Application Support/ABAK-WebPS-Local-Only');
fs.mkdirSync(root,{recursive:true,mode:0o700});
const lock=path.join(root,'window.lock');
let busy=fs.existsSync(lock),context=null,closing=false,launching=false;
let state={busy,message:busy?'Fermeture précédente non confirmée : accès bloqués.':'Prêt pour une page locale.',target:null};
const token=crypto.randomBytes(32).toString('hex');
const wrapper=path.join(root,'chrome-isole.sh');
const quote=s=>"'"+s.replaceAll("'","'\\''")+"'";
fs.writeFileSync(wrapper,'#!/bin/sh\nexec /usr/bin/sandbox-exec -f '+quote(path.join(__dirname,'isolation.sb'))+' '+quote('/Applications/Google Chrome.app/Contents/MacOS/Google Chrome')+' "$@"\n',{mode:0o700});
async function close(){
 if(closing||launching||!context)return;
 closing=true;
 try {await context.close();context=null;fs.unlinkSync(lock);busy=false;state={busy:false,target:null,message:'Fenêtre fermée. Un autre accès est possible.'};}
 catch{state.message='Fermeture non confirmée : accès bloqués.';}
 finally{closing=false;}
}
async function open(target){
 if(busy)throw Error('Une fenêtre est déjà réservée.');
 // Atomic persistent lock shared by services/processes; never clear an uncertain lock.
 let fd;try{fd=fs.openSync(lock,'wx',0o600);}catch(e){if(e.code==='EEXIST'){busy=true;state={busy:true,target:null,message:'Une fenêtre est réservée par un autre service ou sa fermeture reste incertaine.'};}throw e;}fs.closeSync(fd);
 busy=true;launching=true;state={busy:true,target,message:'Ouverture locale en cours…'};
 try{
 const profile=fs.mkdtempSync(path.join(root,'profil-'));
 context=await chromium.launchPersistentContext(profile,{executablePath:wrapper,headless:false,args:['--disable-extensions','--disable-background-networking','--disable-component-update','--disable-sync','--no-first-run','--no-default-browser-check','--password-store=basic']});
 await context.setOffline(true);await context.route(/^https?:/,r=>r.abort());
 const page=context.pages()[0];
 await page.goto(pathToFileURL(path.join(__dirname,'page.html')).href);
 if(target==='patient')await page.locator('#patient').selectOption({label:'Patient fictif B'});
 const childPromise=context.waitForEvent('page');
 await page.locator(target==='patient'?'#dossier':'#dashboard').click();
 const child=await childPromise;
 await child.locator('#context').waitFor();
 const expected=target==='patient'?'Patient fictif B':'Tableau de bord sans patient';
 if(await child.locator('#context').textContent()!==expected)throw Error('Contexte incorrect');
 state={busy:true,target,message:'Fenêtre locale ouverte : '+expected};
 child.on('close',()=>{if(!launching)void close();});
 page.on('close',()=>{if(!launching)void close();});
 context.on('close',()=>{if(!closing){context=null;state.message='Navigateur interrompu : fermeture contrôlée non confirmée, accès bloqués.';}});
 }catch{state.message='Ouverture non confirmée : accès bloqués. Fermer le service après analyse.';throw Error(state.message);}
 finally{launching=false;}
}
const server=http.createServer(async(req,res)=>{
 res.setHeader('Content-Type','application/json');res.setHeader('Cache-Control','no-store');
 if(req.headers.authorization!=='Bearer '+token||req.headers.origin){res.writeHead(403);res.end('{}');return;}
 try{
 if(req.method==='GET'&&req.url==='/state'){}
 else if(req.method==='POST'&&req.url==='/open/dashboard')await open('dashboard');
 else if(req.method==='POST'&&req.url==='/open/patient')await open('patient');
 else if(req.method==='POST'&&req.url==='/close')await close();
 else{res.writeHead(404);res.end('{}');return;}
 res.end(JSON.stringify(state));
 }catch(e){res.writeHead(409);res.end(JSON.stringify({...state,error:String(e.message)}));}
});
server.listen(0,'127.0.0.1',()=>{
 const config={port:server.address().port,token};
 const file=path.join(root,'Connexion_ABAK_locale.json');fs.writeFileSync(file,JSON.stringify(config),{mode:0o600});
 console.log('SERVICE LOCAL PRÊT — aucun accès DV1.\nDans ABAK, sélectionner : '+file);
});
process.on('SIGINT',async()=>{await close();server.close(()=>process.exit());});
process.on('SIGTERM',async()=>{await close();server.close(()=>process.exit());});
