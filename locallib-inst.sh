#!/bin/sh

set -e -x

cpanm -L locallib local::lib Perl::MinimumVersion IPC::Run

