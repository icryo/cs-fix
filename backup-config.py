import os
import shutil
from datetime import datetime

def backup_folder(src, dst):
    """
    Recursively copies all subfolders and files from src to dst.
    Existing files in dst are overwritten if they collide.
    """
    if not os.path.exists(src):
        print(f"[Warning] Source folder does not exist: {src} - Skipping.")
        return

    os.makedirs(dst, exist_ok=True)

    for item_name in os.listdir(src):
        s = os.path.join(src, item_name)
        d = os.path.join(dst, item_name)
        if os.path.isdir(s):
            shutil.copytree(s, d, dirs_exist_ok=True)
        else:
            shutil.copy2(s, d)

def main():
    # ==============================
    # 1) Setup folder paths
    # ==============================
    STEAM_DIR = r"C:\Program Files (x86)\Steam"
    # For many, CS2 is effectively an update to "Counter-Strike Global Offensive"
    CS2_DIR = os.path.join(
        STEAM_DIR,
        "steamapps",
        "common",
        "Counter-Strike Global Offensive",
        "game",
        "csgo",
        "cfg"
    )

    # The userdata directory that contains subfolders named by SteamIDs
    STEAM_USERDATA = os.path.join(STEAM_DIR, "userdata")

    # Where to store backups
    BACKUP_DIR = os.path.join(
        os.path.expanduser("~"),  # Typically C:\Users\<Username>
        "Documents",
        "CS2_Backups"
    )

    # ==============================
    # 2) Create a timestamped backup folder
    # ==============================
    timestamp = datetime.now().strftime("%Y-%m-%d_%H%M")
    destination_folder = os.path.join(BACKUP_DIR, f"backup_{timestamp}")
    os.makedirs(destination_folder, exist_ok=True)

    # ==============================
    # 3) Backup the main game cfg folder
    # ==============================
    print("Backing up main CS2/CS:GO cfg folder...")
    game_cfg_dest = os.path.join(destination_folder, "game_cfg")
    backup_folder(CS2_DIR, game_cfg_dest)

    # ==============================
    # 4) Iterate over each user folder in userdata
    # ==============================
    if not os.path.exists(STEAM_USERDATA):
        print(f"[Warning] userdata folder does not exist: {STEAM_USERDATA}")
    else:
        user_ids = [d for d in os.listdir(STEAM_USERDATA) 
                    if os.path.isdir(os.path.join(STEAM_USERDATA, d))]
        if not user_ids:
            print(f"[Warning] No user ID subfolders found in {STEAM_USERDATA}")
        else:
            print("Backing up cfg folders for all user IDs found in userdata...")
            for user_id in user_ids:
                # The CS2/CS:GO ID is 730. We look for '730/local/cfg' in each user folder.
                cfg_path = os.path.join(STEAM_USERDATA, user_id, "730", "local", "cfg")
                if os.path.exists(cfg_path):
                    # Backup to a subfolder in the destination named after the user ID
                    user_destination = os.path.join(destination_folder, f"user_{user_id}")
                    print(f"  - Backing up cfg for user ID: {user_id}")
                    backup_folder(cfg_path, user_destination)
                else:
                    print(f"  - No CS2/CS:GO cfg folder found for user ID: {user_id}, skipping.")

    # ==============================
    # 5) Done!
    # ==============================
    print("\n==========================================")
    print("Backup complete!")
    print(f"All files have been copied to:\n  {destination_folder}")
    print("==========================================")

if __name__ == "__main__":
    main()
