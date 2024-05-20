#!/bin/bash
#test log file in the .env
echo "---------------------Arguments: $@---------------------"
loadParamaetres(){
    # Load environment variables from .env file
    if [ -f "test.env" ]; then
        source test.env

        # Check if LOG_FILE is already set in .env file
        if [ -n "$LOG_FILE" ]; then
            echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : INFOS : Started a session" >> "$LOG_FILE"
        else
            LOG_FILE="log.txt"
            # Save log file name to .env file
            if [ -f "test.env" ]; then
                # Check if LOG_FILE is already set in .env file
                if grep -q "LOG_FILE=" test.env; then
                    sed -i "s/LOG_FILE=.*/LOG_FILE=$LOG_FILE/" test.env
                else
                    echo "LOG_FILE=$LOG_FILE" >> test.env
                fi
            else
                echo "LOG_FILE=$LOG_FILE" > test.env
            fi
            echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : INFOS : set logfile to default, using log file" >> "$LOG_FILE"
    
        fi


        # create the lg file if not existant and write a message of this format to it  yyyy-mm-dd-hh-mm-ss : username : INFOS : started usin log file 
        if [ ! -f "$LOG_FILE" ]; then
            touch "$LOG_FILE"
            echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : INFOS : started using log file" >> "$LOG_FILE"
        fi

        # Save log file name to .env file
        if [ -f "test.env" ]; then
            # Check if LOG_FILE is already set in .env file
            if grep -q "LOG_FILE=" test.env; then
                sed -i "s/LOG_FILE=.*/LOG_FILE=$LOG_FILE/" test.env
            else
                echo "LOG_FILE=$LOG_FILE" >> test.env
            fi
        else
            echo "LOG_FILE=$LOG_FILE" > test.env
        fi




    else


        echo "script stopped .env file not found"
        if [ ! -f "log.txt" ]; then
            touch "log.txt"
        fi
        echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : ERROR : .env file was not found" >> "log.txt"
        exit 404
    fi
}
printHelp(){
    echo "Usage:"
    echo "Command [-h] : for help "
    echo "Command [-o Folder] : organise the files in the folder or "" to select the folder using GUI"
    echo "Command [-c File|Folder] : for crypting the file or folder"
    echo "Command [-p] : for password and accounts manager"
    echo "Command [-f] : for forking the script"
    echo "Command [-t] : executing via passwords"
    echo "Command [-l LOGFILE] : change default logfile to LOGFILE"
    echo "Command [-r PARAMETERS] : change default parameters to PARAMETERS"
}
change_log_file(){
    logfile=$1
    # Change log file name if specified as command line argument
    if [ -n "$logfile" ]; then
        LOG_FILE="$logfile"
        echo "Changed log file name to $LOG_FILE"
        # Save log file name to .env file
        if [ -f "test.env" ]; then
            # Check if LOG_FILE is already set in .env file
            if grep -q "LOG_FILE=" test.env; then
                sed -i "s/LOG_FILE=.*/LOG_FILE=$LOG_FILE/" test.env
            else
                echo "LOG_FILE=$LOG_FILE" >> test.env
            fi
        else
            echo "LOG_FILE=$LOG_FILE" > test.env
        fi
    fi
}
execute_script_in_fork()
{

    # wait for 2s
    sleep 5
    # loop through the arguments and execute the script in fork
    ./forkapp $newargs
    
}
execute_script_in_thread()
{
    echo "Executing script in thread"
}




#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: Command [-h] [-f] [-t] [-l LOGFILE] [-r PARAMETERS]"
    exit 1
fi

loadParamaetres

FileNamesList=()



# Variables to track if options are set
f_set=false
t_set=false
r_set=false



while getopts "o:hftl:r:pc:" opt; do
    case ${opt} in
        o ) # show the argument after o
            source ./fileOrganiser.sh "$OPTARG"
            ;; 
        h ) # process option h
            printHelp
            ;;
        f ) # process option f
            f_set=true

            # select only the arguments that are not -f or forkapp
            newargs=()
            for arg in "$@"; do
            if [[ $arg != "-f" && $arg != "forkapp" ]]; then
                if [[ $arg == "-o" ]]; then
                echo " in -o:"
                newargs+=("$arg")
                newargs+=("$OPTARG")
                elif [[ $arg == "-c" ]]; then
                echo " in -c:"
                newargs+=("$arg")
                newargs+=("$OPTARG")
                else
                newargs+=("$arg")
                fi
            fi
            done
            # execute the script in fork
            echo "Executing script in fork $newargs"
            execute_script_in_fork "${newargs[@]}" &
            # exit
            exit 0
            

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
                if [ $encrypted_password != $PASSWORD ]; then
                    # exit if password is not correct after writing to log file
                    echo "$(date +"%Y-%m-%d-%H-%M-%S") : $USER : ERROR : wrong password attempt" >> "$LOG_FILE"
                    exit 1
                fi

                source ./passwordManager.sh
                #  password_manager
                
                
            ;;
        c ) # show the argument after o
            source ./crypter.sh "$OPTARG"
            ;; 
        \? ) echo "Usage: cmd [-h] [-o FOLDER|""] [-c FILE|FOLDER] [-p] [-f] [-t] [-l LOGFILE] [-r PARAMETERS] [-p]"
            echo "-h for more help"
        ;;
    esac
done

# Rest of the script...