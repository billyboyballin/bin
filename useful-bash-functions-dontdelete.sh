#!/bin/bash

#Check packages are installed
_check_packages()
{
    package_names=("$@")
    for package_name in "${package_names[@]}"; do
      which $package_name &> /dev/null
      [ $? -ne 0 ] && echo "$package_name is not installed." && package_uninstalled=true
    done
    [ -n "$package_uninstalled" ] && exit 1
    return 0
}

_check_packages kubectl helm flux jq curl envsubst aws-iam-authenticator

#Check environment variables are set
_check_vars()
{
    var_names=("$@")
    for var_name in "${var_names[@]}"; do
        [ -z "${!var_name}" ] && echo "$var_name is unset." && var_unset=true
    done
    [ -n "$var_unset" ] && exit 1
    return 0
}

_check_vars AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION \
REGISTRY_USERNAME REGISTRY_PASSWORD REGISTRY_EMAIL \
GITHUB_USERNAME GITHUB_PAT GITHUB_URL CLUSTER_NAME
