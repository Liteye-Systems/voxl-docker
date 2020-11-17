set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# ubuntu cross compiler installs straight to /usr/bin/
set(tools /usr)
set(CMAKE_C_COMPILER ${tools}/bin/aarch64-linux-gnu-gcc-4.9)
set(CMAKE_CXX_COMPILER ${tools}/bin/aarch64-linux-gnu-g++-4.9)