#!/usr/bin/env bash
# =============================================================================
#  LinuxSetup CLI – Professional Package Installer
#  Author:  Mohammad Mizan
#  Description: 500+ tools installer with queue system & smart detection
#  Version: 1.0
#  Compatibility: Bash 4.0+, Linux (Debian/Ubuntu, Fedora, Arch, openSUSE etc.)
# =============================================================================

set -euo pipefail
shopt -s checkwinsize

# ---------- Global colour & emoji definitions ----------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m'
WHITE='\033[1;37m'; NC='\033[0m' # No Colour
BOLD='\033[1m'
ICON_OK="✅"; ICON_FAIL="❌"; ICON_QUEUED="📌"; ICON_STAR="⭐"
ICON_GEAR="⚙️"; ICON_PACKAGE="📦"; ICON_ROCKET="🚀"; ICON_WARN="⚠️"

# ---------- Global variables ----------
declare -a INSTALL_QUEUE=()          # holds "category|app_id"
declare -A ALL_SOFTWARE=()           # global index: key="cat_id|app_id" -> values delimited
IS_ROOT=false
DISTRO_ID=""; DISTRO_VERSION=""; ARCH=""; PM=""   # package manager
HAS_SNAP=false; HAS_FLATPAK=false

# ---------- System detection ----------
detect_system() {
    ARCH=$(uname -m)
    if [ "$EUID" -eq 0 ]; then IS_ROOT=true; fi

    # Identify distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID=$ID
        DISTRO_VERSION=$VERSION_ID
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO_ID=$DISTRIB_ID
        DISTRO_VERSION=$DISTRIB_RELEASE
    else
        DISTRO_ID="unknown"
    fi

    # Detect package manager
    if command -v apt &>/dev/null; then PM="apt"
    elif command -v dnf &>/dev/null; then PM="dnf"
    elif command -v yum &>/dev/null; then PM="yum"
    elif command -v pacman &>/dev/null; then PM="pacman"
    elif command -v zypper &>/dev/null; then PM="zypper"
    else PM="unknown"; fi

    command -v snap &>/dev/null && HAS_SNAP=true || HAS_SNAP=false
    command -v flatpak &>/dev/null && HAS_FLATPAK=true || HAS_FLATPAK=false
}

# ---------- Software Catalog (subset – extend as desired) ----------
declare -A CAT_NAMES CAT_DESC
CAT_NAMES=(
  ["01"]="🌐 Web Browsers"        ["02"]="💬 Communication"
  ["03"]="💻 Development Tools"   ["04"]="🎵 Media & Entertainment"
  ["05"]="🔧 System Utilities"    ["06"]="📊 Office & Productivity"
  ["07"]="🔒 Security & Privacy"  ["08"]="🎨 Graphics & Design"
  ["09"]="🎮 Gaming Platforms"    ["10"]="🌐 Networking Tools"
  ["11"]="🗄️ Database Tools"      ["12"]="💾 Backup & Recovery"
  ["13"]="📚 Education"           ["14"]="🖥️ Virtualization"
  ["15"]="📝 Languages & Runtimes"["16"]="🎥 Video Production"
  ["17"]="🎵 Audio Production"    ["18"]="⚙️ Utilities & Tweaks"
  ["19"]="💼 Business Tools"      ["20"]="🔍 Custom Search & Install"
)
CAT_DESC=(
  ["01"]="Internet browsers for web surfing"
  ["02"]="Messaging, chat and video calling apps"
  ["03"]="Programming, coding and development environments"
  ["04"]="Music, video players and media apps"
  ["05"]="System maintenance and optimisation tools"
  ["06"]="Office suites and productivity apps"
  ["07"]="Antivirus, VPN and security software"
  ["08"]="Photo editing, design and 3D modelling"
  ["09"]="Game launchers and gaming platforms"
  ["10"]="Network utilities, FTP and remote access"
  ["11"]="Database management and development"
  ["12"]="Data backup and recovery solutions"
  ["13"]="Educational and learning software"
  ["14"]="Virtual machines and container platforms"
  ["15"]="Programming language runtimes/compilers"
  ["16"]="Video editing and production software"
  ["17"]="Audio editing and music production"
  ["18"]="System utilities and tweaking tools"
  ["19"]="Business and finance applications"
  ["20"]="Search and install any software by name"
)

# Each app entry: "app_id|name|install_method:pkg|license|arch|distro|extra"
# install_method can be: apt, snap, flatpak, custom, etc.
# pkg is the package name for that method (may differ from app_id)
# We'll use a single string for each app, stored in associative array keyed by "cat_id|app_num"
declare -A APPS
# Helper to add an app
add_app() {
    local cat="$1" num="$2" data="$3"
    APPS["${cat}|${num}"]="$data"
}

