[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install node
chown node:node /root/.npm
source /hanabi-live/install/install_dependencies.sh
