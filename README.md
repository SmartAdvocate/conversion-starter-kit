# SmartAdvocate Conversion Boilerplate
This repository serves as both the single source of truth for conversion scripts and a project boilerplate that includes all directories that sa-conversion-utils expects.
Scripts are documented in each system directory's respective Readme

## Quick Start
1. Use Template
2. Delete folders for non-applicable legacy systems

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