# --- Category 01: Web Browsers ---
add_app "01" "001" "google-chrome|Google Chrome|apt:google-chrome-stable|Free|x86_64|debian,ubuntu|"
add_app "01" "002" "firefox|Mozilla Firefox|apt:firefox,flatpak:org.mozilla.firefox|Free|any|any|"
add_app "01" "003" "brave|Brave Browser|snap:brave|Free|x86_64|any|"
add_app "01" "004" "opera|Opera Browser|snap:opera|Free|x86_64|any|"
add_app "01" "005" "vivaldi|Vivaldi Browser|apt:vivaldi-stable|Free|x86_64|debian,ubuntu|"
add_app "01" "006" "chromium|Chromium (open-source)|apt:chromium-browser,snap:chromium|Free|any|any|"
add_app "01" "007" "tor|Tor Browser|flatpak:org.torproject.torbrowser-launcher|Free|x86_64|any|"
add_app "01" "008" "waterfox|Waterfox|flatpak:net.waterfox.waterfox|Free|x86_64|any|"
add_app "01" "009" "pale-moon|Pale Moon|apt:palemoon|Free|x86_64|debian,ubuntu|"
add_app "01" "010" "midori|Midori|snap:midori|Free|any|any|"

# --- Category 02: Communication ---
add_app "02" "001" "whatsapp|WhatsApp Desktop|snap:whatsie|Free|any|any|"
add_app "02" "002" "telegram|Telegram Desktop|snap:telegram-desktop|Free|any|any|"
add_app "02" "003" "discord|Discord|snap:discord|Free|x86_64|any|"
add_app "02" "004" "zoom|Zoom|snap:zoom-client|Freemium|any|any|"
add_app "02" "005" "skype|Skype|snap:skype|Free|any|any|"
add_app "02" "006" "signal|Signal Desktop|snap:signal-desktop|Free|any|any|"
add_app "02" "007" "slack|Slack|snap:slack|Freemium|x86_64|any|"
add_app "02" "008" "teams|Microsoft Teams|snap:teams-for-linux|Free|any|any|"
add_app "02" "009" "viber|Viber|flatpak:com.viber.Viber|Free|x86_64|any|"
add_app "02" "010" "line|LINE|flatpak:com.line.Line|Free|x86_64|any|"

# --- Category 03: Development Tools ---
add_app "03" "001" "vscode|Visual Studio Code|snap:code,flatpak:com.visualstudio.code|Free|x86_64,aarch64|any|"
add_app "03" "002" "python3|Python 3|apt:python3|Free|any|any|"
add_app "03" "003" "nodejs|Node.js LTS|apt:nodejs|Free|any|any|"
add_app "03" "004" "git|Git|apt:git|Free|any|any|"
add_app "03" "005" "docker|Docker|apt:docker.io|Free|x86_64,aarch64|any|"
add_app "03" "006" "postman|Postman|snap:postman|Freemium|x86_64|any|"
add_app "03" "007" "android-studio|Android Studio|snap:android-studio|Free|x86_64|any|"
add_app "03" "008" "openjdk|OpenJDK 21|apt:openjdk-21-jdk|Free|any|any|"
add_app "03" "009" "vim|Vim|apt:vim|Free|any|any|"
add_app "03" "010" "notepadqq|Notepadqq (Notepad++ clone)|snap:notepadqq|Free|x86_64|any|"

# --- Category 04: Media ---
add_app "04" "001" "vlc|VLC Media Player|apt:vlc,snap:vlc|Free|any|any|"
add_app "04" "002" "spotify|Spotify|snap:spotify|Freemium|x86_64|any|"
add_app "04" "003" "kodi|Kodi Media Center|apt:kodi,flatpak:tv.kodi.Kodi|Free|any|any|"
add_app "04" "004" "obs-studio|OBS Studio|snap:obs-studio|Free|any|any|"
add_app "04" "005" "audacity|Audacity|apt:audacity,flatpak:org.audacityteam.Audacity|Free|any|any|"
add_app "04" "006" "gimp|GIMP|apt:gimp,flatpak:org.gimp.GIMP|Free|any|any|"
add_app "04" "007" "kdenlive|Kdenlive (Video Editor)|apt:kdenlive,flatpak:org.kde.kdenlive|Free|any|any|"
add_app "04" "008" "blender|Blender|snap:blender|Free|any|any|"
add_app "04" "009" "inkscape|Inkscape|apt:inkscape,flatpak:org.inkscape.Inkscape|Free|any|any|"
add_app "04" "010" "musescore|MuseScore|snap:musescore|Free|any|any|"

# ============================================================
# Category 05: System Utilities
# ============================================================
add_app "05" "001" "7zip|7-Zip|apt:p7zip-full|Free|any|any|"
add_app "05" "002" "unrar|unRAR|apt:unrar|Free|any|any|"
add_app "05" "003" "bleachbit|BleachBit|apt:bleachbit|Free|any|any|"
add_app "05" "004" "stacer|Stacer System Optimizer|apt:stacer|Free|any|any|"
add_app "05" "005" "gnome-disk-utility|GNOME Disks|apt:gnome-disk-utility|Free|any|any|"
add_app "05" "006" "gparted|GParted Partition Editor|apt:gparted|Free|any|any|"
add_app "05" "007" "neofetch|Neofetch|apt:neofetch|Free|any|any|"
add_app "05" "008" "htop|htop Process Viewer|apt:htop|Free|any|any|"
add_app "05" "009" "timeshift|Timeshift Backup|apt:timeshift|Free|any|any|"
add_app "05" "010" "conky|Conky System Monitor|apt:conky-all|Free|any|any|"

