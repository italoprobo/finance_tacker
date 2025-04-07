import { mkdir } from 'fs/promises';
import { join } from 'path';

async function createUploadsDirectory() {
  const uploadsPath = join(__dirname, '../../uploads/profile-images');
  try {
    await mkdir(uploadsPath, { recursive: true });
    console.log('Diretório de uploads criado com sucesso!');
  } catch (error) {
    console.error('Erro ao criar diretório de uploads:', error);
  }
}

createUploadsDirectory();