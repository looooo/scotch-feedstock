:: MSVC is preferred.
set CC=cl.exe
set CXX=cl.exe

cmake ^
  -G "Ninja" ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -B build ^
  %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1
cmake --install . --component=libscotch
if errorlevel 1 exit 1
