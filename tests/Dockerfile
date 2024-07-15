# Use the official Arch Linux image
FROM manjarolinux/base:latest

# Install base dependencies
RUN pacman -Syu --noconfirm \
    sudo \
    bash \
    git

# Copy the script and dotfiles to the container
COPY ./ /root/dotfiles 

WORKDIR /root/dotfiles

RUN mkdir -p /root/.local/bin

ENV USER=root

# Run the script
# RUN bash ./manjaro_essentials.sh 

# Set default command
CMD ["/bin/bash"]
