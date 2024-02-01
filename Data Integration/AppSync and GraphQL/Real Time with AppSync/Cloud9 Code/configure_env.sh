#!/bin/bash

#
# Copyright 2023 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

#title           configure_env.sh
#summary         This script configures a users environment if they are just doing the Going Further modules.
#description     This script configures a users environment if they are just doing the Going Further modules.
#author          Kim Wendt (@kwwendt)
#date            2023-05-15
#version         1.1
#usage           sh configure_env.sh
#==============================================================================

# Function for Sample Data set up
function sample_data_going_further () {
  if [ ! -d "~/environment/sample_data" ]; then
    cd ~/environment
    unzip -o sample_data.zip -d sample_data
    rm sample_data.zip
  fi
}

function init_code_setup() {
  git config --global user.name "Cloud9 User"
  git config --global user.email $1
  
  cd ~/environment/AnyCompanyReads-backend
  npm install
  
  cdk bootstrap

  cd ~/environment/AnyCompanyReads-frontend
  npm install --loglevel error
}

function update_backend_code() {
  cd ~/environment
  unzip -o $1 -d AnyCompanyReads-backend
  rm $1
}

function update_frontend_code() {
  cd ~/environment
  unzip -o $1 -d AnyCompanyReads-frontend
  rm $1
}

function deploy_backend_stack() {
  source ~/.bash_profile 
  cd ~/environment/AnyCompanyReads-backend
  cdk deploy AnyCompanyReadsBackendStack -O output.json --require-approval never >&2
}

function deploy_enterprise_stacks() {
  source ~/.bash_profile 
  cd ~/environment/AnyCompanyReads-backend
  cdk deploy AnyCompanyReadsBackendStack AnyCompanyReadsVpcStack \
    AnyCompanyReadsRdsStack AnyCompanyReadsRdsApiStack AnyCompanyReadsRESTApiStack \
    AnyCompanyReadsMicroservicesApiStack AnyCompanyReadsMergedApiStack \
    AnyCompanyReadsPrivateApiStack AnyCompanyReadsInventoryAppStack \
    -O enterprise-output.json --require-approval never
}

function update_exports_file() {
  cd ~/environment/AnyCompanyReads-frontend
  cp ~/environment/AnyCompanyReads-backend/$1 .
  cat << EOF > src/aws-exports.js
const awsmobile = {
  aws_appsync_apiKey: '`jq -r .AnyCompanyReadsBackendStack.GraphQLAPIKEY $1`',
  aws_appsync_authenticationType: 'API_KEY',
  aws_appsync_region: '`jq -r .AnyCompanyReadsBackendStack.STACKREGION $1`',
  aws_appsync_graphqlEndpoint: '`jq -r .AnyCompanyReadsBackendStack.GraphQLAPIURL $1`',
  aws_cognito_region: '`jq -r .AnyCompanyReadsBackendStack.STACKREGION $1`',
  aws_user_pools_id: '`jq -r .AnyCompanyReadsBackendStack.USERPOOLSID $1`',
  aws_user_pools_web_client_id: '`jq -r .AnyCompanyReadsBackendStack.USERPOOLSWEBCLIENTID $1`'
}

export default awsmobile
EOF
}

function update_exports_file_realtime() {
  cd ~/environment/AnyCompanyReads-frontend
  cp ~/environment/AnyCompanyReads-backend/$1 .
  cat << EOF > src/aws-exports.js
const awsmobile = {
  aws_appsync_apiKey: '`jq -r .AnyCompanyReadsMergedApiStack.MergedApiGraphQLAPIKey $1`',
  aws_appsync_authenticationType: 'API_KEY',
  aws_appsync_region: '`jq -r .AnyCompanyReadsBackendStack.STACKREGION $1`',
  aws_appsync_graphqlEndpoint: '`jq -r .AnyCompanyReadsMergedApiStack.MergedApiGraphQLAPIURL $1`',
  aws_cognito_region: '`jq -r .AnyCompanyReadsBackendStack.STACKREGION $1`',
  aws_user_pools_id: '`jq -r .AnyCompanyReadsBackendStack.USERPOOLSID $1`',
  aws_user_pools_web_client_id: '`jq -r .AnyCompanyReadsBackendStack.USERPOOLSWEBCLIENTID $1`'
}

export default awsmobile
EOF
}

function deploy_frontend_stack() {
  source ~/.bash_profile 
  echo "Push frontend changes - estimated time to completion: 2 minutes" >&2
  git add .
  git commit -m "Frontend code updates"
  git push origin main

  echo "Deploy frontend stack - estimated time to completion: <1 minute" >&2
  cd ~/environment/AnyCompanyReads-backend
  cdk deploy AnyCompanyReadsFrontendStack -O frontend-output.json --require-approval never >&2
}

