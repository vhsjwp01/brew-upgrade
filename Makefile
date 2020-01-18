SOURCE		= brew_upgrade.sh
TARGET_DIR	= ${HOME}/bin
PLATFORM	= $(shell uname -s)

install:
	if [ ! -d "${TARGET_DIR}" ]; then                                                         \
	    mkdir -p "${TARGET_DIR}"                                                            ; \
	fi                                                                                      ; \
	case "${PLATFORM}" in                                                                     \
	    Darwin)                                                                               \
	        cp "${SOURCE}" "${TARGET_DIR}/${SOURCE}"                                       && \
	        chmod 700 "${TARGET_DIR}/${SOURCE}"                                               \
	    ;;                                                                                    \
	    *)                                                                                    \
	        echo "Unknown (and unsupported) platform: ${PLATFORM}"                            \
	    ;; \
	esac
