const {Controller,urlFor,BASE}=require('./controller.cjs');
const fs=require('fs'),os=require('os'),path=require('path'),assert=require('assert'),{EventEmitter}=require('events');
const roots=[];function root(){const r=fs.mkdtempSync(path.join(os.tmpdir(),'abak-webps-mock-'));roots.push(r);return r;}
class Page extends EventEmitter{async goto(url){this.url=url;}async close(){this.emit('close');}}
class Context extends EventEmitter{constructor(){super();this.page=new Page();}pages(){return[this.page];}async route(pattern,fn){this.handler=fn;}async close(){if(this.failClose)throw Error('uncertain');this.emit('close');}}
(async()=>{
 const ctx=new Context(),calls=[];
 const browser={async launchPersistentContext(profile,options){calls.push({profile,options});return ctx;}};
 const c=new Controller(root(),browser);
 assert.throws(()=>urlFor('other'));assert.throws(()=>c.reserve('dashboard','bad'));assert.equal(calls.length,0);
 c.reserve('dashboard','MICHEL_DV1');assert(c.state.busy);assert.throws(()=>c.reserve('patient','MICHEL_DV1'));await c.operation;
 assert.equal(calls.length,1);assert.equal(ctx.page.url,BASE+'/AccesDirect/TableauDeBord');
 const second=new Controller(c.root,browser);assert(second.state.busy);assert.throws(()=>second.reserve('patient','MICHEL_DV1'));
 async function route(url,page){let outcome;await ctx.handler({request:()=>({url:()=>url,frame:()=>({page:()=>page})}),continue:()=>outcome='continue',abort:()=>outcome='abort'});return outcome;}
 assert.equal(await route(BASE+'/resource',ctx.page),'continue');
 for(const url of ['https://wps-cps.dmp.monespacesante.fr','https://evil.test',BASE+':444/path','http://wps-cps.dev1.dmp.gouv.fr', 'file:///tmp/example'])assert.equal(await route(url,ctx.page),'abort');
 assert.equal(await route(BASE,new Page()),'abort');
 const extra=new Page();let extraClosed=false;extra.close=async()=>{extraClosed=true;};ctx.emit('page',extra);await Promise.resolve();assert(extraClosed);
 await c.close();assert(!c.state.busy);assert(!fs.existsSync(c.lock));
 const cp=new Context();const p=new Controller(root(),{async launchPersistentContext(){return cp;}});
 p.reserve('patient','MICHEL_DV1');await p.operation;assert.equal(cp.page.url,BASE+'/AccesDirect/DossierPatient/187012425258307/1.2.250.1.213.1.4.10');
 cp.failClose=true;await p.close();assert(p.state.busy);assert(fs.existsSync(p.lock));cp.failClose=false;await p.close();
 const fail=new Controller(root(),{async launchPersistentContext(){throw Error('no browser');}});fail.reserve('dashboard','MICHEL_DV1');await fail.operation;assert(fail.state.busy);assert.throws(()=>fail.reserve('dashboard','MICHEL_DV1'));
 const crashCtx=new Context();const crash=new Controller(root(),{async launchPersistentContext(){return crashCtx;}});crash.reserve('dashboard','MICHEL_DV1');await crash.operation;crashCtx.emit('close');assert(crash.state.busy);assert(fs.existsSync(crash.lock));
 console.log('PASS: URL exactes, confirmation, réservation, concurrence, reprise verrou, filtrage domaine/page, popup, fermeture confirmée/incertaine, échec ouverture, arrêt inattendu. Navigateur entièrement simulé ; aucun réseau ni CPS.');
})().catch(e=>{console.error(e);process.exitCode=1;});
