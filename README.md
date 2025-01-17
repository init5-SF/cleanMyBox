# cleanMyBox

I've made this script to automate the cleanup of garbage files and packages on my offensive security VM, should work on most distros (Kali, Parrot, etc.).

It includes:
- **Kernel Cleanup**: Removes old and unused kernels.
- **Package Cleanup**: Cleans unused and orphaned packages, APT cache, and Snap cache.
- **Temporary Files**: Clears `/tmp` and `/var/tmp`.
- **Log Files**: Clears `/var/log`.
- **User Data**: Cleans up `~/Downloads`, Firefox cache, and thumbnail cache.
- **Scattered Junk**: Finds and deletes `.DS_Store` and `Thumbs.db` files.
Might add more cleanups later.

`[!]` Use at your own risk!