# ============================================================
# Category 06: Office & Productivity
# ============================================================
add_app "06" "001" "libreoffice|LibreOffice|apt:libreoffice,flatpak:org.libreoffice.LibreOffice|Free|any|any|"
add_app "06" "002" "onlyoffice|OnlyOffice Desktop Editors|snap:onlyoffice-desktopeditors|Free|x86_64|any|"
add_app "06" "003" "wps-office|WPS Office|snap:wps-office|Freemium|x86_64|any|"
add_app "06" "004" "evince|Evince Document Viewer|apt:evince|Free|any|any|"
add_app "06" "005" "okular|Okular|apt:okular,flatpak:org.kde.okular|Free|any|any|"
add_app "06" "006" "calibre|Calibre E-book Manager|apt:calibre|Free|any|any|"
add_app "06" "007" "scribus|Scribus Desktop Publishing|apt:scribus|Free|any|any|"
add_app "06" "008" "gnome-contacts|GNOME Contacts|apt:gnome-contacts|Free|any|any|"
add_app "06" "009" "gnome-calendar|GNOME Calendar|apt:gnome-calendar|Free|any|any|"
add_app "06" "010" "marktext|Mark Text Editor|snap:marktext|Free|x86_64|any|"

# ============================================================
# Category 07: Security & Privacy
# ============================================================
add_app "07" "001" "clamav|ClamAV Antivirus|apt:clamav|Free|any|any|"
add_app "07" "002" "firewalld|Firewalld|apt:firewalld|Free|any|any|"
add_app "07" "003" "ufw|Uncomplicated Firewall (UFW)|apt:ufw|Free|any|any|"
add_app "07" "004" "keepassxc|KeePassXC Password Manager|apt:keepassxc,flatpak:org.keepassxc.KeePassXC|Free|any|any|"
add_app "07" "005" "bitwarden|Bitwarden|snap:bitwarden,flatpak:com.bitwarden.desktop|Freemium|any|any|"
add_app "07" "006" "protonvpn|ProtonVPN|snap:protonvpn|Freemium|any|any|"
add_app "07" "007" "nordvpn|NordVPN|snap:nordvpn|Paid|any|any|"
add_app "07" "008" "veracrypt|VeraCrypt|apt:veracrypt|Free|x86_64|any|"
add_app "07" "009" "gnome-encfs-manager|EncFS Manager|apt:gnome-encfs-manager|Free|any|any|"
add_app "07" "010" "rkhunter|RKHunter Rootkit Scanner|apt:rkhunter|Free|any|any|"

# ============================================================
# Category 08: Graphics & Design
# ============================================================
add_app "08" "001" "gimp|GIMP|apt:gimp,flatpak:org.gimp.GIMP|Free|any|any|"
add_app "08" "002" "inkscape|Inkscape|apt:inkscape,flatpak:org.inkscape.Inkscape|Free|any|any|"
add_app "08" "003" "blender|Blender|snap:blender,flatpak:org.blender.Blender|Free|any|any|"
add_app "08" "004" "krita|Krita|apt:krita,flatpak:org.kde.krita|Free|any|any|"
add_app "08" "005" "pinta|Pinta|apt:pinta|Free|any|any|"
add_app "08" "006" "darktable|Darktable|apt:darktable|Free|any|any|"
add_app "08" "007" "rawtherapee|RawTherapee|apt:rawtherapee|Free|any|any|"
add_app "08" "008" "shotwell|Shotwell Photo Manager|apt:shotwell|Free|any|any|"
add_app "08" "009" "figma-linux|Figma for Linux|snap:figma-linux|Freemium|x86_64|any|"
add_app "08" "010" "synfigstudio|Synfig Studio|apt:synfigstudio|Free|any|any|"

# ============================================================
# Category 09: Gaming Platforms
# ============================================================
add_app "09" "001" "steam|Steam|apt:steam,flatpak:com.valvesoftware.Steam|Free|x86_64|any|"
add_app "09" "002" "lutris|Lutris|apt:lutris,flatpak:net.lutris.Lutris|Free|any|any|"
add_app "09" "003" "wine|Wine|apt:wine|Free|any|any|"
add_app "09" "004" "playonlinux|PlayOnLinux|apt:playonlinux|Free|any|any|"
add_app "09" "005" "heroic|Heroic Games Launcher|snap:heroic|Free|x86_64|any|"
add_app "09" "006" "itch|itch.io|flatpak:io.itch.itch|Free|any|any|"
add_app "09" "007" "minecraft|Minecraft Launcher|snap:mc-installer|Paid|any|any|"
add_app "09" "008" "retroarch|RetroArch|apt:retroarch,flatpak:org.libretro.RetroArch|Free|any|any|"
add_app "09" "009" "ppsspp|PPSSPP Emulator|apt:ppsspp|Free|any|any|"
add_app "09" "010" "dosbox|DOSBox|apt:dosbox|Free|any|any|"