function register_admin_user() {
  cd ~/environment/AnyCompanyReads-backend
  USER_POOL_ID=`jq -r .AnyCompanyReadsBackendStack.USERPOOLSID $2`
  aws cognito-idp admin-create-user --user-pool-id $USER_POOL_ID \
    --username admin \
    --user-attributes Name=email,Value=$1 >&2
}

function is_frontend_deployed() {
  cd ~/environment/AnyCompanyReads-backend
  APP_URL=`jq -r .AnyCompanyReadsFrontendStack.AmplifyAppUrl ./frontend-output.json`
  APP_ID=`jq -r .AnyCompanyReadsFrontendStack.AmplifyAppID ./frontend-output.json`
  BRANCH_NAME=`jq -r .AnyCompanyReadsFrontendStack.AmplifyAppBranch ./frontend-output.json`
  STATUS=$(aws amplify list-jobs --app-id $APP_ID --branch-name $BRANCH_NAME --query "jobSummaries[0].status")
  STATUS=$(sed -e 's/^"//' -e 's/"$//' <<< $STATUS)

  while [ $STATUS != "SUCCEED" ]
  do
    echo 'Waiting for AnyCompany Reads frontend application to fully deploy. This can take around 5 minutes, polling every 30 seconds' >&2
    sleep 30
    STATUS=$(aws amplify list-jobs --app-id $APP_ID --branch-name $BRANCH_NAME --query "jobSummaries[0].status")
    STATUS=$(sed -e 's/^"//' -e 's/"$//' <<< $STATUS)
  done
}

# Function for Enterprise continuing on
function enterprise_continue_on () {
  cd ~/environment
  sample_data_going_further
  unzip -o appsync-backend-enterprise-starter.zip -d AnyCompanyReads-backend
  rm appsync-backend-enterprise-starter.zip
}

# Function for Enterprise starting fresh
function enterprise_starting_fresh () {
  sample_data_going_further
  init_code_setup $1
  update_backend_code appsync-backend-core-completed.zip
  update_frontend_code appsync-frontend-core-completed.zip
  deploy_backend_stack
  update_exports_file ./output.json
  deploy_frontend_stack
  register_admin_user $1 ./output.json
  enterprise_continue_on
  is_frontend_deployed
  echo -e '\n\nSetup is complete\n\n' >&2
  echo "Navigate to the AnyCompany Reads URL to complete your user sign up: https://$APP_URL" >&2
}

# Function for Real-time continuing on
function realtime_continue_unzip() {
  cd ~/environment
  unzip -o appsync-backend-realtime-starter.zip -d AnyCompanyReads-backend
  rm appsync-backend-realtime-starter.zip

  unzip -o appsync-frontend-realtime-starter.zip -d AnyCompanyReads-frontend
  rm appsync-frontend-realtime-starter.zip
}

function realtime_continue_on() {
  realtime_continue_unzip
  cd ~/environment/AnyCompanyReads-backend
  cdk deploy AnyCompanyReadsBackendStack AnyCompanyReadsMergedApiStack \
    -O enterprise-output.json --require-approval never
  update_exports_file_realtime ./enterprise-output.json
}

# Function for Real-time starting fresh
function realtime_starting_fresh () {
  sample_data_going_further
  init_code_setup $1
  update_backend_code appsync-backend-core-completed.zip
  update_frontend_code appsync-frontend-core-completed.zip
  update_backend_code appsync-backend-enterprise-completed.zip
  deploy_enterprise_stacks
  update_exports_file_realtime ./enterprise-output.json
  deploy_frontend_stack
  register_admin_user $1 ./enterprise-output.json
  realtime_continue_unzip
  is_frontend_deployed
  echo -e '\n\nSetup is complete\n\n' >&2
  echo "Navigate to the AnyCompany Reads URL to complete your user sign up: https://$APP_URL" >&2
}

section=$1
config=$2
emailInput=$3

source ~/.bash_profile 

if [[ "$section" = "enterprise" ]]; then
  if [[ "$config" = "continue" ]]; then
    enterprise_continue_on
  elif [[ "$config" = "start" ]]; then
    echo "Deploying Enterprise - starting fresh setup code. This will take approximately 7 minutes to complete." >&2
    enterprise_starting_fresh $emailInput
  else
    echo "Invalid argument. Please specify either continue or start for your second positional argument." >&2
  fi
elif [[ "$section" = "realtime" ]]; then
  if [[ "$config" = "continue" ]]; then
    realtime_continue_on
  elif [[ "$config" = "start" ]]; then
    echo "Deploying Real-time - starting fresh setup code. This will take approximately 36 minutes to complete." >&2
    realtime_starting_fresh $emailInput
  else
    echo "Invalid argument. Please specify either continue or start for your second positional argument." >&2
  fi
else
  echo "Invalid argument. Please specify either enterprise or realtime for your first positional argument." >&2
fi