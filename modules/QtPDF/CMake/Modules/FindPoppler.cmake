# - Try to find Poppler and Poppler-Qt4
# Once done this will define
#
#  POPPLER_FOUND - system has Poppler and Poppler-Qt4
#  POPPLER_HAS_XPDF - A boolean indicating if Poppler XPDF headers are available
#  POPPLER_NEEDS_FONTCONFIG - A boolean indicating if libpoppler depends on libfontconfig
#  POPPLER_XPDF_INCLUDE_DIR - the include directory for Poppler XPDF headers
#  POPPLER_QT_INCLUDE_DIR - the include directory for Poppler-Qt4 headers
#  POPPLER_QT_LIBRARIES  - Link this to use only libpoppler-qt*
#  POPPLER_LIBRARIES - Link these to use Poppler and Poppler-Qt*
#
# Note: the Poppler-cpp include directory is currently not needed by TeXworks
#
# Redistribution and use of this file is allowed according to the terms of the
# MIT license. For details see the file COPYING-CMAKE-MODULES.

if (NOT POPPLER_QT_QTVERSION VERSION_EQUAL QT_VERSION_MAJOR)
  # if the current Qt version does not match the one for which we found the
  # poppler-qt package before, unset (some of) the package info variables to
  # trigger a new search for a version matching the right Qt version
  unset(POPPLER_QT_PKG_FOUND CACHE)
  unset(POPPLER_QT_PKG_LIBRARIES CACHE)
  unset(POPPLER_QT_INCLUDE_DIR CACHE)
  unset(POPPLER_QT_LIBRARIES CACHE)
elseif ( POPPLER_LIBRARIES )
   # in cache already
   SET(Poppler_FIND_QUIETLY TRUE)
endif ()

# use pkg-config to get the directories and then use these values
# in the FIND_PATH() and FIND_LIBRARY() calls
if( NOT WIN32 )
  find_package(PkgConfig)

  pkg_check_modules(POPPLER_BASE_PKG QUIET poppler)
  pkg_check_modules(POPPLER_QT_PKG QUIET poppler-qt${QT_VERSION_MAJOR})
endif( NOT WIN32 )

# Check for Poppler XPDF headers (optional)
FIND_PATH(POPPLER_XPDF_INCLUDE_DIR NAMES poppler-config.h
  PATHS
    /usr/local/include
    /usr/include
  HINTS
    ${POPPLER_BASE_PKG_INCLUDE_DIRS} # Generated by pkg-config
  PATH_SUFFIXES
    poppler
)

IF( NOT(POPPLER_XPDF_INCLUDE_DIR) )
  MESSAGE( STATUS "Could not find poppler-config.h, disabling support for Xpdf headers." )
  SET( POPPLER_HAS_XPDF false )
ELSE( NOT(POPPLER_XPDF_INCLUDE_DIR) )
  SET( POPPLER_HAS_XPDF true )
ENDIF( NOT(POPPLER_XPDF_INCLUDE_DIR) )

# Find libpoppler, libpoppler-qt4 and associated header files (Required)
FIND_LIBRARY(POPPLER_BASE_LIBRARIES NAMES poppler ${POPPLER_BASE_PKG_LIBRARIES}
  PATHS
    /usr/local
    /usr
  HINTS
    ${POPPLER_BASE_PKG_LIBRARY_DIRS} # Generated by pkg-config
  PATH_SUFFIXES
    lib64
    lib
)
IF ( NOT(POPPLER_BASE_LIBRARIES) )
  MESSAGE(STATUS "Could not find libpoppler." )
ENDIF ()

# Scan poppler libraries for dependencies on Fontconfig
INCLUDE(GetPrerequisites)
MARK_AS_ADVANCED(gp_cmd)
GET_PREREQUISITES("${POPPLER_BASE_LIBRARIES}" POPPLER_PREREQS TRUE FALSE "" "")
IF ("${POPPLER_PREREQS}" MATCHES "fontconfig")
  SET(POPPLER_NEEDS_FONTCONFIG TRUE)
