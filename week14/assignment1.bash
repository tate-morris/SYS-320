#! /bin/bash
clear

# filling courses.txt
bash courses.bash

courseFile="courses.txt"

function displayCoursesofInst(){

    echo -n "Please Input an Instructor Full Name: "
    read instName

    echo ""
    echo "Courses of $instName :"
    cat "$courseFile" | grep "$instName" | cut -d';' -f1,2 | \
    sed 's/;/ | /g'
    echo ""

}

function courseCountofInsts(){

    echo ""
    echo "Course-Instructor Distribution"
    cat "$courseFile" | cut -d';' -f7 | \
    grep -v "/" | grep -v "\.\.\." | \
    sort -n | uniq -c | sort -n -r
    echo ""

}

# TODO - 1
# Make a function that displays all the courses in given location
# function displays course code, course name, course days, time, instructor
function displayCoursesOfClassroom(){

    echo -n "Please Input a Class Name: "
    read className
    echo ""
    echo "Courses in $className :"

    awk -F';' -v loc="$className" '
        $10 ~ loc {
            printf "%s | %s | %s | %s | %s\n", $1, $2, $5, $6, $7
        }
    ' "$courseFile"
    echo ""
}

# TODO - 2
# Make a function that displays all the courses that has availability
# (seat number will be more than 0) for the given course code
function displayAvailableCoursesOfSubject(){

    echo -n "Please Input a Subject Name: "
    read subj
    echo ""
    echo "Available courses in $subj :"

    awk -F';' -v subj="$subj" '
        $4 + 0 > 0 && $1 ~ ("^" subj " ") {
            printf "%s | %s | %s | %s | %s | %s | %s | %s | %s | %s\n",
                   $1,$2,$3,$4,$5,$6,$7,$8,$9,$10
        }
    ' "$courseFile"
    echo ""
}

while :
do
    echo ""
    echo "Please select and option:"
    echo "[1] Display courses of an instructor"
    echo "[2] Display course count of instructors"
    echo "[3] Display courses of a classroom"
    echo "[4] Display available courses of subject"
    echo "[5] Exit"

    read userInput
    echo ""

    if [[ "$userInput" == "5" ]]; then
        echo "Goodbye"
        break

    elif [[ "$userInput" == "1" ]]; then
        displayCoursesofInst

    elif [[ "$userInput" == "2" ]]; then
        courseCountofInsts

    elif [[ "$userInput" == "3" ]]; then
        displayCoursesOfClassroom

    elif [[ "$userInput" == "4" ]]; then
        displayAvailableCoursesOfSubject

    # TODO - 3 Display a message, if an invalid input is given
    else
        echo "Invalid option. Please enter 1, 2, 3, 4, or 5."
    fi
done
