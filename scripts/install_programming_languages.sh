#!/bin/bash

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
}' > hello.go
    go run hello.go
    rm hello.go
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
    echo 'main = putStrLn "Hello, Haskell!"' > hello.hs
    runhaskell hello.hs
    rm hello.hs
}

install_rust() {
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
}

purge_rust() {
    echo "Purging Rust..."
    rustup self uninstall -y
}

verify_rust() {
    echo 'fn main() {
    println!("Hello, Rust!");
}' > hello.rs
    rustc hello.rs
    ./hello
    rm hello.rs hello
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
    echo 'console.log("Hello, Node.js!");' > hello.js
    node hello.js
    rm hello.js
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
}' > hello.c
    gcc hello.c -o hello
    ./hello
    rm hello.c hello
}

install_python() {
    echo "Installing Python and pip..."
    sudo apt install -y python3 python3-pip
    echo "Installing virtualenv..."
    sudo pip3 install virtualenv
}

purge_python() {
    echo "Purging Python and virtualenv..."
    sudo apt remove --purge -y python3 python3-pip
    sudo pip3 uninstall -y virtualenv
    sudo apt autoremove -y
}

verify_python() {
    echo 'print("Hello, Python!")' > hello.py
    python3 hello.py
    rm hello.py
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
    read -p "Enter choice: " action
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
    echo "Select programming languages:"
    options=("Go" "Haskell" "Rust" "Node.js" "C/C++" "Python" "All")
    for i in "${!options[@]}"; do
        printf "%d) %s\n" $((i+1)) "${options[i]}"
    done
    read -p "Enter numbers separated by spaces: " selections
    if [[ -z "$selections" ]]; then
        selections=(7)
    else
        read -a selections <<< "$selections"
    fi
    for selection in "${selections[@]}"; do
        case $selection in
            1) langs+=("go") ;;
            2) langs+=("haskell") ;;
            3) langs+=("rust") ;;
            4) langs+=("node") ;;
            5) langs+=("gcc") ;;
            6) langs+=("python") ;;
            7) langs=("${options[@]:0:6}") ;;
            *) echo "Invalid selection: $selection" ;;
        esac
    done
}

update_and_install

while true; do
    menu_action
    action=$?
    menu_action
    read -p "Enter choice: " action
    if [[ $action == 4 ]]; then
        exit 0
    fi
    menu_language
    case $action in
        1)
            for lang in "${langs[@]}"; do
                case $lang in
                    go) install_go ;;
                    haskell) install_haskell ;;
                    rust) install_rust ;;
                    node) install_node ;;
                    gcc) install_gcc ;;
                    python) install_python ;;
                esac
            done
            ;;
        2)
            for lang in "${langs[@]}"; do
                case $lang in
                    go) purge_go ;;
                    haskell) purge_haskell ;;
                    rust) purge_rust ;;
                    node) purge_node ;;
                    gcc) purge_gcc ;;
                    python) purge_python ;;
                esac
            done
            ;;
        3)
            for lang in "${langs[@]}"; do
                case $lang in
                    go) verify_go ;;
                    haskell) verify_haskell ;;
                    rust) verify_rust ;;
                    node) verify_node ;;
                    gcc) verify_gcc ;;
                    python) verify_python ;;
                esac
            done
            ;;
    esac
    unset langs
    echo "Action completed."
done
