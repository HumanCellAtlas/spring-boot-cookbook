#!/usr/bin/env bash

app=$1
version=$2
profile=$3
port=$4
urlPath=$5
deployFolder=~/ena/${app}
file="${app}-$version.jar"
jarUrl="http://ena-dev:8081/artifactory/libs-release-local/uk/ac/ebi/ena/$app/$app/$version/$file"
currentFile="$app-current.jar"
minimumsize=10000000
host=$(hostname)
deployUrl=http://${host}:${port}/${urlPath}

if [[ -n "$version" ]]; then
    echo "Deploying application: $app version: $version profile: $profile to folder: $deployFolder"
    mkdir -p ${deployFolder}
    cd ${deployFolder}
    if [ $? -eq 0 ]; then
        echo "Downloading jar from url: $jarUrl"
        curl -O ${jarUrl}
        actualsize=$(wc -c <"$file")
        if [ ${actualsize} -ge ${minimumsize} ]; then
            chmod +x "$file"
            if [ $? -eq 0 ]; then
                ln -snf ${file} ${currentFile}
                if [ $? -eq 0 ]; then
                    cd ~/monit/latest
                    if [ $? -eq 0 ]; then
                        ./bin/monit restart ${app}
                        if [ $? -eq 0 ]; then
                            cd ${deployFolder}
                            echo "Checking version in jar's META-INF/MANIFEST.MF"
                            jar xf ${currentFile} META-INF/MANIFEST.MF
                            if grep -q "$version" META-INF/MANIFEST.MF
                            then
                                rm -rf META-INF
                                echo "Correctly deployed application: $app version: $version profile: $profile"
                                echo "Please check at: $deployUrl. Please check or wait 10 seconds for automatic check"
                                sleep 10
                                echo "Automatic check results:"
                                curl -s ${deployUrl}/health
                                curl -s ${deployUrl}/info
                            else
                                rm -rf META-INF
                                echo "Current version does not match $version."
                            fi
                        else
                            echo "Failed to restart app using monit. Is monit configured correctly?"
                            echo "There should be a section in monitrc looks like this:"
                            echo ""
                            echo "# $app"
                            echo "check process $app with pidfile /net/isilonP/public/rw/homes/ena_adm/ena/$app/$app.pid"
                            echo "    group $app"
                            echo "    start program = \"/net/isilonP/public/rw/homes/ena_adm/ena/generic-control.sh start $app $profile"
                            echo "    stop program = \"/net/isilonP/public/rw/homes/ena_adm/ena/generic-control.sh stop $app $profile"
                            echo "    if not exist then start"
                            echo "    if failed host localhost port $port protocol http and request \"/$urlPath\" with timeout 10 seconds for 5 cycles"
                            echo "       then restart"
                        fi
                    else
                        echo "Failed to change to monit directory. Does it exist?"
                    fi
                else
                    echo "Failed to make $file current version. Does it exist?"
                fi

            else
                echo "Failed to make $file executable. Does it exist?"
            fi
        else
            echo "The file downloaded was too small. Did not download correctly?"
            rm ${file}
            echo "Removed $file"
        fi
    else
        echo "$deployFolder does not exist"
    fi
else
    echo "Please supply a version to deploy"
fi
