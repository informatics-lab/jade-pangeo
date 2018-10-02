#!/bin/bash
set -e
echo "*** Test ***"



echo "*** Test Dev ***"
helm lint jadepangeo -f env/dev/values.yaml -f env/dev/secrets.yaml

echo "*** Test Prod ***"
helm lint jadepangeo -f env/prod/values.yaml -f env/prod/secrets.yaml
