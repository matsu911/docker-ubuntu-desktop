FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends ubuntu-desktop && \
    apt-get install -y gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal && \
    apt-get install -y apt-utils language-pack-ja-base language-pack-ja unifont && \
    apt-get install -y tightvncserver && \
    mkdir /root/.vnc

RUN locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8

RUN apt-get install -y vim wget libappindicator1 pavucontrol

ADD xstartup /root/.vnc/xstartup
ADD passwd /root/.vnc/passwd
ADD google.list /etc/apt/sources.list.d/google.list

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add
RUN apt-get update && apt-get install -y google-chrome-stable

RUN chmod 600 /root/.vnc/passwd

RUN pulseaudio -D --exit-idle-time=-1

# Create virtual output device (used for audio playback)
RUN pactl load-module module-null-sink sink_name=DummyOutput sink_properties=device.description="Virtual_Dummy_Output"

# Create virtual microphone output, used to play media into the "microphone"
RUN pactl load-module module-null-sink sink_name=MicOutput sink_properties=device.description="Virtual_Microphone_Output"

# Set the default source device (for future sources) to use the monitor of the virtual microphone output
RUN pacmd set-default-source MicOutput.monitor

# Create a virtual audio source linked up to the virtual microphone output
RUN pacmd load-module module-virtual-source source_name=VirtualMic

CMD /usr/bin/vncserver :1 -geometry 1280x800 -depth 24 && tail -f /root/.vnc/*:1.log

EXPOSE 5901
