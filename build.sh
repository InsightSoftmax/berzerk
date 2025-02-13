#!/bin/bash

source .env

cat "variables.hcl" "helix.pkr.hcl" > build-helix.pkr.hcl

packer init build-helix.pkr.hcl
packer build build-helix.pkr.hcl
