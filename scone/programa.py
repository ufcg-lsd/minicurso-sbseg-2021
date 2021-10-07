import os 
print("Alo, mundo!")
secret_env = os.environ.get("VARIAVEL_SECRETA")
print("O segredo é: "+str(secret_env))
