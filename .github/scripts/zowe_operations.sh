#!/bin/bash
set -e

echo "Starting zowe_operations.sh"

echo "Checking Zowe CLI..."
zowe --version

echo "Checking username variable..."
if [ -z "$ZOWE_USERNAME" ]; then
  echo "ERROR: ZOWE_USERNAME is empty"
  exit 1
fi

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
echo "Using USS path: /z/$LOWERCASE_USERNAME/cobolcheck"

echo "Checking local cobol-check folder..."
ls -al
ls -al ./cobol-check || {
  echo "ERROR: ./cobol-check folder not found"
  exit 1
}

echo "Testing mainframe connection..."
timeout 60 zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME" || {
  echo "ERROR: Zowe connection failed or timed out"
  exit 1
}

echo "Checking if USS directory exists..."
if ! timeout 60 zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" &>/dev/null; then
  echo "Directory does not exist. Creating it..."
  timeout 60 zowe zos-files create uss-directory "/z/$LOWERCASE_USERNAME/cobolcheck"
else
  echo "Directory already exists."
fi

echo "Uploading COBOL Check files..."
timeout 300 zowe zos-files upload dir-to-uss "./cobol-check" "/z/$LOWERCASE_USERNAME/cobolcheck" --recursive --binary-files "cobol-check-0.2.9.jar" --overwrite

echo "Verifying upload..."
timeout 60 zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck"

echo "zowe_operations.sh completed successfully"
