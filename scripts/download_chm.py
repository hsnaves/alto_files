import argparse
import bs4
import os
import re
import requests
import urllib
import tempfile
import time

def scrape(url, dirname, include_expanded, sleep_time=2):
    os.makedirs(dirname, exist_ok=True)

    exp_prog = re.compile(r"^.*\.(altodisk|bfs|copydisk|dm)!\d+>$",
                          re.IGNORECASE)

    print("Fetching index page %s at %s ... " % (url, dirname))
    page = requests.get(url)
    soup = bs4.BeautifulSoup(page.content, "html.parser")

    for a_elm in  soup.find_all("a", href=True):
        href = a_elm["href"]
        text = a_elm.text
        new_url = urllib.parse.urljoin(url, href)

        if text == "(raw)":
            filename = os.path.join(dirname, href)
            if os.path.exists(filename):
                print("Skipping file %s ..." % (filename,))
                continue

            time.sleep(sleep_time)
            print("Fetching file %s ... " % (filename,))
            response = requests.get(new_url)
            try:
                fh, tempfilename = tempfile.mkstemp(suffix=".temp",
                                                    dir=dirname)
                with os.fdopen(fh, "wb") as f:
                    f.write(response.content)
            except OSError:
                os.unlink(tempfilename)
                print("Skipping %s ..." % (filename,))
            else:
                os.rename(tempfilename, filename)
        elif href.endswith("/.index.html"):
            is_expanded = False
            if exp_prog.match(text):
                text = text[:-1] + "_"
                is_expanded = True
            else:
                while text.startswith("[") or text.startswith("<"):
                    text = text[1:]
                while text.endswith("]") or text.endswith(">"):
                    text = text[:-1]

            new_dirname = os.path.join(dirname, text)
            if (not include_expanded) and is_expanded:
                print("Skipping directory %s ..." % (new_dirname,))
                continue

            time.sleep(sleep_time)
            scrape(url=new_url,
                   dirname=new_dirname,
                   include_expanded=include_expanded,
                   sleep_time=sleep_time)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output_dir", type=str, default=".",
                        help="the output directory")
    parser.add_argument("--include_expanded", action="store_true",
                        help="to also download the expanded files")
    parser.add_argument("--sleep_time", type=int, default=2,
                        help="the default sleep time in seconds")
    args = parser.parse_args()

    url = "https://xeroxalto.computerhistory.org/index.html"
    scrape(url=url,
           dirname=args.output_dir,
           include_expanded=args.include_expanded,
           sleep_time=args.sleep_time)

if __name__ == "__main__":
    main()
