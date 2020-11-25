#!/bin/bash

# parent inventory
inventory=$1

# parent product
product=$2

# parent cloud type
typeofcloud=$3

# clone / symlink 
direction=$4

# cloud adapter name
target_cloud_type=$5

# target inventory name
direction_inventory=$6

# target product name
target_product=$7

vortex_homedir=`pwd`
oz_workdir="./ansible/inventories/0z-cloud/products/types/"
main_workdir="./ansible/inventories/products/"

echo "Start the create a new inventory from scratch"
# ./\!_make_a_new_inventory_from_scratch.sh beta vortex bare symlink bare test1 v2
echo "After create the new inventory, before use them, you must to change invenotry settings!"

if [ "$1" = "" ]; then
  echo "Usage: $0 parent inventory is must to be a specified"
  exit
fi

if [ "$2" = "" ]; then
  echo "Usage: $0 product is must to be a specified"
  exit
fi

if [ "$3" = "" ]; then
  echo "Usage: $0 type of cloud type is must to be a specified: vsphere / alicloud"
  exit
fi

if [ "$4" = "" ]; then
  echo "Usage: $0 type of spawning from other repo, like clone /or/ symlink"
  exit
fi

if [ "$5" = "" ]; then
  echo "Usage: $0 type of target cloud type is must to be a specified: vsphere / alicloud"
  exit
fi

if [ "$6" = "" ]; then
  echo "Usage: $0 direction new name of inventory is must to be a specified"
  exit
fi

if [ "$7" = "" ]; then
  echo "Usage: $0 direction new target product is must to be scpecified"
  exit
fi

if [[ "$direction_inventory" == "$inventory" ]] && [[ "$target_product" == "$product" ]] && [[ "$target_cloud_type" == "${typeofcloud}" ]]; then
  echo "Cannot create from itself to itself for all ways!"
  exit 1
fi

###(1) SOURCE CLOUD
source_cloud_path='./ansible/inventories/0z-cloud/products/types/\!_'${typeofcloud}'/'$product'/'${inventory}'/'
source_cloud_path_driver='./ansible/inventories/0z-cloud/products/types/\!_'${typeofcloud}'/'$product'/'${inventory}'/v.py'
source_cloud_main_dir='./ansible/inventories/0z-cloud/products/types/\!_'
source_cloud_product='./ansible/inventories/0z-cloud/products/types/\!_'${typeofcloud}'/'$product'/'

source_cloud_path_exists_run=`echo "stat ${source_cloud_path} &>/dev/null && echo 1 || echo 0"`
echo "source_cloud_path: $source_cloud_path"
source_cloud_path_exists=`eval ${source_cloud_path_exists_run}`

###
###(2) SOURCE DEFAULT PRODUCT

source_main_path='./ansible/inventories/products/'${product}'/'${inventory}
source_main_product='./ansible/inventories/products/'${product}
source_main_folder='./ansible/inventories/products/'

####### CHECK SOURCE DEFAULT INVENTORY EXISTS
source_main_path_exists_run=`echo "stat ${source_main_path}/ &>/dev/null && echo 1 || echo 0"`
echo "stat ${source_main_path}/ &>/dev/null && echo 1 || echo 0"
source_main_path_exists=`eval ${source_main_path_exists_run}`

####### CHECK SOURCE DEFAULT PRODUCT EXISTS
source_main_product_exists_run=`echo "stat ${source_main_product}/ &>/dev/null && echo 1 || echo 0"`
echo "stat ${source_main_product}"
source_main_product_exists=`eval ${source_main_product_exists_run}`

if [ $source_cloud_path_exists -eq 0 ] || [ $source_main_path_exists -eq 0 ]; then

  echo "ERROR! Sources cannot to be found, inventory or product not exists, exit"
  exit 1

fi

################
###
###(3) TARGET DEFAULT PRODUCT AND DIRECTION TARGET INVENTORY
target_main_inventory_path='./ansible/inventories/products/'${target_product}'/'${direction_inventory}
target_main_inventory_product='./ansible/inventories/products/'${target_product}

####### CHECK THE TARGET INVENTORY EXISTS
target_main_inventory_exists_run=`echo "stat ${target_main_inventory_path} &>/dev/null && echo 1 || echo 0"`
target_main_inventory_exists=`eval ${target_main_inventory_exists_run}`

