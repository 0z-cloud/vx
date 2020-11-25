#!/bin/bash
echo "Changing rights to www-data"
chown -R www-data:www-data {{ apt_mirror_settings.directories.main }}/*
echo "Done sync"