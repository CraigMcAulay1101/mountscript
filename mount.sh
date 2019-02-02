#!/bin/bash

remove()
{
    # Try to remove symlink first.
    if [[ -L "$homedir" ]]; then

        sudo rm "$homedir"

        if [[ -L "$homedir" ]]; then
            echo "failed to remove symlink. Exiting"
            exit 1
        else 
            echo "Symlink $homedir has been removed."
        fi

    else
        echo "$homedir does not exist"
    fi

    # Try to unmount the server.
    if [[ -d "$mntdir" ]]; then

        sudo fusermount -u "$mntdir"
        sudo rmdir "$mntdir"

        if [[ -d "$mntdir" ]]; then 
            echo "Failed to unmount server. Exiting..."
            exit 1
        else
            echo "$hostname has been unmounted from $mntdir."
        fi
            
    else
        echo "$mntdir does not exist"
    fi

    exit 1
}

#### MAIN ####
while getopts "u:h:p:r" opt; do
  case ${opt} in
    u ) 
        # username
        username=$OPTARG
      ;;
    h ) 
        # hostname
        hostname=$OPTARG

        # dir variables
        mntdir="/mnt/$hostname"
        homedir="$HOME/$hostname"
      ;;
    p )
        # server path to mount
        path=$OPTARG
    ;;
    r )
        # if remove flag is passed
        remove
    ;;
    \? ) 
        echo "Invalid option. Usage: [-u] username [-h] hostname -p path -r remove"
      ;;
  esac
done

if [[ ! -d "$mntdir" && ! -L "$homedir" ]]; then

    sudo mkdir $mntdir
    sudo sshfs -o allow_other ${username}@${hostname}:/ "$mntdir"
   
    if [ ! -z ${path} ]; then
        # mount the path specified
        sudo ln -s "$mntdir/$path" "$homedir"
    else
        # mount the / dir
        sudo ln -s "$mntdir/" "$homedir"
    fi

    echo "Server has successfully been mounted to $homedir"   
        
else
    echo "Failed to mount server. Ensure mount point does not currently exist $mntdir"
fi