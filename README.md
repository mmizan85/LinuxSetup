<!--
============================================================
          LinuxSetup CLI – Professional Installer
============================================================
-->

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0-blue?style=for-the-badge" alt="Version 1.0">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License MIT">
  <img src="https://img.shields.io/badge/platform-Linux-informational?style=for-the-badge&logo=linux" alt="Platform Linux">
  <img src="https://img.shields.io/badge/Made%20with-Bash-4EAA25?style=for-the-badge&logo=gnu-bash" alt="Made with Bash">
</p>

<h1 align="center">🐧 LinuxSetup CLI</h1>
<h3 align="center">🛠️ 500+ Tools · Smart Queue Installer · Cross-Distro</h3>

<p align="center">
  <i>A modern, emoji‑rich terminal toolkit that installs <b>any</b> Linux software in seconds.
  Just pick what you need, queue it up, and let the script handle the rest.</i>
</p>

<br>

## ✨ What is LinuxSetup CLI?

LinuxSetup CLI is a **professional shell script** that brings the power of a huge curated software catalogue right into your terminal.
It automatically **detects your distribution, architecture, and available package managers** (apt, snap, flatpak, …) to install software in the most compatible way.
No more googling package names – just choose from a well‑organised menu and let the tool do the heavy lifting.

### 🔥 Why you’ll love it

- 🚀 **Blazing‑fast installation** – queue as many apps as you like, then install them all in one go.
- 🧠 **Smart detection** – auto‑detects your distro, package manager, snap/flatpak support, and even warns about compatibility.
- 🗂️ **20 curated categories** – Browsers, Development, Gaming, Office, Security, and many more (over 150 apps pre‑defined, with room for 500+).
- 🎨 **Beautiful, modern UI** – emojis, colours, and clean layouts make the terminal fun to use.
- 🌍 **Cross‑distro support** – works on Ubuntu, Debian, Fedora, Arch, openSUSE, and others.
- 💡 **Custom search** – can’t find what you need? Search the whole repository and add any package instantly.

---

## 📦 Included Categories (20 Sections)

| 🏷️ No. | Category                      | 📖 Description                                   |
|--------|-------------------------------|--------------------------------------------------|
| 01     | 🌐 Web Browsers               | Internet browsers for web surfing               |
| 02     | 💬 Communication              | Messaging, chat and video calling apps          |
| 03     | 💻 Development Tools          | Programming, coding and development environments|
| 04     | 🎵 Media & Entertainment      | Music, video players and media apps             |
| 05     | 🔧 System Utilities           | System maintenance and optimisation tools       |
| 06     | 📊 Office & Productivity      | Office suites and productivity apps             |
| 07     | 🔒 Security & Privacy         | Antivirus, VPN and security software            |
| 08     | 🎨 Graphics & Design          | Photo editing, design and 3D modelling          |
| 09     | 🎮 Gaming Platforms           | Game launchers and gaming platforms             |
| 10     | 🌐 Networking Tools           | Network utilities, FTP and remote access        |
| 11     | 🗄️ Database Tools             | Database management and development             |
| 12     | 💾 Backup & Recovery          | Data backup and recovery solutions              |
| 13     | 📚 Education & Learning       | Educational and learning software               |
| 14     | 🖥️ Virtualization            | Virtual machines and container platforms        |
| 15     | 📝 Languages & Runtimes       | Programming language runtimes/compilers         |
| 16     | 🎥 Video Production           | Video editing and production software           |
| 17     | 🎵 Audio Production           | Audio editing and music production              |
| 18     | ⚙️ Utilities & Tweaks        | System utilities and tweaking tools             |
| 19     | 💼 Business Tools             | Business and finance applications               |
| 20     | 🔍 Custom Search & Install    | Search and install any software by name         |

Each category holds 10 hand‑picked applications (150+ total) with their **correct package names** for apt, snap, or flatpak.

