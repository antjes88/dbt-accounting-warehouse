#!/bin/bash

set -e

printf "\n \e[32mSetting up Python environment...\e[0m\n"
rm -rf venv
python3.10 -m venv ./venv
source ./venv/bin/activate
printf "\n \e[32mPython environment created.\e[0m\n"

printf "\n \e[32mInstalling Python packages...\e[0m\n"
pip install --upgrade pip
pip install -r requirements.txt
dbt deps
if [ "$ISDEVCONTAINER" == "true" ]; then
    pip install -r dev-requirements.txt    
    pip install pipx
    pipx ensurepath
    pipx install sqlfmt==0.0.3
fi
printf "\n \e[32mPython packages installed.\e[0m\n"
