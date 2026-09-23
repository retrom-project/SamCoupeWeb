cmake_minimum_required(VERSION 3.18...3.31)

project(samcoupeweb)

# Allow FetchContent_Populate for EXCLUDE_FROM_ALL logic
if(POLICY CMP0169)
  cmake_policy(SET CMP0169 OLD)
endif()

set(PROJECT_TITLE SamCoupeWeb)

set(MAJOR_VERSION 1)
set(MINOR_VERSION 2)
set(PATCH_VERSION 17)

if (CMAKE_TOOLCHAIN_FILE)
  message(STATUS "Using toolchain file: ${CMAKE_TOOLCHAIN_FILE}")
  include(${CMAKE_TOOLCHAIN_FILE})
endif()

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

set(BUILD_BACKEND "auto" CACHE STRING "Back-end framework for video/sound/input")
set_property(CACHE BUILD_BACKEND PROPERTY STRINGS auto win32 sdl)
option(RETROM_BROWSER_CANDIDATE "Build without bundled machine or speech ROMs" OFF)

set(ORIG_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/..")

if (EMSCRIPTEN)
  add_compile_options("-sUSE_SDL=2" "-sUSE_ZLIB=1" "-sUSE_BZIP2=1")
endif()

if (BUILD_BACKEND STREQUAL "win32" OR (BUILD_BACKEND STREQUAL "auto" AND WIN32 AND NOT EMSCRIPTEN))
  set(BUILD_WIN32 1)
elseif (BUILD_BACKEND STREQUAL "sdl" OR BUILD_BACKEND STREQUAL "auto")
  set(BUILD_SDL 1)
else()
  message(FATAL_ERROR "Unknown backend type: ${BUILD_BACKEND}")
endif()
message(STATUS "Build back-end: ${BUILD_BACKEND}")

if (CMAKE_VERBOSE_MAKEFILE STREQUAL "")
  set(CMAKE_VERBOSE_MAKEFILE OFF)
endif()

########

set(CMAKE_MODULE_PATH "${ORIG_SRC_DIR}/cmake" ${CMAKE_MODULE_PATH})
include(GNUInstallDirs)
include(PreCompiledHeaders)
include(FetchContent)

set(BASE_CPP_FILES
    ${ORIG_SRC_DIR}/Base/Actions.cpp ${ORIG_SRC_DIR}/Base/ATA.cpp ${ORIG_SRC_DIR}/Base/AtaAdapter.cpp ${ORIG_SRC_DIR}/Base/Atom.cpp
    ${ORIG_SRC_DIR}/Base/AtomLite.cpp ${ORIG_SRC_DIR}/Base/AVI.cpp ${ORIG_SRC_DIR}/Base/BlipBuffer.cpp ${ORIG_SRC_DIR}/Base/BlueAlpha.cpp
    ${ORIG_SRC_DIR}/Base/Breakpoint.cpp ${ORIG_SRC_DIR}/Base/Clock.cpp ${ORIG_SRC_DIR}/Base/CPU.cpp ${ORIG_SRC_DIR}/Base/Debug.cpp
    ${ORIG_SRC_DIR}/Base/Disassem.cpp ${ORIG_SRC_DIR}/Base/Disk.cpp ${ORIG_SRC_DIR}/Base/Drive.cpp ${ORIG_SRC_DIR}/Base/Expr.cpp ${ORIG_SRC_DIR}/Base/Events.cpp
    ${ORIG_SRC_DIR}/Base/Font.cpp ${ORIG_SRC_DIR}/Base/Frame.cpp ${ORIG_SRC_DIR}/Base/FrameBuffer.cpp ${ORIG_SRC_DIR}/Base/GIF.cpp ${ORIG_SRC_DIR}/Base/GUI.cpp
    ${ORIG_SRC_DIR}/Base/GUIDlg.cpp ${ORIG_SRC_DIR}/Base/GUIIcons.cpp ${ORIG_SRC_DIR}/Base/HardDisk.cpp ${ORIG_SRC_DIR}/Base/Joystick.cpp
    ${ORIG_SRC_DIR}/Base/Keyboard.cpp ${ORIG_SRC_DIR}/Base/Keyin.cpp src/Main.cpp ${ORIG_SRC_DIR}/Base/Memory.cpp
    ${ORIG_SRC_DIR}/Base/Mouse.cpp ${ORIG_SRC_DIR}/Base/Options.cpp ${ORIG_SRC_DIR}/Base/Parallel.cpp ${ORIG_SRC_DIR}/Base/Paula.cpp
    ${ORIG_SRC_DIR}/Base/SavePNG.cpp ${ORIG_SRC_DIR}/Base/SAMIO.cpp ${ORIG_SRC_DIR}/Base/SAMVox.cpp ${ORIG_SRC_DIR}/Base/SDIDE.cpp
    ${ORIG_SRC_DIR}/Base/SID.cpp ${ORIG_SRC_DIR}/Base/Sound.cpp ${ORIG_SRC_DIR}/Base/SSX.cpp ${ORIG_SRC_DIR}/Base/Stream.cpp ${ORIG_SRC_DIR}/Base/Symbol.cpp
    ${ORIG_SRC_DIR}/Base/Tape.cpp ${ORIG_SRC_DIR}/Base/Util.cpp ${ORIG_SRC_DIR}/Base/Video.cpp ${ORIG_SRC_DIR}/Base/WAV.cpp ${ORIG_SRC_DIR}/Base/VoiceBox.cpp
    ${ORIG_SRC_DIR}/Base/sp0256.cpp)

if (NOT EMSCRIPTEN)
  set(BASE_C_FILES ${ORIG_SRC_DIR}/Extern/gl3w/src/gl3w.c)
endif()

set(BASE_H_FILES
    ${ORIG_SRC_DIR}/Base/Actions.h ${ORIG_SRC_DIR}/Base/ATA.h ${ORIG_SRC_DIR}/Base/AtaAdapter.h ${ORIG_SRC_DIR}/Base/Atom.h ${ORIG_SRC_DIR}/Base/AtomLite.h
    ${ORIG_SRC_DIR}/Base/AVI.h ${ORIG_SRC_DIR}/Base/BlipBuffer.h ${ORIG_SRC_DIR}/Base/BlueAlpha.h ${ORIG_SRC_DIR}/Base/Breakpoint.h
    ${ORIG_SRC_DIR}/Base/Clock.h ${ORIG_SRC_DIR}/Base/CPU.h ${ORIG_SRC_DIR}/Base/Debug.h ${ORIG_SRC_DIR}/Base/Disassem.h
    ${ORIG_SRC_DIR}/Base/Disk.h ${ORIG_SRC_DIR}/Base/Drive.h ${ORIG_SRC_DIR}/Base/Events.h ${ORIG_SRC_DIR}/Base/Expr.h ${ORIG_SRC_DIR}/Base/Font.h ${ORIG_SRC_DIR}/Base/Frame.h
    ${ORIG_SRC_DIR}/Base/GIF.h ${ORIG_SRC_DIR}/Base/GUI.h ${ORIG_SRC_DIR}/Base/GUIDlg.h ${ORIG_SRC_DIR}/Base/GUIIcons.h ${ORIG_SRC_DIR}/Base/HardDisk.h
    ${ORIG_SRC_DIR}/Base/Joystick.h ${ORIG_SRC_DIR}/Base/Keyboard.h ${ORIG_SRC_DIR}/Base/Keyin.h ${ORIG_SRC_DIR}/Base/Main.h
    ${ORIG_SRC_DIR}/Base/Memory.h ${ORIG_SRC_DIR}/Base/Mouse.h ${ORIG_SRC_DIR}/Base/Options.h ${ORIG_SRC_DIR}/Base/Parallel.h ${ORIG_SRC_DIR}/Base/Paula.h
    ${ORIG_SRC_DIR}/Base/SavePNG.h ${ORIG_SRC_DIR}/Base/SAM.h ${ORIG_SRC_DIR}/Base/SAMIO.h
    ${ORIG_SRC_DIR}/Base/SAMVox.h ${ORIG_SRC_DIR}/Base/SDIDE.h ${ORIG_SRC_DIR}/Base/SID.h src/SimCoupe.h ${ORIG_SRC_DIR}/Base/Sound.h
    ${ORIG_SRC_DIR}/Base/SSX.h ${ORIG_SRC_DIR}/Base/Stream.h ${ORIG_SRC_DIR}/Base/Symbol.h ${ORIG_SRC_DIR}/Base/Tape.h ${ORIG_SRC_DIR}/Base/Util.h ${ORIG_SRC_DIR}/Base/Video.h
    ${ORIG_SRC_DIR}/Base/VL1772.h ${ORIG_SRC_DIR}/Base/WAV.h ${ORIG_SRC_DIR}/Base/VoiceBox.h ${ORIG_SRC_DIR}/Base/sp0256.h
    ${ORIG_SRC_DIR}/Extern/gl3w/include/GL/gl3w.h)

set(BASE_RUNTIME_FILES
    ${ORIG_SRC_DIR}/Resource/atom.rom ${ORIG_SRC_DIR}/Resource/atomlite.rom ${ORIG_SRC_DIR}/Resource/samcoupe.rom ${ORIG_SRC_DIR}/Resource/sp0256-al2.bin
    ${ORIG_SRC_DIR}/Resource/samports.map ${ORIG_SRC_DIR}/Resource/samrom.map ${ORIG_SRC_DIR}/Resource/samdos2.map ${ORIG_SRC_DIR}/Resource/samdos2.sbt
    ${ORIG_SRC_DIR}/Resource/SimCoupe.bmp)
if (RETROM_BROWSER_CANDIDATE)
  list(FILTER BASE_RUNTIME_FILES EXCLUDE REGEX "(atom|atomlite|samcoupe)\\.rom$|sp0256-al2\\.bin$")
endif()

set(SOURCE_FILES ${BASE_CPP_FILES} ${BASE_C_FILES})
set(HEADER_FILES ${BASE_H_FILES})
set(RESOURCE_FILES ${BASE_RUNTIME_FILES})

if (BUILD_WIN32)
  include(HlslCompile)
  set(WIN_CPP_FILES ${ORIG_SRC_DIR}/Win32/Audio.cpp ${ORIG_SRC_DIR}/Win32/D3D11Video.cpp ${ORIG_SRC_DIR}/Win32/Floppy.cpp ${ORIG_SRC_DIR}/Win32/IDEDisk.cpp ${ORIG_SRC_DIR}/Win32/Input.cpp ${ORIG_SRC_DIR}/Win32/MIDI.cpp ${ORIG_SRC_DIR}/Win32/ODMenu.cpp ${ORIG_SRC_DIR}/Win32/OSD.cpp ${ORIG_SRC_DIR}/Win32/UI.cpp)
  set(WIN_H_FILES ${ORIG_SRC_DIR}/Win32/afxres.h ${ORIG_SRC_DIR}/Win32/Audio.h ${ORIG_SRC_DIR}/Win32/D3D11Video.h ${ORIG_SRC_DIR}/Extern/fdrawcmd/fdrawcmd.h ${ORIG_SRC_DIR}/Win32/Floppy.h ${ORIG_SRC_DIR}/Win32/IDEDisk.h ${ORIG_SRC_DIR}/Win32/Input.h ${ORIG_SRC_DIR}/Win32/MIDI.h ${ORIG_SRC_DIR}/Win32/ODMenu.h ${ORIG_SRC_DIR}/Win32/OSD.h ${ORIG_SRC_DIR}/Win32/resource.h ${ORIG_SRC_DIR}/Win32/UI.h)
  set(SOURCE_FILES ${SOURCE_FILES} ${WIN_CPP_FILES})
  set(HEADER_FILES ${HEADER_FILES} ${WIN_H_FILES})
elseif (BUILD_SDL)
  set(SDL_CPP_FILES ${ORIG_SRC_DIR}/SDL/Audio.cpp ${ORIG_SRC_DIR}/SDL/IDEDisk.cpp ${ORIG_SRC_DIR}/SDL/Input.cpp ${ORIG_SRC_DIR}/SDL/MIDI.cpp src/OSD.cpp ${ORIG_SRC_DIR}/SDL/SDL20.cpp src/SDL20_GL3.cpp src/UI.cpp)
  set(SDL_H_FILES ${ORIG_SRC_DIR}/SDL/Audio.h ${ORIG_SRC_DIR}/SDL/IDEDisk.h ${ORIG_SRC_DIR}/SDL/Input.h ${ORIG_SRC_DIR}/SDL/MIDI.h ${ORIG_SRC_DIR}/SDL/OSD.h src/SDL20.h src/SDL20_GL3.h ${ORIG_SRC_DIR}/SDL/UI.h)
  set(SOURCE_FILES ${SOURCE_FILES} ${SDL_CPP_FILES})
  set(HEADER_FILES ${HEADER_FILES} ${SDL_H_FILES})
endif()

# Aggressively disable testing for all dependencies
set(Z80_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(LIBSPECTRUM_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(FMT_INSTALL OFF CACHE BOOL "" FORCE)
set(FMT_TEST OFF CACHE BOOL "" FORCE)

########

get_filename_component(DEP_ROOT "${CMAKE_CURRENT_BINARY_DIR}/_deps" ABSOLUTE)

# Use URL for better reliability in CI
FetchContent_Declare(z80 URL https://github.com/kosarev/z80/archive/9917a379abdc80d49831e4b6eff9e2c4df43bfbc.zip)
FetchContent_Declare(fmt URL https://github.com/fmtlib/fmt/archive/e69e5f977d458f2650bb346dadf2ad30c5320281.zip)
FetchContent_Declare(resid URL https://github.com/simonowen/resid/archive/9ac2b4b5633a6c64fb02fd09a350ea857dd0c6d3.zip)
FetchContent_Declare(spectrum URL https://github.com/simonowen/libspectrum/archive/eb93bd36f6253471bf709bb9745176d1f9c994f0.zip)
FetchContent_Declare(saasound URL https://github.com/stripwax/SAASound/archive/7ceef2af64e7411cc723cb465f060bb856459eea.zip)
FetchContent_Declare(zlib URL https://github.com/madler/zlib/archive/51b7f2abdade71cd9bb0e7a373ef2610ec6f9daf.zip)

# Populate dependencies
FetchContent_MakeAvailable(fmt resid)

# Manually add these with EXCLUDE_FROM_ALL to skip tests
FetchContent_GetProperties(z80)
if(NOT z80_POPULATED)
  FetchContent_Populate(z80)
  # Define z80 as an INTERFACE library to satisfy dependencies without a physical .a file
  add_library(z80 INTERFACE)
  target_include_directories(z80 INTERFACE ${z80_SOURCE_DIR})
  # Do NOT add_subdirectory for z80 as it has no usable library target for us
endif()

FetchContent_GetProperties(spectrum)
if(NOT spectrum_POPULATED)
  FetchContent_Populate(spectrum)
  add_subdirectory(${spectrum_SOURCE_DIR} ${spectrum_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()

FetchContent_GetProperties(saasound)
if(NOT saasound_POPULATED)
  FetchContent_Populate(saasound)
  # Patch saasound to remove SHARED which causes warnings on Wasm
  file(READ "${saasound_SOURCE_DIR}/CMakeLists.txt" SAASOUND_CMAKE)
  string(REPLACE "add_library(SAASound SHARED" "add_library(SAASound STATIC" SAASOUND_CMAKE "${SAASOUND_CMAKE}")
  file(WRITE "${saasound_SOURCE_DIR}/CMakeLists.txt" "${SAASOUND_CMAKE}")
  add_subdirectory(${saasound_SOURCE_DIR} ${saasound_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()

FetchContent_GetProperties(zlib)
if(NOT zlib_POPULATED)
  FetchContent_Populate(zlib)
endif()

# Fix SAASound compatibility for Linux/Wasm
if (TARGET SAASound)
  target_compile_definitions(SAASound PRIVATE "strnicmp=strncasecmp")
endif()

########

add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE ${SOURCE_FILES} ${HEADER_FILES} ${RESOURCE_FILES})
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_17)

target_include_directories(${PROJECT_NAME} PRIVATE ${z80_SOURCE_DIR})

target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt)

target_link_libraries(${PROJECT_NAME} PRIVATE resid)
target_include_directories(${PROJECT_NAME} PRIVATE ${resid_SOURCE_DIR})

target_link_libraries(${PROJECT_NAME} PRIVATE spectrum)
target_include_directories(${PROJECT_NAME} PRIVATE ${spectrum_SOURCE_DIR})

target_link_libraries(${PROJECT_NAME} PRIVATE SAASound)

target_sources(${PROJECT_NAME} PRIVATE src/whereami.c)
target_include_directories(${PROJECT_NAME} PRIVATE ${ORIG_SRC_DIR}/Extern/whereami/src)

########

if (NOT EMSCRIPTEN)
    find_package(ZLIB)
    if (ZLIB_FOUND)
      target_link_libraries(${PROJECT_NAME} PRIVATE ZLIB::ZLIB)
      set(HAVE_LIBZ 1)
      target_sources(${PROJECT_NAME} PRIVATE ${zlib_SOURCE_DIR}/contrib/minizip/ioapi.c ${zlib_SOURCE_DIR}/contrib/minizip/unzip.c)
      target_include_directories(${PROJECT_NAME} PRIVATE ${zlib_SOURCE_DIR}/contrib/minizip)
    endif()

    find_package(BZip2)
    if (BZIP2_FOUND)
      target_link_libraries(${PROJECT_NAME} PRIVATE BZip2::BZip2)
      set(HAVE_BZ2LIB 1)
    endif()
else()
    # Emscripten provides these via -sUSE_ZLIB=1 and -sUSE_BZIP2=1
    set(HAVE_LIBZ 1)
    set(HAVE_BZ2LIB 1)
    # But we still need minizip sources from our Extern directory
    target_sources(${PROJECT_NAME} PRIVATE ${zlib_SOURCE_DIR}/contrib/minizip/ioapi.c ${zlib_SOURCE_DIR}/contrib/minizip/unzip.c)
    target_include_directories(${PROJECT_NAME} PRIVATE ${zlib_SOURCE_DIR}/contrib/minizip)
endif()

find_package(OpenGL)
if (OPENGL_FOUND)
  target_link_libraries(${PROJECT_NAME} PRIVATE ${OPENGL_LIBRARIES})
  set(HAVE_OPENGL 1)
endif()

if (EMSCRIPTEN)
  set_target_properties(${PROJECT_NAME} PROPERTIES CXX_STANDARD 17 CXX_STANDARD_REQUIRED ON)
  target_compile_options(${PROJECT_NAME} PRIVATE "-sFULL_ES3=1")
  target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_CONFIG_H HAVE_LIBSDL2 HAVE_STD_FILESYSTEM HAVE_ZLIB HAVE_MINIZIP)
  target_link_options(${PROJECT_NAME} PRIVATE 
    "-O0"
    "-sUSE_SDL=2" 
    "-sUSE_ZLIB=1" 
    "-sUSE_BZIP2=1" 
    "-sFULL_ES3=1" 
    "-sWASM=1" 
    "-sALLOW_MEMORY_GROWTH=1"
    "-sINITIAL_MEMORY=134217728"
    "-sSTACK_SIZE=5242880"
  )
  if (RETROM_BROWSER_CANDIDATE)
    set(RETROM_RESOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/retrom-resource")
    file(MAKE_DIRECTORY "${RETROM_RESOURCE_DIR}")
    foreach(resource IN ITEMS samports.map samrom.map samdos2.map samdos2.sbt SimCoupe.bmp)
      configure_file("${ORIG_SRC_DIR}/Resource/${resource}" "${RETROM_RESOURCE_DIR}/${resource}" COPYONLY)
    endforeach()
    target_link_options(${PROJECT_NAME} PRIVATE "--preload-file" "${RETROM_RESOURCE_DIR}@/Resource")
  else()
    target_link_options(${PROJECT_NAME} PRIVATE "--preload-file" "${ORIG_SRC_DIR}/Resource@/Resource")
  endif()
  target_link_options(${PROJECT_NAME} PRIVATE "-sEXPORTED_FUNCTIONS=['_main','_EMS_InsertDisk','_EMS_InsertTape','_EMS_Reset','_EMS_Boot','_EMS_GetFPS','_EMS_SetAudioEnabled','_EMS_StartAudio','_EMS_EjectDisk','_EMS_EjectTape','_EMS_DoAction','_EMS_GetLastWavPath','_EMS_GetLastGifPath','_EMS_GetLastPngPath','_EMS_GetLastAviPath','_EMS_GetOption','_EMS_SetOption','_EMS_IsDiskModified','_EMS_ClearDiskModified','_EMS_FlushDisk']")
  target_link_options(${PROJECT_NAME} PRIVATE "-sEXPORTED_RUNTIME_METHODS=['ccall','cwrap','FS','addFunction','removeFunction']")
  target_link_options(${PROJECT_NAME} PRIVATE "-sEXIT_RUNTIME=1")
endif()

########

target_include_directories(${PROJECT_NAME} PRIVATE src ${ORIG_SRC_DIR}/Base ${ORIG_SRC_DIR}/SDL ${ORIG_SRC_DIR}/Extern/gl3w/include ${ORIG_SRC_DIR}/Extern/ghc)

if (NOT MSVC AND NOT EMSCRIPTEN)
  CHECK_CXX_COMPILER_FLAG("-stdlib=libc++" COMPILER_SUPPORTS_STDLIBCXX)
  if (COMPILER_SUPPORTS_STDLIBCXX AND NOT APPLE)
    target_compile_options(${PROJECT_NAME} PRIVATE $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libstdc++>)
  endif()
endif()

if (NOT EMSCRIPTEN)
  set(CPACK_RESOURCE_FILE_LICENSE "${ORIG_SRC_DIR}/License.txt")
  set(CPACK_RESOURCE_FILE_README "${ORIG_SRC_DIR}/ReadMe.md")
  include(cpack_simcoupe)
endif()

configure_file(${ORIG_SRC_DIR}/config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h)
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
