import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_pdf_cda_isolated/native_archive.dart';
import 'package:abak_desktop_companion/features/dmp_pdf_cda_isolated/native_archive_screen.dart';
Future<void> main() async {
 final binding=WidgetsFlutterBinding.ensureInitialized(); final ctl=LiveWidgetController(binding);
 final out=Directory(Platform.environment['NATIVE_OUTPUT']!)..createSync(recursive:true);
 final assets=Directory(Platform.environment['NATIVE_ASSETS']!);
 Future<List<int>> loader(String n) async=>File('${assets.path}/$n').readAsBytesSync();
 final root=Directory('${out.path}/store');final passed=<String>[];final errors=<String>[];
 FlutterError.onError=(e)=>errors.add(e.toString());
 void check(bool value,String name){if(!value)throw StateError(name);passed.add(name);}
 Future<void> settle() async{for(var i=0;i<12;i++){await ctl.pump(const Duration(milliseconds:50));}}
 Future<void> mount() async{runApp(const SizedBox.shrink());await settle();runApp(MaterialApp(home:NativeArchiveScreen(simulationRoot:root,loader:loader)));await settle();}
 bool enabled(String key)=>ctl.widget<FilledButton>(find.byKey(Key(key))).onPressed!=null;
 await mount();
 check(enabled('record'),'positif accessible');
 ctl.widget<FilledButton>(find.byKey(const Key('record'))).onPressed!();await settle();await mount();
 check(!enabled('record'),'examen conservé après recréation écran');
 final model=NativeArchive(root,loader);await model.open();check(model.examined,'examen relu depuis journal');
 for(final entry in model.cases){
  final id=entry['id'] as String;
  ctl.widget<DropdownButton<String>>(find.byKey(const Key('scenario'))).onChanged!(id);await settle();
  final expectedPdf = ['sans_xmp','sans_profil_couleur','police_non_incorporee','action_javascript'].contains(id) ? 'Non conforme' : ['chiffre','tronque'].contains(id) ? 'Non vérifié' : 'Conforme';
  check(ctl.widget<Text>(find.byKey(const Key('pdf-status'))).data!.contains(expectedPdf),'message PDF $id');
  final expectedCda=id=='sans_patient'?'Non conforme':['positif','blanc','entete','contenu_modifie'].contains(id)?'Conforme':'Non évalué';
  check(ctl.widget<Text>(find.byKey(const Key('cda-status'))).data!.contains(expectedCda),'message CDA $id');
  check(enabled('record')==(['positif','contenu_modifie'].contains(id)),'blocage $id');
  check(!enabled('send'),'envoi bloqué $id');
  await mount();
  check(ctl.widget<DropdownButton<String>>(find.byKey(const Key('scenario'))).value==id,'sélection persistée $id');
  final reread=NativeArchive(root,loader);await reread.open();check(!reread.examined,'aucune approbation héritée $id');
 }
 await model.select('positif');await model.record();await model.select('contenu_modifie');check(!model.examined,'modification réinitialise examen');
 final bad=NativeArchive(Directory('${out.path}/bad'),(n) async=>n.endsWith('pdf_report.xml')?[0]:loader(n));
 bool rejected=false;try{await bad.open();}catch(_){rejected=true;}check(rejected,'preuve altérée refusée');
 File('${root.path}/journal.json').writeAsStringSync('{}');await mount();check(find.byKey(const Key('failure')).evaluate().isNotEmpty,'journal altéré bloque écran');check(!enabled('send'),'journal altéré interdit envoi');
 check(errors.isEmpty,'aucune erreur Flutter');
 File('${out.path}/Resultats.json').writeAsStringSync(jsonEncode({'passed':passed.length,'checks':passed,'calls':0,'network':'denied by sandbox','errors':errors}));exit(0);
}
