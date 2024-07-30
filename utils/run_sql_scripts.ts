// External
import { execSync } from 'child_process';
import { readdirSync, writeFileSync, appendFileSync } from 'fs';
import path from 'path';
const moment = require('moment');
import readlineSync from 'readline-sync';
import { createDatabaseBackups, BackupOptions } from './backup-db';

// Variables & Constants
const datetime = moment().format('YYYY-MM-DD_HH-mm');
const SERVER = 'DYLANS\\MSSQLSERVER2022';
const NEEDLES_DB = 'NeedlesSLF';
const SA_DB = 'SANeedlesSLF';
const BASE_DIR = __dirname;
const SQL_SCRIPTS_DIR = path.resolve(BASE_DIR, '../sql-scripts/conv/');
const LOGS_DIR = path.join(BASE_DIR, '../logs');
const LOG_FILE = path.join(LOGS_DIR, `error_log_${datetime}.txt`);

// Function to log messages to the log file
function logMessage(message: string): void {
    appendFileSync(LOG_FILE, message + '\n');
}

// Function to run a SQL script
function runScript(scriptPath: string): void {
    const scriptName = path.basename(scriptPath);
    const outputFilePath = path.join(LOGS_DIR, `${scriptName}_${datetime}.out`);
    
    try {
        const result = execSync(`sqlcmd -S ${SERVER} -E -d ${SA_DB} -i "${scriptPath}" -b -h -1`, 
            { encoding: 'utf-8', stdio: 'pipe' });
        
        console.log(`SUCCESS - ${scriptName}`);
        logMessage(`SUCCESS - ${scriptName}`);
        logMessage(`    Timestamp: ${datetime}`);
        if (result) {
            logMessage(`n${result}`);
        }
        logMessage('---------------------------------------------------------------------------------------');
    } catch (error: any) {
        const errorOutput = (error.stdout || '').toString() + (error.stderr || '').toString();
        
        logMessage(`FAIL - ${scriptName}`);
        logMessage(`    Timestamp: ${datetime}`);
        logMessage(`    Output File: ${outputFilePath}`);
        
        writeFileSync(outputFilePath, errorOutput);
        console.error(`FAIL - ${scriptName}`);
    }
}

// Menu for script execution options
const menuOptions: { 
    [key: string]: { description: string, pattern: RegExp | null } 
} = {
    'A': { description: 'All', pattern: /^.*\.sql$/i },
    '0': { description: 'Initialize', pattern: /^0.*\.sql$/i },
    '1': { description: 'Contact', pattern: /^1.*\.sql$/i },
    '2': { description: 'Case', pattern: /^2.*\.sql$/i },
    '3': { description: 'UDF', pattern: /^3.*\.sql$/i },
    '4': { description: 'Misc', pattern: /^4.*\.sql$/i },
    '5': { description: 'Intake', pattern: /^5.*\.sql$/i },
    'P': { description: 'Post', pattern: /^post.*\.sql$/i },
    'Q': { description: 'Quit', pattern: null }
};

// Display menu and prompt user for choice
console.log('Select scripts to run:');
Object.keys(menuOptions).forEach(key => {
    console.log(`${key}. ${menuOptions[key].description}`);
});

const choice = readlineSync.question('Enter your choice: ').toUpperCase();
const selectedOption = menuOptions[choice];

if (selectedOption && selectedOption.pattern) {
    try {
        const allFiles = readdirSync(SQL_SCRIPTS_DIR);
        const files = allFiles.filter((file: string) => selectedOption.pattern!.test(file));

        if (files.length === 0) {
            console.log(`No scripts found for pattern: ${selectedOption.pattern}`);
        } else {
            files.forEach((file: string) => runScript(path.join(SQL_SCRIPTS_DIR, file)));
        }
    } catch (error: any) {
        console.error(`Error reading directory ${SQL_SCRIPTS_DIR}\n`, error.message);
    }
} else if (choice === 'Q') {
    console.log('Exiting script.');
} else {
    console.log('Invalid choice. Please try again.');
}

// Create db backups
if (choice !== 'Q') {
    createDatabaseBackups({
        databaseName1: SA_DB,
        // databaseName2: NEEDLES_DB,
        directory: path.join(BASE_DIR, '../backups'),
        step: selectedOption.description,
        server: SERVER
    });
}
