# Provide support for ports requiring Emacs.
#
# Feature:	emacs
# Usage:	USES=emacs or USES=emacs:args
# Valid ARGS:	build, run, noflavors
#
# build		Indicates that Emacs is required at build time.
# run		Indicates that Emacs is required at run time.
#
# If build and run are omitted from the argument list, Emacs will be added to
# BUILD_DEPENDS and RUN_DEPENDS.  EMACS_NO_DEPENDS can be set to prevent both
# dependencies.
#
# Variables, which can be set in make.conf:
#
# Variables, which can be set by ports:
# EMACS_NO_DEPENDS:           Do NOT add build or run dependencies on Emacs.
#
# Variables, which can be read by ports:
# EMACS_CMD:                  Emacs command with full path (e.g. /usr/local/bin/emacs-28.2)
# EMACS_FLAVOR:               Used for dependencies (e.g. BUILD_DEPENDS= dash.el${EMACS_PKGNAMESUFFIX}>0:devel/dash@${EMACS_FLAVOR})
# EMACS_LIBDIR:               Emacs Library directory without ${PREFIX} (e.g. share/emacs)
# EMACS_LIBDIR_WITH_VER:      Library directory without ${PREFIX} including version (e.g. share/emacs/28.2)
# EMACS_MAJOR_VER:            Emacs major version (e.g. 28)
# EMACS_PKGNAMESUFFIX:        PKGNAMESUFFIX to distinguish Emacs flavors
# EMACS_SITE_LISPDIR:         Emacs site-lisp directory without ${PREFIX} (e.g. share/emacs/site-lisp)
# EMACS_VER:                  Emacs version (e.g. 28.2)
# EMACS_VERSION_SITE_LISPDIR: Include version (e.g. share/emacs/28.2/site-lisp)
#-------------------------------------------------------------------------------
#
# MAINTAINER:	emacs@FreeBSD.org

.if !defined(_INCLUDE_USES_EMACS_MK)
_INCLUDE_USES_EMACS_MK=	yes

# Make sure that no dependency or some other environment variable
# pollutes the build/run dependency detection
.undef _EMACS_BUILD_DEP
.undef _EMACS_RUN_DEP
.undef _EMACS_NOFLAVORS
_EMACS_ARGS=		${emacs_ARGS:S/,/ /g}
.  if ${_EMACS_ARGS:Mbuild}
_EMACS_BUILD_DEP=	yes
_EMACS_ARGS:=		${_EMACS_ARGS:Nbuild}
.  endif
.  if ${_EMACS_ARGS:Mrun}
_EMACS_RUN_DEP=		yes
_EMACS_ARGS:=		${_EMACS_ARGS:Nrun}
.  endif
.  if ${_EMACS_ARGS:Mnoflavors}
_EMACS_NOFLAVORS=	yes
_EMACS_ARGS:=		${_EMACS_ARGS:Nnoflavors}
.  endif

# If the port does not specify a build or run dependency, and does not define
# EMACS_NO_DEPENDS, assume both dependencies are required.
.  if !defined(_EMACS_BUILD_DEP) && !defined(_EMACS_RUN_DEP) && \
	!defined(EMACS_NO_DEPENDS)
_EMACS_BUILD_DEP=	yes
_EMACS_RUN_DEP=		yes
.  endif

# Only set FLAVORS when...
.  if defined(_EMACS_RUN_DEP) && !defined(_EMACS_NOFLAVORS)
FLAVORS=	nox
# Sort the default to be first
.    if defined(EMACS_DEFAULT)
FLAVORS:=	${EMACS_DEFAULT} ${FLAVORS:N${EMACS_DEFAULT}}
.    endif
.    for flavor in ${EMACS_FLAVORS_EXCLUDE}
FLAVORS:=	${FLAVORS:N${flavor}}
.    endfor
.  endif

# Only set FLAVOR when...
.  if defined(_EMACS_RUN_DEP) && !defined(_EMACS_NOFLAVORS) && empty(FLAVOR)
.    if defined(EMACS_DEFAULT)
FLAVOR=	${EMACS_DEFAULT}
.    else
FLAVOR=	${FLAVORS:[1]}
.    endif # defined(EMACS_DEFAULT)
.  endif # !defined(_EMACS_NOFLAVORS) && defined(_EMACS_RUN_DEP) && empty(FLAVOR)

EMACS_FLAVOR=	nox

EMACS_VER=		29.1
EMACS_PORTDIR=		editors/emacs

EMACS_MAJOR_VER=	${EMACS_VER:C/\..*//}
EMACS_LIBDIR=		share/emacs
EMACS_LIBDIR_WITH_VER=	share/emacs/${EMACS_VER}
EMACS_PORT_NAME=	emacs${EMACS_MAJOR_VER}

EMACS_PKGNAMESUFFIX=

EMACS_CMD=	${PREFIX}/bin/emacs-${EMACS_VER}
EMACS_SITE_LISPDIR=	${EMACS_LIBDIR}/site-lisp
EMACS_VERSION_SITE_LISPDIR=	${EMACS_LIBDIR_WITH_VER}/site-lisp

.  if defined(_EMACS_BUILD_DEP)
BUILD_DEPENDS+=		${EMACS_CMD}:${EMACS_PORTDIR}@${EMACS_FLAVOR}
.  endif
.  if defined(_EMACS_RUN_DEP)
RUN_DEPENDS+=	${EMACS_CMD}:${EMACS_PORTDIR}@${EMACS_FLAVOR}
.  endif

MAKE_ARGS+=	EMACS=${EMACS_CMD}
SCRIPTS_ENV+=	EMACS_LIBDIR=${EMACS_LIBDIR} \
		EMACS_VER=${EMACS_VER} \
		EMACS_LIBDIR_WITH_VER=${EMACS_LIBDIR_WITH_VER} \
		EMACS_SITE_LISPDIR=${EMACS_SITE_LISPDIR} \
		EMACS_VERSION_SITE_LISPDIR=${EMACS_VERSION_SITE_LISPDIR}

PLIST_SUB+=	EMACS_LIBDIR=${EMACS_LIBDIR} \
		EMACS_VER=${EMACS_VER} \
		EMACS_LIBDIR_WITH_VER=${EMACS_LIBDIR_WITH_VER} \
		EMACS_SITE_LISPDIR=${EMACS_SITE_LISPDIR} \
		EMACS_VERSION_SITE_LISPDIR=${EMACS_VERSION_SITE_LISPDIR}

.endif # _INCLUDE_USES_EMACS_MK
