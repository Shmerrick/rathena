# RESTART — Private Ragnarok Online Server

A custom Ragnarok Online server based on rAthena, combining Renewal content with pre-Renewal gameplay mechanics and custom skill/balance changes.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Database Setup](#2-database-setup)
   - 2.4 [MySQL 8.0 Auth Plugin Fix (Required)](#24-mysql-80--fix-authentication-plugin-required)
3. [Build the Server](#3-build-the-server)
4. [Configure the Server](#4-configure-the-server)
5. [Run the Server](#5-run-the-server)
6. [Configure the Client](#6-configure-the-client)
   - 6.2 [Patch the Client with WARP (Required)](#62-patch-the-client-with-warp-required)
   - See also: `tools/warp-restart.yml` for the patch list
7. [Creating a GM Account](#7-creating-a-gm-account)
8. [Config File Reference](#8-config-file-reference)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. Prerequisites

### Software Required

| Software | Minimum Version | Download |
|---|---|---|
| **MySQL** or **MariaDB** | 5.7+ / 10.3+ | [MySQL](https://dev.mysql.com/downloads/mysql/) · [MariaDB](https://mariadb.org/download/) |
| **Visual Studio** (Windows) | 2017 or newer | [Visual Studio](https://visualstudio.microsoft.com/downloads/) — install the **Desktop development with C++** workload |
| **Git** | Any recent | [Git for Windows](https://gitforwindows.org/) |

### Hardware (Minimum)

| Resource | Minimum |
|---|---|
| CPU | 2 cores |
| RAM | 2 GB |
| Disk | 1 GB |

---

## 2. Database Setup

The server uses a MySQL/MariaDB database named `ragnarok`.

### 2.1 Create the Database

Open a MySQL prompt (or MySQL Workbench) and run:

```sql
CREATE DATABASE ragnarok;
```

### 2.2 Import the Schema

From the repository root, import the four required SQL files **in this order**:

```bash
# Using the mysql CLI — replace <user> and <password> as needed
mysql -u root -p ragnarok < sql-files/main.sql
mysql -u root -p ragnarok < sql-files/logs.sql
mysql -u root -p ragnarok < sql-files/web.sql
mysql -u root -p ragnarok < sql-files/roulette_default_data.sql
```

Or from within the MySQL prompt:

```sql
USE ragnarok;
SOURCE sql-files/main.sql;
SOURCE sql-files/logs.sql;
SOURCE sql-files/web.sql;
SOURCE sql-files/roulette_default_data.sql;
```

### 2.3 Verify

```sql
USE ragnarok;
SHOW TABLES;
```

You should see roughly 70 tables (login, char, inventory, guild, etc.).

### 2.4 MySQL 8.0 — Fix Authentication Plugin (Required)

MySQL 8.0 defaults to the `caching_sha2_password` authentication plugin, which rAthena's bundled MySQL connector does not support. You **must** switch the user to the older `mysql_native_password` plugin or the servers will fail to connect to the database.

Run this once in a MySQL prompt:

```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
FLUSH PRIVILEGES;
```

Replace `'root'` and `'password'` with your actual MySQL username and password. If you are using a dedicated database user (recommended for production), run the same command for that user instead.

You only need to do this once. Verify it worked:

```sql
SELECT user, host, plugin FROM mysql.user WHERE user = 'root';
-- plugin column should now show: mysql_native_password
```

---

## 3. Build the Server

### Windows — Visual Studio / MSBuild

Open the solution `rAthena.sln` in Visual Studio, set the configuration to **Release / x64**, and press **Build → Build Solution**.

Or build from the command line using MSBuild:

```bat
"C:\Program Files\Microsoft Visual Studio\18\Enterprise\MSBuild\Current\Bin\amd64\MSBuild.exe" ^
    rAthena.sln ^
    -p:Configuration=Release ^
    -p:Platform=x64 ^
    -m
```

> **PACKETVER:** The server is compiled against a specific client version. This project uses `PACKETVER 20250402` (April 2025 client). This is set in `src/custom/defines_pre.hpp` and must match the client executable you are using. If you ever update the client, update this value and rebuild.

After a successful build, the following executables will be in the repository root:

| Executable | Purpose |
|---|---|
| `login-server.exe` | Handles account login authentication |
| `char-server.exe` | Manages characters, guilds, parties |
| `map-server.exe` | Runs the game world, maps, monsters, skills |
| `web-server.exe` | Optional HTTP API for modern clients |

### Linux — GCC / Make

```bash
sudo apt-get install gcc make libmysqlclient-dev zlib1g-dev libpcre3-dev
./configure
make server
```

---

## 4. Configure the Server

All configuration files live in the `conf/` directory. You only need to edit a small number of files for a standard setup.

### 4.1 Database Credentials — `conf/inter_athena.conf`

This is the **most important** file. Every server component reads DB credentials from here.

Find and update all credential blocks to match your MySQL setup:

```conf
// MySQL Login server
login_server_ip: 127.0.0.1
login_server_port: 3306
login_server_id: root          ← your MySQL username
login_server_pw: password      ← your MySQL password
login_server_db: ragnarok      ← database name (keep as-is)

// (repeat the same id/pw for ipban, char, map, web, and log blocks)
```

> **Note:** If MySQL is running on the same machine as the server, leave all `_ip` fields as `127.0.0.1`.

The following setting controls whether item/mob data is read from YAML files or SQL tables. Keep it set to `no` — this server uses YAML:

```conf
use_sql_db: no
```

### 4.2 Server Name & Inter-Server Password — `conf/char_athena.conf`

```conf
// The name shown in the server select screen
server_name: RESTART

// Inter-server communication password (must match map_athena.conf)
userid: s1
passwd: p1
```

Change `userid` / `passwd` to any secret value you like — just make sure both `char_athena.conf` and `map_athena.conf` use **the same values**.

Also configure where new characters spawn:

```conf
// Starting map and coordinates
start_point: iz_int,18,26
```

### 4.3 Map Server — `conf/map_athena.conf`

```conf
// Must match char_athena.conf userid/passwd exactly
userid: s1
passwd: p1

// Port the map server listens on (default 5121)
map_port: 5121

// Character server port to connect to (default 6121)
char_port: 6121
```

If you are hosting for players **outside your local network**, uncomment and set the public IP:

```conf
// Public-facing IP address clients will connect to
map_ip: 192.168.4.55    ← replace with your actual public/LAN IP
```

### 4.4 Login Server — `conf/login_athena.conf`

Defaults work out of the box. Key settings:

```conf
// Login server listens on this port
login_port: 6900

// Allow players to self-register accounts with _M/_F suffix
// Set to yes if you want open registration
new_account: no

// Web authentication token (required for modern clients)
use_web_auth_token: yes
```

### 4.5 Subnet Configuration — `conf/subnet_athena.conf`

This file tells the servers what IP to advertise to clients connecting from the same subnet. For a local/LAN server, the default works fine:

```conf
subnet: 255.0.0.0:127.0.0.1:127.0.0.1
```

For a server with a public IP that LAN clients connect to internally, add a second entry:

```conf
subnet: 255.0.0.0:127.0.0.1:127.0.0.1
subnet: 255.255.255.0:192.168.4.55:192.168.4.55
```

Format: `net-mask : char-server-ip : map-server-ip`

### 4.6 Import / Override Files

Each main config ends with an import directive pointing to a file in `conf/import/`. These files are intentionally left empty and are the **correct place to put local overrides** — they will not be overwritten by git pulls.

| Import file | Overrides |
|---|---|
| `conf/import/inter_conf.txt` | inter_athena.conf |
| `conf/import/char_conf.txt` | char_athena.conf |
| `conf/import/map_conf.txt` | map_athena.conf |
| `conf/import/login_conf.txt` | login_athena.conf |

**Example** — put your credentials in `conf/import/inter_conf.txt` instead of editing `inter_athena.conf` directly:

```conf
login_server_id: root
login_server_pw: password
char_server_id: root
char_server_pw: password
map_server_id: root
map_server_pw: password
web_server_id: root
web_server_pw: password
log_db_id: root
log_db_pw: password
```

---

## 5. Run the Server

### Using `runserver.bat` (Recommended)

The repository includes `runserver.bat`, a full server management script. Run it from the repository root:

| Command | What it does |
|---|---|
| `runserver.bat start` | Start all four servers (no auto-restart on crash) |
| `runserver.bat watch` | Start all servers with **auto-restart** if one crashes (default if no argument) |
| `runserver.bat stop` | Kill all running server processes |
| `runserver.bat status` | Show which servers are currently running |

**Quick start — double-click `runserver.bat`** (no argument = `watch` mode, starts everything with auto-restart).

This opens four separate console windows — one for each server (login, char, map, web). They start in sequence.

### Start Order

The servers must come up in this order. `runserver.bat` handles this automatically:

```
login-server.exe  →  char-server.exe  →  web-server.exe  →  map-server.exe
```

### What "Ready" Looks Like

Watch the console output. Each server prints a ready message when it finishes loading:

- Login server: `Login server is ready and listening on port 6900`
- Char server: `Character server is ready and listening on port 6121`
- Map server: `Map server is ready and listening on port 5121`

### Stopping the Servers

Run `runserver.bat stop`, or close each console window individually.

---

## 6. Configure the Client

The client used is the April 2025 English Ragnarok client located at `C:\Users\Admin\Desktop\20250416Ragnarok_en`.

### 6.1 Server Connection — `data\clientinfo.xml`

This is the **only file you need to edit** to point the client at your server.

Open `data\clientinfo.xml` in a text editor (Notepad++ recommended — the file uses EUC-KR encoding):

```xml
<?xml version="1.0" encoding="euc-kr" ?>
<clientinfo>
    <desc>Ragnarok Client Information</desc>
    <servicetype>korea</servicetype>
    <servertype>primary</servertype>
    <connection>
        <display>RESTART</display>
        <address>127.0.0.1</address>   ← server IP (127.0.0.1 for local)
        <port>6900</port>              ← login server port (default 6900)
        <version>55</version>          ← must match server packet version
        <langtype>1</langtype>
        <registrationweb>127.0.0.1</registrationweb>
        <loading>
            <image>loading00.jpg</image>
            <image>loading01.jpg</image>
            <image>loading02.jpg</image>
            <image>loading03.jpg</image>
            <image>loading04.jpg</image>
            <image>loading05.jpg</image>
            <image>loading06.jpg</image>
        </loading>
        <aid>
            <admin>2000000</admin>
        </aid>
    </connection>
</clientinfo>
```

**Fields to change:**

| Field | What to set |
|---|---|
| `<display>` | Name shown in the server-select dropdown |
| `<address>` | Your server's IP. Use `127.0.0.1` for local; use your LAN/public IP for other players |
| `<port>` | Login server port — must match `login_port` in `login_athena.conf` (default `6900`) |
| `<version>` | Client version number — leave as `55` unless you know it needs to change |

> **Encoding warning:** Always save this file with **EUC-KR** encoding. If you save it as UTF-8 the client may fail to read it. Notepad++ → Encoding → Character sets → East Asian → Korean (EUC-KR).

### 6.2 Patch the Client with WARP (Required)

The stock `Ragexe.exe` has **GameGuard** (anti-cheat) enabled and uses **packet encryption** that is incompatible with a private server. You must patch it using **WARP** before it will connect.

The WARP tool is integrated as a git submodule in `tools/warp/` (Neo-Mind/WARP) and `tools/warp2025/` (hiphop9/Warp2025). These are always kept up to date automatically when you build.

#### Automated patching (recommended)

Run from the repository root:

```bat
patch-client.bat
```

This script:
1. Pulls the latest WARP patch scripts from both submodules
2. Applies the RESTART patch set to `Ragexe.exe` using `WARP_console.exe`
3. Saves the result as `Ragexe_patched.exe` in the client folder

To patch a client at a different path:

```bat
patch-client.bat "D:\Ragnarok\Ragexe.exe"
```

#### Patches applied (`tools/warp-restart.yml`)

| Patch key | Title | Purpose |
|---|---|---|
| `NoGGuard` | Disable Game Guard | Removes anti-cheat that blocks private server connections |
| `NoPacketEncr` | Disable Map packet encryption | Matches `#undef PACKET_OBFUSCATION` in the server build |
| `NoEncrForLC` | Disable Login/Char encryption | Disables encryption on login and char server packets |
| `DataFolderFirst` | Read data folder first | Loads loose `data\` files before GRF — required for `clientinfo.xml` |

To change which patches are applied, edit `tools/warp-restart.yml`.

#### Manual patching (alternative)

If `patch-client.bat` fails, you can run WARP directly:

```bat
tools\warp\win32\WARP_console.exe using tools\warp-restart.yml
```

Or open the GUI: `tools\warp\win32\WARP.exe`

#### Initial submodule setup

If you just cloned the repository, initialize submodules first:

```bat
git submodule update --init --recursive
```

This downloads `tools/warp` and `tools/warp2025`.

#### WARP submodule auto-update during builds

A `Directory.Build.targets` file at the repository root tells MSBuild to run `git submodule update --remote tools/warp tools/warp2025` before every build. This keeps the WARP patch scripts current automatically.

To skip the update for a specific build:

```bat
MSBuild.exe rAthena.sln -p:SkipWarpUpdate=true ...
```

### 6.3 GRF Load Order — `DATA.ini`

Controls which data archives the client loads and in what priority order:

```ini
[Data]
0=en.grf
1=data.grf
2=data\
```

- `en.grf` — English localization (highest priority)
- `data.grf` — Base Korean game data
- `data\` — Loose files folder (where `clientinfo.xml` and custom overrides live)

The `data\` entry at the bottom ensures the client reads files from the loose `data\` folder on disk. This is how `clientinfo.xml` gets picked up. Do not remove it.

### 6.4 Adding a Custom GRF (Optional)

If you want to distribute custom textures, sprites, or sounds, package them in a GRF archive and add it as the new `0=` entry:

```ini
[Data]
0=custom.grf
1=en.grf
2=data.grf
```

Tools for creating/editing GRFs: [GRF Editor](https://rathena.org/board/topic/77080-grf-grf-editor/) (free, Windows).

### 6.5 Launching the Client

Run the **patched** `Ragexe.exe` (created by WARP in step 6.2). Do **not** run `Ragnarok.exe` — that is the official patcher/launcher and will not connect to a private server.

If the client shows a list of servers, select **RESTART** (or whatever you set `<display>` to) and log in.

### 6.6 Connecting from Other Machines

If other players want to connect over your LAN:

1. Set `<address>` in `clientinfo.xml` to your machine's LAN IP (e.g. `192.168.4.55`).
2. In `conf/char_athena.conf`, uncomment and set:
   ```conf
   char_ip: 192.168.4.55
   ```
3. In `conf/map_athena.conf`, uncomment and set:
   ```conf
   map_ip: 192.168.4.55
   ```
4. Make sure Windows Firewall allows inbound connections on ports **6900**, **6121**, and **5121**.

---

## 7. Creating a GM Account

### 7.1 Register an Account

By default `new_account: no` — so you must insert accounts directly into the database:

```sql
INSERT INTO login (userid, user_pass, sex, email)
VALUES ('admin', 'yourpassword', 'M', 'admin@localhost');
```

Or temporarily enable in-game registration:

1. Set `new_account: yes` in `conf/login_athena.conf`
2. Launch the client and create your account by appending `_M` or `_F` to the username field (e.g. `admin_M` with the password)
3. Set `new_account: no` again afterward

### 7.2 Grant GM Level 99

After the account exists in the database:

```sql
UPDATE login SET group_id = 99 WHERE userid = 'admin';
```

Group 99 is the maximum level with full permissions. See `conf/groups.conf` for a breakdown of all group levels and their permissions.

### 7.3 In-Game GM Commands

Once logged in as a GM, prefix commands with `@`:

```
@go 0              — teleport to Prontera
@item 501 10       — give yourself 10 Red Potions
@monster 1002 1    — spawn a Poring
@speed 0           — move at maximum speed
@warp prontera 155 180
```

Type `@help` in game for a full list.

---

## 8. Config File Reference

### Core Config Files

| File | Purpose |
|---|---|
| `conf/inter_athena.conf` | **Database credentials** — all servers read this. Edit MySQL username/password here. |
| `conf/login_athena.conf` | Login server settings: port, account restrictions, IP banning, web auth token |
| `conf/char_athena.conf` | Character server: server name, starting point/items, character rules, pincode |
| `conf/map_athena.conf` | Map server: ports, autosave interval, motd file |
| `conf/subnet_athena.conf` | Subnet routing: tells servers which IP to advertise to clients per subnet |
| `conf/packet_athena.conf` | Network socket settings, DDoS protection, stall timeout |
| `conf/channels.conf` | Chat channel system (global, map, guild channels) |
| `conf/groups.conf` | GM group permissions — who can use which `@` commands |
| `conf/motd.txt` | Message of the Day shown when players log in |

### Battle / Gameplay Config Files (`conf/battle/`)

These files control balance and gameplay mechanics. Changes take effect on server restart.

| File | Controls |
|---|---|
| `battle.conf` | Hit rate, flee, damage caps, attack delays, critical hits |
| `exp.conf` | Base/job EXP rates, death penalties, level caps |
| `drops.conf` | Item drop rate multipliers, rare drop chance |
| `skill.conf` | Skill delays, fixed cast time, knockback behavior |
| `player.conf` | HP/SP regen intervals, max stats, inventory size |
| `items.conf` | Item usage rules, card equip restrictions |
| `monster.conf` | Monster spawn timers, aggro range, teleport on attack |
| `party.conf` | Party EXP share range and rules |
| `guild.conf` | Guild size, WoE settings |
| `pet.conf` | Pet system mechanics |
| `homunc.conf` | Homunculus leveling and intimacy |

### Import / Override Files (`conf/import/`)

Put local overrides here. These files are never overwritten by updates.

| File | Overrides |
|---|---|
| `conf/import/inter_conf.txt` | inter_athena.conf |
| `conf/import/char_conf.txt` | char_athena.conf |
| `conf/import/map_conf.txt` | map_athena.conf |
| `conf/import/login_conf.txt` | login_athena.conf |

### Data / Database Files

| Location | Format | Purpose |
|---|---|---|
| `db/re/skill_db.yml` | YAML | All skill definitions (SP, damage, cast times) |
| `db/re/skill_tree.yml` | YAML | Job skill trees and prerequisites |
| `db/re/item_db_*.yml` | YAML | Item definitions |
| `db/re/mob_db.yml` | YAML | Monster stats |
| `db/re/attr_fix.yml` | YAML | Elemental damage chart |
| `sql-files/` | SQL | Database schema and seed data |

---

## 9. Troubleshooting

### "Cannot connect to MySQL server"

- Confirm MySQL is running: `net start mysql` (Windows) or `sudo systemctl status mysql`
- Check credentials in `conf/inter_athena.conf` match your MySQL user/password
- On Windows, use `127.0.0.1` not `localhost` in the config to avoid socket issues

### "MySQL authentication plugin not supported" / Silent DB connection failure on MySQL 8.0

MySQL 8.0 defaults to `caching_sha2_password`, which rAthena's MySQL connector does not support. The servers may start but fail silently, or show a DB connection error.

Fix: switch the user's authentication plugin to `mysql_native_password` (see Section 2.4).

```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
FLUSH PRIVILEGES;
```

### "Failed to connect to char-server" / "Failed to connect to login-server"

- Start servers in order: login → char → map. Each must be fully loaded before the next starts.
- Check that `userid`/`passwd` in `char_athena.conf` and `map_athena.conf` match exactly.
- Check that `login_port` in `login_athena.conf` and `login_port` in `char_athena.conf` match.

### Client shows "Failed to connect to server"

- Verify `<address>` and `<port>` in `data\clientinfo.xml` match the running login server's IP and port.
- Make sure the login server is running and shows "listening on port 6900".
- If connecting over LAN, confirm the firewall allows ports 6900, 6121, 5121.

### "Unknown packet 0x..." in server console

The client version does not match the server's expected packet version. The `<version>` field in `clientinfo.xml` may need adjustment, or the server needs a matching `PACKETVER` in its build configuration.

### `patch-client.bat` — "WARP_console.exe not found"

The WARP submodule has not been initialized. Run:

```bat
git submodule update --init --recursive
```

### Map server crashes at startup

- Usually a corrupted or missing YAML database file. Run the server from the command line to see the full error output.
- Check `log/map-msg_log.log` for detailed error messages.

### Players spawn in the wrong place

Edit `start_point` in `conf/char_athena.conf`. Format: `mapname,x,y`.

---

## Server Architecture

```
Client (Ragexe.exe)
    │
    ├─ Port 6900 → login-server.exe   (account authentication)
    │                   │
    │                   └─ MySQL (ragnarok DB — login table)
    │
    ├─ Port 6121 → char-server.exe    (character management)
    │                   │
    │                   └─ MySQL (ragnarok DB — char, inventory, guild...)
    │
    └─ Port 5121 → map-server.exe     (game world)
                        │
                        ├─ MySQL (ragnarok DB — map data, mapreg...)
                        └─ YAML  (db/re/*.yml — items, mobs, skills)

Port 8888 → web-server.exe (optional HTTP API for new clients)
```

---

## License

Copyright (c) rAthena Development Team — Licensed under [GNU General Public License v3.0](LICENSE)

Custom RESTART modifications copyright (c) Shmerrick.
