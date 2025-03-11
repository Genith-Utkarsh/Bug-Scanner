#!/usr/bin/env python3
import asyncio
import aiohttp
import sys
from tqdm import tqdm

INPUT_FILE = "subdomains.txt"
WORKING_FILE = "working_sni.txt"
NONWORKING_FILE = "nonworking_sni.txt"
CONCURRENCY = 200          # Adjust concurrency as needed
CHECK_TIMEOUT = 7          # Timeout per host in seconds
MAX_RETRIES = 3            # Number of retry attempts per host
RETRY_DELAY = 1            # Delay between retries in seconds

# Custom headers to simulate a real browser
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                  "AppleWebKit/537.36 (KHTML, like Gecko) "
                  "Chrome/115.0 Safari/537.36"
}

def prepare_url(host: str) -> str:
    host = host.strip()
    if not host:
        return ""
    # Prepend "https://" if not present
    if not host.startswith("http"):
        return f"https://{host}"
    return host

async def check_host_once(session: aiohttp.ClientSession, host: str) -> (str, int):
    """
    Attempt a GET request, and if that fails try a HEAD request.
    Returns (host, status) where status 0 indicates failure.
    """
    url = prepare_url(host)
    if not url:
        return host, 0
    status = 0
    try:
        async with session.get(url, headers=HEADERS) as response:
            status = response.status
    except Exception:
        try:
            async with session.head(url, headers=HEADERS) as response:
                status = response.status
        except Exception:
            status = 0
    return host, status

async def retry_check_host(session: aiohttp.ClientSession, host: str) -> (str, int):
    """
    Retry checking the host up to MAX_RETRIES times.
    Return the first non-zero status or 0 if all attempts fail.
    """
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            result = await asyncio.wait_for(check_host_once(session, host), timeout=CHECK_TIMEOUT)
            if result[1] != 0:
                return result
        except asyncio.TimeoutError:
            pass
        await asyncio.sleep(RETRY_DELAY)
    return host, 0

async def worker(host_queue: asyncio.Queue, session: aiohttp.ClientSession, results: list, pbar: tqdm):
    """
    Worker task that processes hosts from the queue and updates the progress bar.
    """
    while not host_queue.empty():
        host = await host_queue.get()
        result = await retry_check_host(session, host)
        results.append(result)
        pbar.update(1)
        host_queue.task_done()

async def main():
    # Read hosts from input file
    try:
        with open(INPUT_FILE, "r") as f:
            hosts = [line.strip() for line in f if line.strip()]
    except Exception as e:
        print(f"Error reading {INPUT_FILE}: {e}")
        sys.exit(1)

    total = len(hosts)
    if total == 0:
        print("No hosts found in the input file.")
        return

    # Prepare an asyncio Queue with all hosts
    host_queue = asyncio.Queue()
    for host in hosts:
        await host_queue.put(host)

    results = []
    # Create a TCPConnector with ssl=False to disable SSL verification
    connector = aiohttp.TCPConnector(ssl=False)
    async with aiohttp.ClientSession(connector=connector, headers=HEADERS) as session:
        with tqdm(total=total, desc="Scanning hosts", dynamic_ncols=True) as pbar:
            # Launch a number of worker tasks; use CONCURRENCY tasks
            workers = [
                asyncio.create_task(worker(host_queue, session, results, pbar))
                for _ in range(CONCURRENCY)
            ]
            await asyncio.gather(*workers)

    # Separate results into working and non-working hosts
    working = []
    nonworking = []
    for host, status in results:
        if status and status != 0:
            working.append((host, status))
        else:
            nonworking.append(host)

    # Write results to files
    with open(WORKING_FILE, "w") as wf:
        for host, status in working:
            wf.write(f"{host} - {status}\n")
    with open(NONWORKING_FILE, "w") as nwf:
        for host in nonworking:
            nwf.write(f"{host}\n")

    print(f"\nTotal hosts: {total}")
    print(f"Working hosts: {len(working)}")
    print(f"Non-working hosts: {len(nonworking)}")
    print(f"Working hosts saved in {WORKING_FILE}")
    print(f"Non-working hosts saved in {NONWORKING_FILE}")

if __name__ == "__main__":
    asyncio.run(main())
