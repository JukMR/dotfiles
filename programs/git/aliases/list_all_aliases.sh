#!/bin/bash
git config --global alias.alias '! git config --get-regexp ^alias\. | sed -e s/^alias\.// -e s/\ /\ =\ /'
