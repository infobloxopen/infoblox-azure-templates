#!/bin/bash
# Pack all template files into zip archive to deploy on Azure

zip -j -r nios_template.zip main/*.json