---

## 🚀 Quick Start

### 1️⃣ Download the script

```bash
git clone https://github.com/mmizan85/LinuxSetup-CLI.git

cd LinuxSetup-CLI
```
### Or simply grab the raw file:

```bash

wget https://raw.githubusercontent.com/your-username/LinuxSetup-CLI/main/linuxsetup.sh
```

### 2️⃣ Make it executable
```bash
chmod +x linuxsetup.sh
```

### 3️⃣ Run the installer
```bash
./linuxsetup.sh
```

Note: Some installations will ask for your password (sudo). The script will prompt you when needed.

## 📘 How to Use
The interface is self‑explanatory, but here’s a quick walk‑through:

1. **Main Menu** – pick a category by entering its number (01‑20).

2. **Submenu** – choose any software by its 3‑digit code.

- Press the same code again to remove it from the queue.

- Queued items show a 📌 icon.

3. **Special** commands inside a category:

- `99` – start installing everything in the queue.

- `C` – clear the queue.

- `0` – go back to the main menu.

- `S` (in category 20) – open the Custom Search.

5. **Installation** – the script will loop through your queue, check compatibility, and install each package one by one. A summary is shown at the end.

## 🎯 Example session
```text
User: ./linuxsetup.sh
  → selects 03 (Development Tools)
  → selects 001 (Visual Studio Code) → 📌 QUEUED
  → selects 004 (Git) → 📌 QUEUED
  → presses 99 → installation begins
```

## 🧩 Compatibility & Detection
The script automatically adapts to your system:

- **Distro detection:** Ubuntu/Debian, Fedora/RHEL, Arch, openSUSE, and derivatives.

- **Package managers:** apt, dnf, yum, pacman, zypper.

- **Alternatives:** Falls back to Snap or Flatpak if the native package isn’t available.

- **Architecture:** warns if a package doesn’t support your CPU architecture (e.g., x86_64, aarch64).

If an installation requires a paid license, you’ll see a friendly notice.

## 🛠️ Custom Search (Category 20)
Forgot a tool?
Category 20 opens an interactive search prompt:

1. Type a keyword (e.g., markdown, torrent, python IDE).

2. The script searches your package manager’s repository and shows matching results.

3. If you know the exact package name, you can add it directly to the queue.

This way, you’re never limited to the built‑in catalogue.

## 📥 Adding More Software
The script is modular and easy to extend. Inside the file, each application is defined like this:

```bash
add_app "05" "002" "unrar|unRAR|apt:unrar|Free|any|any|"
```

You can add hundreds more by following the same pattern (category number, item number, pipe‑separated fields). The fields are:

Field	  Meaning
**ID**	  Short identifier (e.g., `unrar`)
**Name**	  Human‑readable name (`unRAR`)
**Methods**	  `method:pkg,method:pkg,…` (apt, snap, flatpak, custom)
**License**	  Free, Paid, Freemium, Trial
**Arch**	  Supported arch (`x86_64`, `any`)
**Distro**	  Compatible distro (`any`, `debian`,`ubuntu`)
**Extra**	  Additional info (optional)

---

The script will automatically pick the best installation method based on your system.

## 🤝 Contributing
Contributions are very welcome!
If you want to add more categories, apps, or improve the detection logic:

1. Fork the repository.

2. reate a feature branch: git checkout -b feature/awesome-app

3. Commit your changes: git commit -m 'Add awesome app'

4. Push to the branch: git push origin feature/awesome-app

5. Open a Pull Request.

Please keep the emoji‑based UI style and test on at least two distributions.

## 🧾 License
This project is licensed under the MIT License – see the LICENSE file for details.

## 🌟 Show Your Support
If you found this project helpful, give it a ⭐ on GitHub and share it with your friends!


<p align="center"> Made with ❤️ by <b>Mohammad Mizan</b><br> <i>For the open‑source community</i> </p> ```
