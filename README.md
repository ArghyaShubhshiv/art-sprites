# Art Sprites

Bringing masterpieces from world-class museums to your terminal.

<img src="https://i.postimg.cc/SxGDrcsg/demo.png" alt="Demo of the tool" style="width:375px;"/>

---

## 1. Inspiration

Imagine opening the terminal and graced with a really good work of art! <br>
`art-sprites` was born from a love for cool artistic endeavors, and classic command-line tools like `pokemon-colorscripts`, `neofetch`, and other "sprite" tools, that make the terminal a more vibrant and personal space. 


## 2. How it Works

Unlike tools like `pokemon-colorscripts` that store all data locally in an ASCII-like format to ensure near zero latency, our tool uses APIs due to a large catalog which can't be managed locally. To ensure fast performance, we maintain a **local cache directory with 5 unique images**.

The initial run populates this cache, which may cause a brief delay, but all subsequent runs are nearly instant.

After an image is printed, it's automatically removed and replaced by a new one fetched in the background. You can also manually refresh the entire cache using the `--update` flag.



## 3. Installation

### Prerequisites

First, ensure you have the required command-line tools.
- **`curl`**: For making API requests.
- **`jq`**: A flexible command-line JSON processor.
- **`viu`**: A modern terminal image viewer.

You can install them on **Debian/Ubuntu** with:
```bash
sudo apt-get update && sudo apt-get install curl jq viu
```

On **Arch**-based distros:
```bash
sudo pacman -Syu && sudo pacman -S curl jq viu
```
For downloading the code and actually running it:

```sh
git clone https://github.com/ArghyaShubhshiv/art-sprites
cd art-sprites
chmod +x art-sprites.sh
```
### How to use

For reloading a random image from the cache, i.e., to load a random painting up
```bash
./art-sprites.sh
```
For reloading the cache
```bash
./art-sprites.sh --update
```
## 4. What's next
The project is planned to be a longterm one, which I'll keep updating whenever I'm free. As of now, the following todos are a high-priority:-

1. **API citizenship and rate-limits**:  I haven't yet checked how to keep the tool running in the event of large usage. That is, to use the APIs politely.

2. The **banner** right now isn't that good-looking.

3. **Add more public-domain sources**: Perhaps incorporate more APIs from different museums, archive.org, etc.

3. See if there's a better way to **manage cache/reduce latency**.

4. **Package the script** for the Arch User Repository (AUR) to simplify installation on Arch Linux.
