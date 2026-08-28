#!/usr/bin/env bash

# Este script demonstra as combinações de cores de fundo e texto no terminal usando códigos ANSI.
# Ele itera sobre os códigos de fundo (background) de 40 a 47 e de texto (foreground) de 30 a 37,
# imprimindo uma amostra de texto colorido para cada combinação possível.

for bg in {40..47}; do
  for fg in {30..37}; do
    echo -e "\e[${fg};${bg}m fg=${fg}, bg=${bg} \e[0m"
  done
done