# NetRequire

## Installation

```sh
wget https://raw.githubusercontent.com/Frityet/NetRequire/master/netrequire.lua
```

## Usage

### Simple
```lua
local netrequire = require("netrequire")
local pkg = netrequire("https://raw.githubusercontent.com/jagt/pprint.lua/master/pprint.lua")
```

### More options
```lua
local netrequire = require("netrequire")
local pkg = netrequire { 
    url = "https://raw.githubusercontent.com/jagt/pprint.lua/master/pprint.lua",
	name = "prettyprint.lua",
	cache = false --does not save to /cache/package/[name]
}
```

## Roadmap

- [] Async loading 
- [] Multiple sources
	- [] Github-gist 
	- [] Github-repo
	- [] Pastebin
	- [] dev.bin
- [] Custom require loader
