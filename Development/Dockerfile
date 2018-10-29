FROM beeline-firmware-img:latest
LABEL author="Mark Uckermann <mark.uckermann@gmail.com>"

RUN apt-get install -y gdb

#Re-install a new version of nodejs compared to the one installed by firmware-img

#remove installed version
RUN apt-get remove -y nodejs

#get new version
# NB: comes with npm!
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get install -y nodejs

# needed for canvas compilation for svg2bing:
#  see https://www.npmjs.com/package/canvas
RUN apt-get install -y build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev

#install nan
 # see https://github.com/kelektiv/node.bcrypt.js/issues/428


RUN cd /beeline/tools/svg2bin && rm -rf node-modules && npm install nan && npm install


