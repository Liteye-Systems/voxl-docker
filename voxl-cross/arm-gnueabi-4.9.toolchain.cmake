set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# ubuntu cross compiler installs straight to /usr/bin/
set(tools /usr)
set(CMAKE_C_COMPILER ${tools}/bin/arm-linux-gnueabi-gcc-4.9)
set(CMAKE_CXX_COMPILER ${tools}/bin/arm-linux-gnueabi-g++-4.9)