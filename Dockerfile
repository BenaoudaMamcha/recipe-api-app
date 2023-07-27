
# Ce Dockerfile est conçu pour créer un conteneur Docker contenant une application Django avec ses dépendances Python
#  installées dans un environnement virtuel. L'utilisateur "django-user" sera utilisé pour exécuter l'application dans
#   le conteneur. Vous pouvez ensuite exécuter ce conteneur en utilisant Docker pour héberger votre application Django
#  avec les dépendances bien isolées dans un environnement virtuel.



# Utilisation d'une image Python Alpine 3.9 comme image de base
FROM python:3.9-alpine3.13


LABEL MAINTAINER =  "XXXX App Developer Ltd"



# Cela définit une variable d'environnement pour Python qui indique de désactiver la mise en mémoire 
# tampon des sorties standard. Cela est souvent recommandé pour éviter les problèmes avec l'affichage 
# des logs dans le conteneur.

ENV PYTHONUNBUFFERED 1

# Cette commande copie le fichier requirements.txt depuis le répertoire local (celui où se trouve le Dockerfile) 
# vers le répertoire /requirements.txt à l'intérieur de l'image. Ce fichier est utilisé pour 
# installer les dépendances du projet Python.

# COPY ./requirements.txt /requirements.txt

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt




# Crée un répertoire /app à l'intérieur de l'image. Ce sera le répertoire de travail principal pour notre application Django.

RUN mkdir /app

# Définit le répertoire de travail de l'image sur /app. Cela signifie que toutes les commandes suivantes 
# s'exécuteront dans ce répertoire, à moins qu'elles ne spécifient un chemin complet différent.

WORKDIR /app

# Copie le contenu du répertoire app (qui se trouve dans le même répertoire que le Dockerfile)
# dans le répertoire /app de l'image. Cela copie le code source de notre application Django dans le conteneur.

COPY ./app /app


# Exposer le port 8000 pour que Django puisse écouter les requêtes entrantes

EXPOSE 8000



# Commande pour lancer le serveur Django lorsqu'un conteneur est démarré à partir de cette image
# CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]





# Les lignes suivantes commencent par RUN et comprennent plusieurs commandes exécutées à l'intérieur du conteneur :

# python -m venv /py: Crée un environnement virtuel Python nommé "py" à la racine du conteneur.
# /py/bin/pip install --upgrade pip: Met à jour pip dans l'environnement virtuel pour obtenir la dernière version.
# /py/bin/pip install -r /tmp/requirement.txt: Installe les dépendances Python spécifiées dans le fichier requirements.txt dans l'environnement virtuel.
# rm -rf /tmp: Supprime le répertoire temporaire "tmp" utilisé pendant l'installation des dépendances.
# adduser --disabled-password --no-create-home django-user: Cette instruction ajoute un nouvel utilisateur nommé "django-user"
# au conteneur, qui sera utilisé pour exécuter l'application Django. L'option --disabled-password indique que cet utilisateur
# n'aura pas de mot de passe, et --no-create-home indique que nous ne voulons pas créer de répertoire utilisateur pour lui,
# car il ne sera utilisé que pour l'exécution de l'application.

ARG DEV=false
RUN python3 -m venv /py && \
      /py/bin/pip install --upgrade pip && \
      /py/bin/pip install -r /tmp/requirements.txt  && \
      if [ $DEV = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt ; fi && \
      rm -rf /tmp && \
      adduser \
            --disabled-password \
            --no-create-home \
            django-user

#  Modifie la variable d'environnement PATH pour inclure le chemin vers l'environnement virtuel Python que nous avons créé 
#  précédemment. Cela permettra d'exécuter les commandes Python à partir de l'environnement virtuel sans avoir à spécifier
#   le chemin complet.

ENV PATH="/py/bin:$PATH"

# Définit l'utilisateur qui exécutera les commandes à partir de maintenant à l'intérieur du conteneur.
# Cela signifie que toutes les commandes seront exécutées avec l'utilisateur "django-user" que nous avons créé auparavant.


USER django-user