#!/usr/bin/env bash

###############################################################################
###### Bootstrap
###############################################################################

# ensure jq is available
TEST_JQ=`hash jq`
if [ $? -eq 1 ]; then
	echo -e "jq is required to run the cli tests. Get jq from https://stedolan.github.io/jq/"
	exit 1
fi

# pass parameters in the following order: 
# $ bin/test-cli.sh <SCOPE> <CLIENT_ID> <CLIENT_SECRET> <USER> <USER_PW> <HOST> <SANDBOX_REALM>

# mapping input parameters
ARG_SCOPE=$1
ARG_CLIENT_ID=$2
ARG_CLIENT_SECRET=$3
ARG_USER=$4
ARG_USER_PW=$5
ARG_HOST=$6
ARG_SANDBOX_REALM=$7

# scope of tests, either 'minimal' or 'full'
if [ $ARG_SCOPE = "minimal" ]; then
	echo -e "Running default test scope with limited coverage of commands and options..."
elif [ $ARG_SCOPE = "full" ]; then
	echo -e "Running full test scope with maximum coverage of commands and options..."
else
	echo -e "Unknown test scope $ARG_SCOPE. Please provide either 'minimal' or 'full'."
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci´
###############################################################################

echo "Testing command ´sfcc-ci´ without command and option:"
node ./cli.js
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci´ without command and --help option:"
node ./cli.js --help
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci´ without command and --version option:"
node ./cli.js --version
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci´ and unknown command (expected to fail):"
node ./cli.js unknown
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci client:auth´
###############################################################################

echo "Testing command ´sfcc-ci client:auth´ without option:"
node ./cli.js client:auth "$ARG_CLIENT_ID" "$ARG_CLIENT_SECRET"
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci client:auth´ with valid client, but invalid user credentials (expected to fail):"
node ./cli.js client:auth "$ARG_CLIENT_ID" "$ARG_CLIENT_SECRET" "foo" "bar"
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci client:auth´ with valid client and user credentials:"
node ./cli.js client:auth "$ARG_CLIENT_ID" "$ARG_CLIENT_SECRET" "$ARG_USER" "$ARG_USER_PW"
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci client:auth:token´
###############################################################################