# ============================================================
# Category 10: Networking Tools
# ============================================================
add_app "10" "001" "filezilla|FileZilla|apt:filezilla|Free|any|any|"
add_app "10" "002" "putty|PuTTY SSH Client|apt:putty|Free|any|any|"
add_app "10" "003" "wireshark|Wireshark|apt:wireshark|Free|any|any|"
add_app "10" "004" "nmap|Nmap|apt:nmap|Free|any|any|"
add_app "10" "005" "remmina|Remmina Remote Desktop|apt:remmina,flatpak:org.remmina.Remmina|Free|any|any|"
add_app "10" "006" "teamviewer|TeamViewer|apt:teamviewer|Freemium|x86_64|any|"
add_app "10" "007" "anydesk|AnyDesk|apt:anydesk|Freemium|x86_64|any|"
add_app "10" "008" "openvpn|OpenVPN|apt:openvpn|Free|any|any|"
add_app "10" "009" "wireguard|WireGuard|apt:wireguard|Free|any|any|"
add_app "10" "010" "angryipscanner|Angry IP Scanner|apt:ipscan|Free|any|any|"

# ============================================================
# Category 11: Database Tools
# ============================================================
add_app "11" "001" "mysql-server|MySQL Server|apt:mysql-server|Free|any|any|"
add_app "11" "002" "postgresql|PostgreSQL|apt:postgresql|Free|any|any|"
add_app "11" "003" "mongodb|MongoDB|apt:mongodb|Free|x86_64|any|"
add_app "11" "004" "sqlite3|SQLite|apt:sqlite3|Free|any|any|"
add_app "11" "005" "dbeaver|DBeaver|snap:dbeaver-ce,flatpak:io.dbeaver.DBeaverCommunity|Free|any|any|"
add_app "11" "006" "mysql-workbench|MySQL Workbench|apt:mysql-workbench|Free|x86_64|any|"
add_app "11" "007" "pgadmin4|pgAdmin 4|apt:pgadmin4,flatpak:org.pgadmin.pgadmin4|Free|any|any|"
add_app "11" "008" "redis|Redis|apt:redis-server|Free|any|any|"
add_app "11" "009" "mariadb-server|MariaDB Server|apt:mariadb-server|Free|any|any|"
add_app "11" "010" "robo3t|Robo 3T (MongoDB GUI)|snap:robo3t|Free|x86_64|any|"

# ============================================================
# Category 12: Backup & Recovery
# ============================================================
add_app "12" "001" "timeshift|Timeshift|apt:timeshift|Free|any|any|"
add_app "12" "002" "deja-dup|Déjà Dup Backup|apt:deja-dup|Free|any|any|"
add_app "12" "003" "duplicity|Duplicity|apt:duplicity|Free|any|any|"
add_app "12" "004" "rsync|rsync|apt:rsync|Free|any|any|"
add_app "12" "005" "borgbackup|BorgBackup|apt:borgbackup|Free|any|any|"
add_app "12" "006" "testdisk|TestDisk|apt:testdisk|Free|any|any|"
add_app "12" "007" "photorec|PhotoRec|apt:testdisk|Free|any|any|"
add_app "12" "008" "clonezilla|Clonezilla (live)|apt:clonezilla|Free|any|any|"
add_app "12" "009" "grsync|Grsync (rsync GUI)|apt:grsync|Free|any|any|"
add_app "12" "010" "partimage|Partimage|apt:partimage|Free|any|any|"

# ============================================================
# Category 13: Education & Learning
# ============================================================
add_app "13" "001" "anki|Anki|apt:anki,flatpak:net.ankiweb.Anki|Free|any|any|"
add_app "13" "002" "geogebra|GeoGebra|apt:geogebra|Free|any|any|"
add_app "13" "003" "stellarium|Stellarium|apt:stellarium|Free|any|any|"
add_app "13" "004" "musescore|MuseScore|snap:musescore,flatpak:org.musescore.MuseScore|Free|any|any|"
add_app "13" "005" "kicad|KiCad EDA|apt:kicad,flatpak:org.kicad.KiCad|Free|any|any|"
add_app "13" "006" "octave|GNU Octave|apt:octave|Free|any|any|"
add_app "13" "007" "r-base|R Programming Language|apt:r-base|Free|any|any|"
add_app "13" "008" "jupyter-notebook|Jupyter Notebook|apt:jupyter-notebook|Free|any|any|"
add_app "13" "009" "kalgebra|KAlgebra|apt:kalgebra|Free|any|any|"
add_app "13" "010" "gcompris|GCompris Educational Suite|apt:gcompris|Free|any|any|"

# ============================================================
# Category 14: Virtualization
# ============================================================
add_app "14" "001" "virtualbox|VirtualBox|apt:virtualbox|Free|any|any|"
add_app "14" "002" "virt-manager|Virtual Machine Manager|apt:virt-manager|Free|any|any|"
add_app "14" "003" "qemu|QEMU|apt:qemu-system-x86|Free|any|any|"
add_app "14" "004" "docker|Docker Engine|apt:docker.io|Free|x86_64,aarch64|any|"
add_app "14" "005" "docker-desktop|Docker Desktop|apt:docker-desktop|Freemium|x86_64|any|"
add_app "14" "006" "vagrant|Vagrant|apt:vagrant|Free|any|any|"
add_app "14" "007" "lxd|LXD Container Hypervisor|snap:lxd|Free|any|any|"
add_app "14" "008" "wine|Wine (Windows compat)|apt:wine|Free|any|any|"
add_app "14" "009" "bottles|Bottles (Wine manager)|flatpak:com.usebottles.bottles|Free|any|any|"
add_app "14" "010" "genymotion|Genymotion Android Emulator|apt:genymotion|Freemium|x86_64|any|"

