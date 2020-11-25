#!/bin/bash

set -e

#### BASE PART

useradd_default_route53master () {
    #######################
    echo "Start add Route53User to DB woincapi"
    #######################
    PGPASSWORD=7539148620qQ psql -U postgres -h woinc-api-postgresql woincapi -qtA << EOF
    INSERT INTO public.user (username, password, firstname, lastname, role_id) VALUES
('route53master', '\$2b\$12\$XFyG0mvGSRx.E2q71E5lB.pl/y0X1o3TdRFHConKu6PMyxu7XrcZO', 'Administrator', 'Route53', '1');
EOF
    #######################
    echo "Completed adding Route53User to DB woincapi"
    #######################
   return $@
}

route53usercheck_woincapi () {
    #######################
    echo "Start get Route53User from DB woincapi"
    #######################
    PGPASSWORD=7539148620qQ psql -U postgres -h woinc-api-postgresql woincapi -qtA << EOF
    SELECT id FROM public.user WHERE 'route53master' ~ username;
EOF
    echo "$@"
    #######################
    echo "Completed, return result of query for Route53User from DB woincapi"
    #######################
    #return $@
}

perform_web_user_check_woincapi () {
    #######################
    echo "Start User Check woincapi"
    #######################
    VALUE_woincapi=$(route53usercheck_woincapi)
    VALUE_woincapi_D="1"

    echo "VALUE_woincapi: $VALUE_woincapi"
    echo "VALUE_woincapi_D: $VALUE_woincapi_D"

    if [[ $VALUE_woincapi -eq $VALUE_woincapi_D ]]; then
        echo "User Exists in DB woincapi"
    else
        echo "We need add Master User to DB woincapi"
        useradd_default_route53master;
    fi
    #######################
    echo "Completed for DB woincapi"
    #######################
}

## SETUP DB NAME woincapi;

perform_web_user_check_woincapi;