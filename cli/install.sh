#!/bin/bash

SOURCE_DIR=$( cd "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BIN_DIR="${SOURCE_DIR}/bin"

if ! [[ "$PATH" == *"${BIN_DIR}"* ]]; then
    echo "export PATH=${PATH}:${BIN_DIR}" >> ~/.bashrc
    echo "export PATH=${PATH}:${BIN_DIR}" >> ~/.zshrc
fi