# ============================================================
# Category 15: Programming Languages & Runtimes
# ============================================================
add_app "15" "001" "python3|Python 3|apt:python3|Free|any|any|"
add_app "15" "002" "nodejs|Node.js LTS|apt:nodejs|Free|any|any|"
add_app "15" "003" "openjdk-21|OpenJDK 21|apt:openjdk-21-jdk|Free|any|any|"
add_app "15" "004" "golang|Go|apt:golang-go|Free|any|any|"
add_app "15" "005" "rustc|Rust|apt:rustc|Free|any|any|"
add_app "15" "006" "php|PHP|apt:php|Free|any|any|"
add_app "15" "007" "ruby|Ruby|apt:ruby|Free|any|any|"
add_app "15" "008" "perl|Perl|apt:perl|Free|any|any|"
add_app "15" "009" "dotnet-sdk|.NET SDK|apt:dotnet-sdk-8.0|Free|any|any|"
add_app "15" "010" "lua5.4|Lua 5.4|apt:lua5.4|Free|any|any|"

# ============================================================
# Category 16: Video Production
# ============================================================
add_app "16" "001" "kdenlive|Kdenlive|apt:kdenlive,flatpak:org.kde.kdenlive|Free|any|any|"
add_app "16" "002" "openshot|OpenShot Video Editor|apt:openshot,flatpak:org.openshot.OpenShot|Free|any|any|"
add_app "16" "003" "shotcut|Shotcut|snap:shotcut,flatpak:org.shotcut.Shotcut|Free|any|any|"
add_app "16" "004" "davinci-resolve|DaVinci Resolve|apt:davinci-resolve|Freemium|x86_64|any|"
add_app "16" "005" "flowblade|Flowblade|apt:flowblade|Free|any|any|"
add_app "16" "006" "pitivi|Pitivi|apt:pitivi,flatpak:org.pitivi.Pitivi|Free|any|any|"
add_app "16" "007" "olive|Olive Video Editor|snap:olive-editor|Free|x86_64|any|"
add_app "16" "008" "avidemux|Avidemux|apt:avidemux|Free|any|any|"
add_app "16" "009" "handbrake|HandBrake|apt:handbrake,flatpak:fr.handbrake.ghb|Free|any|any|"
add_app "16" "010" "obs-studio|OBS Studio|apt:obs-studio,snap:obs-studio|Free|any|any|"

# ============================================================
# Category 17: Audio Production
# ============================================================
add_app "17" "001" "audacity|Audacity|apt:audacity,flatpak:org.audacityteam.Audacity|Free|any|any|"
add_app "17" "002" "ardour|Ardour DAW|apt:ardour|Free|any|any|"
add_app "17" "003" "lmms|LMMS|apt:lmms|Free|any|any|"
add_app "17" "004" "musescore|MuseScore|snap:musescore|Free|any|any|"
add_app "17" "005" "rosegarden|Rosegarden|apt:rosegarden|Free|any|any|"
add_app "17" "006" "qtractor|Qtractor|apt:qtractor|Free|any|any|"
add_app "17" "007" "hydrogen|Hydrogen Drum Machine|apt:hydrogen|Free|any|any|"
add_app "17" "008" "guvcview|GUVCView (webcam capture)|apt:guvcview|Free|any|any|"
add_app "17" "009" "sound-juicer|Sound Juicer CD ripper|apt:sound-juicer|Free|any|any|"
add_app "17" "010" "easytag|EasyTAG|apt:easytag|Free|any|any|"

# ============================================================
# Category 18: Utilities & Tweaks
# ============================================================
add_app "18" "001" "neofetch|Neofetch|apt:neofetch|Free|any|any|"
add_app "18" "002" "gnome-tweaks|GNOME Tweaks|apt:gnome-tweaks|Free|any|any|"
add_app "18" "003" "dconf-editor|Dconf Editor|apt:dconf-editor|Free|any|any|"
add_app "18" "004" "synaptic|Synaptic Package Manager|apt:synaptic|Free|any|any|"
add_app "18" "005" "lightdm-gtk-greeter-settings|LightDM GTK Greeter Settings|apt:lightdm-gtk-greeter-settings|Free|any|any|"
add_app "18" "006" "tlp|TLP Power Management|apt:tlp|Free|any|any|"
add_app "18" "007" "bleachbit|BleachBit|apt:bleachbit|Free|any|any|"
add_app "18" "008" "gparted|GParted|apt:gparted|Free|any|any|"
add_app "18" "009" "piper|Piper (gaming mouse config)|apt:piper|Free|x86_64|any|"
add_app "18" "010" "screenfetch|screenFetch|apt:screenfetch|Free|any|any|"

