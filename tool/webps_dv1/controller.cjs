'use strict';
const fs=require('fs'),path=require('path');
const BASE='https://wps-cps.dev1.dmp.gouv.fr';
function urlFor(target){
 if(target==='dashboard')return BASE+'/AccesDirect/TableauDeBord';
 if(target==='patient')return BASE+'/AccesDirect/DossierPatient/187012425258307/1.2.250.1.213.1.4.10';
 throw Error('Accès inconnu');
}
class Controller{
 constructor(root,browser){this.root=root;this.browser=browser;this.lock=path.join(root,'window.lock');this.context=null;this.page=null;this.closing=false;this.launching=false;this.generation=0;this.state={mode:'webps-dv1',busy:fs.existsSync(this.lock),target:null,message:fs.existsSync(this.lock)?'Fermeture antérieure non confirmée : accès bloqués.':'Prêt. Aucun accès DV1 effectué.'};}
 snapshot(){return {...this.state};}
 reserve(target,confirmation){
  const url=urlFor(target);
  if(confirmation!=='MICHEL_DV1')throw Error('Confirmation explicite requise');
  if(this.state.busy)throw Error('Fenêtre déjà réservée');
  try{fs.writeFileSync(this.lock,JSON.stringify({target,date:new Date().toISOString()}),{flag:'wx',mode:0o600});}
  catch(e){this.state.busy=true;this.state.message='Réservation existante ou stockage indisponible : ouverture bloquée.';throw e;}
  this.state={mode:'webps-dv1',busy:true,target,message:'Ouverture en cours. Sélectionnez le certificat de Michel dans Chrome.'};
  // Reservation completes before asynchronous launch; never retry automatically.
  const generation=++this.generation;
  this.operation=this.launch(url).catch(()=>{if(this.generation===generation&&this.state.busy)this.state.message='Ouverture ou navigation non confirmée. Fermez le navigateur via ABAK ; aucun réessai automatique.';}).finally(()=>{this.launching=false;});
  return this.snapshot();
 }
 async launch(url){
  this.launching=true;
  this.context=await this.browser.launchPersistentContext(path.join(this.root,'profil-michel'),{executablePath:'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',headless:false,acceptDownloads:false,serviceWorkers:'block',args:['--disable-extensions','--disable-background-networking','--disable-component-update','--disable-sync','--no-first-run','--no-default-browser-check','--password-store=basic']});
  const ctx=this.context;
  this.page=ctx.pages()[0]||await ctx.newPage();const page=this.page;
  await ctx.route('**/*',r=>{
   let permitted=false;
   try{const u=new URL(r.request().url());permitted=u.origin===BASE && !u.username && !u.password && r.request().frame().page()===page;}catch{}
   return permitted?r.continue():r.abort();
  });
  ctx.on('page',p=>{if(p!==page)void p.close().catch(()=>{this.state.message='Fenêtre supplémentaire non maîtrisée : fermeture requise.';});});
  page.on('close',()=>{if(this.context===ctx)void this.close();});
  ctx.on('close',()=>{if(!this.closing&&this.context===ctx){this.context=null;this.state.message='Navigateur interrompu : fermeture non confirmée, accès bloqués.';}});
  await page.goto(url,{waitUntil:'domcontentloaded',timeout:120000});
  if(this.context===ctx&&!this.closing)this.state.message='Page Web-PS ouverte. Vérifiez Michel et le contexte affichés dans Chrome ; authentification et droits non déduits automatiquement.';
 }
 async close(){
  if(this.closing||!this.context)return this.snapshot();
  this.closing=true;
  try{await this.context.close();this.context=null;this.page=null;
   fs.unlinkSync(this.lock);this.state={mode:'webps-dv1',busy:false,target:null,message:'Fermeture confirmée. Un autre accès est possible.'};
  }catch{this.state.message='Fermeture non confirmée : accès bloqués.';}
  finally{this.closing=false;}
  return this.snapshot();
 }
}
module.exports={Controller,urlFor,BASE};
