function func_config()
{
  echo -e ${txtbld}"including vendor/extra/build/config"${rst}${pa}
  unset repo_sync
  source "vendor/extra/build/config"
  func_setenv
}

apply-test () {
  filename=$1
  shift
  patch_args=$*

  gotSubject=no
  msg=""

  unset debug
  debug=&>/dev/null

  cat $filename | while read line; do
  if [ "$line" == "---" ]; then

    title=$(sed -rn "s/Subject: (\[[^]]+] *)*//p" "$patch")
    absolute_patch_path="$patches_path/$patch"
    repo_to_patch="$(if dirname $patch|grep -q /; then dirname $patch; else dirname $patch |tr '_' '/'|tr '+' '_'; fi)"

    printf "%-45s %-75s %s" "${bldblu}$repo_to_patch${rst}" "$title"

        if [ ! -d $build_root/$repo_to_patch ] ; then
                echo "$repo_to_patch NOT EXIST! Go away and check your manifests. Skipping this patch."
                continue
        fi
    # do some dry-tests to figure out if fuzzy or binary is needed to patch
    if patch $patch_args -p1 < $filename --dry-run | grep -e 'applied' ${debug}; then
        echo -e $(tput setaf 6)"Previously applied patch detected!"${rst}
        #break
    #fi
    elif patch $patch_args -p1 < $filename --dry-run --quiet | grep -e 'binary' ${debug}; then
        if git am -3 $filename &>/dev/null; then echo -e $(tput setaf 6)"patched (bin)!"${rst}; patched="1";fi
    elif patch $patch_args -p1 < $filename --dry-run --quiet ${debug}; then
        if patch $patch_args -p1 < $filename --version-control=never ${debug}; then echo -e $(tput setaf 6)"patched (nor)!"${rst}; patched="1";fi
    elif ! patch $patch_args -p1 < $filename --dry-run --quiet ${debug}; then
        if patch $patch_args -p1 < $filename --version-control=never -F3 ${debug}; then echo -e $(tput setaf 6)"patched (fuz)!"${rst}; patched="1";fi
    fi
    if [ "$patched" == "1" ]; then
      git add --all; git commit -a -m "$msg" ${debug}
        fi
      break
    fi
    if [ "$gotSubject" == "no" ]; then
      hdr=(${line//:/ })
      if [ "${hdr[0]}" == "Subject" ]; then
        gotSubject=yes
        msg="${hdr[@]:3}"
      fi
    else
      msg="$msg $line"
    fi
  done
}

apply () {
  filename=$1
  shift
  patch_args=$*

  gotSubject=no
  msg=""

  cat $filename | while read line; do
  if [ "$line" == "---" ]; then


    patch $patch_args -p1 < $filename --no-backup-if-mismatch --version-control=never -F3 &>/dev/null
    git commit -a -m "$msg" &>/dev/null
    break
    fi
    if [ "$gotSubject" == "no" ]; then
      hdr=(${line//:/ })
      if [ "${hdr[0]}" == "Subject" ]; then
        gotSubject=yes
        msg="${hdr[@]:3}"
      fi
    else
      msg="$msg $line"
    fi
  done
}

function func_alias()
{
# GIT
alias gs='git status'
alias gl='git log --oneline'
alias gr='git remote -v'
alias gb='git branch -a'
alias rb='repo branches'
alias gcp='git cherry-pick --signoff'
alias gcpa='git cherry-pick --abort'
alias gcpc='git add --all && git cherry-pick --continue'
alias gres='git reset'
alias gd='git diff'
alias gca='git commit --amend'
alias gprr='git push $1 "$2:$2" -f'
# TMUX
alias tml='tmux ls'
alias tmk='tmux kill-session'
alias tmux="env TERM=xterm-256color tmux"
}

function func_colors()
{
if [ ! "$BUILD_WITH_COLORS" = "0" ]; then
    CL_RED="\033[31m"
    CL_GRN="\033[32m"
    CL_YLW="\033[33m"
    CL_BLU="\033[34m"
    CL_MAG="\033[35m"
    CL_CYN="\033[36m"
    CL_RST="\033[0m"
    red=$(tput setaf 1)             #  red
    grn=$(tput setaf 2)             #  green
    ylw=$(tput setaf 3)             #  yellow
    blu=$(tput setaf 4)             #  blue
    ppl=$(tput setaf 5)             #  purple
    cya=$(tput setaf 6)             #  cyan
    rst=$(tput sgr0)                #  Reset
    txtbld=$(tput bold)             #  Bold
    bldred=${txtbld}$(tput setaf 1) #  red
    bldgrn=${txtbld}$(tput setaf 2) #  green
    bldylw=${txtbld}$(tput setaf 3) #  yellow
    bldblu=${txtbld}$(tput setaf 4) #  blue
    bldppl=${txtbld}$(tput setaf 5) #  purple
    bldcya=${txtbld}$(tput setaf 6) #  cyan
    txtrst=$(tput sgr0)             #  Reset
    rev=$(tput rev)                 #  Reverse color
    pplrev=${rev}$(tput setaf 5)
    cyarev=${rev}$(tput setaf 6)
    ylwrev=${rev}$(tput setaf 3)
    blurev=${rev}$(tput setaf 4)
    pa="\n"
    par=$(tput sgr0)${pa}
fi
}

function func_su()
{
  if [ "${with_su}" == "1" ]; then myrom="$myrom+SU"; export WITH_SU="true"; else unset WITH_SU; fi
}

function func_ccache()
{
  if [[ ! -f $(which ccache &>/dev/null) ]]; then
    alias ccache='./prebuilts/misc/linux-x86/ccache/ccache'
  fi

  ccmd=$(ccache -M $ccache_size 2>&1)
  cdir=$(ccache -s|grep directory|cut -d '/' -f 3-10)
  csiz=$(ccache -s|grep 'cache size')
  ccur=$(echo $csiz|cut -d ' ' -f 3-4)
  cmax=$(echo $csiz|cut -d ' ' -f 8-9)


  if [[ "${ccache_use}" == "" || "${ccache_use}" == "0" || "${ccache_use}" == "false" ]]; then
    echo -e ${ylw}" * Disabled ccache"${txtrst};
    export USE_CCACHE=0;
  elif [ "${ccache_dir}" == "" ]; then
    echo -e ${red}"Error: ccache_dir not set [vendor/extra/config]"${txtrst};
  else
    export USE_CCACHE=1;
    export CCACHE_DIR=${ccache_dir}/${rom_dir};
    mkdir -p $CCACHE_DIR
    echo -e ${txtbld}"Setup ccache : ${rst}${cya}$ccur /${cya} $cmax ($cdir)"${rst};
  fi
}

function func_toolchain()
{
  if [ "${have_sdclang}" == "1" ]; then
    sdclang_version=`strings vendor/extra/toolchain/sdclang-3.8/bin/clang|grep Snapdragon|cut -d '"' -s -f 2|cut -b 18-51|sed 's/ /_/g'`
    export SDCLANG="true"; export SDCLANG_PATH=$path_sdclang; export SDCLANG_LTO_DEFS=$sdclang_lto_defs; export SDCLANG_VERSION=$sdclang_version;
    else unset SDCLANG; unset SDCLANG_PATH; unset have_sdclang; unset sdclang_version
  fi
}

function func_inject()
{
injection=$(echo -e'
function luxx {\n
    if [ "$DEVICE" == "" ]; then\n
        if [ "$1" != "" ]; then\n
            DEVICE="$1"\n
        fi\n
    fi\n
    if [ "$DEVICE" == "" ]; then\n
        echo -e "Abort: no device\n Try luxx falcon" >&2\n
    else\n
        if [ ! "$myrom" ]; then\n
            source build/envsetup.sh\n
        fi\n
        lunch "$myrom"_"$1"-userdebug\n
    fi\n
}\n
export -f luxx\n
')

    if [ "${OLD_HOME}" ]; then
        userhome=${OLD_HOME}
    else
        userhome=${HOME}
    fi

    if ! cat ${userhome}/.bashrc | grep -e "function luxx" &>/dev/null; then
        echo $injection >> ${userhome}/.bashrc
        source ${userhome}/.bashrc
        echo -e "... lunch function injected to .bashrc!"
    fi
    inject_luxx="luxx"
}

function func_inject_tmux()
{
injection_exitd=$(echo -e'
function exitd() {\n
    if [[ -z $TMUX ]]; then\n
        builtin exit\n
    else\n
        /usr/bin/tmux detach\n
    fi\n
}\n
export -f exitd\n
')

injection_exitk=$(echo -e'
function exitk() {\n
    if [[ ! -z $TMUX ]]; then\n
        builtin exit\n
    fi\n
}\n
export -f exitk\n
')

    if [ "${OLD_HOME}" ]; then
        userhome=${OLD_HOME}
    else
        userhome=${HOME}
    fi

    if ! cat ${userhome}/.bashrc | grep -e "function exitd" &>/dev/null; then
        echo $injection_exitd >> ${userhome}/.bashrc
        source ${userhome}/.bashrc
        echo -e "... tmux exitd function injected to .bashrc!"
    fi
    if ! cat ${userhome}/.bashrc | grep -e "function exitk" &>/dev/null; then
        echo $injection_exitk >> ${userhome}/.bashrc
        source ${userhome}/.bashrc
        echo -e "... tmux exitk function injected to .bashrc!"
    fi
    inject_tmux="tmux"
    alias exit='exitd'
}


function func_setenv()
{
    if [ "${rom_type}" == "cm" ]; then
        myrom="cm"; export MY_BUILD="$CM_BUILD";
    elif [ "${rom_type}" == "bliss" ]; then
        myrom="bliss"; export MY_BUILD="$BLISS_BUILD";
    elif [ "${rom_type}" == "du" ]; then
        myrom="du"; export MY_BUILD="$DU_BUILD";
    elif [ "${rom_type}" == "omni" ]; then
        myrom="omni"; export MY_BUILD="$CUSTOM_BUILD";
    else echo -e "\e[1;38;5;81m * Error: rom_type not set [vendor/extra/build/config]\033[0m\n";
    fi

    if [ "${system_kati}" == "1" ]; then
        system_kati="system kati"; export USE_SYSTEM_KATI="true";
    fi

    if [ "${inject_lunch}" == "1" ]; then
        func_inject
    fi

    if [[ "${use_tmux}" == "1" && "${inject_tmux}" == "1" ]]; then
        func_inject_tmux
    fi

    if [ "${set_alias}" == "1" ]; then
        func_alias
    fi

    if [ "${build_colors}" == "1" ]; then
        build_colors="colored"
        export BUILD_WITH_COLORS="1"
    else
        build_colors=""
        export BUILD_WITH_COLORS="0"
    fi

    mypyt=$(python --version 2>&1)
    myjdk=$(java -version 2>&1 | sed q | cut -d ' ' -f 1,3 | sed 's/["]//g')

    rom_dir_full=`pwd`
    rom_dir=`basename $rom_dir_full`

  if [ "${use_tmux}" == "1" ]; then
    export MY_TMUX="$rom_type"
    export REPO_HOME=$rom_dir_full
    export MY_ROM=$rom_dir
    export PATH="$jdk_dir:$PATH"
    rom_dir_len=$(expr length "$rom_dir_full")

    $(/usr/bin/tmux set-environment rom_dir_full $rom_dir_full)
    $(/usr/bin/tmux set-environment rom_dir_len $rom_dir_len)
    $(/usr/bin/tmux set-environment rom_dir $rom_dir)
    $(/usr/bin/tmux set-environment my_rom $rom_dir)

    if [ "${export_home}" == "1" ]; then
        export_home="HOME: ${rom_dir_full}"
        if [ ! -n "$OLD_HOME" ]; then
            export OLD_HOME=$HOME
        fi
        NEW_HOME=$rom_dir_full;
        export HOME=$NEW_HOME
        ln -sf ${OLD_HOME}/.gitconfig ${NEW_HOME}/.gitconfig
    fi
  fi

  func_colors
  func_ccache
  func_su
  func_toolchain

    echo -e ${txtbld}"Checking env : ${rst}${cya}$mypyt${rst} | ${cya}$myjdk${rst} | ${cya}$myrom${rst} | ${cya}${system_kati}${rst} | ${cya}${export_home}${rst} | ${cya}${inject_luxx} ${inject_tmux}${rst} | ${cya}${sdclang_version}"${txtrst};
}

function afterlunch()
{
    if [ -n "$TARGET_PRODUCT" ]; then
        TARGET_PRODUCT=$TARGET_PRODUCT
        if [ "${use_tmux}" == "1" ]; then
        $(/usr/bin/tmux set-environment TARGET_PRODUCT $TARGET_PRODUCT)
        fi
    fi
}

function patchbase()
{
    for f in `test -d vendor && find -L vendor/extra/patch -maxdepth 1 -name 'apply.sh' 2> /dev/null`
    do
        echo -e ${cya}"applying base patches"${rst}
        pvar=$(dirname $f)/base
        . $f
    done
    unset f
}

function patchcommon()
{
    for f in `test -d vendor && find -L vendor/extra/patch -maxdepth 1 -name 'apply.sh' 2> /dev/null`
    do
        echo -e ${cya}${pa}"applying common patches"${rst}
        pvar=$(dirname $f)/common
        . $f
    done
    unset f
}

function patchdevice()
{
    for f in `test -d device && find -L device/*/$MY_BUILD/patch -maxdepth 4 -name 'apply.sh' 2> /dev/null | sort` \
             `test -d vendor && find -L vendor/extra/patch -maxdepth 1 -name 'apply.sh' 2> /dev/null | sort`
    do
        echo -e ${cya}${pa}"applying $MY_BUILD patches"${rst}
        pvar=$(dirname $f)/device/$MY_BUILD
        . $f
    done
    unset f
}

function set_stuff_for_environment()
{
    settitle
    set_java_home
    setpaths
    set_sequence_number
  if [ "${rom_type}" ]; then
    afterlunch
    patchbase
    patchcommon
    patchdevice
  fi
  if [[ "${rom_type}" == "bliss" || "${rom_type}" == "omni" ]]; then
    export ANDROID_BUILD_TOP=$(gettop)
  fi
    # With this environment variable new GCC can apply colors to warnings/errors
    export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
    export ASAN_OPTIONS=detect_leaks=0

  if [ "${rom_type}" == "twrp" ]; then
    export TW_MAIN_VERSION="`cat bootable/recovery/variables.h |grep '#define TW_MAIN_VERSION_STR'|cut -d ' ' -f 9| sed 's/"//g'`"
    export TW_DEV_VERSION="`cat vendor/extra/vcontrol/TW_REC_BUILD_NUMBER-${TARGET_PRODUCT}.TXT`"
    export TW_NEW="`cat bootable/recovery/variables.h |grep '#define TW_MAIN_VERSION_STR'|cut -d ' ' -f 9| sed 's/"//g'| sed 's/\.//g'`"
    export TW_OLD="`cat vendor/extra/vcontrol/TW_REC_MAIN_VERSION-${TARGET_PRODUCT}.TXT`"
  fi
}

function set_sequence_number()
{
    export BUILD_ENV_SEQUENCE_NUMBER=10
}

# Force JAVA_HOME to point to java 1.7/1.8 if it isn't already set.
function set_java_home() {
    # Clear the existing JAVA_HOME value if we set it ourselves, so that
    # we can reset it later, depending on the version of java the build
    # system needs.
    #
    # If we don't do this, the JAVA_HOME value set by the first call to
    # build/envsetup.sh will persist forever.
    if [ -n "$ANDROID_SET_JAVA_HOME" ]; then
      export JAVA_HOME=""
    fi

    if [ ! "$JAVA_HOME" ]; then
      if [ -n "$LEGACY_USE_JAVA7" ]; then
        echo Warning: Support for JDK 7 will be dropped. Switch to JDK 8.
        case `uname -s` in
            Darwin)
                export JAVA_HOME=$(/usr/libexec/java_home -v 1.7)
                ;;
            *)
                export JAVA_HOME=/usr/lib/jvm/java-7-openjdk
                ;;
        esac
      else
        case `uname -s` in
            Darwin)
                export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
                ;;
            *)
                export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
                ;;
        esac
      fi

      # Keep track of the fact that we set JAVA_HOME ourselves, so that
      # we can change it on the next envsetup.sh, if required.
      export ANDROID_SET_JAVA_HOME=true
    fi
}

function addcompletions()
{
    local T dir f

    # Keep us from trying to run in something that isn't bash.
    if [ -z "${BASH_VERSION}" ]; then
        return
    fi

    # Keep us from trying to run in bash that's too old.
    if [ ${BASH_VERSINFO[0]} -lt 3 ]; then
        return
    fi

    dir="sdk/bash_completion"
    if [ -d ${dir} ]; then
        for f in `/bin/ls ${dir}/[a-z]*.bash 2> /dev/null`; do
            echo -e ${CL_GRN}
            #echo -e " including $f"
            echo -e ${CL_RST}
            . $f
        done
    fi
}

function analyse_log()
{
    # Check compile result and patch file success
    echo -e "\n***************************************************"
    echo -e "${CL_GRN}Check for compile errors:"

    #cd $ROOT_PATH
    echo -e ${CL_RED}
    grep " error" ./compile.log
    grep "forbidden warning" ./compile.log
    grep "note: previous definition is here" ./compile.log
    grep "fatal error:" ./compile.log
    grep "terminate" ./compile.log
    grep "ninja: error:" ./compile.log
    grep "needed" ./compile.log
    echo -e ${CL_RST}

    echo -e "***************************************************"
}

function repo()
{
  if [ "$1" == "sync" ] && [ -n "$repo_sync" ]; then
    read -r -p "check for uncommited changes? [y/N] " response
        response=${response,,}    # tolower
        if [[ "$response" =~ ^(yes|y)$ ]]; then
            repo diff | grep project
            if [[ "$?" == "0" ]]; then
                read -r -p "found uncommited changes, abort repo sync? [y/N] " response
                response=${response,,}    # tolower
                if [[ "$response" =~ ^(yes|y)$ ]]; then
                    echo "sync aborted"
                else
                    echo -e "Warning: using special sync command \n${repo_sync}\n" >&2
                    ${repo_sync}
                fi
            fi
        else
            echo -e "Warning: using special sync command \n${repo_sync}\n" >&2
            ${repo_sync}
        fi
  else
    /home/sub77/bin/repo $1
  fi
}

# Make using all available CPUs
function mka() {
    case `uname -s` in
        Darwin)
            make -j `sysctl hw.ncpu|cut -d" " -f2` "$@"
            ;;
        *)
            schedtool -B -n 1 -e ionice -n 1 make -j `cat /proc/cpuinfo | grep "^processor" | wc -l` "$@" | tee ./compile.log
            #DISPLAY=:0 ssh -Y grill uxterm -geometry 20x2 -cr black -fg grey -bg black -e 'ssh arch tail -f $(echo cat /roms/bliss/compile.log) | cut -c 1-18'
            analyse_log
            ;;
    esac
}

function mka_log()
{
  if [[ "$1" == "bootimage" || "$1" == "b" ]]; then
    echo -e ${CL_GRN}
    echo -e "Logging to ./compile.log" >&2
    echo -e ${CL_RST}
    alias mka='mka'; mka bootimage 2>&1 | tee ./compile.log; alias mka='mka_log'; analyse_log
  elif [[ "$1" == "bacon" || "$1" == "ba" ]]; then
    echo -e ${CL_GRN}
    echo -e "Logging to ./compile.log" >&2
    echo -e ${CL_RST}
    make -j8 bacon 2>&1 | tee ./compile.log
    analyse_log
  elif [[ "$1" == "clobber" || "$1" == "c" ]]; then
    echo -e ${CL_GRN}
    echo -e "Logging off" >&2
    echo -e ${CL_RST}
    make -j8 clobber
  else
    make -j8 $1
  fi
}

unset -f

func_config
