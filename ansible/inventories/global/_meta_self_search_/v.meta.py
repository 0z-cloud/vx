#!/usr/bin/env python3

#

import yaml
import json
import sys
import re
import os
import argparse
from collections import defaultdict
from collections import OrderedDict
from collections import namedtuple
import ipaddress

_data = { "_meta" : { "hostvars": {} }}
_matcher = {}
_hostlog = []
inventory_uniq_groups=[]
var_inventory_uniq_groups=[]