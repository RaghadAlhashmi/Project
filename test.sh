#!/bin/bash

# Initialize variables
declare -A parked_cars
declare -A parking_times
declare -i total_spots=10
declare -i occupied_spots=0
declare -a available_spots=($(seq 1 $total_spots))
ticket_counter=0

# Function to generate a unique ticket ID
generate_ticket_id() {
    ticket_counter=$((ticket_counter + 1))
    echo "TICKET$ticket_counter"
}
# Function to park a car
park_car() {
    car=$1
    ticket_id=$(generate_ticket_id)
    parked_cars[$ticket_id]=$car
    parking_times[$ticket_id]=$(date +%s)
    occupied_spots=$((occupied_spots + 1))
    available_spots=(${available_spots[@]/$occupied_spots})
    echo "Parked car: $car"
    echo "Ticket ID: $ticket_id"
}
# Function to retrieve a car
retrieve_car() {
    ticket_id=$1
    if [[ -n ${parked_cars[$ticket_id]} ]]; then
        car=${parked_cars[$ticket_id]}
        parked_time=${parking_times[$ticket_id]}
        current_time=$(date +%s)
        parked_duration=$(( (current_time - parked_time) / 60 )) # in minutes
        cost=$((parked_duration * 5)) # $5 per hour
        unset parked_cars[$ticket_id]
        unset parking_times[$ticket_id]
        occupied_spots=$((occupied_spots - 1))
        available_spots+=($occupied_spots)
        echo "Retrieved car: $car"
        echo "Parked duration: $parked_duration minutes"
        echo "Cost: $cost"
    else
        echo "Invalid ticket ID"
    fi
}

# Function to display available parking spots
show_available_spots() {
    echo "Available parking spots: ${available_spots[@]}"
}

# Function to prompt user to select a parking spot
select_parking_spot() {
    read -p "Select a parking spot: " selected_spot
    if [[ " ${available_spots[@]} " =~ " $selected_spot " ]]; then
        park_car "$car_number"
    else
        echo "Invalid parking spot. Please select from the available spots."
    fi
}

# Main menu
while true; do
    echo "Parking Lot System"
    echo "1. Park a car"
    echo "2. Retrieve a car"
    echo "3. Show available parking spots"
    echo "4. Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1) read -p "Enter car registration number: " car_number
           show_available_spots
           select_parking_spot
           ;;
        2) read -p "Enter ticket ID: " ticket
           retrieve_car "$ticket"
           ;;
        3) show_available_spots ;;
        4) break ;;
        *) echo "Invalid choice. Please try again." ;;
    esac

    echo
done
