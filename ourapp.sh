#test log file in the .env
loadParamaetres(){
    # Load environment variables from .env file
    if [[ -f ".env" ]]; then
        source .env

        # Check if LOG_FILE is already set in .env file
        if [[ -n "$LOG_FILE" ]]; then
            echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : INFOS : Started a session" >> "$LOG_FILE"
        else
            LOG_FILE="log.txt"
            # Save log file name to .env file
            if [[ -f ".env" ]]; then
                # Check if LOG_FILE is already set in .env file
                if grep -q "LOG_FILE=" .env; then
                    sed -i "s/LOG_FILE=.*/LOG_FILE=$LOG_FILE/" .env
                else
                    echo "LOG_FILE=$LOG_FILE" >> .env
                fi
            else
                echo "LOG_FILE=$LOG_FILE" > .env
            fi
            echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : INFOS : set logfile to default, using log file" >> "$LOG_FILE"
    
        fi


        # create the lg file if not existant and write a message of this format to it  yyyy-mm-dd-hh-mm-ss : username : INFOS : started usin log file 
        if [[ ! -f "$LOG_FILE" ]]; then
            touch "$LOG_FILE"
            echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : INFOS : started using log file" >> "$LOG_FILE"
        fi

        # Save log file name to .env file
        if [[ -f ".env" ]]; then
            # Check if LOG_FILE is already set in .env file
            if grep -q "LOG_FILE=" .env; then
                sed -i "s/LOG_FILE=.*/LOG_FILE=$LOG_FILE/" .env
            else
                echo "LOG_FILE=$LOG_FILE" >> .env
            fi
        else
            echo "LOG_FILE=$LOG_FILE" > .env
        fi




    else
        echo "script stopped .env file not found"
        if [[ ! -f "log.txt" ]]; then
            touch "log.txt"
        fi
        echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : ERROR : .env file was not found" >> "log.txt"
        exit 404
    fi
}

CheckZenityDependence(){
    package_name="zenity"
    
    #checks if the package zenity is installed
    dpkg-query -W -f='${Status}\n' $package_name | grep -q 'installed'

    if [ $? -eq 0 ]; then
        return 0
    else

        #we should install the package 
        echo "$package_name is not installed. Installing..."
        sudo apt update
        sudo apt install -y $package_name
        if [ $? -eq 0 ]; then
            echo "$package_name has been successfully installed."
            return 0
        else
            echo "Failed to install $package_name. Please check your internet connection."
            return 1
        fi
    fi
}

PopulateListWithFileNames(){	

    #checks if there is a folder provided as an argument and the folder does exist  
    if [ $# -ge 1 ]; then
    	if [ -d "$1" ]; then
		selected_dir=$1
	else
		echo "Directory does not exist"
		return 1
        fi
    else
        #checks the installation of zenity the GUI lib
        CheckZenityDependence
        if [ $? -eq 0 ];then
            selected_dir=$(zenity --file-selection --directory --title="Select a directory ")
            #if any error occured we exit
            if [ $? -ne 0 ]; then
                echo "Directory selection canceled."
                return 2
            fi  
        else
            #zenity failed to install exit
            echo "there is a problem installing zenity, you may to use an argument of the target folder "
            return 3
        fi
    fi

    #move to the folder that will be organized
    cd "$selected_dir" || { echo "Failed to change directory."; return 4; }

    #loop and save all the file names that are in the folder
    while IFS= read -r -d '' file; do
        FileNamesList+=("$file")
    done < <(find . -maxdepth 1 -type f -print0)

    return 0
}
FileOrganizer(){


    PopulateListWithFileNames $1

    if [ $? -eq 0 ];then

        for File in "${FileNamesList[@]}"; do

            Extension=$(echo "$File" | sed 's/.*\.//' )

            case $Extension in 
                "aif" | "cda" | "mid" | "midi" | "mp3" | "mpa" | "ogg" | "wav" | "wma" | "wpl" )
                    MoveFileToCorrectFolder "Audio"  "$File"
                    ;;
                "7z" | "arj" | "deb" | "pkg" | "rar" | "rpm" | "tar" | "gz" | "z" | "zip" )
                    MoveFileToCorrectFolder "Compressed" "$File"
                    ;;
                "dmg" | "iso" | "toast" | "vcd" )                
                    MoveFileToCorrectFolder "Disc and media" "$File"
                    ;;
                "csv" | "dat" | "db" | "dbf" | "log" | "mdb" | "sav" | "sql" | "tar" | "xml" | "accdb" )
                    MoveFileToCorrectFolder "Data and database" "$File"
                    ;;
                "email" | "eml" | "emlx" | "msg" | "oft" | "ost" | "pst" | "vcf" )
                    MoveFileToCorrectFolder "E-mail" "$File"
                    ;;
                "bat" | "bin" | "com" | "exe" | "gadget" | "msi" | "sh" | "wsf" )
                    MoveFileToCorrectFolder "Executable" "$File"
                    ;;
                "fnt" | "fon" | "otf" | "ttf" )
                    MoveFileToCorrectFolder "Font" "$File"
                    ;;
                "ai" | "bmp" | "gif" | "ico" | "jpeg" | "jpg" | "png" | "ps" | "psd" | "scr" | "svg" | "tif" | "tiff" | "webp" )
                    MoveFileToCorrectFolder "Image" "$File"
                    ;;
                "asp" | "aspx" | "cer" | "cfm" | "cgi" | "pl" | "css" | "htm" | "html" | "js" | "jsp" | "part" | "php"  | "rss" | "xhtml" )
                    MoveFileToCorrectFolder "Web related" "$File"
                    ;;
                "key" | "odp" | "pps" | "ppt" | "pptx" )
                    MoveFileToCorrectFolder "Presentation" "$File"
                    ;;
                "apk" | "c" | "class" | "cpp" | "cs" | "h" | "jar" | "java" | "php" | "py" | "sh" | "swift" | "vb" )
                    MoveFileToCorrectFolder "Programming" "$File"
                    ;;
                "ods" | "xls" | "xlsm" | "xlsx" )
                    MoveFileToCorrectFolder "Spreadsheet" "$File"
                    ;;
                "bak" | "cab" | "cfg" | "cpl" | "cur" | "dll" | "dmp" | "drv" | "icns" | "ico" | "ini" | "msi" | "sys" | "tmp" ) 
                    MoveFileToCorrectFolder "System related" "$File"
                    ;;
                "3g2" | "3gp" | "avi" | "flv" | "h264" | "m4v" | "mkv" | "mov" | "mp4" | "mpg" | "mpeg" | "rm" | "swf" | "vob" | "webm" | "wmv" )
                    MoveFileToCorrectFolder "Video" "$File"
                    ;;
                "doc" | "docx" | "odt" | "pdf" | "rtf" | "tex" | "txt" | "wpd" )
                    MoveFileToCorrectFolder "Word PDF TEXT" "$File"
                    ;;
                *)
                    if [ $Extension != "lnk" ]; then
                        MoveFileToCorrectFolder "Other" "$File"
                    fi
                    ;;
            esac 
        done
        dpkg-query -W -f='${Status}\n' $package_name | grep -q 'installed'

	    if [ $? -eq 0 ]; then
		    zenity --info --text="The folder has been organized"
	    else
		    echo "The folder has been organized"
	    fi
    fi
}

