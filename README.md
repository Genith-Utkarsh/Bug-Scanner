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
