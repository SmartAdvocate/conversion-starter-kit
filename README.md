# SmartAdvocate Conversion Boilerplate
This repository serves as both the single source of truth for conversion scripts and a project boilerplate that includes all directories that [sa-conversion-utils](https://github.com/dylangetssmart/sa-conversion-utils) expects.
Scripts are documented in each system directory's respective Readme

## Quick Start
Select "use template" in the top right and create a new repository.
### Use Template
1. Use Template


### Project Setup
2. Delete folders for non-applicable legacy systems
3. 
```bash
git clone <repo-url>
cd <project>              
python -m venv _venv      # creates python virtual environment for use with sa-conversion-utils
.\_venv\Scripts\activate  # activate virtual environment
pip install -e C:\LocalConv\sa-conversion-utils\  # install sa-conversion-utils
```

### Update `'USE'` Directives
The boilerplate uses the following default database references:
- `[SA]` to represent the target SA database
- `[Needles]`- to represent the source Needles database

Use a bulk replace function (such as VS Code's Replace in Folder)
|Replace|With|
|--|--|
`[SA]`|`[<client_SA>]`
`[Needles]`|`[<client_Needles>]`

![image](https://github.com/user-attachments/assets/3517e142-123d-431a-bf54-ef5d7c5b9fea)


## Methodology

## Workspace Directories
| Directory | Sub Directory | Purpose |
| -- | -- | -- |
_lib | |
||post-scripts|SQL scripts to be run after conversion scripts|
||python|python scripts to generate readme files|
||wipe-data|SQL scripts to wipe transactional data|
_trans | | General use transfer directory
_venv | | Python virtual environment
.github | | Github actions
backups | | Database backups
data | | Source data
logs | | Log files

## Source System Directories
litify
needles
