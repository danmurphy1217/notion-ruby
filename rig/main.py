# Entrypoint for application

from app.routes import hello

if __name__=='__main__':
    print(hello())