MoveFileToCorrectFolder(){
    FolderName=$1
    FileName=$2
    if [ ! -d "$FolderName" ]; then
        mkdir "$FolderName" 
    fi
    mv "$FileName" "$FolderName/"
}
printHelp(){
    echo "Usage:"
    echo "Command [-h] : for help "
    echo "Command [-o Folder] : organise the files in the folder"
    echo "Command [-p] : for password and accounts manager"
    echo "Command [-f] : for forking the script"
    echo "Command [-t] : executing via passwords"
    echo "Command [-l LOGFILE] : change default logfile to LOGFILE"
    echo "Command [-r PARAMETERS] : change default parameters to PARAMETERS"
}

change_log_file(){
    logfile=$1
    # Change log file name if specified as command line argument
    if [[ -n "$logfile" ]]; then
        LOG_FILE="$logfile"
        echo "Changed log file name to $LOG_FILE"
        # Save log file name to .env file
        if [[ -f ".env" ]]; then
            # Check if LOG_FILE is already set in .env file
            if grep -q "LOG_FILE=" .env; then
                sed -i "s/LOG_FILE=.*/LOG_FILE=$LOG_FILE/" .env
            else
                echo "LOG_FILE=$LOG_FILE" >> .env
            fi
        else
            echo "LOG_FILE=$LOG_FILE" > .env
        fi
    fi
}
execute_script_in_fork()
{
    echo "Executing script in fork"
}
execute_script_in_thread()
{
    echo "Executing script in thread"
}
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


#!/bin/bash
if [[ $# -eq 0 ]]; then
    echo "Usage: Command [-h] [-f] [-t] [-l LOGFILE] [-r PARAMETERS]"
    exit 1
fi

loadParamaetres
FileNamesList=()



# Variables to track if options are set
f_set=false
t_set=false
r_set=false


while getopts "o:hftl:r:p" opt; do
    case ${opt} in
        o ) # show the argument after o
            echo "Organising the folder $OPTARG"
            FileOrganizer $OPTARG
            ;; 
        h ) # process option h
            printHelp
            ;;
        f ) # process option f
            f_set=true
            execute_script_in_fork
            ;;
        t ) # process option t
            t_set=true
            execute_script_in_thread
            ;;
        l ) # process option l
            change_log_file $OPTARG
        ;;
        r ) # process option r
            parameters=$OPTARG
            echo "Changed parameters to $parameters"
        ;;
        p ) # process option r
                echo "Enter the password to login :"
                tmp_var=""
                read -s tmp_var
                # Encrypt password as MD5
                encrypted_password=$(echo -n "$tmp_var" | md5sum | awk '{print $1}')
                if [[ $encrypted_password != $PASSWORD ]]; then
                    # exit if password is not correct after writing to log file
                    echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : ERROR : wrong password attempt" >> "$LOG_FILE"
                    exit 1
                fi
                password_manager
                
                
            ;;
        \? ) echo "Usage: cmd [-h] [-o FOLDER] [-p] [-f] [-t] [-l LOGFILE] [-r PARAMETERS] [-p]"
        ;;
    esac
done

# Rest of the script...