# ============================================================
# Category 19: Business Tools
# ============================================================
add_app "19" "001" "gnucash|GnuCash|apt:gnucash,flatpak:org.gnucash.GnuCash|Free|any|any|"
add_app "19" "002" "homebank|HomeBank|apt:homebank|Free|any|any|"
add_app "19" "003" "kmymoney|KMyMoney|apt:kmymoney|Free|any|any|"
add_app "19" "004" "skrooge|Skrooge|apt:skrooge|Free|any|any|"
add_app "19" "005" "ledger|Ledger CLI Accounting|apt:ledger|Free|any|any|"
add_app "19" "006" "moneymanagerex|Money Manager Ex|apt:moneymanagerex|Free|any|any|"
add_app "19" "007" "projectlibre|ProjectLibre|apt:projectlibre|Free|any|any|"
add_app "19" "008" "ganttproject|GanttProject|apt:ganttproject|Free|any|any|"
add_app "19" "009" "calcurse|calcurse (CLI calendar)|apt:calcurse|Free|any|any|"
add_app "19" "010" "zim|Zim Desktop Wiki|apt:zim|Free|any|any|"

# ============================================================
# Category 20: Custom Search (only one entry needed)
# ============================================================
add_app "20" "001" "search|Custom Search (any name)|custom:search|N/A|any|any|search"

# ---------- Helper: parse app data ----------
# splits the data string into individual fields
parse_app_data() {
    local data="$1"
    IFS='|' read -r app_id name methods license arch distro extra <<< "$data"
    echo "$app_id|$name|$methods|$license|$arch|$distro|$extra"
}

# ---------- Compatibility check ----------
check_compatibility() {
    local data="$1"
    local app_id name methods license req_arch req_distro extra
    IFS='|' read -r app_id name methods license req_arch req_distro extra <<< "$(parse_app_data "$data")"

    local compatible=true
    local messages=()

    # Architecture check
    if [ "$req_arch" != "any" ]; then
        if ! echo "$req_arch" | grep -qw "$ARCH"; then
            compatible=false
            messages+=("Architecture mismatch: requires $req_arch, current is $ARCH")
        fi
    fi

    # Distro check (basic substring match)
    if [ "$req_distro" != "any" ]; then
        if ! echo "$req_distro" | grep -qi "$DISTRO_ID"; then
            messages+=("Distribution warning: tested on $req_distro, you run $DISTRO_ID")
            # not necessarily a hard error
        fi
    fi

    # Special warning for paid/freemium
    if [ "$license" = "Paid" ] || [ "$license" = "Freemium" ]; then
        messages+=("Note: This software requires a license (${license})")
    fi

    # Admin rights
    if [ "$IS_ROOT" = false ]; then
        messages+=("Sudo required for installation (password may be asked)")
    fi

    echo "$compatible|${messages[*]}"
}

# ---------- Queue management ----------
add_to_queue() {
    local cat="$1" app_num="$2"
    local key="${cat}|${app_num}"
    if ! printf '%s\n' "${INSTALL_QUEUE[@]}" | grep -qxF "$key"; then
        INSTALL_QUEUE+=("$key")
        echo -e "${GREEN}${ICON_OK} Added to queue.${NC}"
    else
        echo -e "${YELLOW}${ICON_QUEUED} Already in queue.${NC}"
    fi
}

remove_from_queue() {
    local key="$1"
    local new_queue=()
    for item in "${INSTALL_QUEUE[@]}"; do
        if [ "$item" != "$key" ]; then
            new_queue+=("$item")
        fi
    done
    INSTALL_QUEUE=("${new_queue[@]}")
    echo -e "${YELLOW}🗑️ Removed from queue.${NC}"
}

clear_queue() {
    INSTALL_QUEUE=()
    echo -e "${YELLOW}🧹 Queue cleared.${NC}"
}

# ---------- Installation engine ----------
run_install() {
    local app_data="$1"
    local app_id name methods license req_arch req_distro extra
    IFS='|' read -r app_id name methods license req_arch req_distro extra <<< "$app_data"

    echo -e "${CYAN}${ICON_GEAR} Installing: ${BOLD}${name}${NC} (${license})..."

    # Determine best install method available
    local chosen_method=""
    local chosen_pkg=""
    # methods is a comma-separated list like "apt:firefox,flatpak:org.mozilla.firefox"
    IFS=',' read -ra method_list <<< "$methods"
    for m in "${method_list[@]}"; do
        IFS=':' read -r method pkg <<< "$m"
        case "$method" in
            apt|dnf|yum|pacman|zypper)
                if [ "$method" = "$PM" ]; then
                    chosen_method="$method"
                    chosen_pkg="$pkg"
                    break
                fi
                ;;
            snap)
                if $HAS_SNAP; then chosen_method="snap"; chosen_pkg="$pkg"; break; fi
                ;;
            flatpak)
                if $HAS_FLATPAK; then chosen_method="flatpak"; chosen_pkg="$pkg"; break; fi
                ;;
            custom)
                chosen_method="custom"; chosen_pkg="$pkg"; break
                ;;
        esac
    done

    if [ -z "$chosen_method" ]; then
        echo -e "${RED}${ICON_FAIL} No compatible installation method found for $name.${NC}"
        return 1
    fi

    # Perform installation
    local cmd=""
    case "$chosen_method" in
        apt) cmd="sudo apt install -y $chosen_pkg";;
        dnf) cmd="sudo dnf install -y $chosen_pkg";;
        yum) cmd="sudo yum install -y $chosen_pkg";;
        pacman) cmd="sudo pacman -S --noconfirm $chosen_pkg";;
        zypper) cmd="sudo zypper install -y $chosen_pkg";;
        snap) cmd="sudo snap install $chosen_pkg";;
        flatpak) cmd="flatpak install -y flathub $chosen_pkg";;
        custom)
            if [ "$chosen_pkg" = "search" ]; then
                echo -e "${YELLOW}Custom search will be handled interactively.${NC}"
                return 0
            fi
            ;;
        *) echo -e "${RED}Unknown method $chosen_method${NC}"; return 1;;
    esac

    echo -e "${BLUE}Running: $cmd${NC}"
    if eval "$cmd"; then
        echo -e "${GREEN}${ICON_OK} Successfully installed ${name}${NC}"
        return 0
    else
        echo -e "${RED}${ICON_FAIL} Installation failed for ${name}${NC}"
        return 1
    fi
}

