fpc -TLinux -O2 HelloWorld.pas -Fu../../rtl/ -Fu../../rtl/drivers -MObjfpc
rm -f /tmp/firecracker.socket
starttime=$(($(date +%s%N)/1000000))
./firecracker --api-sock /tmp/firecracker.socket &
pid=$!
curl --unix-socket /tmp/firecracker.socket -i \
    -X PUT 'http://localhost/boot-source'   \
    -H 'Accept: application/json'           \
    -H 'Content-Type: application/json'     \
    -d '{
        "kernel_image_path": "./HelloWorld",
        "boot_args": "console=ttyS0 reboot=k panic=1 pci=off"
    }'
curl --unix-socket /tmp/firecracker.socket -i \
    -X PUT 'http://localhost/actions'       \
    -H  'Accept: application/json'          \
    -H  'Content-Type: application/json'    \
    -d '{
        "action_type": "InstanceStart"
     }'
wait $pid
endtime=$(($(date +%s%N)/1000000))
echo "Firecrack, Boot from binary: $((endtime-starttime)) ms"
