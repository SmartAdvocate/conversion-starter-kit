# SmartAdvocate Conversion Starter Kit
This repository serves as both the single source of truth for standardized conversion scripts and as a conversion project starter kit that includes all directories expected by [sa-conversion-utils](https://github.com/dylangetssmart/sa-conversion-utils).
Scripts are documented in each system directory's respective Readme

## Quick Start
### Project setup
1. Select "use template" in the top right and create a new repository
2. [Clone the repository into your working directory](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)
```bash
cd c:\my-conversion-projects
git clone <repo-url> <client-name> # a folder named <client-name> will be created 
cd <client-name>
```
3. Delete folders for non-applicable legacy systems (e.g. delete `/litify` if you are not working on a Litify conversion)
4. _(optional)_ Install [sa-conversion-utils](https://github.com/dylangetssmart/sa-conversion-utils)
    - Instantiate python virtual environment
    - activate virtual environment
    - install sa-conversion-utils
```bash
python -m venv .venv      # creates python virtual environment ".venv"
.\.venv\Scripts\activate  # activate virtual environment
pip install git+https://github.com/dylangetssmart/sa-conversion-utils.git
```
### Update SQL script database references
> [!NOTE]
> SQL scripts in this starter kit reference the target SA database with `[SA]` and the source database with `[<source-system]` (ex: `[Needles]`)

Use a bulk replace function (such as VS Code's Replace in Folder)
|Replace|With|
|--|--|
`[SA]`|`[<client_SA>]`
`[Needles]`|`[<client_Needles>]`

![image](https://github.com/user-attachments/assets/3517e142-123d-431a-bf54-ef5d7c5b9fea)

## Directories
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
