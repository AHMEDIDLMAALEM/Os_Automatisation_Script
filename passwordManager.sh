show_password_manager_menu(){
    clear
    echo "Access granted ,what can i do for you ?"
    echo "1- Add new account"
    echo "2- List all accounts"
    echo "3- Change password"
    echo "4- Exit"
    read -p "Enter your choice : " choice
}
add_ann_account(){
    clear
    echo "Adding new account"
    read -p "Enter the account name : " account_name
    read -p "Enter the account password : " account_password
    
    # chzck if the ACCOUNTS_FILE exist if not create a locked file
    if [ ! -f "$ACCOUNTS_FILE.gpg" ]; then
        echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : INFO : created new accounts file" >> "$LOG_FILE"
        touch "$ACCOUNTS_FILE"
    else
        # When you need to read from the file, decrypt it first
        echo "$ACCOUNTS_FILE_PASSWORD" | gpg --batch --yes --passphrase-fd 0 -d "$ACCOUNTS_FILE.gpg" > "$ACCOUNTS_FILE"
        rm "$ACCOUNTS_FILE.gpg"

    fi
    # debugging
    sleep 5

    echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : INFOS : added new account $account_name" >> "$LOG_FILE"
    
    echo "$account_name:$account_password" >> "$ACCOUNTS_FILE"

    #debugging
    #sleep 5

    # Encrypt the file
    echo "$ACCOUNTS_FILE_PASSWORD" | gpg --batch --yes --passphrase-fd 0 -c --cipher-algo AES256 "$ACCOUNTS_FILE"

    #debugging
    #sleep 5

    # Delete the unencrypted file
    rm "$ACCOUNTS_FILE"
    sleep 5
}
change_password(){
    echo "Changing password"
    read -p "Enter the old password : " old_password
    # Encrypt password as MD5
    encrypted_old_password=$(echo -n "$old_password" | md5sum | awk '{print $1}')
    if [[ $encrypted_old_password != $PASSWORD ]]; then
        echo "Wrong password"
        echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : ERROR : wrong password attempt to change passwords manager password" >> "$LOG_FILE"
        sleep 5
        continue
    fi
    read -p "Enter the new password : " new_password
    # Encrypt password as MD5
    encrypted_new_password=$(echo -n "$new_password" | md5sum | awk '{print $1}')
    echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : INFOS : changed password" >> "$LOG_FILE"
    PASSWORD=$encrypted_new_password
    # Save password to .env file
    if [[ -f ".env" ]]; then
        # Check if PASSWORD is already set in .env file
        if grep -q "PASSWORD=" .env; then
            sed -i "s/PASSWORD=.*/PASSWORD=$PASSWORD/" .env
        else
            echo "PASSWORD=$PASSWORD" >> .env
        fi
    else
        echo "PASSWORD=$PASSWORD" > .env
    fi
}
delete_account(){
    echo "Deleting an account"
    read -p "Enter the account name : " account_name
    # When you need to read from the file, decrypt it first
    echo "$ACCOUNTS_FILE_PASSWORD" | gpg --batch --yes --passphrase-fd 0 -d "$ACCOUNTS_FILE.gpg" > "$ACCOUNTS_FILE"
    rm "$ACCOUNTS_FILE.gpg"
    # Delete the line with the account name
    sed -i "/$account_name:.*/d" "$ACCOUNTS_FILE"
    # Encrypt the file
    echo "$ACCOUNTS_FILE_PASSWORD" | gpg --batch --yes --passphrase-fd 0 -c --cipher-algo AES256 "$ACCOUNTS_FILE"
    # Delete the unencrypted file
    rm "$ACCOUNTS_FILE"
    echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : INFOS : deleted account $account_name" >> "$LOG_FILE"
}
edit_account(){
    echo "Editing an account"
    read -p "Enter the account name : " account_name
    read -p "Enter the new password : " account_password
    # When you need to read from the file, decrypt it first
    echo "$ACCOUNTS_FILE_PASSWORD" | gpg --batch --yes --passphrase-fd 0 -d "$ACCOUNTS_FILE.gpg" > "$ACCOUNTS_FILE"
    rm "$ACCOUNTS_FILE.gpg"
    # Replace the line with the new password
    sed -i "s/$account_name:.*/$account_name:$account_password/" "$ACCOUNTS_FILE"
    # Encrypt the file
    echo "$ACCOUNTS_FILE_PASSWORD" | gpg --batch --yes --passphrase-fd 0 -c --cipher-algo AES256 "$ACCOUNTS_FILE"
    # Delete the unencrypted file
    rm "$ACCOUNTS_FILE"
    echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : INFOS : edited account $account_name" >> "$LOG_FILE"
}
show_account_manager_list_menu(){
    echo "__________________________________________________________"
    # edit an account
    echo "1- Edit an account"
    echo "2- Delete an account"
    echo "3- Exit"
    read -p "Enter your choice : " choice
}
manage_account_list(){
    in_list=true 
    while $in_list; do
        if [[ ! -f "$ACCOUNTS_FILE.gpg" ]]; then
            echo "No accounts found"
            echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : ERROR : failed to list all accounts" >> "$LOG_FILE"
            
            sleep 5
        else
            
            # When you need to read from the file, decrypt it first
            echo "$ACCOUNTS_FILE_PASSWORD" | gpg --batch --yes --passphrase-fd 0 -d "$ACCOUNTS_FILE.gpg" > "$ACCOUNTS_FILE"
            clear
            echo "Listing all accounts"  
            # When you need to read from the file, decrypt it first
            echo "$ACCOUNTS_FILE_PASSWORD" | gpg --batch --yes --passphrase-fd 0 -d "$ACCOUNTS_FILE.gpg" > "$ACCOUNTS_FILE"
                
            cat "$ACCOUNTS_FILE"
            # ebugging
            #sleep 5
            rm "$ACCOUNTS_FILE"
        fi

        show_account_manager_list_menu
        clear 
        echo "Listing all accounts"     
        cat "$ACCOUNTS_FILE"
        echo "__________________________________________________________"

        case $choice in
            1)
                edit_account
                ;;
            2)
                delete_account
                ;;
            3)
                echo "Exiting list"
                echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : INFOS : exited list" >> "$LOG_FILE"
                in_list=false
                ;;
            *)
                echo "Invalid choice"
                ;;
        esac
    done
}
password_manager(){
    echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : INFOS : access the passwords and accounts manager" >> "$LOG_FILE"
    #define a bool to check if the user is still in the password manager
    in_password_manager=true
    
    # do while loop to keep the user in the password manager until he exits
    while $in_password_manager; do
        show_password_manager_menu

        case $choice in
            1)

                echo "Enter the accounts file password :"
                read -s user_input
                # Encrypt password as MD5
                encrypted_ACCOUNTS_FILE_PASSWORD=$(echo -n "$user_input" | md5sum | awk '{print $1}')
                if [[ $encrypted_ACCOUNTS_FILE_PASSWORD != $ACCOUNTS_FILE_PASSWORD ]]; then
                    echo "Wrong password"
                    echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : ERROR : wrong accounts file password attempt" >> "$LOG_FILE"
                    sleep 5
                    continue
                fi
                add_ann_account
                ;;
            2)
                
                
                manage_account_list

                ;;
            3)
                change_password
                
                ;;
            4)
                echo "Exiting password manager"
                echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : INFOS : exited password manager" >> "$LOG_FILE"
                in_password_manager=false
                ;;
            *)
                echo "Invalid choice"
                ;;
        esac

    done
}

password_manager

