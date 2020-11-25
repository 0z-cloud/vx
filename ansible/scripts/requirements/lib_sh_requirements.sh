#!/bin/bash

if [ "$type_of_run" = "true" ] || [ "$type_of_run" = "print_only" ]; then

    if [ "$type_of_run" != "run_from_wrapper" ]; then

        echo -e "          ${YELLOW}Installing${NC} python and requirements"
        echo "     |>..........................................................................................................................................................................................<|"

        # install_requirements ${typeofcloud};

        echo "     |>..........................................................................................................................................................................................<|"
        echo -e "            ${GREEN}Done${NC} Installing python and requirements"
        echo "     |>..........................................................................................................................................................................................<|"

    fi

fi


if [ "$type_of_run" != "run_from_wrapper" ]; then

echo -e "          ${YELLOW}Installing${NC} python and requirements"
echo "     |>..........................................................................................................................................................................................<|"

# install_requirements ${typeofcloud};

echo "     |>..........................................................................................................................................................................................<|"
echo -e "            ${GREEN}Done${NC} Installing python and requirements"
echo "     |>..........................................................................................................................................................................................<|"

fi

if [ "$type_of_run" != "run_from_wrapper" ]; then

        echo -e "          ${YELLOW}Installing${NC} python and requirements"
        echo "     |>..........................................................................................................................................................................................<|"

        # install_requirements ${typeofcloud};

        echo "     |>..........................................................................................................................................................................................<|"
        echo -e "            ${GREEN}Done${NC} Installing python and requirements"
        echo "     |>..........................................................................................................................................................................................<|"

    fi

    if [ "$type_of_run" != "run_from_wrapper" ]; then

        echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
        echo -e "          ${YELLOW}Installing${NC} python and requirements"
        echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

        # install_requirements ${typeofcloud};

        echo "     |>..........................................................................................................................................................................................<|"
        echo -e "            ${GREEN}Done${NC} Installing python and requirements"
        echo "     |>..........................................................................................................................................................................................<|"

    fi


if [ "$type_of_run" = "true" ] || [ "$type_of_run" = "print_only" ]; then

    if [ "$type_of_run" != "run_from_wrapper" ]; then

        echo -e "          ${YELLOW}Installing${NC} python and requirements"
        echo "     |>..........................................................................................................................................................................................<|"

        # install_requirements ${typeofcloud};

        echo "     |>..........................................................................................................................................................................................<|"
        echo -e "            ${GREEN}Done${NC} Installing python and requirements"
        echo "     |>..........................................................................................................................................................................................<|"

    fi

fi

    if [ "$type_of_run" != "run_from_wrapper" ]; then

        echo -e "          ${YELLOW}Installing${NC} python and requirements"
        echo "     |>..........................................................................................................................................................................................<|"

        # install_requirements ${typeofcloud};

        echo "     |>..........................................................................................................................................................................................<|"
        echo -e "            ${GREEN}Done${NC} Installing python and requirements"
        echo "     |>..........................................................................................................................................................................................<|"

    fi

install_requirements(){
    
    typeofcloud=$1
    pipelinename=$2
    
    echo -e "            ${GREEN}Type of Cloud${NC} in install_requirements ${typeofcloud}"


    if [ -z "$certificate_prefix" ]; then

        if [ "$automatic" = "true" ]; then

            echo -e "         ${RED}Auto mode enabled${NC}"

        else

        echo -e "         ${RED}Certificate prefix is null, possible die:${NC} ${certificate_prefix}"

        set=ERROR

        usage_cloud $set;

        fi

    fi

    if [ -z "${typeofcloud}" ]; then

        echo -e "         ${RED}Type is null, possible die:${NC} ${type_of_run}"

        set=ERROR

        usage_cloud $set;

    else

        echo -e "         Start the Stand perform type of cloud ${typeofcloud}"
        case ${typeofcloud} in
            vsphere|alicloud|bare|vcd) CLOUD_PROVIDER="${typeofcloud}"; echo "         RUN WITH CLOUD_PROVIDER: $CLOUD_PROVIDER"; run_req ${typeofcloud} $uname;;
            *)             usage_cloud $set;;
        esac

    fi
}

install_requirements(){
    
    typeofcloud=$1
    pipelinename=$2
   
    echo -e "            ${GREEN}Type of Cloud${NC} in install_requirements ${typeofcloud}"

    if [ -z "${typeofcloud}" ]; then

        echo -e "         ${RED}Type is null, possible die:${NC} ${type_of_run}"

        set=ERROR

        usage_cloud $set print_run_info $pipelinename;

    else

        echo -e "         Start the Services Wrapper to perform on type of cloud ${typeofcloud}"

        case ${typeofcloud} in
            vsphere|alicloud|bare|vcd) CLOUD_PROVIDER="${typeofcloud}"; echo "         RUN WITH CLOUD_PROVIDER: $CLOUD_PROVIDER";;
            *)             usage_cloud $set print_run_info $pipelinename;;
        esac

    fi
}


install_requirements(){

    typeofcloud=$1
    pipelinename=$2

    echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
    echo -e "            ${GREEN}Type of Cloud${NC} in install_requirements ${typeofcloud}"
    echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

    if [ -z "${typeofcloud}" ]; then

        echo -e "         ${RED}Type is null, possible die:${NC} ${type_of_run}"

        set=ERROR

        usage_cloud $set;

    else

        echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"
        echo -e "         Start the Services Wrapper to perform on type of cloud ${typeofcloud}"
        echo -e "     ${GREEN}|>..........................................................................................................................................................................................<|${NC}"

        case ${typeofcloud} in
            vsphere|alicloud|bare|vcd) CLOUD_PROVIDER="${typeofcloud}"; echo "         RUN WITH CLOUD_PROVIDER: $CLOUD_PROVIDER"; run_req ${typeofcloud} $uname;;
            *)             usage_cloud $set;;
        esac

    fi


}

if [ "$type_of_run" != "run_from_wrapper" ]; then

        echo -e "          ${YELLOW}Installing${NC} python and requirements"
        echo "     |>..........................................................................................................................................................................................<|"

        # install_requirements ${typeofcloud};

        echo "     |>..........................................................................................................................................................................................<|"
        echo -e "            ${GREEN}Done${NC} Installing python and requirements"
        echo "     |>..........................................................................................................................................................................................<|"

    fi

install_requirements(){
    
    typeofcloud=$1
    pipelinename=$2

    echo -e "            ${GREEN}Type of Cloud${NC} in install_requirements ${typeofcloud}"

    if [ -z "${typeofcloud}" ]; then

        echo -e "         ${RED}Type is null, possible die:${NC} ${type_of_run}"

        set=ERROR

        usage_cloud $set;

    else

        echo -e "         Start the Stand perform type of cloud ${typeofcloud}"

        case ${typeofcloud} in
            vsphere|alicloud|bare|vcd) CLOUD_PROVIDER="${typeofcloud}"; echo "         RUN WITH CLOUD_PROVIDER: $CLOUD_PROVIDER"; run_req ${typeofcloud} $uname;;
            *)             usage_cloud $set;;
        esac

    fi
}
