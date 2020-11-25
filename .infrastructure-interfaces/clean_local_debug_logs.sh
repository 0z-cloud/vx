#!/bin/bash

find ./../ | grep vcd | grep log | grep -v 'py' | xargs -I ID rm -f ID