start_installation() {
    if [ ${#INSTALL_QUEUE[@]} -eq 0 ]; then
        echo -e "${RED}${ICON_FAIL} Queue is empty!${NC}"
        return
    fi

    echo -e "\n${BOLD}${CYAN}🚀 Starting batch installation of ${#INSTALL_QUEUE[@]} packages...${NC}\n"
    local total=${#INSTALL_QUEUE[@]} success=0 failed=0

    for key in "${INSTALL_QUEUE[@]}"; do
        local cat="${key%%|*}" num="${key##*|}"
        local app_data="${APPS[$key]}"
        echo -e "\n${MAGENTA}[$((success+failed+1))/$total]${NC} Processing ${app_data%%|*}..."
        local comp
        comp=$(check_compatibility "$app_data")
        local is_compat="${comp%%|*}"
        local msgs="${comp#*|}"
        if [ "$is_compat" != "true" ]; then
            echo -e "${YELLOW}${ICON_WARN} Compatibility issues: ${msgs}${NC}"
        fi

        if run_install "$app_data"; then
            ((success++))
        else
            ((failed++))
        fi
    done

    echo -e "\n${BOLD}${GREEN}✅ Installation finished: $success succeeded, $failed failed.${NC}"
    clear_queue
}

# ---------- UI Components ----------
show_header() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
  _     _       _                 ____       _                 
 | |   (_)_ __ | |_ _   _ ___    / ___|  ___| |_ _   _ _ __  
 | |   | | '_ \| __| | | / __|___\___ \ / _ \ __| | | | '_ \ 
 | |___| | | | | |_| |_| \__ \_____|_) |  __/ |_| |_| | |_) |
 |_____|_|_| |_|\__|\__,_|___/    |____/ \___|\__|\__,_| .__/ 
                                                         |_|    
EOF
    echo -e "${NC}"
    echo -e "${BOLD}${YELLOW}🐧 LinuxSetup CLI – Professional Installer${NC}"
    echo -e "${WHITE}System: $DISTRO_ID $DISTRO_VERSION | $ARCH | PM: $PM${NC}"
    echo -e "${GREEN}Queue: ${#INSTALL_QUEUE[@]} item(s) ready${NC}"
    if $IS_ROOT; then echo -e "${GREEN}Mode: Root (Full access)${NC}"; else echo -e "${YELLOW}Mode: User (sudo needed)${NC}"; fi
    echo -e "${CYAN}------------------------------------------------${NC}\n"
}

show_category_menu() {
    local cat_id="$1"
    local cat_name="${CAT_NAMES[$cat_id]}"
    local desc="${CAT_DESC[$cat_id]}"

    while true; do
        show_header
        echo -e "${BOLD}${YELLOW}${cat_name}${NC}"
        echo -e "${WHITE}${desc}${NC}\n"
        echo -e "${WHITE}Select software to toggle (same number removes):${NC}\n"

        # List apps in this category
        local i=1
        while [ $i -le 10 ]; do
            local num
            num=$(printf "%03d" $i)
            local key="${cat_id}|${num}"
            if [ -z "${APPS[$key]+_}" ]; then ((i++)); continue; fi
            local app_data="${APPS[$key]}"
            local app_id name methods license
            IFS='|' read -r app_id name methods license rest <<< "$(parse_app_data "$app_data")"

            # Check if in queue
            local in_queue=false
            for q in "${INSTALL_QUEUE[@]}"; do
                if [ "$q" = "$key" ]; then in_queue=true; break; fi
            done

            local status="${WHITE}⬜${NC}"
            if $in_queue; then status="${GREEN}📌 QUEUED${NC}"; fi

            local lic_color="$GREEN"
            if [ "$license" = "Paid" ]; then lic_color="$RED"; elif [ "$license" = "Freemium" ]; then lic_color="$YELLOW"; fi

            echo -e " [${CYAN}$num${NC}] ${status} ${WHITE}${name}${NC} ${lic_color}(${license})${NC}"
            ((i++))
        done

        echo -e "\n${CYAN}------------------------------------------------${NC}"
        echo -e " [${GREEN}99${NC}] 🚀 Start Installation (${#INSTALL_QUEUE[@]} in queue)"
        echo -e " [${RED}C${NC}]  🧹 Clear Queue"
        echo -e " [${YELLOW}0${NC}]  ↩️ Return to Main Menu"
        if [ "$cat_id" = "20" ]; then
            echo -e " [${CYAN}S${NC}]  🔍 Search for any software"
        fi

        read -rp $'\n👉 Enter choice: ' choice

        case "$choice" in
            0) break;;
            99) start_installation; continue;;
            [Cc]) clear_queue; sleep 1; continue;;
            [Ss]) [ "$cat_id" = "20" ] && custom_search; continue;;
            *)
                # Must be a three-digit number
                if [[ "$choice" =~ ^[0-9]{3}$ ]]; then
                    local sel_key="${cat_id}|${choice}"
                    if [ -n "${APPS[$sel_key]+_}" ]; then
                        # Toggle
                        if printf '%s\n' "${INSTALL_QUEUE[@]}" | grep -qxF "$sel_key"; then
                            remove_from_queue "$sel_key"
                        else
                            add_to_queue "$cat_id" "$choice"
                            # Show compatibility
                            local comp=$(check_compatibility "${APPS[$sel_key]}")
                            local is_compat="${comp%%|*}"
                            local msgs="${comp#*|}"
                            if [ "$is_compat" != "true" ]; then
                                echo -e "${YELLOW}${ICON_WARN} ${msgs}${NC}"
                            fi
                        fi
                        sleep 1
                    else
                        echo -e "${RED}Invalid selection.${NC}"
                        sleep 1
                    fi
                else
                    echo -e "${RED}Invalid input.${NC}"
                    sleep 1
                fi
                ;;
        esac
    done
}

