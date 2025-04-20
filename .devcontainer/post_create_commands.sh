#!/bin/bash
# shellcheck disable=SC1091,SC2059

sed -i 's/\r$//' /workspaces/python/cli/bin/template-python-devcontainer
chmod +x /workspaces/template-python-devcontainer/cli/bin/template-python-devcontainer
git config --global --add safe.directory /workspaces/template-python-devcontainer
gcloud auth application-default login

FILE="./.devcontainer/git_config.sh"
if [ -f "$FILE" ]; then
    chmod +x "$FILE"
    "$FILE"
else
    echo "$FILE not found. Follow instructions in README.md to set up git config. ### Configure Git"
fi