
#!/bin/bash

write() {
    if [ "$1" = "title"]
    then 
        echo "\e[32m$data :: ===> $1.\e[0m\n"
    done
}