<div align="center">

# ⚡ ScriptGrab

[![Version](https://img.shields.io/badge/version-0.0.3-blue)](https://github.com/devmesis/scriptgrab)
[![By Devmesis](https://img.shields.io/badge/creator-Devmesis-black)](https://devmesis.com)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](https://github.com/devmesis/scriptgrab/blob/main/LICENSE)
[![Open Source](https://img.shields.io/badge/open--source-100%25-brightgreen)](https://github.com/devmesis/scriptgrab)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-blueviolet)](https://github.com/devmesis/scriptgrab/pulls)

<sub>
📅 Sunday, May 25, 2025 · Made with ❤️ for developers who move fast.
</sub>

---

### 🚀 Run Any Shell Script from GitHub – Instantly

No downloads. No setup. Just one command to rule them all.

```bash
bash <(curl -sL scriptgrab.com)
```

##### Does the following:

###### curl -sL scriptgrab.com: This part uses curl to silently (-s) and following any redirects (-L) download whatever script or file is served at  [scriptgrab.com](https://scriptgrab.com).  
###### The output is the raw shell script content from that URL. 
###### bash <( ... ): The <( ... ) syntax is called process substitution. It takes the output from the curl command and treats it as a temporary file, then passes that file to bash to execute.

###### [scriptgrab.com](https://scriptgrab.com) is just the application layer, the “header” or GUI if you like. All the actual scripts live in the [/scripts](https://github.com/devmesis/scriptgrab/tree/main/scripts) folder on GitHub, open for you to inspect, fork, or hack. No black boxes. No surprises. Check the code before you run it.


##### In plain English:
###### This command instantly downloads a shell script from [scriptgrab.com](https://scriptgrab.com) and runs it in your terminal, all in one go, no manual downloads, no saving files, just direct execution. It’s a super-fast way to run remote scripts, perfect for engineers who want to skip the hassle and get straight to automating tasks.

##### Caution:
###### Because this runs code directly from the internet, you should only use it with sources you trust. Running remote scripts as root or on production systems can be risky if you don’t know exactly what the script does.

---

### 🛠️ Why ScriptGrab Exists

Let’s get real:

Ever found yourself on a fresh machine, staring at a terminal, knowing exactly what you need to do—but your scripts are stuck on another box, or locked away on a USB you can’t plug in, or lost in some cloud folder you can’t reach?
Yeah. Been there. Too many times.

I got tired of wasting time on “simple” problems that turn into click-fests or copy-paste nightmares. As an engineer, I refuse to click through endless nonsense just to get my environment right. If there’s a terminal, I want to move fast.

So I built ScriptGrab.

---

### ⚡ What is ScriptGrab?

ScriptGrab is my answer to “Why isn’t this easier?”
It lets you grab and run shell scripts straight from GitHub, instantly.

⚡ **Fast** — Instant access to curated scripts.


🧼 **Clean** — No install, no clutter.


🔐 **Safe** — No shady copy-paste jobs.

###### Perfect for developers, sysadmins, and makers who hate wasting time.



---

### 💡 Why Use ScriptGrab?

🚫 No more digging through repos.


💥 Skip the setup and config.


📦 Zero dependencies.


🧪 Supports stable & beta channels.


🧩 Modular and open-source.

###### Copy. Paste. Go. That’s it.

---

### 🌍 Community & Contributions

ScriptGrab is built for speed, but it thrives on community.
Fix a bug, suggest a feature, or go wild with your own scripts, jump in!

🤝 [Contribute](https://github.com/devmesis/scriptgrab/pulls)


🐛 [Report Issues](https://github.com/devmesis/scriptgrab/issues)


⭐️ [Star the Repo](https://github.com/devmesis/scriptgrab)

###### Let’s build it faster together.

---

### 👤 About the Creator

Crafted with ☕, code, and a bit of chaos by [Devmesis](https://devmesis.com).  
Connect on [LinkedIn](https://linkedin.com/in/ginodg) · [X/Twitter](https://x.com/Devmesis)

###### ScriptGrab: Because engineers should spend more time building, less time clicking.

---

### ⚠️ Important Notes

###### ⚠️ **Shell scripts can be powerful and risky.** Even small scripts can cause serious damage if misused. I strongly recommend **cloning this repo or creating your own fork** if you're cautious, especially for production environments. Or stay on the official repo to ensure you’re using trusted, reviewed code.

###### 💡 Prefer a local experience? While the cloud version works everywhere, cloning the repo allows for **better root access** and is recommended for **heavier or system-level tasks**.

###### 🛠️ You can also **customize and redirect ScriptGrab to your own GitHub repo**, making it perfect for internal tools, private scripts, or team-specific setups. 


