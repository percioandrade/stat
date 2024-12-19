Stat 🟢

# About 📝
stat.sh is a bash script that monitors and displays active network connections by port, with color-coded output based on connection volume:

- Green: < 20 connections 🟢
- Orange: 20-50 connections 🟠
- Red: > 50 connections 🔴

This script is useful for quickly identifying which ports have the highest number of active connections on your system.

- Author 👨‍💻
- Percio Andrade
- Email: percio@zendev.com.br
- Website: Zendev : https://zendev.com.br

# Requirements 🛠️
Root/Superuser Privileges: The script must be run as root.

- Required Commands: `ss`, `awk`, `sort`, `uniq`

# Usage 🚀
```bash
sudo ./stat.sh [OPTIONS]
```

# Options 🎛️
- `-n NUMBER`: Show top N ports (default: 10)
- `-i INTERVAL`: Refresh interval in seconds (default: no refresh)
- `-h`: Show this help message

# Output 📋
The script displays ports sorted by the number of active connections in the following format:

# Port - Total Connections (color coded)
Example 🌟

```bash
sudo ./stat.sh -n 5 -i 10
```

This command will display the top 5 ports with the highest number of connections, refreshing every 10 seconds.

# How It Works 🛠️
Gather Port Statistics: The script uses the ss command to gather network statistics.

Process and Sort: The data is processed and sorted to identify the top ports by connection count.

Color-Coded Output: The results are displayed with color-coded output based on the number of connections.

# Notes 📌
- Ensure you have the necessary permissions to run the script as root.
- Make sure all required commands are installed on your system.

# License 📄
This project is licensed under the GNU General Public License v2.0