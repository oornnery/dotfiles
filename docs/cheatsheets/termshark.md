# termshark

Packets, like Wireshark, in the terminal (tshark underneath).

Project: <https://github.com/gcla/termshark>

## Start

- `termshark -i eth0`: capture
- `termshark -r file.pcap`: read a capture

## Keys

| Key | Action |
| --- | ------ |
| `/` | Display filter (`sip`, `tcp.port == 443`...) |
| `Tab` | Next pane |
| `Enter` | Open a packet or a field |
| `?` | Help |
| `q` | Quit |

## Notes

- Capturing needs the `wireshark` group: `dots install tui-network` adds it; log in again after.

From its documentation.
