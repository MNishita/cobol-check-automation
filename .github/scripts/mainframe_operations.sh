#!/bin/bash
# mainframe_operations.sh

# Set up environment
export PATH=$PATH:/usr/lpp/java/J8.0_64/bin
export JAVA_HOME=/usr/lpp/java/J8.0_64
export PATH=$PATH:/usr/lpp/zowe/cli/node/bin

# Check Java availability
java -version

# Set ZOWE_USERNAME
ZOWE_USERNAME="Z88453"

# Go to COBOL Check directory
cd cobolcheck || {
  echo "ERROR: cobolcheck directory not found"
  exit 1
}

echo "Changed to $(pwd)"
ls -al

# Make cobolcheck executable
chmod +x cobolcheck
echo "Made cobolcheck executable"

# Make test runner executable
cd scripts || {
  echo "ERROR: scripts directory not found"
  exit 1
}

chmod +x linux_gnucobol_run_tests
echo "Made linux_gnucobol_run_tests executable"

cd ..

#Function to run cobolcheck and copy files
run_cobolcheck() {
  program=$1
  echo "Running COBOL Check for $program"
  
  ./cobolcheck -p "$program"
  
  echo "COBOL Check execution completed for $program"
  
  # Copy generated COBOL file to your CBL PDS
  if [ -f "CC##99.CBL" ]; then
    cp CC##99.CBL "//'${ZOWE_USERNAME}.CBL(${program})'"

    if [ $? -eq 0 ]; then
      echo "Copied CC##99.CBL to ${ZOWE_USERNAME}.CBL(${program})"
    else
      echo "ERROR: Failed to copy CC##99.CBL to ${ZOWE_USERNAME}.CBL(${program})"
    fi
  else
    echo "ERROR: CC##99.CBL not found for $program"
  fi
  
# Copy the JCL file if it exists
if [ -f "${program}.JCL" ]; then
  cp "${program}.JCL" "//'${ZOWE_USERNAME}.JCL(${program})'";

  if [ $? -eq 0 ]; then
    echo "Copied ${program}.JCL to ${ZOWE_USERNAME}.JCL(${program})"
  else
    echo "Failed to copy ${program}.JCL to ${ZOWE_USERNAME}.JCL(${program})"
  fi
else
  echo "${program}.JCL not found"
fi
}

#Run for each program
for program in NUMBERS EMPPAY DEPTPAY
do
  run_cobolcheck "$program"
done

echo "Mainframe operations completed"
