#!/bin/bash
set -e

echo "Starting mainframe_operations.sh"

echo "Checking Java..."
java -version

if [ -z "$ZOWE_USERNAME" ]; then
  echo "ERROR: ZOWE_USERNAME is empty"
  exit 1
fi

echo "Going to local COBOL Check directory..."
cd cobol-check || {
  echo "ERROR: local cobol-check directory not found"
  exit 1
}

echo "Current directory:"
pwd
ls -al

echo "Making cobolcheck executable..."
chmod +x bin/cobolcheck || true
chmod +x cobolcheck || true

echo "Making test runner executable..."
chmod +x scripts/linux_gnucobol_run_tests || true

echo "Checking files:"
find . -maxdepth 3 -type f | head -50

echo "Mainframe operations script reached COBOL Check folder successfully"
