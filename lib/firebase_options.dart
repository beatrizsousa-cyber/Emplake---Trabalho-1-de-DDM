import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Opções de configuração do Firebase para o Emplake.
///
/// O trabalho é entregue para a WEB, então só existe a configuração web.
/// (As chaves de um app web do Firebase são públicas por natureza: quem
/// protege os dados são as regras do Firestore, em firestore.rules.)
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAFiYKa2XOgyaqcKRXQ1ygEBcf9C5XEWd8',
    appId: '1:170845795672:web:4af1885c409ed89ccaa12d',
    messagingSenderId: '170845795672',
    projectId: 'emplake-app',
    authDomain: 'emplake-app.firebaseapp.com',
    storageBucket: 'emplake-app.firebasestorage.app',
    measurementId: 'G-BCSNJFRRPY',
  );
}
