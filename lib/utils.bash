#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/Vyxal/Vyxal"
TOOL_NAME="vyxal2"
TOOL_TEST="vyxal2 '' 'h'"


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
        # Ensure Python 3.9 is fully installed via asdf
        asdf plugin-add python || true
        asdf install python 3.9.0 || true
        asdf local python 3.9.0

        # Get the exact Python installation path
        PYTHON_PATH=$(asdf which python3)
        PYTHON_DIR=$(dirname "$(dirname "$PYTHON_PATH")")

        echo "PYTHON_PATH = $PYTHON_PATH"
	echo "PYTHON_DIR = $PYTHON_DIR"

        mkdir -p "$install_path"
        cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"
        cd "$install_path"

        # Use the specific Python from asdf to install
        "$PYTHON_PATH" -m pip install . --user

        # Move vyxal package
	mv $HOME/.local/bin/vyxal ./vyxal2
        mv $PYTHON_DIR .

        # Update the shebang to use the exact Python path
        sed -i "1c#!$install_path/3.9.0/bin/python3" vyxal2
	cat vyxal2

        # Find the library path
	library_path=$(find -name "libpython3.9.so.1.0")
	
	if [ -n "$library_path" ]; then
	    # Get the directory containing the library
	    library_dir=$(dirname "$library_path")
            library_dir="${library_dir/\.\//$install_path/}"
	    
	    # Safely update LD_LIBRARY_PATH
	    if [ -z "${LD_LIBRARY_PATH+x}" ]; then
	        export LD_LIBRARY_PATH="$library_dir"
	    else
	        export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$library_dir"
	    fi
	    
	    echo "Found Python library at: $library_path - $library_dir"
	else
	    echo "Could not find libpython3.9.so.1.0"
	fi

        # Verify the installation
        local tool_cmd
        tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
        test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

        echo "$TOOL_NAME $version installation was successful!"

cd 3.9.0/lib
ls .
    ) || (
        rm -rf "$install_path"
        fail "An error occurred while installing $TOOL_NAME $version."
    )
}
