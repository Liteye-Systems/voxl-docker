set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# ubuntu cross compiler installs straight to /usr/bin/
set(tools /usr)
set(CMAKE_C_COMPILER ${tools}/bin/aarch64-linux-gnu-gcc-4.9)
set(CMAKE_CXX_COMPILER ${tools}/bin/aarch64-linux-gnu-g++-4.9)


## 4.9 includes and glibc are off in a separate location in voxl-cross to avoid
## conflicting with the new gcc8 compiler stuff whic is in the default location
set(LOC /usr/aarch64-linux-gnu-4.9)
set(CMAKE_C_FLAGS   "-march=armv8-a -L ${LOC}/lib -I ${LOC}/include ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "-march=armv8-a -L ${LOC}/lib -I ${LOC}/include ${CMAKE_CXX_FLAGS}")

