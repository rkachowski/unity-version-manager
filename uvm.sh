readonly UNITY_LINK=/Applications/Unity
readonly UNITY_PATH=/Applications/Unity/Unity.app/Contents/MacOS/Unity
readonly UNITY_INSTALL_LOCATION=/Applications
readonly UVM_VERSION=0.0.2
readonly UVM_WEBPAGE="https://github.com/rkachowski/unity-version-manager/"

function join { local IFS="$1"; shift; echo "$*";  }

function uvm_help ()
{
    uvm_print_header
    uvm_print_help
}

function uvm_print_help ()
{
    echo "help - show this help"
    echo "use <version> - use a specific unity version "
    echo "list - list unity versions available"
    echo "current - list the current unity version"
    echo ""
}

function uvm_print_header()
{
    echo "= Unity Version Manager - v$UVM_VERSION"
    echo ""
    echo " * $UVM_WEBPAGE"
    echo ""

}
function uvm_current_unity_version()
{
    local plist_path="${UNITY_PATH%MacOS/Unity}Info.plist"
    if [[ -f "$plist_path" ]]; then
        local VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' $plist_path)
        echo $VERSION
    else
        echo "No unity version detected"
        return -1
    fi
}

function uvm_use_version()
{
    local desired_version="$1"
    local desired_version_path="$UNITY_INSTALL_LOCATION/Unity$desired_version"

    if [[ ! -d $desired_version_path ]]; then
        echo "Version $desired_version isn't installed"
        echo "Available versions are - "
        uvm_list_available_versions
    else
        #nothing exists in the unity dir
        if [[ ! -e  "$UNITY_LINK" ]]; then
            ln -s "$desired_version_path" "$UNITY_LINK"
        fi

        #link exists
        if [[ -h "$UNITY_LINK" ]]; then
            echo "Switching from $(uvm_current_unity_version) to $desired_version..."
            rm "$UNITY_LINK"
            ln -s "$desired_version_path" "$UNITY_LINK"
        fi

        #standard unity install, need to rename folder and create link
        if [[ -d "$UNITY_LINK" && ! -L "$UNITY_LINK" ]]; then
            echo "setting up link "
        fi
    fi
}

function uvm_list_available_versions()
{
    local current_version=$(uvm_current_unity_version)
    echo "LOCAL:"
    for version in $(uvm_list_local_versions); do
        if [[ "$version" == "${current_version%f*}" ]]
        then
            echo "  $version [active]"
        else
            echo "  $version"
        fi
    done
}

function uvm_list_local_versions()
{
    local -a version_numbers=()

    for version in $(find $UNITY_INSTALL_LOCATION -name "Unity*" -type d -maxdepth 1); do
        local version_number="${version#*Unity}"
        version_numbers+=($version_number)
    done

    echo ${version_numbers[*]}
}


#argument parsing
while [[ $# > 0  ]]
do
    key="$1"
    case $key in
        help)
            uvm_help
            shift # past argument
            exit 0
            ;;
        use)
            to_use="$2"
            if [[ ! ${#to_use} -gt 4 ]]; then
                echo "Invalid version '$to_use'"
                echo "Please enter a version in the format 'X.X.X'"
                echo ""
                exit -2
            fi

            uvm_use_version "$2"
            exit 0
            ;;
        list)
            uvm_print_header
            uvm_list_available_versions
            exit 0
            ;;
        current)
            uvm_print_header
            echo "Active: "$(uvm_current_unity_version)
            exit 0
            ;;
        *) # unknown option
            uvm_help
            echo ""
            echo "Unknown option '$key'"
            echo ""
            exit -1
            ;;
    esac
    shift
done

#no arguments passed
if [[ $# -eq 0 ]]; then
    uvm_help
fi

