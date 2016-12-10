require 'opal'

Opal.append_path 'lib'
Opal.append_path 'test_app'
File.binwrite "main.js", "var electron = require('electron');\nvar {BrowserWindow} = electron;\n" + Opal::Builder.build('main').to_s