ELSE ()
  SET(POPPLER_NEEDS_FONTCONFIG FALSE)
ENDIF ()


FIND_PATH(POPPLER_QT_INCLUDE_DIR NAMES poppler-qt${QT_VERSION_MAJOR}.h poppler-link.h
  PATHS
    /usr/local/include
    /usr/include
  HINTS
    ${POPPLER_QT_PKG_INCLUDE_DIRS} # Generated by pkg-config
  PATH_SUFFIXES
    poppler
    qt${QT_VERSION_MAJOR}
    poppler/qt${QT_VERSION_MAJOR}
)
IF ( NOT(POPPLER_QT_INCLUDE_DIR) )
  MESSAGE(STATUS "Could not find Poppler-Qt${QT_VERSION_MAJOR} headers." )
ENDIF ()
FIND_LIBRARY(POPPLER_QT_LIBRARIES NAMES poppler-qt${QT_VERSION_MAJOR} ${POPPLER_QT_PKG_LIBRARIES}
  PATHS
    /usr/local
    /usr
  HINTS
    ${POPPLER_PKG_LIBRARY_DIRS} # Generated by pkg-config
  PATH_SUFFIXES
    lib64
    lib
)
SET(POPPLER_QT_QTVERSION ${QT_VERSION_MAJOR} CACHE INTERNAL "Qt version used by poppler-qt")
MARK_AS_ADVANCED(POPPLER_QT_LIBRARIES)
IF ( NOT(POPPLER_QT_LIBRARIES) )
  MESSAGE(STATUS "Could not find libpoppler-qt${QT_VERSION_MAJOR}." )
ENDIF ()

SET(POPPLER_LIBRARIES ${POPPLER_QT_LIBRARIES} ${POPPLER_BASE_LIBRARIES})

IF ( POPPLER_QT_INCLUDE_DIR AND EXISTS "${POPPLER_QT_INCLUDE_DIR}/../poppler-config.h" )
  file(STRINGS "${POPPLER_QT_INCLUDE_DIR}/../poppler-config.h" POPPLER_CONFIG_H REGEX "^#define POPPLER_VERSION \"[0-9.]+\"$")

  if(POPPLER_CONFIG_H)
    string(REGEX REPLACE "^.*POPPLER_VERSION \"([0-9.]+)\"$" "\\1" POPPLER_VERSION_STRING "${POPPLER_CONFIG_H}")
    string(REGEX REPLACE "^([0-9]+).*$" "\\1" POPPLER_VERSION_MAJOR "${POPPLER_VERSION_STRING}")
    string(REGEX REPLACE "^${POPPLER_VERSION_MAJOR}\\.([0-9]+).*$" "\\1" POPPLER_VERSION_MINOR  "${POPPLER_VERSION_STRING}")
    string(REGEX REPLACE "^${POPPLER_VERSION_MAJOR}\\.${POPPLER_VERSION_MINOR}\\.([0-9]+)$" "\\1" POPPLER_VERSION_PATCH "${POPPLER_VERSION_STRING}")

	if (POPPLER_VERSION_MINOR STREQUAL POPPLER_VERSION_STRING)
		unset(POPPLER_VERSION_MINOR)
	endif()
	if (POPPLER_VERSION_PATCH STREQUAL POPPLER_VERSION_STRING)
		unset(POPPLER_VERSION_PATCH)
	endif()
  endif()
ENDIF ()

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Poppler REQUIRED_VARS POPPLER_LIBRARIES POPPLER_QT_INCLUDE_DIR VERSION_VAR POPPLER_VERSION_STRING )

# show the POPPLER_(XPDF/QT4)_INCLUDE_DIR and POPPLER_LIBRARIES variables only in the advanced view
MARK_AS_ADVANCED(POPPLER_XPDF_INCLUDE_DIR POPPLER_QT_INCLUDE_DIR POPPLER_BASE_LIBRARIES POPPLER_LIBRARIES)

