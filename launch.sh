#!/bin/bash

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is required but not installed. Please install it."
    exit 1
fi

# Check if Tkinter is installed
python3 -c "import tkinter" &> /dev/null
if [ $? -ne 0 ]; then
    echo "Tkinter is required but not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y python3-tk
fi

# Launch the GUI
python3 ./gui/main_gui.py
