# Docker Image Builder Tool

These are small projects like PoC on docker. Each folder have Dockerfile to build for each projects.
And to prepare docker environment, I launched docker image development tool "run.sh".
This script can build a docker image from a Dockerfile, delete containers and images, commit and push images with consistency.

## How to use

### Command
Easy. When you build a docker image from a Dockerfile, put a Dockerfile on current directory have "runs.sh"
then put the command below.

```
$ ./run.sh create
```

The object of this script is that multiple commands assemble to one line.
So if you want to delete only containers, just do "docker stop" and "docker rm".

You can get other information to execute this command.

```
$ ./run.sh help

usage: ./run.sh [help | create | delete | commit | register-secret]

optional arguments:
create              Create image and container after that run the container.
delete              Delete image and container.
commit              Create image from target container and push the image to remote repository.
push                Push image you create to Docker Hub.
register-secret     Create password.txt for make it login process within 'commit' operation.
```

### Login to Docker Hub
You have to login to Docker Hub before you do `./run.sh push` which push your image to Docker Hub.
I create the generating credential function to short cut the authentication of Docker Hub.

```
$ ./run.sh register-secret
```
Type in above command, you generate password file interactively.(Generate `.password.txt` file on your current directory.)
But this is so vulnerable and insecure because `.password.txt` is BASE64 encoded messages.
If you use this function on your development environment, I highly recommend to write `.password.txt` to your `.gitignore`
to prevent from publishing your credentials by mistake.

## Authors

* **Kento Kashiwagi** - [tuimac](https://github.com/tuimac)

If you have some opinion and find bugs, please post [here](https://github.com/tuimac/tagdns/issues).

## License

There is no license. I don't have any responsibility to this product.
