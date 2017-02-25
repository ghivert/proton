require 'opal'

Opal.append_path 'lib'
Opal.append_path 'test_app'
File.binwrite "main.js", "var electron = require('electron');\nvar {BrowserWindow, webContents} = electron;\n" + Opal::Builder.build('main').to_s
File.binwrite "front.js", "var electron = require('electron');" + Opal::Builder.build('front').to_s
