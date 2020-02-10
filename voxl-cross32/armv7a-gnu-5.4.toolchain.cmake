set(CMAKE_SYSTEM_PROCESSOR arm)
set(GNU_MACHINE "arm-linux-gnueabi" CACHE STRING "GNU compiler triple")
include("${CMAKE_CURRENT_LIST_DIR}/arm.toolchain.cmake")
