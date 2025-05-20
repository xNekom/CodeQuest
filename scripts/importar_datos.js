// Script para importar datos a Firebase Firestore
const path = require('path');
const { spawn } = require('child_process');

console.log('Ejecutando script de importación de datos...');

// Ruta al script de importación
const importScriptPath = path.join(__dirname, '..', 'assets', 'data', 'import_all_data.js');

// Ejecutar el script usando node
const childProcess = spawn('node', [importScriptPath], {
  stdio: 'inherit' // Esto permite ver la salida del proceso hijo en la consola
});

childProcess.on('close', (code) => {
  if (code === 0) {
    console.log('¡Importación de datos completada correctamente!');
  } else {
    console.error(`El proceso de importación falló con código de salida ${code}`);
  }
});
