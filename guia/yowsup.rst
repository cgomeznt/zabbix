Configurar Yowsup 2 para Whatsapp

Instalamos  pip en CentOS 

# yum install epel-release

# yum install -y python-pip

# which pip
/usr/bin/pip

# rpm -qa|grep pip
python-pip-1.3.1-4.el6.noarch


Instalacion de yowsup 2

Requiere python2.6+, or python3.0 +
Requiere python packages: python-dateutil,
Requiere python packages for end-to-end encryption: protobuf, pycrypto, python-axolotl-curve25519
Requiere python packages for yowsup-cli: argparse, readline (or pyreadline for windows), pillow (for sending images)

Instalar usando setup.py para traer todas las dependencias de pyton o usar pip


# yum install gcc cc

# wget https://www.python.org/ftp/python/2.6.6/Python-2.6.6.tgz
# tar -zxvf Python-2.6.6.tgz
# cd Python-2.6.6
# ./configure && make && make install

# pip install --upgrade pip

Instalamos setuptools 2.6

# wget https://bootstrap.pypa.io/ez_setup.py -O - | python

Baixando e instalando o Yowsup:
Vamos criar uma pasta para baixar o Yowsup:

# mkdir yowsup

# cd yowsup

# wget http://www.blogdomedeiros.com.br/wp-content/uploads/2015/06/yowsup-master.zip

Descompactamos o arquivo:
# unzip master.zip

# cd yowsup-master

Instalando o Yowsup:
Dentro da pasta descompactada, basta rodar o script de instalação com o argumento “install”:



yum install patch ncurses ncurses-devel python-crypto2.6 python-dateutil python-unittest2 python-six python-importlib


# ./setup.py install


INFO:yowsup.common.http.warequest:{"status":"ok","login":"584120121235","type":"new","pw":"6tYtvbGMP1ywZwmElpj9sufmAf8=","expiration":4444444444.0,"kind":"free","price":"US$0.99","cost":"0.99","currency":"USD","price_expiration":1484754248}

status: ok
kind: free
pw: 6tYtvbGMP1ywZwmElpj9sufmAf8=
price: US$0.99
price_expiration: 1484754248
currency: USD
cost: 0.99
expiration: 4444444444.0
login: 584120121235
type: new




