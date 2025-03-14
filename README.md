# Bug-Scanner

# 🚀 Subdomain Health Checker Script 🌐


## Prerequisites

* Python 3.6+ installed.
* Basic understanding of the command line.

## Steps

1.  **Create Necessary Files:**
    ```bash
    touch subdomains.txt
    touch working_sni.txt
    touch nonworking_sni.txt
    ```
    * `subdomains.txt`: This file will contain the list of subdomains you want to check.
    * `working_sni.txt`: This file will store the subdomains that are working.
    * `nonworking_sni.txt`: This file will store the subdomains that are not working.

2.  **Populate Subdomains:**
    ```bash
    nano subdomains.txt
    ```
    * Open `subdomains.txt` with the `nano` text editor.
    * Enter the subdomains you want to check, one per line. For example:
        ```
        [sub.example.com](https://www.google.com/search?q=sub.example.com)
        [api.example.com](https://www.google.com/search?q=api.example.com)
        [blog.example.com](https://www.google.com/search?q=blog.example.com)
        ```
    * Save the file (Ctrl + O, Enter, Ctrl + X).

3.  **Optional: Create a Virtual Environment (Recommended):**
    ```bash
    python3 -m venv myenv
    source myenv/bin/activate
    ```
    * This creates an isolated Python environment to avoid conflicts with other Python packages.
    * The `source` command activates the virtual environment.

4.  **Install Required Libraries:**
    ```bash
    pip install aiohttp tqdm
    ```
    * `aiohttp`: A powerful asynchronous HTTP client/server framework.
    * `tqdm`: A library for adding progress bars to loops.

5.  **Create the Checker Script:**
    ```bash
    nano check_host.py
    ```
    * Open `check_host.py` in `nano`.
    * Paste the following Python script (or the script from your repository):

    ```python
    import asyncio
    import aiohttp
    import ssl
    import argparse
    from tqdm.asyncio import tqdm

    async def check_host(hostname, working_file, nonworking_file, timeout=5):
        sslcontext = ssl.create_default_context()
        sslcontext.check_hostname = False
        sslcontext.verify_mode = ssl.CERT_NONE

        try:
            async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=timeout)) as session:
                async with session.get(f"https://{hostname}", ssl=sslcontext, allow_redirects=False) as response:
                    if response.status < 400:
                        with open(working_file, "a") as f:
                            f.write(f"{hostname}\n")
                        return True
                    else:
                        with open(nonworking_file, "a") as f:
                            f.write(f"{hostname}\n")
                        return False

        except Exception as e:
            with open(nonworking_file, "a") as f:
                f.write(f"{hostname}\n")
            return False

    async def main(subdomains_file, working_file, nonworking_file, timeout):
        with open(subdomains_file, "r") as f:
            subdomains = [line.strip() for line in f]

        tasks = [check_host(subdomain, working_file, nonworking_file, timeout) for subdomain in subdomains]

        await tqdm.gather(*tasks, desc="Checking Subdomains")

    if __name__ == "__main__":
        parser = argparse.ArgumentParser(description="Check subdomain health.")
        parser.add_argument("subdomains_file", help="Path to the subdomains file.")
        parser.add_argument("--working_file", default="working_sni.txt", help="Path to the working subdomains file.")
        parser.add_argument("--nonworking_file", default="nonworking_sni.txt", help="Path to the nonworking subdomains file.")
        parser.add_argument("--timeout", type=int, default=5, help="Timeout in seconds for each request.")
        args = parser.parse_args()

        asyncio.run(main(args.subdomains_file, args.working_file, args.nonworking_file, args.timeout))

    ```
    * Save the file (Ctrl + O, Enter, Ctrl + X).

6.  **Make the Script Executable:**
    ```bash
    chmod +x check_host.py
    ```
    * This command grants execute permissions to the script.

7.  **Run the Script:**
    ```bash
    ./check_host.py subdomains.txt
    ```
    * This will execute the script, checking the subdomains listed in `subdomains.txt`.
    * You can also specify different output files and timeout values:
        ```bash
        ./check_host.py subdomains.txt --working_file good.txt --nonworking_file bad.txt --timeout 10
        ```
    * The script will display a progress bar using `tqdm`.

8.  **View Results:**
    * The working subdomains will be saved in `working_sni.txt` (or the file you specified).
    * The non-working subdomains will be saved in `nonworking_sni.txt` (or the file you specified).

## Important Notes

* Ensure you have a stable internet connection.
* The script uses asynchronous requests for faster processing.
* The script ignores SSL certificate errors.
* Adjust the timeout value based on your network conditions and server response times.
* Deactivate your virtual environment when you're done:
    ```bash
    deactivate
    ```
