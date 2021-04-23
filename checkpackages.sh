#!/bin/bash

check_package () {
  which $1 &> /dev/null
  if [ $? -eq 0 ]; then
      echo "$1 is installed!"
    else
      echo "$1 is NOT installed!."
      exit 1
    fi
}

check_package aws
check_package terraform
check_package helm
check_package jq
check_package openssl
check_package curl
check_package qemu-kvm
check_package libvirt-daemon-system
check_package build-essential
