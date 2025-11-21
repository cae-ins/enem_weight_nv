import os
import sys
import argparse
from minio import Minio
from minio.error import S3Error, InvalidResponseError
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

class DataManager:
    def __init__(self):
        self.endpoint = os.getenv("MINIO_ENDPOINT")
        if self.endpoint:
            self.endpoint = self.endpoint.replace("http://", "").replace("http://", "").rstrip("/")
            
        self.access_key = os.getenv("MINIO_ACCESS_KEY")
        self.secret_key = os.getenv("MINIO_SECRET_KEY")
        self.bucket_name = os.getenv("MINIO_BUCKET")
        
        # Correctly parse boolean for secure connection
        secure_env = os.getenv("MINIO_SECURE", "True").lower()
        self.secure = secure_env in ("true", "1", "yes", "on")

        if not all([self.endpoint, self.access_key, self.secret_key, self.bucket_name]):
            print("Error: Missing MinIO configuration in .env file.")
            sys.exit(1)

        self.client = Minio(
            self.endpoint,
            access_key=self.access_key,
            secret_key=self.secret_key,
            secure=self.secure
        )

        self._ensure_bucket_exists()

    def _ensure_bucket_exists(self):
        try:
            if not self.client.bucket_exists(self.bucket_name):
                self.client.make_bucket(self.bucket_name)
                print(f"Bucket '{self.bucket_name}' created.")
            else:
                print(f"Bucket '{self.bucket_name}' exists.")
        except InvalidResponseError as e:
            print(f"Error connecting to MinIO: {e}")
            # Check for common "Console port vs API port" error
            if "S3 API Requests must be made to API port" in str(e) or "400" in str(e):
                print("\n[!] HINT: It looks like you might be connecting to the MinIO Console port (often 9001).")
                print("    Please check your .env file and ensure MINIO_ENDPOINT points to the API port (often 9000).")
            sys.exit(1)
        except S3Error as e:
            print(f"Error checking/creating bucket: {e}")
            sys.exit(1)
        except Exception as e:
            if "MaxRetryError" in str(e) or "Connection refused" in str(e) or "10061" in str(e):
                print(f"\n[!] CRITICAL: Could not connect to MinIO at {self.endpoint}")
                print(f"    Error details: {e}")
                print("\n    Troubleshooting:")
                print("    1. Is the MinIO server running?")
                print("    2. Is the IP and Port correct in .env? (e.g. 192.168.1.230:32639)")
                print("    3. Has the port changed? (Dynamic ports in Docker/K8s change on restart)")
                print("    4. Are you on the correct network (VPN/Wifi)?")
                print("    5. Is a firewall blocking the connection?")
            else:
                print(f"Unexpected error: {e}")
            sys.exit(1)

    def upload_all_data(self, data_dir="data"):
        """Recursively uploads all files in the data directory."""
        if not os.path.exists(data_dir):
            print(f"Error: Directory '{data_dir}' not found.")
            return

        print(f"Starting upload of all files in '{data_dir}'...")
        for root, dirs, files in os.walk(data_dir):
            for file in files:
                local_path = os.path.join(root, file)
                # Object name should be relative to the project root (e.g., data/01_raw/file.dta)
                # Assuming the script is run from project root or we handle paths carefully.
                # Let's normalize to forward slashes for object storage
                object_name = local_path.replace("\\", "/")
                
                self.upload_file(local_path, object_name)

    def upload_file(self, file_path, object_name=None):
        """Uploads a single file."""
        if object_name is None:
            object_name = file_path.replace("\\", "/")

        try:
            self.client.fput_object(
                self.bucket_name,
                object_name,
                file_path,
            )
            print(f"Uploaded: {file_path} -> {object_name}")
        except S3Error as e:
            print(f"Error uploading {file_path}: {e}")

    def download_files(self, file_paths, force=False):
        """Downloads a list of files if they don't exist locally or if force=True."""
        for object_name in file_paths:
            local_path = os.path.normpath(object_name)
            
            if os.path.exists(local_path) and not force:
                print(f"Skipping (exists): {local_path}")
                continue
            
            # Ensure local directory exists
            os.makedirs(os.path.dirname(local_path), exist_ok=True)
            
            try:
                self.client.fget_object(
                    self.bucket_name,
                    object_name,
                    local_path
                )
                print(f"Downloaded: {object_name} -> {local_path}")
            except S3Error as e:
                print(f"Error downloading {object_name}: {e}")

def main():
    parser = argparse.ArgumentParser(description="MinIO Data Manager for ENE Survey Weights")
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")

    # Upload All
    subparsers.add_parser("upload-all", help="Upload all files in data/ directory")

    # Upload Single
    upload_parser = subparsers.add_parser("upload", help="Upload a specific file")
    upload_parser.add_argument("file", help="Local path to the file")

    # Download
    download_parser = subparsers.add_parser("download", help="Download specific files")
    download_parser.add_argument("--files", nargs="+", required=True, help="List of object paths (e.g. data/01_raw/file.dta)")
    download_parser.add_argument("--force", action="store_true", help="Overwrite existing files")

    args = parser.parse_args()
    
    manager = DataManager()

    if args.command == "upload-all":
        manager.upload_all_data()
    elif args.command == "upload":
        manager.upload_file(args.file)
    elif args.command == "download":
        manager.download_files(args.files, force=args.force)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
