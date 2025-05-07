# SmartAdvocate Conversion Boilerplate
This repository serves as both the single source of truth for conversion scripts and a project boilerplate that includes all directories that [sa-conversion-utils](https://github.com/dylangetssmart/sa-conversion-utils) expects.
Scripts are documented in each system directory's respective Readme

## Quick Start
1. Select "use template" in the top right and create a new repository
2. Create a new repo and [clone it](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) locally
2. Delete folders for non-applicable legacy systems (e.g. delete /litify if you are not working on a Litify conversion)
3. _(optional)_ Install [sa-conversion-utils](https://github.com/dylangetssmart/sa-conversion-utils)
    - Instantiate python virtual environment
    - activate virtual environment
    - install sa-conversion-utils
4. Update SQL scripts
    - Update `'USE'` Directives
      - The boilerplate uses the following default database references:
      - `[SA]` to represent the target SA database
      - `[Needles]`- to represent the source Needles database

> [!TIP]
> Use a bulk replace function (such as VS Code's Replace in Folder)
> |Replace|With|
> |--|--|
> `[SA]`|`[<client_SA>]`
> `[Needles]`|`[<client_Needles>]`
> 
> ![image](https://github.com/user-attachments/assets/3517e142-123d-431a-bf54-ef5d7c5b9fea)

```bash
git clone <repo-url>
cd <project>              
python -m venv _venv      # creates python virtual environment for use with sa-conversion-utils
.\_venv\Scripts\activate  # activate virtual environment
pip install -e C:\LocalConv\sa-conversion-utils\  # install sa-conversion-utils
```

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
