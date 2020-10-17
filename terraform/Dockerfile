# usage:
# $ docker build --tag terraform-ansible .
# $ docker run --rm terraform-ansible terraform
# $ docker run --rm terraform-ansible ansible

FROM alpine

# define variables for new user
ENV USER sloth
ENV HOME /home/$USER

# install sudo, terraform, and ansible as root
RUN apk add --update terraform ansible openssh rsync --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

# add new user and set id to match host computer's
RUN adduser -u 1000 -D $USER $USER -h $HOME \
        && mkdir -p /etc/sudoers.d \
        && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
        && chmod 0440 /etc/sudoers.d/$USER

# switch container to execute commands as new user
USER $USER
WORKDIR $HOME

CMD sh
