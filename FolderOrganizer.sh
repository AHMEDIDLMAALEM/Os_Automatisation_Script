#!/bin/bash

#List that will hold the file names 
FileNamesList=()

CheckDependency(){
    package_name="$1"

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
        CheckDependency zenity
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

    #Fills the list with file names 
    PopulateListWithFileNames $1

    if [ $? -eq 0 ];then

        # That is the main loop that will loop through existing files 
        # It will create categorized folders based on the extensions of existing files
        # moves the file to the correspondent folder 

        for File in "${FileNamesList[@]}"; do

            #get the extension from the file
            Extension=$(echo "$File" | sed 's/.*\.//' )

            #a switch case that will categorize files and make them into a folder 
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

        # if zenity exist use it to display an info else use the echo
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

    #if the folder doesn't exist create a new one
    if [ ! -d "$FolderName" ]; then
        mkdir "$FolderName" 
    fi

    #move the file to the folder
    mv "$FileName" "$FolderName/"
}

#calling the main function that takes a path as an argument 
FileOrganizer $1
