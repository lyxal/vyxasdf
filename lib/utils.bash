#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/Vyxal/Vyxal"
TOOL_NAME="vyxal"
TOOL_TEST="vyxal --help"

# Source the Python installer script
source_python_installer() {
    local installer_path="$1"
    if [ ! -f "$installer_path" ]; then
        echo "Error: Python installer script not found at $installer_path"
        return 1
    fi
    
    # Source the installer script
    source "$installer_path"
    
    # Check if required functions are available
    if ! declare -F install_python39 > /dev/null; then
        echo "Error: Required functions not found in installer script"
        return 1
    fi
}

# Function to ensure Python 3.9 is available
ensure_python39() {
    local installer_script="$1"
    
    # Check if Python 3.9 is already installed
    if command -v python3.9 >/dev/null 2>&1; then
        echo "Python 3.9 is already installed"
        python3.9 --version
        return 0
    fi
    
    echo "Python 3.9 not found, installing..."
    
    # Source the installer
    if ! source_python_installer "$installer_script"; then
        echo "Failed to source Python installer script"
        return 1
    fi
    
    # Run the installation
    install_python39
    
    # Verify installation
    if ! command -v python3.9 >/dev/null 2>&1; then
        echo "Failed to install Python 3.9"
        return 1
    fi
    
    echo "Python 3.9 installation completed successfully"
    return 0
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_SCRIPT="$SCRIPT_DIR/install_python39.sh"

# Call the function to ensure Python 3.9 is installed
ensure_python39 "$INSTALLER_SCRIPT"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//' |
		grep '^2\.' # Only list v2.x.x releases
}

list_all_versions() {
	list_github_tags
}

download_release() {
	local version filename url
	version="$1"
	filename="$2"
	url="$GH_REPO/archive/v${version}.tar.gz"

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"
	
	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"
		cd "$install_path"
		pipx install . --python 3.9

		# TODO: Assert vyxal executable exists.
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
