# Set up a new machine

This is where I store files to be synched between machines.
Much of this is thanks to [Jake Weisler's videos here](https://www.youtube.com/watch?v=70YMTHAZyy4&list=PL1C97G3GhlHdANMFUIXTcFr14R7b7EBj9&pp=iAQB)

## Set up SSH keys

```
# Generate your ssh key
ssh-keygen -t rsa
# Copy the key to Github
cat .ssh/id_rsa.pub
```

## Set up a new environment

Just run the `install.sh` script
