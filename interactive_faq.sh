#!/bin/bash

clear

echo -e "\n\n\n\n\n                                                        Dynamic code works introduction manual \n\n\n\n\n\n"

sleep 3

echo -e "\n\n\n\n\n                                                        Please relax, read and try to understand the basic concept \n\n\n\n\n\n"

sleep 3

echo -e "\n\n\n\n\n                                                        This a primary root Project path, and its contents \n\n\n\n\n\n"

sleep 3

echo -e "#  Project Root Dir."

sleep 2

clear && echo -e '\n\n /Users/rostislavgrigoriev/OZ/adam/ \n\n Project Root Dir \n\n';ls -la $(dirname `pwd`);

sleep 6

echo -e "#  Ansible Root Dir - Contains all IaC CodeBase, for DevOps team code side ansible is a 'workdir' not are project root - "

sleep 2

clear && echo -e '\n\n /Users/rostislavgrigoriev/OZ/adam/ansible \n\n Ansible Root Dir \n\n';ls -la `pwd`;

sleep 2

echo -e "#  Services which we develop for the product. Root Dir services."


clear && echo -e '\n\n /Users/rostislavgrigoriev/OZ/adam/ \n\n Project Root Dir \n\n';ls -la $(dirname `pwd`)\/services;


echo -e "#  Backend equipment services, databases, and applications which operate by services that we develop for the product. Root Dir dockerfiles"


clear && echo -e '\n\n /Users/rostislavgrigoriev/OZ/adam/ \n\n Project Root Dir \n\n';ls -la $(dirname `pwd`)\/dockerfiles;


clear && echo -e '\n\n /Users/rostislavgrigoriev/OZ/adam/ \n\n Products Root Dir \n\n';ls -la $(dirname `pwd`)\/ansible\/inventories\/products;
