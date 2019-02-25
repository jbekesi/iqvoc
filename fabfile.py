# -*- coding: utf8 -*-
"""
Upload der lokal erzeugten SQLITE-Db sowie Starten des Uploads nach
easydb5 usw."""
from __future__ import absolute_import, print_function
import datetime
import os
import logging


from fabric.api import local, run, env, cd, lcd, put, get, settings, warn_only
from fabric.colors import red, green, cyan, magenta
logger = logging.getLogger(__name__)
logging.basicConfig(filename="remote_actions.log",
                    level=logging.DEBUG,
                    format='%(levelname)s [%(asctime)s]: %(message)s',
                    datefmt='%Y-%m-%d %H:%M')
env.hosts = ['bekesij9@vocab.phaidra.org']

WORKDIR = '/var/www/iqvoc.phdr'



def gitupd():
    "update git on vocab"
    with cd(WORKDIR):
        local("git push")
        run("git pull")
