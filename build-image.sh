#!/bin/bash

echo ""

echo -e "\nbuild docker hadoop image\n"
sudo docker build -t zlh/hadoop:3.3.1 .

echo ""