####### CHECK THE TARGET PRODUCT EXISTS
target_main_inventory_product_exists_run=`echo "stat ${target_main_inventory_product} &>/dev/null && echo 1 || echo 0"`
target_main_inventory_product_exists=`eval ${target_main_inventory_product_exists_run}`

###
###(4)

target_cloud_inventory_path='./ansible/inventories/0z-cloud/products/types/!_'$target_cloud_type'/'$target_product'/'${direction_inventory}
target_cloud_inventory_path_driver='./ansible/inventories/0z-cloud/products/types/!_'$target_cloud_type'/'$target_product'/'${direction_inventory}'/v.py'

target_cloud_inventory_exists_run=`echo "stat ${target_cloud_inventory_path} &>/dev/null && echo 1 || echo 0"`
target_cloud_inventory_exists=`eval ${target_main_inventory_exists_run}`
#

# # Check target product in main default inventories exists
# target_main_inventory_path_product_exists_run=`echo "stat ${target_main_inventory_product} &>/dev/null && echo 1 || echo 0"`
# target_main_inventory_path_product_exists=`eval ${target_main_inventory_path_product_exists_run}`

echo "source_cloud_path: $source_cloud_path"
source_cloud_path_exits_state_run=`echo "readlink ${source_cloud_path} &>/dev/null && echo 1 || echo 0"`
source_cloud_path_exits_state=`eval ${source_cloud_path_exits_state_run}`
echo "source_cloud_path_exits_state: ${source_cloud_path_exits_state}"


echo "source_cloud_product: $source_cloud_product"
source_cloud_product_exits_state_run=`echo "readlink ${source_cloud_product} &>/dev/null && echo 1 || echo 0"`
source_cloud_product_exits_state=`eval ${source_cloud_product_exits_state_run}`
echo "source_cloud_product_exits_state: ${source_cloud_product_exits_state}"

#

# Check target 0z in adapter product and inventories exists
# Check exists repository 0z which a parent for create by scratch

if [ $source_cloud_path_exists -eq 0 ]; then

  echo "source zero inventory not exists, exit"
  exit 1

fi

##############

echo "source_cloud_path_exits_state: $source_cloud_path_exits_state"

if [ $source_cloud_path_exits_state -ne 0 ]; then

    echo "it's a symbolic link"
    source_cloud_path_exits_state_data=`echo "readlink $source_cloud_path"`
    source_cloud_path_exits_state_data_result=`eval $source_cloud_path_exits_state_data | tail -n -1`
    echo "source_cloud_path_exits_state_data: $source_cloud_path_exits_state_data_result"
    parent_source_cloud_product=`eval "echo $source_cloud_path_exits_state_data_result | awk '{print $NF}' | sed 's/..\///' | sed 's/\/.*//g'"`
    parent_source_cloud_inventory=`eval "echo $source_cloud_path_exits_state_data_result | awk '{print $NF}' | sed 's/..\///' | sed 's/$parent_source_cloud_product\///g'"`
    echo "parent_inventory: $parent_source_cloud_inventory"
    ls -la $parent_source_cloud_inventory
    echo "parent_product: $parent_source_cloud_product"
    ls -la $parent_source_cloud_product

    target_symlink=1

else

    echo "link target does not exist"

fi

if [ $source_cloud_product_exits_state -ne 0 ]; then
    
    echo "it's a symbolic link"
    source_cloud_product_exits_state_data=`echo "readlink $source_cloud_product"`
    source_cloud_product_exits_state_data_result=`eval $source_cloud_product_exits_state_data | tail -n -1`
    echo "source_cloud_path_exits_state_data: $source_cloud_product_exits_state_data_result"
    parent_cloud_product=`eval "echo $source_cloud_product_exits_state_data_result | awk '{print $NF}' | sed 's/..\///' | sed 's/\/.*//g'"`
    parent_cloud_inventory=`eval "echo $source_cloud_product_exits_state_data_result | awk '{print $NF}' | sed 's/..\///' | sed 's/$parent_cloud_product\///g'"`
    echo "parent_inventory: $parent_cloud_inventory"
    echo "parent_product: $parent_cloud_product"
    echo "parent_inventory: $parent_source_cloud_inventory"
    ls -la $parent_source_cloud_inventory
    echo "parent_product: $parent_source_cloud_product"
    ls -la $parent_source_cloud_product

    target_symlink=1

else

    echo "link target does not exist"

fi


#####
#



