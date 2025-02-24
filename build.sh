#!/bin/bash

source .env

packer init helix.pkr.hcl
packer build helix.pkr.hcl
