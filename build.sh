#!/bin/bash

source .env

if [ -z "$1" ]; then
  echo "Error: Please specify a platform (aws or vultr)"
  echo "Usage: $0 [aws|vultr]"
  exit 1
fi

if [ "$1" != "aws" ] && [ "$1" != "vultr" ]; then
  echo "Error: Invalid platform. Please use 'aws' or 'vultr'"
  echo "Usage: $0 [aws|vultr]"
  exit 1
fi

if [ "$1" == "aws" ]; then
  packer init aws.pkr.hcl
  packer build aws.pkr.hcl
else
  packer init vultr.pkr.hcl
  packer build vultr.pkr.hcl
fi
