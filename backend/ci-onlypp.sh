#!/bin/sh
echo "Removing And Recreating folders"
sudo ssh -A -tt -i ~/.ssh/bitbucket -o StrictHostKeyChecking=no -p 22 bitbucket@185.98.137.58 'rm -rf ~/repo/app; mkdir ~/repo/app'
echo "Copy File to Repo"
sudo rsync -a -e "ssh -i $HOME/.ssh/bitbucket" --exclude 'node_modules' --exclude '.git' --exclude 'Archive.zip' --exclude 'uploads' ./ bitbucket@185.98.137.58:~/repo
echo "UPLOADING SUCCESSFULLY"
echo "npm install started"
sudo ssh -A -tt -i ~/.ssh/bitbucket -o StrictHostKeyChecking=no -p 22 bitbucket@185.98.137.58 'cd ~/repo && pm2 restart 0'
