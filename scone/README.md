# SBSEG 2021

Este repositório contém um exemplo simples de aplicacao confidencial SCONE.

## Instalar driver do SGX

```bash
# Instruções em https://github.com/intel/linux-sgx-driver
dpkg-query -s linux-headers-$(uname -r)
sudo apt-get install linux-headers-$(uname -r)

git clone https://github.com/intel/linux-sgx-driver
cd linux-sgx-drive
make
sudo mkdir -p "/lib/modules/"`uname -r`"/kernel/drivers/intel/sgx"    
sudo cp isgx.ko "/lib/modules/"`uname -r`"/kernel/drivers/intel/sgx"    
sudo sh -c "cat /etc/modules | grep -Fxq isgx || echo isgx >> /etc/modules"    
sudo /sbin/depmod
sudo /sbin/modprobe isgx

ls /dev/isgx
```

## Instalar Docker

```bash
# Instruções em: https://docs.docker.com/engine/install/ubuntu/

sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
docker --version
```

## Primeira execucao: Alo Mundo sem atestação e sem segredo

```bash
sudo docker build . -t alo-mundo-scone-no-attest -f scone-no-attest.Dockerfile
sudo docker run -it --rm --device /dev/isgx alo-mundo-scone-no-attest
```

## Segunda execução: fonte encriptado, com atestacao e acesso a segredo

```bash
# Criamos o diretório para as diferentes versões dos arquivos
# (e para o nosso arquivos de controle, fspf.sh e volume.fspf)
mkdir fspf native-files encrypted-files 
cat /native-files/keytag
cp programa.py native-files/
chmod +x fspf.sh
cp fspf.sh fspf/
export IMAGEM=spire:network-shield-python-alpha3
 
sudo docker run -it --rm --device /dev/isgx \
 -v $PWD/fspf:/fspf \
 -v $PWD/native-files:/native-files \
 -v $PWD/encrypted-files:/app \
 registry.scontain.com:5050/sconecuratedimages/$IMAGEM \
 bash -c /fspf/fspf.sh

cat native-files/keytag

# Geração da imagem
sudo docker build . -t sbseg-alo-mundo-scone-fspf -f scone-fspf.Dockerfile

# Para a primeira execução precisamos descobrir o MRENCLAVE
# Vamos fazer isso dentro do contêiner
sudo docker run -it --rm --device /dev/isgx --entrypoint /bin/bash \
    sbseg-alo-mundo-scone-fspf

# Dentro do contêiner, descobrimos o MRENCLAVE do binário com:
SCONE_HASH=1 python3 

# Vamos usar um servidor CAS público
# Antes de usar, precisamos estabelecer a confiança nele.
scone cas attest 5-5-0.scone-cas.cf -GCS \
   --only_for_testing-trust-any --only_for_testing-ignore-signer \
   --only_for_testing-debug

apk add vim
vim sessao.yml
# Adicionar MRENCLAVE, KEY, e TAG

# Finalmente, enviamos a sessão para o CAS público
scone session create sessao.yml
# CTRL+D para sair

# Deploy do LAS
sudo docker run -it --rm --name las --device /dev/isgx -p 18766:18766 registry.scontain.com:5050/sconecuratedimages/spire:las-scone5.4.0

# Configurando o CAS remoto, o LAS local e o nome da sessão
export SCONE_CAS_ADDR=5-5-0.scone-cas.cf
export SCONE_LAS_ADDR=172.17.0.1
export SCONE_CONFIG_ID=sessao-exemplo/alo-mundo

# Por fim, executamos a app confidencial, que é atestada e consome o segredo:
sudo docker run -it --rm --device /dev/isgx \
  -e SCONE_CAS_ADDR=$SCONE_CAS_ADDR \
  -e SCONE_LAS_ADDR=$SCONE_LAS_ADDR \
  -e SCONE_CONFIG_ID=$SCONE_CONFIG_ID \
  sbseg-alo-mundo-scone-fspf
```

