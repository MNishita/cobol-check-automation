#!/bin/bash
set -e

echo "Starting mainframe_operations.sh"

# Set up environment on z/OS USS
export PATH=$PATH:/usr/lpp/java/J8.0_64/bin
export JAVA_HOME=/usr/lpp/java/J8.0_64
export PATH=$PATH:/usr/lpp/zowe/cli/node/bin

echo "Checking Java..."
java -version

if [ -z "$ZOWE_USERNAME" ]; then
  echo "ERROR: ZOWE_USERNAME is empty"
  exit 1
fi

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

echo "Going to COBOL Check directory..."
cd "/z/$LOWERCASE_USERNAME/cobolcheck/cobol-check" || {
  echo "ERROR: Could not find /z/$LOWERCASE_USERNAME/cobolcheck/cobol-check"
  exit 1
}

echo "Current directory:"
pwd
ls -al

echo "Checking COBOL Check files..."
find . -maxdepth 3 -type f | head -50

echo "Making cobolcheck executable..."
chmod +x cobolcheck || true

echo "Making test runner executable..."
chmod +x scripts/linux_gnucobol_run_tests || true

run_cobolcheck() {
  program=$1
  echo "======================================"
  echo "Running COBOL Check for $program"
  echo "======================================"

  ./cobolcheck -p "$program" || true

  echo "COBOL Check finished for $program"

  if [ -f "CC##99.CBL" ]; then
    echo "Found CC##99.CBL. Copying to ${ZOWE_USERNAME}.CBL(${program})..."
    cp CC##99.CBL "//'${ZOWE_USERNAME}.CBL(${program})'"
    echo "Copied CC##99.CBL to ${ZOWE_USERNAME}.CBL(${program})"
  else
    echo "WARNING: CC##99.CBL not found for $program"
  fi

  if [ -f "${program}.JCL" ]; then
    echo "Found ${program}.JCL. Copying to ${ZOWE_USERNAME}.JCL(${program})..."
    cp "${program}.JCL" "//'${ZOWE_USERNAME}.JCL(${program})'"
    echo "Copied ${program}.JCL to ${ZOWE_USERNAME}.JCL(${program})"
  else
    echo "WARNING: ${program}.JCL not found"
  fi
}

for program in NUMBERS EMPPAY DEPTPAY
do
  run_cobolcheck "$program"
done

echo "Mainframe operations completed"
