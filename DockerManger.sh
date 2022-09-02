#!/bin/bash

# Project: Docker Bash Manger
# Name: Mohammed Alsayegh
# The script uses whiptail to navigate into docker images and volumes lists for import, export, and deletion

clear

retval=()

function DockerImageNameSelect() {
    STATIONS=()
    number=()
    s2=()
    
    FILE=img_names.txt

    if test -f "$FILE"; then
        echo "$FILE exists."
        rm $FILE
    else 
        echo "$FILE does not exist."
    fi

    docker image list --format "table {{.Repository}}" > "$FILE"

    FILE=img_names.txt
    mapfile  -t STATIONS < <( cat $FILE) 
     
    cnt=${#STATIONS[@]}
    j=1
    for (( i=1 ; i<cnt ; i++ )); do
        s2[$j]="$(($i))"
        j=$(expr $j + 1)
        s2[j]=${STATIONS[i]}
        j=$(expr $j + 1)
    done
    
    choice=$(whiptail --title "Choose radio station:" --menu "select your choice" 0 0 0 "${s2[@]}" 3>&1 1>&2 2>&3)
     
    echo 'whiptail choice is: ' $choice
    number=$(expr $choice)
    echo 'number is: ' $number
    echo 'string is: ' ${STATIONS[$number]}
    retval="${STATIONS[$number]}"
}

function DockerVolumeNameSelect() {
    STATIONS3=()
    number3=()
    s2=()
    
    FILE=vol_names.txt

    if test -f "$FILE"; then
        echo "$FILE exists."
        rm $FILE
    else 
        echo "$FILE does not exist."
    fi
    docker volume list --format "table {{.Name}}" > "$FILE"

    FILE=vol_names.txt 
    mapfile  -t STATIONS3 < <( cat $FILE) 
     
    cnt=${#STATIONS3[@]}
    j=1
    for (( i=1 ; i<cnt ; i++ )); do
        s2[$j]="$(($i))"
        j=$(expr $j + 1)
        s2[j]=${STATIONS3[i]}
        j=$(expr $j + 1)
    done
    
    choice=$(whiptail --title "Choose radio station:" --menu "select your choice" 0 0 0 "${s2[@]}" 3>&1 1>&2 2>&3)
     
    echo 'whiptail choice is: ' $choice
    number3=$(expr $choice)
    echo 'number is: ' $number3
    echo 'string is: ' ${STATIONS3[$number3]}
    retval="${STATIONS3[$number3]}"
}

function tarSearshSelect() {
    STATIONS2=()
    number2=()
    s2=()

    FILE=tar_files_list.txt

    if test -f "$FILE"; then
        echo "$FILE exists."
        rm $FILE
    else 
        echo "$FILE does not exist."
    fi

    find -type f -name "*.tar" > "$FILE" 
    mapfile  -t STATIONS2 < <( cat $FILE)
     
    cnt=${#STATIONS2[@]}
    j=0
    for (( i=0 ; i<cnt ; i++ )); do
        s2[$j]="$(($i+1))"
        j=$(expr $j + 1)
        s2[j]=${STATIONS2[i]}
        j=$(expr $j + 1)
    done
    
    choice=$(whiptail --title "tar List:" --menu "Choose .tar from the list" 0 0 0 "${s2[@]}" 3>&1 1>&2 2>&3)
     
    echo 'whiptail choice is: ' $choice
    number2=$(expr $choice)
    echo 'number is: ' $number2
    echo 'string is: ' ${STATIONS2[$number2 -1]}
    retval="${STATIONS2[$number2 -1]}"
}

function tgzSearshSelect() {
    STATIONS2=()
    number2=()
    s2=()

    FILE=tgz_files_list.txt

    if test -f "$FILE"; then
        echo "$FILE exists."
        rm $FILE
    else 
        echo "$FILE does not exist."
    fi

    find -type f -name "*.tgz" > "$FILE" 
    mapfile  -t STATIONS2 < <( cat $FILE)
     
    cnt=${#STATIONS2[@]}
    j=0
    for (( i=0 ; i<cnt ; i++ )); do
        s2[$j]="$(($i+1))"
        j=$(expr $j + 1)
        s2[j]=${STATIONS2[i]}
        j=$(expr $j + 1)
    done
    
    choice=$(whiptail --title "tgz List:" --menu "Choose .tgz from the list" 0 0 0 "${s2[@]}" 3>&1 1>&2 2>&3)
     
    echo 'whiptail choice is: ' $choice
    number2=$(expr $choice)
    echo 'number is: ' $number2
    echo 'string is: ' ${STATIONS2[$number2 -1]}
    retval="${STATIONS2[$number2 -1]}"
}

function DockerManagerMenu() {
    SELECTED=$(whiptail --title "Image Volume Docker Manager" --fb --menu "Choose an option" 15 60 4 \
        "1" "image export into image.tar 💿" \
        "2" "image import from image.tar" \
        "3" "backup export into .tgz file 🔙🆙" \
        "4" "Volume import from .tgz 📦" \
        "5" "Remove image 🔥" \
        "6" "Remove volume 🔥" \
        "7" "Exit" \
        3>&1 1>&2 2>&3)

    case $SELECTED in
        1)
            echo "image saved gone start in few second"
            DockerImageNameSelect

            if [[ $retval =~ ['!@#$%^&*()_\+/'] ]]; then
                #echo yes
                store=$(echo $retval | tr '<>:\\//#%|?*' ' ')
            else
                echo no
            fi
            
            if (whiptail --title "Export Image" --yesno "Are you sure you want to export $retval ?" 8 78); then
                #time docker save -o "$retval"".tar" "$retval"
                time docker save -o "$store"".tar" "$retval"
                whiptail --title "Image save" --msgbox ""$retval" save successfully completed." 8 45
            else
                echo "User selected No, exit status was $?."
            fi

            DockerManagerMenu
        ;;
        2)
            echo "image load gone start in few second"
            tarSearshSelect
            
            if (whiptail --title "Import Image" --yesno "Are you sure you want to import $retval ?" 8 78); then
                time docker load -i "$retval"
                whiptail --title "Image load" --msgbox ""$retval" load successfully completed." 8 45
            else
                echo "User selected No, exit status was $?."
            fi

            DockerManagerMenu
        ;;
        3)
            echo "The backup gone start in few second"
            DockerVolumeNameSelect
            echo \ && read -p "Press key to continue.. " -n1 -s
            
            if (whiptail --title "Export Volume" --yesno "Are you sure you want to export $retval ?" 8 78); then
                time docker run --rm -v "$retval":/volume busybox sh -c 'tar -cOzf - volume' > "$retval".tgz
                whiptail --title "Option 1" --msgbox ""$retval" were fully backed up." 8 45
            else
                echo "User selected No, exit status was $?."
            fi
            DockerManagerMenu
        ;;
        4)
            echo "In a few seconds, the volume restore will start"
            docker volume ls

            tgzSearshSelect
            echo \ && read -p "Press key to continue.. " -n1 -s

            if (whiptail --title "Import Volume" --yesno "Are you sure you want to import $retval ?" 8 78); then
                docker volume create "${retval:2:-4}"
                docker run -v "${retval:2:-4}":/dbdata --name dbstore2 ubuntu /bin/bash
                time docker run --rm --volumes-from dbstore2 -v $(pwd):/backup ubuntu bash -c "cd /dbdata && tar xf /backup/"${retval:2}" --strip 1 -C /dbdata"
                docker stop dbstore2 && docker rm dbstore2
                whiptail --title "Volume restore" --msgbox ""${retval:2:-4}" restoration have been completed successfully." 8 45
            else
                echo "User selected No, exit status was $?."
            fi

            DockerManagerMenu
        ;;
        5)
            echo "Remove image 🔥"
            docker image ls

            DockerImageNameSelect
            echo \ && read -p "Press key to continue.. " -n1 -s

            if (whiptail --title "Remove Image" --yesno "Are you sure you want to remove $retval ?" 8 78); then
                time docker image rm "$retval"
                whiptail --title "Remove image" --msgbox "$retval have been removed" 8 45
            else
                echo "User selected No, exit status was $?."
            fi
            
            DockerManagerMenu
        ;;
        6)
            echo "Remove volume 🔥"
            docker volume ls

            DockerVolumeNameSelect
            echo \ && read -p "Press key to continue.. " -n1 -s
            
            if (whiptail --title "Remove volume" --yesno "Are you sure you want to remove $retval ?" 8 78); then
                time docker volume rm "$retval"
                whiptail --title "Remove volume" --msgbox "$retval have been removed" 8 45
            else
                echo "User selected No, exit status was $?."
            fi

            DockerManagerMenu
        ;;
        7)
            echo "Exit 🐟"
        ;;
    esac
}

function warning()
{
    if (whiptail --title "⚠️ WARNING" --yesno "There is still a lot of work to be done on this script or it has not been fully debugged. Would you like to use it?" 8 78); then
        DockerManagerMenu
    else
        echo "Docker Manager is closing!!"
    fi
}

warning