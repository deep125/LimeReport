#TARGET = limereport


CONFIG(debug, debug|release) {
    TARGET = limereportd
} else {
    TARGET = limereport
}


TEMPLATE = lib

contains(CONFIG, static_build){
    CONFIG += staticlib
}

!contains(CONFIG, staticlib){
    CONFIG += lib
    CONFIG += dll
}

CONFIG += create_prl
CONFIG += link_prl

macx{
    CONFIG  -= dll
    CONFIG  += lib_bundle
    CONFIG  += plugin
}

DEFINES += LIMEREPORT_EXPORTS

contains(CONFIG, staticlib){
    DEFINES += HAVE_STATIC_BUILD
    message(STATIC_BUILD)
    DEFINES -= LIMEREPORT_EXPORTS
}

EXTRA_FILES += \
    $$PWD/lrglobal.h \
    $$PWD/lrdatasourcemanagerintf.h \
    $$PWD/lrreportengine.h \
    $$PWD/lrscriptenginemanagerintf.h \
    $$PWD/lrcallbackdatasourceintf.h \
    $$PWD/lrpreparedpagesintf.h \
    $$PWD/lrpreviewreportwidget.h

include(limereport.pri)

unix:{
    DESTDIR  = $${DEST_LIBS}
    linux{
        QMAKE_POST_LINK += mkdir -p $$quote($${DEST_INCLUDE_DIR}) $$escape_expand(\\n\\t) # qmake need make mkdir -p on subdirs more than root/
        for(FILE,EXTRA_FILES){
            QMAKE_POST_LINK += $$QMAKE_COPY $$quote($$FILE) $$quote($${DEST_INCLUDE_DIR}) $$escape_expand(\\n\\t) # inside of libs make /include/files
        }
    }
    macx{
        for(FILE,EXTRA_FILES){
            QMAKE_POST_LINK += $$QMAKE_COPY $$quote($$FILE) $$quote($${DEST_INCLUDE_DIR}) $$escape_expand(\\n\\t)
        }
        QMAKE_POST_LINK += mkdir -p $$quote($${DESTDIR}/include) $$escape_expand(\\n\\t)
    }
    QMAKE_POST_LINK += $$QMAKE_COPY_DIR $$quote($${DEST_INCLUDE_DIR}) $$quote($${DESTDIR})
}

win32 {
    DESTDIR = $${DEST_LIBS}
    contains(QMAKE_HOST.os, Linux){
        QMAKE_POST_LINK += mkdir -p $$quote($${DEST_INCLUDE_DIR}) $$escape_expand(\\n\\t) # qmake need make mkdir -p on subdirs more than root/
        for(FILE,EXTRA_FILES){
            QMAKE_POST_LINK += $$QMAKE_COPY $$quote($$FILE) $$quote($${DEST_INCLUDE_DIR}) $$escape_expand(\\n\\t) # inside of libs make /include/files
        }
	QMAKE_POST_LINK += $$QMAKE_COPY_DIR $$quote($${DEST_INCLUDE_DIR}) $$quote($${DESTDIR})
    } else {
	EXTRA_FILES ~= s,/,\\,g
	BUILD_DIR ~= s,/,\\,g
	DEST_DIR = $$DESTDIR/include
	DEST_DIR ~= s,/,\\,g
	DEST_INCLUDE_DIR ~= s,/,\\,g

	for(FILE,EXTRA_FILES){
    	    QMAKE_POST_LINK += $$QMAKE_COPY \"$$FILE\" \"$${DEST_INCLUDE_DIR}\" $$escape_expand(\\n\\t)
	}
	QMAKE_POST_LINK += $$QMAKE_COPY_DIR \"$${DEST_INCLUDE_DIR}\" \"$${DEST_DIR}\"
    }
}

contains(CONFIG,zint){
    message(zint)
    INCLUDEPATH += $$ZINT_PATH/backend $$ZINT_PATH/backend_qt4
    DEPENDPATH += $$ZINT_PATH/backend $$ZINT_PATH/backend_qt4
    LIBS += -L$${DEST_LIBS}

    CONFIG(debug, debug|release) {
        LIBS += -lQtZintd
    } else {
        LIBS += -lQtZint
    }

}


#### Install mkspecs, headers and libs to QT_INSTALL_DIR

headerFiles.path = $$[QT_INSTALL_HEADERS]/LimeReport/
headerFiles.files = $${DEST_INCLUDE_DIR}/*
INSTALLS += headerFiles

mkspecs.path = $$[QT_INSTALL_DATA]/mkspecs/features
mkspecs.files = limereport.prf
INSTALLS += mkspecs

target.path = $$[QT_INSTALL_LIBS]
INSTALLS += target

#######
####Automatically build required translation files (*.qm)

contains(CONFIG,build_translations){
    LANGUAGES = ru es_ES ar fr zh pl

    defineReplace(prependAll) {
        for(a,$$1):result += $$2$${a}$$3
        return($$result)
    }

    TRANSLATIONS = $$prependAll(LANGUAGES, $$TRANSLATIONS_PATH/limereport_,.ts)

    qtPrepareTool(LUPDATE, lupdate)
    ts.commands = $$LUPDATE $$PWD -ts $$TRANSLATIONS

    TRANSLATIONS_FILES =
    qtPrepareTool(LRELEASE, lrelease)
    for(tsfile, TRANSLATIONS) {
        qmfile = $$tsfile
        qmfile ~= s,.ts$,.qm,
        qm.commands += $$LRELEASE -removeidentical $$tsfile -qm $$qmfile $$escape_expand(\\n\\t)
        tmp_command = $$LRELEASE -removeidentical $$tsfile -qm $$qmfile $$escape_expand(\\n\\t)
        TRANSLATIONS_FILES += $$qmfile
    }
    qm.depends = ts
    OTHER_FILES += $$TRANSLATIONS
    QMAKE_EXTRA_TARGETS += qm ts
    POST_TARGETDEPS +=  qm
}

#### EN AUTOMATIC TRANSLATIONS