custom_search() {
    clear
    echo -e "${CYAN}🔍 Custom Software Search${NC}\n"
    echo -e "Type a name to search (or 'back' to return).\n"
    while true; do
        read -rp "Search: " term
        if [ "$term" = "back" ] || [ "$term" = "0" ]; then break; fi
        [ -z "$term" ] && continue

        echo -e "\n${BLUE}Searching package repositories...${NC}"
        # Try native PM search
        case "$PM" in
            apt) apt-cache search "$term" 2>/dev/null | head -20;;
            dnf|yum) $PM search "$term" 2>/dev/null | head -20;;
            pacman) pacman -Ss "$term" 2>/dev/null | head -20;;
            zypper) zypper search "$term" 2>/dev/null | head -20;;
            *) echo "No native search available";;
        esac

        echo -e "\n${YELLOW}If you know the exact package name, you can add it to queue.${NC}"
        read -rp "Package name to add (empty to skip): " pkg
        if [ -n "$pkg" ]; then
            INSTALL_QUEUE+=("custom|$pkg")
            echo -e "${GREEN}Added custom package '$pkg' to queue.${NC}"
        fi
        read -rp "Search again? (y/N): " again
        if [[ ! "$again" =~ ^[Yy] ]]; then break; fi
        clear
    done
}

show_stats() {
    show_header
    echo -e "${BOLD}📊 Software Database Statistics${NC}\n"
    local total_cats=0 total_apps=0 free=0 paid=0 freemium=0
    for cat in "${!CAT_NAMES[@]}"; do
        ((total_cats++))
        for i in $(seq -w 1 10); do
            local key="${cat}|${i}"
            [ -z "${APPS[$key]+_}" ] && continue
            ((total_apps++))
            local license
            license=$(echo "${APPS[$key]}" | cut -d'|' -f4)
            case "$license" in
                Free) ((free++));;
                Paid) ((paid++));;
                Freemium) ((freemium++));;
            esac
        done
    done
    echo -e "Categories: $total_cats"
    echo -e "Software entries: $total_apps"
    echo -e "${GREEN}Free: $free${NC}   ${RED}Paid: $paid${NC}   ${YELLOW}Freemium: $freemium${NC}"
    echo -e "${GREEN}Current Queue: ${#INSTALL_QUEUE[@]} item(s)${NC}"
    read -rp "Press Enter to continue..."
}

# ---------- Main ----------
main() {
    # Check Bash version
    if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
        echo "This script requires Bash 4.0 or higher." >&2
        exit 1
    fi

    detect_system

    while true; do
        show_header
        echo -e "${BOLD}${YELLOW}📋 MAIN MENU – CHOOSE A CATEGORY${NC}\n"
        local cats_sorted=($(for k in "${!CAT_NAMES[@]}"; do echo "$k"; done | sort))
        for c in "${cats_sorted[@]}"; do
            echo -e " [${CYAN}${c}${NC}] ${CAT_NAMES[$c]} ${WHITE}→ ${CAT_DESC[$c]}${NC}"
        done

        echo -e "\n${CYAN}------------------------------------------------${NC}"
        echo -e " [${GREEN}99${NC}] 🚀 START INSTALLATION (${#INSTALL_QUEUE[@]} in queue)"
        echo -e " [${CYAN}S${NC}]  📊 Show Statistics"
        echo -e " [${RED}C${NC}]  🧹 Clear Queue"
        echo -e " [${YELLOW}Q${NC}]  ❌ Quit"

        read -rp $'\n👉 Enter choice: ' choice

        case "$choice" in
            [Qq]) echo -e "${CYAN}Goodbye!${NC}"; exit 0;;
            99) start_installation;;
            [Ss]) show_stats;;
            [Cc]) clear_queue; sleep 1;;
            *)
                if [ -n "${CAT_NAMES[$choice]+_}" ]; then
                    show_category_menu "$choice"
                else
                    echo -e "${RED}Invalid option.${NC}"
                    sleep 1
                fi
                ;;
        esac
    done
}

# Run the script
main