if [[ "$target_cloud_type" == "${typeofcloud}" ]]; then

    echo "CLOUD TYPE TARGETS IS SAME"

    tg_tpofcld=1

    if [[ "$target_product" == "$product" ]]; then

      echo "CLOUD PRODUCTS SAME"
      tg_product=1

      if [[ "${direction}" == 'symlink' ]]; then 

      echo "CLONE TYPE FOR SAME CLOUD TYPE AND PRODUCT NAME"
      echo "target_product: $target_cloud_type"
      echo "typeofcloud: ${typeofcloud}"
      echo "target_product: $target_product"
      echo "product: $product"
      echo "direction_inventory: $direction_inventory"
      echo "inventory: $inventory"
      echo "source_cloud_main_dir: $source_cloud_main_dir"
      echo "source_main_folder: $source_main_folder"
      echo "ttt: $source_cloud_main_dir${typeofcloud}/$target_product"
      # rm $source_cloud_main_dir${typeofcloud}/$target_product/$direction_inventory

      echo "========================================================================"
      echo "vortex_homedir: $vortex_homedir"
      echo "oz_workdir: ${oz_workdir}"
      echo "main_workdir: ${main_workdir}"
      echo "========================================================================"

      # ./ansible/inventories/0z-cloud/products/types/\!_bare/vortex/beta/ ../vortex/123
      echo "========================================================================"
      cd -P $oz_workdir
      echo "========================================================================"

      pwd
      ls -la ./
      cd -P ./\!_$target_cloud_type\
      ls -la ./

      echo "direction_inventory $direction_inventory"
      echo "product: $product"
      echo "inventory: $inventory"

      cd -P ./$product/

      ln -s ../$product/${inventory} ./../$direction_inventory
      mv ../$direction_inventory ../$product
      ls -la ../$product
      ls -la ../$product/$direction_inventory/

      cd -P $vortex_homedir

      echo "========================================================================"
      cd -P $main_workdir
      echo "========================================================================"

      ls -la ./

      cd -P ./$product/

      cp -R $main_workdir/${inventory} $direction_inventory

      ls -la ./$product/

      ls -la ./$product/$direction_inventory

      else

            if [[ "${direction}" == 'clone' ]]; then 

            echo "CLONE TYPE FOR SAME CLOUD TYPE AND PRODUCT NAME"
            echo "target_product: $target_cloud_type"
            echo "typeofcloud: ${typeofcloud}"
            echo "target_product: $target_product"
            echo "product: $product"
            echo "direction_inventory: $direction_inventory"
            echo "inventory: $inventory"
            echo "source_cloud_main_dir: $source_cloud_main_dir"
            echo "source_main_folder: $source_main_folder"
            echo "ttt: $source_cloud_main_dir${typeofcloud}/$target_product"
            # rm $source_cloud_main_dir${typeofcloud}/$target_product/$direction_inventory

            echo "========================================================================"
            echo "vortex_homedir: $vortex_homedir"
            echo "oz_workdir: ${oz_workdir}"
            echo "main_workdir: ${main_workdir}"
            echo "========================================================================"

            # ./ansible/inventories/0z-cloud/products/types/\!_bare/vortex/beta/ ../vortex/123
            echo "========================================================================"
            cd -P $oz_workdir
            echo "========================================================================"

            pwd
            ls -la ./
            cd -P ./\!_$target_cloud_type\
            ls -la ./

            echo "direction_inventory $direction_inventory"
            echo "product: $product"
            echo "inventory: $inventory"

            cd -P ./$product/
            ls -la 
            cp -R ./${inventory} ./$direction_inventory
            ls -la ./$direction_inventory
            ls -la ../$product/$direction_inventory/

            cd -P $vortex_homedir

            # ln -s 

            #cp -R $source_cloud_path/* $target_cloud_inventory_path/

            cd -P $vortex_homedir

            echo "========================================================================"
            cd -P $main_workdir
            echo "========================================================================"

            ls -la ./

            cd -P ./$product/

            # cp -R $main_workdir/${inventory} $direction_inventory

            ls -la ./$product/

            ls -la ./$product/$direction_inventory

          fi

      fi

    else
      echo "CLOUD PRODUCTS DIFFERENT"
      tg_product=0

      if [[ "${direction}" == 'symlink' ]]; then 

        echo "CLONE TYPE FOR SAME CLOUD TYPE"
        echo "DIFFERENT PRODUCT NAMES"
        echo "target_product: $target_cloud_type"
        echo "typeofcloud: ${typeofcloud}"
        echo "target_product: $target_product"
        echo "product: $product"
        echo "direction_inventory: $direction_inventory"
        echo "inventory: $inventory"
        echo "source_cloud_main_dir: $source_cloud_main_dir"
        echo "source_main_folder: $source_main_folder"

        echo "ttt: $source_cloud_main_dir${typeofcloud}"

            # else

            #     if [[ "${direction}" == 'clone' ]]; then 

            #       # oz_workdir $source_cloud_path/* $target_cloud_inventory_path/

            # fi

      fi

    fi


    if [[ "$direction_inventory" == "$inventory" ]]; then
      echo "CLOUD INVENTORIES SAME"
      tg_product=1
    else

      echo "CLOUD INVENTORIES DIFFERENT"
      tg_product=0

      echo "CLONE TYPE FOR SAME CLOUD TYPE AND PRODUCT NAME"
      echo "target_product: $target_cloud_type"
      echo "typeofcloud: ${typeofcloud}"
      echo "target_product: $target_product"
      echo "product: $product"
      echo "direction_inventory: $direction_inventory"
      echo "inventory: $inventory"
      echo "source_cloud_main_dir: $source_cloud_main_dir"
      echo "source_main_folder: $source_main_folder"
      echo "ttt: $source_cloud_main_dir${typeofcloud}/$target_product"
      # rm $source_cloud_main_dir${typeofcloud}/$target_product/$direction_inventory

      echo "========================================================================"
      echo "vortex_homedir: $vortex_homedir"
      echo "oz_workdir: ${oz_workdir}"
      echo "main_workdir: ${main_workdir}"
      echo "========================================================================"

      # ./ansible/inventories/0z-cloud/products/types/\!_bare/vortex/beta/ ../vortex/123
      echo "========================================================================"
      cd -P $oz_workdir
      echo "========================================================================"

      pwd
      ls -la ./
      cd -P ./\!_$target_cloud_type\
      ls -la ./

      echo "direction_inventory $direction_inventory"
      echo "product: $product"
      echo "inventory: $inventory"

      cd -P ./$product/

      # cp -R ./$product/${inventory} $direction_inventory
      ls -la ./$direction_inventory
      ls -la ../$product/$direction_inventory/

      cd -P $vortex_homedir

      # ln -s 

      # cp -R $source_cloud_path/* $target_cloud_inventory_path/

      echo "========================================================================"
      cd -P $main_workdir
      echo "========================================================================"

      ls -la ./

      cd -P ./$product/

      cp -R ${inventory} $direction_inventory

      ls -la ./$product/

      ls -la ./$product/$direction_inventory

    fi

