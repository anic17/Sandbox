# Sandbox

![downloads](https://img.shields.io/github/downloads/anic17/Sandbox/total)
![license](https://img.shields.io/github/license/anic17/Sandbox)
![stars](https://img.shields.io/github/stars/anic17/Sandbox)
![forks](https://img.shields.io/github/forks/anic17/Sandbox)
![issues](https://img.shields.io/github/issues/anic17/Sandbox)

Batch sandbox to simulate a file system using environment variables.

## Usage

`sandbox <command line>`  
You can run any command from there and it'll make a simulated file system on the directory `fs`.

## User and computer name spoofing

Batch sandbox allows you to spoof your username and your computer name by changing this [line](https://github.com/anic17/Sandbox/blob/main/SandBox.bat#L14) to either 0 or 1.  
A random username and computer name will be created to hide your computer' real information.
