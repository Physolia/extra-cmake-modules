

if(SOPRANO_INCLUDE_DIR AND SOPRANO_LIBRARIES)

  # read from cache
  set(Soprano_FOUND TRUE)

else(SOPRANO_INCLUDE_DIR AND SOPRANO_LIBRARIES)

  FIND_PATH(SOPRANO_INCLUDE_DIR 
    NAMES
    soprano/soprano.h
    PATHS 
    /usr/include
    /usr/local/include
    ${KDE4_INCLUDE_DIR}
    ${INCLUDE_INSTALL_DIR}
    )
  
  FIND_LIBRARY(SOPRANO_LIBRARIES 
    NAMES
    soprano
    PATHS
    /usr/lib
    /usr/local/lib
    ${KDE4_LIB_DIR}
    ${LIB_INSTALL_DIR}
    )
  if(SOPRANO_INCLUDE_DIR AND SOPRANO_LIBRARIES)
    set(Soprano_FOUND TRUE)
  endif(SOPRANO_INCLUDE_DIR AND SOPRANO_LIBRARIES)

  if(MSVC)
    FIND_LIBRARY(SOPRANO_LIBRARIES_DEBUG 
      NAMES
      sopranod
      PATHS
      /usr/lib
      /usr/local/lib
      ${KDE4_LIB_DIR}
      ${LIB_INSTALL_DIR}
      )
    if(NOT SOPRANO_LIBRARIES_DEBUG)
      set(Soprano_FOUND FALSE)
    endif(NOT SOPRANO_LIBRARIES_DEBUG)
    
    if(MSVC_IDE)
      if( NOT SOPRANO_LIBRARIES_DEBUG OR NOT SOPRANO_LIBRARIES)
        message(FATAL_ERROR "\nCould NOT find the debug AND release version of the Soprano library.\nYou need to have both to use MSVC projects.\nPlease build and install both soprano libraries first.\n")
      endif( NOT SOPRANO_LIBRARIES_DEBUG OR NOT SOPRANO_LIBRARIES)
    else(MSVC_IDE)
      string(TOLOWER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE_TOLOWER)
      if(CMAKE_BUILD_TYPE_TOLOWER MATCHES debug)
        set(SOPRANO_LIBRARIES ${SOPRANO_LIBRARIES_DEBUG})
      else(CMAKE_BUILD_TYPE_TOLOWER MATCHES debug)
        set(SOPRANO_LIBRARIES ${SOPRANO_LIBRARIES})
      endif(CMAKE_BUILD_TYPE_TOLOWER MATCHES debug)
    endif(MSVC_IDE)
  endif(MSVC)

  if(Soprano_FOUND)
    if(NOT Soprano_FIND_QUIETLY)
      message(STATUS "Found Soprano: ${SOPRANO_LIBRARIES}")
    endif(NOT Soprano_FIND_QUIETLY)
  else(Soprano_FOUND)
    if(Soprano_FIND_REQUIRED)
      if(NOT SOPRANO_INCLUDE_DIR)
	message(FATAL_ERROR "Could not find Soprano includes.")
      endif(NOT SOPRANO_INCLUDE_DIR)
      if(NOT SOPRANO_LIBRARIES)
	message(FATAL_ERROR "Could not find Soprano library.")
      endif(NOT SOPRANO_LIBRARIES)
    else(Soprano_FIND_REQUIRED)
      if(NOT SOPRANO_INCLUDE_DIR)
        message(STATUS "Could not find Soprano includes.")
      endif(NOT SOPRANO_INCLUDE_DIR)
      if(NOT SOPRANO_LIBRARIES)
        message(STATUS "Could not find Soprano library.")
      endif(NOT SOPRANO_LIBRARIES)
    endif(Soprano_FIND_REQUIRED)
  endif(Soprano_FOUND)

endif(SOPRANO_INCLUDE_DIR AND SOPRANO_LIBRARIES)
