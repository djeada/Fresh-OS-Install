#!/bin/bash

set -e

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

update_and_install() {
    echo "Updating package lists..."
    sudo apt update
}

install_go() {
    echo "Installing Go..."
    sudo apt install -y golang
}

purge_go() {
    echo "Purging Go..."
    sudo apt remove --purge -y golang
    sudo apt autoremove -y
}

verify_go() {
    echo 'package main
import "fmt"
func main() {
    fmt.Println("Hello, Go!")
}' > "$TMPDIR/hello.go"
    go run "$TMPDIR/hello.go"
    rm -f "$TMPDIR/hello.go"
}

install_haskell() {
    echo "Installing Haskell Platform..."
    sudo apt install -y haskell-platform
}

purge_haskell() {
    echo "Purging Haskell Platform..."
    sudo apt remove --purge -y haskell-platform
    sudo apt autoremove -y
}

verify_haskell() {
    echo 'main = putStrLn "Hello, Haskell!"' > "$TMPDIR/hello.hs"
    runhaskell "$TMPDIR/hello.hs"
    rm -f "$TMPDIR/hello.hs"
}

install_rust() {
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
}

purge_rust() {
    echo "Purging Rust..."
    rustup self uninstall -y
}

verify_rust() {
    echo 'fn main() {
    println!("Hello, Rust!");
}' > "$TMPDIR/hello.rs"
    rustc "$TMPDIR/hello.rs" -o "$TMPDIR/hello"
    "$TMPDIR/hello"
    rm -f "$TMPDIR/hello.rs" "$TMPDIR/hello"
}

install_node() {
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
}

purge_node() {
    echo "Purging Node.js..."
    sudo apt remove --purge -y nodejs
    sudo apt autoremove -y
}

verify_node() {
    echo 'console.log("Hello, Node.js!");' > "$TMPDIR/hello.js"
    node "$TMPDIR/hello.js"
    rm -f "$TMPDIR/hello.js"
}

install_gcc() {
    echo "Installing GCC and build-essential..."
    sudo apt install -y build-essential
}

purge_gcc() {
    echo "Purging GCC and build-essential..."
    sudo apt remove --purge -y build-essential
    sudo apt autoremove -y
}

verify_gcc() {
    echo '#include <stdio.h>
int main() {
    printf("Hello, C!\\n");
    return 0;
}' > "$TMPDIR/hello.c"
    gcc "$TMPDIR/hello.c" -o "$TMPDIR/hello"
    "$TMPDIR/hello"
    rm -f "$TMPDIR/hello.c" "$TMPDIR/hello"
}

install_python() {
    echo "Installing Python and pip..."
    sudo apt install -y python3 python3-pip python3-venv
}

purge_python() {
    echo "Purging Python and pip..."
    sudo apt remove --purge -y python3 python3-pip python3-venv
    sudo apt autoremove -y
}

verify_python() {
    echo 'print("Hello, Python!")' > "$TMPDIR/hello.py"
    python3 "$TMPDIR/hello.py"
    rm -f "$TMPDIR/hello.py"
}

install_all() {
    install_go
    install_haskell
    install_rust
    install_node
    install_gcc
    install_python
}

purge_all() {
    purge_go
    purge_haskell
    purge_rust
    purge_node
    purge_gcc
    purge_python
}

verify_all() {
    verify_go
    verify_haskell
    verify_rust
    verify_node
    verify_gcc
    verify_python
}

menu_action() {
    echo "Select action:"
    echo "1) Install"
    echo "2) Purge"
    echo "3) Verify"
    echo "4) Exit"
    read -rp "Enter choice: " action
    case $action in
        1|2|3)
            ;;
        4)
            exit 0
            ;;
        *)
            echo "Invalid choice."
            menu_action
            ;;
    esac
}

menu_language() {
    local selected_langs=()
    echo "Select programming languages:"
    options=("Go" "Haskell" "Rust" "Node.js" "C/C++" "Python" "All")
    for i in "${!options[@]}"; do
        printf "%d) %s\n" $((i+1)) "${options[i]}"
    done
    read -rp "Enter numbers separated by spaces: " selections_input
    if [[ -z "$selections_input" ]]; then
        selected_langs=(go haskell rust node gcc python)
    else
        read -ra selections <<< "$selections_input"
        for selection in "${selections[@]}"; do
            case $selection in
                1) selected_langs+=("go") ;;
                2) selected_langs+=("haskell") ;;
                3) selected_langs+=("rust") ;;
                4) selected_langs+=("node") ;;
                5) selected_langs+=("gcc") ;;
                6) selected_langs+=("python") ;;
                7) selected_langs=(go haskell rust node gcc python); break ;;
                *) echo "Invalid selection: $selection" ;;
            esac
        done
    fi
    langs=("${selected_langs[@]}")
}

update_and_install

while true; do
    menu_action
    menu_language
    for lang in "${langs[@]}"; do
        case $action in
            1)
                case $lang in
                    go) install_go ;;
                    haskell) install_haskell ;;
                    rust) install_rust ;;
                    node) install_node ;;
                    gcc) install_gcc ;;
                    python) install_python ;;
                esac
                ;;
            2)
                case $lang in
                    go) purge_go ;;
                    haskell) purge_haskell ;;
                    rust) purge_rust ;;
                    node) purge_node ;;
                    gcc) purge_gcc ;;
                    python) purge_python ;;
                esac
                ;;
            3)
                case $lang in
                    go) verify_go ;;
                    haskell) verify_haskell ;;
                    rust) verify_rust ;;
                    node) verify_node ;;
                    gcc) verify_gcc ;;
                    python) verify_python ;;
                esac
                ;;
        esac
    done
    unset langs
    echo "Action completed."
done
