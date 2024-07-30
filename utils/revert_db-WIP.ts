import { exec, execSync } from 'child_process';
import * as readline from 'readline';

// Function to execute a command and return a promise
const executeCommand = (command: string): Promise<void> => {
  return new Promise((resolve, reject) => {
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error: ${stderr}`);
        reject(stderr);
      } else {
        console.log(stdout);
        resolve();
      }
    });
  });
};

// Function to prompt the user for input
const prompt = (question: string): Promise<string> => {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });
  return new Promise(resolve => rl.question(question, answer => {
    rl.close();
    resolve(answer);
  }));
};

// Function to open file dialog using PowerShell
const openFileDialog = (): string => {
  const script = `
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "SQL Backup Files (*.bak)|*.bak"
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
      $dialog.FileName
    }
  `;
  try {
    const result = execSync(`powershell -command "${script.replace(/\n/g, ';')}"`, { encoding: 'utf-8' });
    return result.trim();
  } catch (error) {
    console.error('Failed to open file dialog:', error);
    return '';
  }
};

(async () => {
  const SERVER = 'DYLANS';

  // Prompt for database name
  const DATABASE = await prompt('Enter the name of the database to restore: ');

  if (!DATABASE) {
    console.error('Database name cannot be empty. Exiting script.');
    process.exit(1);
  }

  // Open file dialog to select .bak file
  console.log('Select the .bak file to restore:');
  const FILE = openFileDialog();

  if (!FILE) {
    console.error('No file selected. Exiting script.');
    process.exit(1);
  }

  try {
    // Put the database in single user mode
    console.log(`Putting database ${DATABASE} in single user mode ...`);
    await executeCommand(`sqlcmd -S ${SERVER} -Q "ALTER DATABASE [${DATABASE}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;" -b -d master`);

    // Restore the database
    console.log(`Restoring database ${DATABASE} from ${FILE} ...`);
    await executeCommand(`sqlcmd -S ${SERVER} -Q "RESTORE DATABASE [${DATABASE}] FROM DISK='${FILE}' WITH REPLACE, RECOVERY;" -b -d master`);

    // Set the database back to multi-user mode
    console.log(`Putting database ${DATABASE} back in multi-user mode ...`);
    await executeCommand(`sqlcmd -S ${SERVER} -Q "ALTER DATABASE [${DATABASE}] SET MULTI_USER;" -b -d master`);

    console.log(`Database ${DATABASE} restored successfully from ${FILE}.`);
  } catch (error) {
    console.error(error);
  }

  process.exit(0);
})();
