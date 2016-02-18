UNITY_LINK=/Applications/Unity
UNITY_PATH=/Applications/Unity/Unity.app/Contents/MacOS/Unity
UNITY_INSTALL_LOCATION=/Applications
UVM_VERSION=0.0.1

function join { local IFS="$1"; shift; echo "$*";  }

uvm ()
{
    uvm_print_header
    uvm_list_available_versions
}

uvm_print_header()
{
    echo "Unity Version Manager - v$UVM_VERSION"
    echo ""

}
uvm_current_unity_version()
{
    local plist_path="${UNITY_PATH%MacOS/Unity}Info.plist"
    if [[ -f "$plist_path" ]]; then
        local VERSION=`/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' $plist_path`
        echo $VERSION
    else
        echo "No unity version detected"
        return -1
    fi
}

uvm_use_version()
{
    local desired_version="$1"
    local desired_version_path="$UNITY_INSTALL_LOCATION/Unity$desired_version" 
    if [[ ! -d $desired_version_path ]]
    then
        echo "Version $desired_version isn't installed"
        echo "Available versions are - "
        uvm_list_available_versions
    else
        #nothing exists in the unity dir
        if [[ ! -e  "$UNITY_LINK" ]]; then
            ln -s "$desired_version_path" "$UNITY_LINK"
        fi

        #link exists
        if [[ -h "$UNITY_LINK" ]]
        then
            echo "Switching from `uvm_current_unity_version` to $desired_version..."
            rm "$UNITY_LINK"
            ln -s "$desired_version_path" "$UNITY_LINK"
        fi

        #standard unity install, need to rename folder and create link
        if [[ -d "$UNITY_LINK" && ! -L "$UNITY_LINK" ]]; then
            echo "setting up link "
        fi
    fi
}

uvm_list_available_versions()
{
    local current_version=`uvm_current_unity_version`
    echo "LOCAL:"
    for version in `uvm_list_local_versions`
    do
        if [[ "$version" == "${current_version%f*}" ]]
        then
            echo "  $version [active]"
        else
            echo "  $version"
        fi
    done
}

uvm_list_local_versions()
{
    local -a version_numbers=()

    for version in `find $UNITY_INSTALL_LOCATION -name "Unity*" -type d -maxdepth 1`
    do
        local version_number="${version#*Unity}"
        version_numbers+=($version_number)
    done

    echo ${version_numbers[*]}
}


