#!/bin/bash

# Navigate to the script's directory
cd "$(dirname "$0")"

echo "----------------------------------------------------------------------"
echo "Checking Prerequisites..."
echo "----------------------------------------------------------------------"

if ! command -v node &> /dev/null; then
    echo ""
    echo "[INFO] Node.js is not installed. Attempting automatic installation..."
    echo ""

    if ! command -v curl &> /dev/null; then
        echo "[ERROR] curl is required for automatic Node.js installation but was not found."
        echo "Please install curl (e.g. sudo apt install curl) or install Node.js manually from: https://nodejs.org/"
        echo ""
        exit 1
    fi

    NODE_INSTALLED=0

    # Fetch the latest Node.js major version number from the release index
    NODE_MAJOR=$(curl -fsSL https://nodejs.org/dist/index.json | grep -o '"version":"v[0-9]*' | head -1 | grep -o '[0-9]*$')
    if [ -z "$NODE_MAJOR" ]; then
        echo "[WARN] Could not determine latest Node.js version. Defaulting to current channel."
        NODE_MAJOR="current"
    fi
    echo "Latest Node.js major version: $NODE_MAJOR"

    # Try package managers in order of preference
    if command -v apt-get &> /dev/null; then
        echo "Detected apt-get (Debian/Ubuntu). Installing Node.js..."
        curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | sudo -E bash - && \
        sudo apt-get install -y nodejs && NODE_INSTALLED=1

    elif command -v dnf &> /dev/null; then
        echo "Detected dnf (Fedora/RHEL). Installing Node.js..."
        curl -fsSL "https://rpm.nodesource.com/setup_${NODE_MAJOR}.x" | sudo bash - && \
        sudo dnf install -y nodejs && NODE_INSTALLED=1

    elif command -v yum &> /dev/null; then
        echo "Detected yum (CentOS/RHEL). Installing Node.js..."
        curl -fsSL "https://rpm.nodesource.com/setup_${NODE_MAJOR}.x" | sudo bash - && \
        sudo yum install -y nodejs && NODE_INSTALLED=1

    elif command -v pacman &> /dev/null; then
        echo "Detected pacman (Arch Linux). Installing Node.js..."
        sudo pacman -Sy --noconfirm nodejs npm && NODE_INSTALLED=1

    elif command -v zypper &> /dev/null; then
        echo "Detected zypper (openSUSE). Installing Node.js..."
        sudo zypper install -y nodejs npm && NODE_INSTALLED=1

    elif command -v brew &> /dev/null; then
        echo "Detected Homebrew. Installing Node.js..."
        brew install node && NODE_INSTALLED=1

    else
        echo "[ERROR] No supported package manager found (apt, dnf, yum, pacman, zypper, brew)."
        echo "Please install Node.js manually from: https://nodejs.org/"
        echo ""
        exit 1
    fi

    if [ "$NODE_INSTALLED" -ne 1 ]; then
        echo ""
        echo "[ERROR] Node.js installation failed."
        echo "Please install Node.js manually from: https://nodejs.org/"
        echo ""
        exit 1
    fi

    if ! command -v node &> /dev/null; then
        echo ""
        echo "[ERROR] Node.js still not found after installation."
        echo "Try opening a new terminal and running this script again."
        echo ""
        exit 1
    fi
fi

echo "Node.js detected."
echo ""

# ----------------------------------------------------------------------
# Detect a supported Python interpreter (3.10 - 3.13).
# torch==2.7.0 has no wheels for Python 3.14+, so we must avoid that even
# when it is the default "python3". We first probe the explicit versioned
# binaries (python3.13 ... python3.10), then fall back to python3/python
# only if they fall inside the supported range.
# ----------------------------------------------------------------------
PYTHON_CMD=""

# Helper: returns 0 if "$1 --version" reports a supported 3.10-3.13 interpreter.
py_is_supported() {
    local cmd="$1"
    command -v "$cmd" &> /dev/null || return 1
    local major minor
    major=$("$cmd" -c "import sys; print(sys.version_info.major)" 2>/dev/null) || return 1
    minor=$("$cmd" -c "import sys; print(sys.version_info.minor)" 2>/dev/null) || return 1
    [ "$major" -eq 3 ] && [ "$minor" -ge 10 ] && [ "$minor" -lt 14 ]
}

# Prefer explicit versioned interpreters, newest supported first.
for candidate in python3.13 python3.12 python3.11 python3.10; do
    if py_is_supported "$candidate"; then
        PYTHON_CMD="$candidate"
        break
    fi
done

# Fall back to the generic python3/python only if they are in range.
if [ -z "$PYTHON_CMD" ]; then
    for candidate in python3 python; do
        if py_is_supported "$candidate"; then
            PYTHON_CMD="$candidate"
            break
        fi
    done
fi

if [ -z "$PYTHON_CMD" ]; then
    echo ""
    if command -v python3 &> /dev/null; then
        FOUND_VER=$(python3 -c "import sys; print('%d.%d' % sys.version_info[:2])" 2>/dev/null)
        echo "[ERROR] No supported Python found (3.10 - 3.13 required). Default python3 is $FOUND_VER."
    else
        echo "[ERROR] Python is not installed!"
    fi
    echo "Please install Python 3.10 - 3.13 from: https://www.python.org/downloads/"
    echo "(On Linux you can usually install e.g. python3.12; this script will then pick it up automatically.)"
    echo ""
    exit 1
fi

PY_VER=$("$PYTHON_CMD" -c "import sys; print('%d.%d' % sys.version_info[:2])")
echo "Using $PYTHON_CMD ($PY_VER)..."

if [ ! -d "venv" ]; then
    echo "Creating venv..."
    $PYTHON_CMD -m venv venv
    if [ $? -ne 0 ]; then
        echo ""
        echo "[ERROR] Failed to create virtual environment."
        echo ""
        exit 1
    fi
else
    echo "Venv already exists."
fi

# Activate venv
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    if [ $? -ne 0 ]; then
        echo ""
        echo "[ERROR] Failed to activate virtual environment."
        echo "Try deleting the venv folder and running this script again."
        echo ""
        exit 1
    fi
else
    echo ""
    echo "[ERROR] venv/bin/activate not found!"
    echo "Try deleting the venv folder and running this script again."
    echo ""
    exit 1
fi

echo "----------------------------------------------------------------------"
echo "Installing requirements from requirements.txt..."
echo "----------------------------------------------------------------------"
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo ""
    echo "[ERROR] pip install failed."
    echo "Check the output above for details."
    echo ""
    exit 1
fi

echo ""
echo "----------------------------------------------------------------------"
echo "Installing UI dependencies (npm install)..."
echo "----------------------------------------------------------------------"
cd training-ui
npm install
if [ $? -ne 0 ]; then
    echo ""
    echo "[ERROR] npm install failed."
    echo "Check the output above for details."
    echo ""
    cd ..
    exit 1
fi
cd ..

echo ""
echo "----------------------------------------------------------------------"
echo "Installation Complete!"
echo "----------------------------------------------------------------------"
