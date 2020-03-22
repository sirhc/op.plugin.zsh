# 1Password (op) plugin

This plugin command line completions for the
[1Password](https://1password.com/)
[`op`](https://1password.com/downloads/command-line/ command).

It provides the following convenience functions.

| Function | Purpose |
| --- | --- |
| `1ps` | Sign in, setting the returned session variable in the current shell |
| `1pt` | Copy the returned TOPT using `xclip` |

To use it, add `op` to the plugins array in your zshrc file:

```zsh
plugins=(... op)
```