else 



  if [[ "${direction}" == 'symlink' ]]; then 


      echo "CLOUD PRODUCTS DIFFERENT"

  else

      if [[ "${direction}" == 'clone' ]]; then 

        cp -R $source_cloud_path/* $target_cloud_inventory_path/

      fi

  fi


    echo "CLOUD TYPE TARGETS IS DIFFERENT"

    # if [[ "$direction_inventory" == "$inventory" ]]; then



    # fi


    # if [ $source_cloud_path_exits_state -eq 0 ]; then

    #   echo "target result works inventory not exists, need to create"

    #   # if [[ "${direction}" == 'symlink' ]]; then 

    #   # else 

    #   #   if [[ "${direction}" == 'clone' ]]; then 



    #   #   fi

    #   # fi

    # else 

    #   echo "target result works inventory are presented, why?"
    #   exit 1

    # fi



fi

# mkdir ansible/group_vars/products/$product/$inventory
# mkdir ansible/inventories/0z-cloud/products/types/\!_${typeofcloud}/$product/$inventory
# mkdir ansible/inventories/products/$product/$inventory

# cp -r ansible/group_vars/products/$product/development/* ansible/group_vars/products/$product/$inventory/
# cp -r ansible/inventories/0z-cloud/products/types/\!_${typeofcloud}/$product/development/* ansible/inventories/0z-cloud/products/types/\!_${typeofcloud}/$product/$inventory
# cp -r ansible/inventories/products/$product/development/* ansible/inventories/products/$product/$inventory

# if [ $target_main_inventory_product_exists -eq 0 ]; then
  
#   #
#   echo "target result product not exists, must to create a new product"
#   mkdir -p ${target_main_inventory_product}
#   #

# fi

# if [ $target_cloud_inventory_exists -eq 0 ]; then

#   echo "target zero inventory not exists, create them"
#   mkdir -p ${target_cloud_inventory_path}
  
# fi

echo "Enjoy ansible magic!"