echo "Testing command ´sfcc-ci client:auth:token´:"
TEST_RESULT=`node ./cli.js client:auth:token`
if [ $? -eq 0 ] && [ ! -z "$TEST_RESULT" ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci client:renew´
###############################################################################

echo "Testing command ´sfcc-ci client:renew´ (expected to fail):"
node ./cli.js client:auth:renew
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci client:auth´ with --renew option:"
node ./cli.js client:auth $ARG_CLIENT_ID $ARG_CLIENT_SECRET --renew
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci client:renew´ (expected to succeed):"
node ./cli.js client:auth:renew
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci auth:logout´
###############################################################################

echo "Testing command ´sfcc-ci auth:logout´:"
node ./cli.js auth:logout
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci instance:clear´
###############################################################################

echo "Testing command ´sfcc-ci instance:add´ (without alias):"
node ./cli.js instance:add $ARG_HOST
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci instance:clear´:"
node ./cli.js instance:clear
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci instance:add´
###############################################################################

echo "Testing command ´sfcc-ci instance:add´ (with alias):"
node ./cli.js instance:add $ARG_HOST my
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci instance:add´ with invalid instance (expected to fail):"
node ./cli.js instance:add my-instance.demandware.net
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci instance:add´:"
node ./cli.js instance:add $ARG_HOST someotheralias
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci instance:set´
###############################################################################

echo "Testing command ´sfcc-ci instance:set´ with host name:"
node ./cli.js instance:set $ARG_HOST
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci instance:set´ with alias:"
node ./cli.js instance:set my
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci instance:upload´
###############################################################################

# the next set of tests are testing real interactions with a Commerce Cloud instance
# re-authorize first using client:auth, this ensure, that we have a proper authentication
echo "Running ´sfcc-ci client:auth <api_key> <secret>´:"
node ./cli.js client:auth $ARG_CLIENT_ID $ARG_CLIENT_SECRET
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci instance:upload´:"
node ./cli.js instance:upload ./test/cli/site_import.zip
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci instance:upload´ with --instance option:"
node ./cli.js instance:upload ./test/cli/site_import.zip --instance $ARG_HOST
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci instance:upload´ with non-existing file (expected to fail):"
node ./cli.js instance:upload ./test/does/not/exist/site_import.zip
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci instance:state:save´
###############################################################################

if [ $ARG_SCOPE = "full" ]; then
	echo "Testing command ´sfcc-ci instance:state:save´ with --sync option:"
	node ./cli.js instance:state:save --sync
	if [ $? -eq 0 ]; then
		echo -e "\t> OK"
	else
		echo -e "\t> FAILED"
		exit 1
	fi
fi

###############################################################################
###### Testing ´sfcc-ci instance:import´
###############################################################################

echo "Testing command ´sfcc-ci instance:import´ without options:"
node ./cli.js instance:import site_import.zip
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci instance:import´ with --instance option:"
node ./cli.js instance:import site_import.zip --instance $ARG_HOST
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci instance:import´ with --sync option:"
node ./cli.js instance:import site_import.zip --sync
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci instance:import´ with --json option:"
node ./cli.js instance:import site_import.zip --json
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci instance:import´ with --json and --sync option:"
TEST_RESULT=`node ./cli.js instance:import site_import.zip --json --sync | jq '.exit_status.code' -r`
if [ $? -eq 0 ] && [ $TEST_RESULT = "OK" ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	echo -e "\t> Test result was: $TEST_RESULT"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci instance:state:reset´
###############################################################################

if [ $ARG_SCOPE = "full" ]; then
	echo "Testing command ´sfcc-ci instance:state:reset´ with --sync option:"
	node ./cli.js instance:state:reset --sync
	if [ $? -eq 0 ]; then
		echo -e "\t> OK"
	else
		echo -e "\t> FAILED"
		exit 1
	fi
fi

###############################################################################
###### Testing ´sfcc-ci code:deploy´
###############################################################################

echo "Testing command ´sfcc-ci code:deploy´ without option:"
node ./cli.js code:deploy ./test/cli/custom_code.zip
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci code:deploy´ with non-existing file (expected to fail):"
node ./cli.js code:deploy ./test/does/not/exist/custom_code.zip
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci code:deploy´ with --instance option:"
node ./cli.js code:deploy ./test/cli/custom_code.zip --instance $ARG_HOST
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci code:list´
###############################################################################

echo "Testing command ´sfcc-ci code:list´ with --json option:"
TEST_RESULT=`node ./cli.js code:list --json | jq '.count'`
if [ $? -eq 0 ] && [ $TEST_RESULT -gt 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	echo -e "\t> Test result was: $TEST_RESULT"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci code:activate´
###############################################################################

echo "Testing command ´sfcc-ci code:activate´ without option:"
node ./cli.js code:activate modules
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci code:activate´ with --instance option:"
node ./cli.js code:activate modules --instance $ARG_HOST
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci code:activate´ with invalid version (expected to fail):"
node ./cli.js code:activate does_not_exist
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci job:run´
###############################################################################

# TODO

###############################################################################
###### Testing ´sfcc-ci job:status´
###############################################################################

# TODO

###############################################################################
###### Testing ´sfcc-ci sandbox:realm:list´
###############################################################################

# we have to re-authenticate with API key and user first
echo "Running ´sfcc-ci client:auth <api_key> <secret> <user> <pwd>´:"
node ./cli.js client:auth "$ARG_CLIENT_ID" "$ARG_CLIENT_SECRET" "$ARG_USER" "$ARG_USER_PW"
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:realm:list´:"
node ./cli.js sandbox:realm:list
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:realm:list --json´:"
node ./cli.js sandbox:realm:list --json
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:realm:list --realm´ (expected to fail):"
node ./cli.js sandbox:realm:list --realm
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:realm:list --realm <realm>´:"
node ./cli.js sandbox:realm:list --realm $ARG_SANDBOX_REALM
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:realm:list --realm <realm> --json´:"
node ./cli.js sandbox:realm:list --realm $ARG_SANDBOX_REALM --json
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci sandbox:realm:update´
###############################################################################

echo "Testing command ´sfcc-ci sandbox:realm:update´ (expected to fail):"
node ./cli.js sandbox:realm:update
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:realm:update --realm <INVALID_REALM>´ (expected to fail):"
node ./cli.js sandbox:realm:update --realm INVALID_REALM
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

# memorize realm settings before tests
TEST_REALM_MAX_SANDBOX_TTL=`node ./cli.js sandbox:realm:list --realm $ARG_SANDBOX_REALM --json | jq '.sandbox.sandboxTTL.maximum' -r`
TEST_REALM_DEFAULT_SANDBOX_TTL=`node ./cli.js sandbox:realm:list --realm $ARG_SANDBOX_REALM --json | jq '.sandbox.sandboxTTL.defaultValue' -r`

echo "Testing command ´sfcc-ci sandbox:realm:update --realm <realm> --max-sandbox-ttl 144´:"
node ./cli.js sandbox:realm:update --realm $ARG_SANDBOX_REALM --max-sandbox-ttl 144
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi
echo "Testing command ´sfcc-ci sandbox:realm:update --realm <realm> --max-sandbox-ttl <previous>´ (restore):"
node ./cli.js sandbox:realm:update --realm $ARG_SANDBOX_REALM --max-sandbox-ttl $TEST_REALM_MAX_SANDBOX_TTL
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:realm:update --realm <realm> --default-sandbox-ttl 48´:"
node ./cli.js sandbox:realm:update --realm $ARG_SANDBOX_REALM --default-sandbox-ttl 48
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi
echo "Testing command ´sfcc-ci sandbox:realm:update --realm <realm> --default-sandbox-ttl <previous>´ (restore):"
node ./cli.js sandbox:realm:update --realm $ARG_SANDBOX_REALM --default-sandbox-ttl $TEST_REALM_DEFAULT_SANDBOX_TTL
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci sandbox:list´
###############################################################################

echo "Testing command ´sfcc-ci sandbox:list´:"
node ./cli.js sandbox:list
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:list --json´:"
node ./cli.js sandbox:list --json
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:list --sortby´ (expected to fail):"
node ./cli.js sandbox:list --sortby
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:list --sortby createdAt´:"
node ./cli.js sandbox:list --sortby createdAt
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:list --sortby createdAt --json´:"
node ./cli.js sandbox:list --sortby createdAt --json
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci sandbox:create´
###############################################################################

echo "Testing command ´sfcc-ci sandbox:create <INVALID_REALM>´ (expected to fail):"
node ./cli.js sandbox:create INVALID_REALM
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:create <realm> --ttl 1 --sync´:"
node ./cli.js sandbox:create $ARG_SANDBOX_REALM --ttl 1 --sync
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:create <realm> --ttl 1 --sync --json´:"
TEST_NEW_SANDBOX_RESULT=`node ./cli.js sandbox:create $ARG_SANDBOX_REALM --ttl 1 --sync --json`
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi
# grab some sandbox details for next set of tests
TEST_NEW_SANDBOX_ID=`echo $TEST_NEW_SANDBOX_RESULT | jq '.sandbox.id' -r`
TEST_NEW_SANDBOX_INSTANCE=`echo $TEST_NEW_SANDBOX_RESULT | jq '.sandbox.instance' -r`

###############################################################################
###### Testing ´sfcc-ci sandbox:get´
###############################################################################

echo "Testing command ´sfcc-ci sandbox:get <INVALID_ID>´ (expected to fail):"
node ./cli.js sandbox:get INVALID_ID
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:get <sandbox>´:"
node ./cli.js sandbox:get $TEST_NEW_SANDBOX_ID
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:get <sandbox> --json´:"
node ./cli.js sandbox:get $TEST_NEW_SANDBOX_ID --json
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:get <sandbox>´ (using <realm>-<instance> as id):"
node ./cli.js sandbox:get $ARG_SANDBOX_REALM"_"$TEST_NEW_SANDBOX_INSTANCE
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:get <sandbox> --host´:"
node ./cli.js sandbox:get $TEST_NEW_SANDBOX_ID --host
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:get <sandbox> --show-usage´:"
node ./cli.js sandbox:get $TEST_NEW_SANDBOX_ID --show-usage
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:get <sandbox> --show-operations´:"
node ./cli.js sandbox:get $TEST_NEW_SANDBOX_ID --show-operations
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:get <sandbox> --show-settings´:"
node ./cli.js sandbox:get $TEST_NEW_SANDBOX_ID --show-settings
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci sandbox:update´
###############################################################################

echo "Testing command ´sfcc-ci sandbox:update´ (expected to fail):"
node ./cli.js sandbox:update
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:update --sandbox <INVALID_ID>´ (expected to fail):"
node ./cli.js sandbox:update --sandbox INVALID_ID
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:update <sandbox> --ttl 2´:"
node ./cli.js sandbox:update --sandbox $TEST_NEW_SANDBOX_ID --ttl 1
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

###############################################################################
###### Testing ´sfcc-ci sandbox:delete´
###############################################################################

echo "Testing command ´sfcc-ci sandbox:delete´ (expected to fail):"
node ./cli.js sandbox:delete
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:delete <INVALID_ID>´ (expected to fail):"
node ./cli.js sandbox:delete INVALID_ID
if [ $? -eq 1 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi

echo "Testing command ´sfcc-ci sandbox:delete <sandbox>´:"
node ./cli.js sandbox:delete $TEST_NEW_SANDBOX_ID
if [ $? -eq 0 ]; then
    echo -e "\t> OK"
else
	echo -e "\t> FAILED"
	exit 1
fi