#! /bin/bash

INSTALL_DIR="/opt/ttn-gateway"

mkdir -p $INSTALL_DIR/dev
cd $INSTALL_DIR/dev

if [ ! -d lora_gateway ]; then
    git clone https://github.com/Lora-net/lora_gateway.git  || { echo 'Cloning lora_gateway failed.' ; exit 1; }
else
    cd lora_gateway
    git reset --hard
    git pull
    cd ..
fi

if [ ! -d packet_forwarder ]; then
    git clone https://github.com/Lora-net/packet_forwarder.git  || { echo 'Cloning packet forwarder failed.' ; exit 1; }
else
    cd packet_forwarder
    git reset --hard
    git pull
    cd ..
fi

cd $INSTALL_DIR/dev/lora_gateway/libloragw
sed -i -e 's/PLATFORM= .*$/PLATFORM= imst_rpi/g' library.cfg
sed -i -e 's/CFG_SPI= .*$/CFG_SPI= native/g' library.cfg
make -j$(nproc)


# Some custom changes
cd $INSTALL_DIR/dev/packet_forwarder/lora_pkt_fwd/inc/

sed -i -e 's/#define DEBUG_PKT_FWD .*$/#define DEBUG_PKT_FWD 1/g' trace.h
sed -i -e 's/#define DEBUG_JIT .*$/#define DEBUG_JIT 1/g' trace.h
sed -i -e 's/#define DEBUG_JIT_ERROR .*$/#define DEBUG_JIT_ERROR 1/g' trace.h
# Timersync prints out way too much, so disable
sed -i -e 's/#define DEBUG_TIMERSYNC .*$/#define DEBUG_TIMERSYNC 0/g' trace.h
sed -i -e 's/#define DEBUG_BEACON .*$/#define DEBUG_BEACON 1/g' trace.h
sed -i -e 's/#define DEBUG_LOG .*$/#define DEBUG_LOG 1/g' trace.h
sed -i -e 's/#define DEBUG_FOLLOW .*$/#define DEBUG_FOLLOW 1/g' trace.h



cd $INSTALL_DIR/dev/packet_forwarder/lora_pkt_fwd/
make -j$(nproc)

# Copy things needed at runtime to where they'll be expected
cp $INSTALL_DIR/dev/packet_forwarder/lora_pkt_fwd/lora_pkt_fwd $INSTALL_DIR/lora_pkt_fwd

echo "Build & Installation Completed."
