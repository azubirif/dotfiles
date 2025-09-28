#!/bin/bash

man $(man -k . | awk '{print $1}' | fzf)
