#!/bin/bash
# helpers.sh, ABr
# Helper functions for this app

########################################################################
# local folder
g_CURDIR="$(pwd)"
g_SCRIPT_FOLDER_RELATIVE=$(dirname "$0")
cd "$g_SCRIPT_FOLDER_RELATIVE"
g_SCRIPT_FOLDER_ABSOLUTE="$(pwd)"
cd "$g_CURDIR"

########################################################################
# globals
g_NAME='lambda-example-helloworld'

########################################################################
# utilities
helpers-i-echo-stderr() {
  echo "$@" 1>&2
}

########################################################################
# create role
helpers-x-create-role() {
  # locals
  local l_rc=0
  local l_arn=''
  local l_policy_arn=''

  # role exist?
  l_arn=$(aws iam list-roles --query "Roles[?RoleName==\`$g_NAME\`].Arn" --output text)
  l_rc=$?
  [ $l_rc -ne 0 ] && return $l_rc
  if [ x"$l_arn" = x ] ; then
    l_arn=$(aws iam create-role --role-name $g_NAME --assume-role-policy-document file://trust-policy.json --output text --query 'Role.Arn')
    l_rc=$?
    [ $l_rc -ne 0 ] && return $l_rc
  fi
  [ x"$l_arn" = x ] && helpers-i-echo-stderr "Unable to create role $g_NAME" && return 1

  # attach policy
  l_policy_arn=$(aws iam list-attached-role-policies --role-name $g_NAME --query 'AttachedPolicies[?PolicyName==`AWSLambdaBasicExecutionRole`].PolicyArn' --output text)
  l_rc=$?
  [ $l_rc -ne 0 ] && return $l_rc
  if [ x"$l_policy_arn" = x ] ; then
    l_policy_arn=$(aws iam attach-role-policy --role-name $g_NAME --policy-arn 'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole' --output text --query 'AttachedPolicies.PolicyArn')
    l_rc=$?
    [ $l_rc -ne 0 ] && return $l_rc
  fi
  [ x"$l_policy_arn" = x ] && helpers-i-echo-stderr "Unable to attach policy AWSLambdaBasicExecutionRole role $g_NAME" && return 1

  # all appears well
  return 0
}

########################################################################
# optional call support
l_do_run=0
if [ "x$1" != "x" ]; then
  [ "x$1" != "xsource-only" ] && l_do_run=1
fi
if [ $l_do_run -eq 1 ]; then
  l_func="$1"; shift
  [ x"$l_func" != x ] && eval helpers-x-"$l_func" "$@"
fi


