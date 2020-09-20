#!/bin/bash

# Menu for admin, vpn, and security functions

function invalid_opt() {
  echo ""
  echo "Invalid option"
  echo ""
  sleep 2
}

function menu() {
  #clear screen
  clear

  echo "[1] Admin Menu"
  echo "[2] Security Menu"
  echo "[3] Exit"
  read -p "Please enter a choice: " choice

  case "$choice" in
    1) admin_menu
    ;;

    2) security_menu
    ;;

    3) exit 0
    ;;

    *)
      invalid_opt
      # Call the main menu
      menu
    ;;
  esac
}

function admin_menu() {
  clear

  echo "[L]ist running proccesses"
  echo "[N]etwork Sockets"
  echo "[V]PN Menu"
  echo "[4] Exit"
  read -p "Please enter a choice: " choice

  case "$choice" in
    L|l) ps -ef | less
    ;;
    N|n) netstat -an --inet | less
    ;;
    V|v) vpn_menu
    ;;
    4) exit 0
    ;;
    *)
      invalid_opt
      admin_menu
    ;;
  esac

admin_menu
}

function vpn_menu() {
  clear
  echo "[A]dd a a peer"
  echo "[D]elete a peer"
  echo "[B]ack to admin menu"
  echo "[M]ain menu"
  echo "[E]xit"
  read -p "Please select an option: " choice

  case "$choice" in
    A|a)
      bash peer.bash
      tail -6 wg0.conf | less
    ;;
    D|d)
      # Create a prompt for the user
      read -p "Name of user to be deleted: " name
      # Call manage-user.bash passing switches
      bash manage-users.bash -d -u "$name"
    ;;
    B|b) admin_menu
    ;;
    M|m) menu
    ;;
    E|e) exit 0
    ;;
    *)
    invalid_opt
    vpn_menu
    ;;
  esac
  vpn_menu
}

function check_user() {
  user=$(cut -d: -f1,3 /etc/passwd | grep :0 | grep -v -e "root")
  if [[ ${user} == "" ]]
  then
    echo "No other users found" | less
  else
    echo $user | less
  fi
}

function security_menu() {
  clear

  echo "[L]ist open sockets"
  echo "[C]heck for users with UID 0 other than root"
  echo "[S]how last 10 logged in users"
  echo "[V]iew logged in users"
  echo "[E]xit"
  read -p "Please select an option: " choice

  case "$choice" in
    L|l) netstat -ltu | less
    ;;
    C|c) check_user
    ;;
    S|s) tail -10 /var/log/wtmp | less
    ;;
    V|v) who -u | less
    ;;
    E|e) exit 0
    ;;
    *)
    invalid_opt
    menu
    ;;
  esac
  security_menu
}

# Call the main function
menu
