from fastapi import FastAPI
import socket

app = FastAPI()


# Read - GET
@app.get("/")
def default():
    return {"message": "Hello World!"}


@app.get("/hostname")
def show_hostname():
    return {"hostname": socket.gethostname()}
