#!/bin/bash
set -e

exec mysqld --defaults-file=/etc/mysql/my.cnf $CMDARG
