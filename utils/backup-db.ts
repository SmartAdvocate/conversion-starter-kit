import { execSync } from 'child_process';
import * as path from 'path';
const moment = require('moment')

interface BackupOptions {
    directory: string;
    step: string;
    databaseName1: string;
    server: string;
    // databaseName2: string;
}

const createDatabaseBackups = (options: BackupOptions): void => {
    const { directory, step, databaseName1, server } = options;
    const timestamp = moment().format('YYYY-MM-DD_HH-mm');
    const backupPath1 = path.join(directory, `${databaseName1}-after-${step}_${timestamp}.bak`);
    // const backupPath2 = path.join(directory, `${databaseName2}-after-${step}_${timestamp}.bak`);
  
    const backupCommand1 = `sqlcmd -S ${server} -Q "BACKUP DATABASE [${databaseName1}] TO DISK = '${backupPath1}' WITH FORMAT, INIT, NAME = '${databaseName1} Full Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10"`;
    // const backupCommand2 = `sqlcmd -Q "BACKUP DATABASE [${databaseName2}] TO DISK = '${backupPath2}' WITH FORMAT, INIT, NAME = '${databaseName2} Full Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10"`;
  
    try {
      execSync(backupCommand1);
      console.log(`Backup for ${databaseName1} completed successfully at ${directory}.`);
    } catch (error) {
      console.error(`Error backing up database ${databaseName1}:`, error);
    }
  
    // try {
    //   execSync(backupCommand2);
    //   console.log(`Backup for ${databaseName2} completed successfully at ${directory}.`);
    // } catch (error) {
    //   console.error(`Error backing up database ${databaseName2}:`, error);
    // }
  }
  
  export { createDatabaseBackups, BackupOptions };