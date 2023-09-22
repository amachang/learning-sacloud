#!/bin/bash

set -eux

usacloud vpc-router create-standard -y --name 'main-vpc-router'
usacloud switch create -y --name 'main-switch'

# Switch と VPC ルータを接続する部分は長大な JSON を書かなきゃいけないので挫折

