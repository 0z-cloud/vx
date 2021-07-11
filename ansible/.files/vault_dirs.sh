#!/bin/bash

all_users_products=()


echo "############## PRODUCTS IN PROTECTED/PRODUCTS"

products_list_in_protected=`ls -la .files/protected/products/ | grep -v README | tail -n +4 | awk '{print $9}'`

for p in ${products_list_in_protected[@]}; do
	echo -e"\nproduct: $p\n"
done

echo "############### USERS AND HIS PRODUCTS IN PROTECTED/STORAGE"

users_list=`ls -la .files/protected/storage/users | grep -v README | tail -n +4 | awk '{print $9}'`




for p in ${users_list}; do echo $p; done

for u in ${users_list[@]}; do
    
    echo -e "\nuser: $u\n"
	user_products=`ls -la .files/protected/storage/users/$u/products/ | grep -v README | tail -n +4 | awk '{print $9}'`

    for p in ${user_products}; do echo "user_products: $p"; done

	echo "############### USERS AND HIS PRODUCTS IN PROTECTED/STORAGE"
	
    for p in ${user_products[@]}; do
        
        echo -e "\nuser product: $p\n"

		if [[ " ${all_users_products[@]} " =~ " ${p} " ]]; then
			echo -e "\nalready in final list: ${p}\n"
		else
			all_users_products+=("$p")
		fi

	done

done



#################

string_with_all_user_products=`echo "${all_users_products[@]}"`

IFS=$'\n' sorted=($(sort <<<"${string_with_all_user_products[*]}")); unset IFS

echo -e "\nSorted products: $sorted\n"

for up in ${all_users_products[@]}; do
	if [[ " ${products_list_in_protected[@]} " =~ "${up}" ]]; then
		echo -e "\nprotected product is presents for storage: ${up}\n"
	else
		echo -e "\nerror! protected dir for product are not found: ${up}\n"
		echo "${up}" >> ../../.local/vault_products_missed.lock
	fi
done


################ FIXING MISSED PRODUCTS

for up in ${all_users_products[@]}; do
        if [[ " ${products_list_in_protected[@]} " =~ "${up}" ]]; then
                echo -e "\nprotected product is presents for storage: ${up}\n"
        else
                echo -e "\nerror! protected dir for product are not found: ${up}\nwe are go create them\n"
		        mkdir .files/protected/products/${up}

        fi
done


########

echo -e "GET THE EMPTY PRODUCTS IN PROTECTED"

for up in ${all_users_products[@]}; do



	# evali=$(a=`ls -la .files/protected/products/${up}| awk '{print $9}' | grep -v README | tail -n +4` ; if [[ ! -z $a ]]; then get_return_core="0"; export get_return_code=$get_return_code; else get_return_code="1"; export get_return_code=$get_return_code; fi)

	# echo $evali

	return=`ls -la .files/protected/products/${up} | awk '{print $9}' | grep -v README | tail -n +4`
	user_products=`ls -la .files/protected/storage/users/${up}/products/ | awk '{print $9}' | grep -v README | tail -n +4`

	echo "returned: $return"
	echo "user_products: $user_products"

	if [[ -z $return ]]; then
		echo "return null"
	else
		echo "something more then zero: $up "
	fi
	# cat_count=`echo ${return} | wc -l`
	# echo -e "return: $return"
	# count=`echo -e "$return" | wc -l`
	# echo "count $count"

	# echo $return
	# && echo 1 || echo 0"
	# return=$(eval $return)
        # result_return=`echo $return | tail -n -1`
	# if [ "$cat_count" == "1" ]; then
		#echo "KO"
	# else
		#echo "OK"
	# fi
	# echo -e "\nreturn result for product: ${up} is: ${result_return}\n"
done
