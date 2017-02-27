require 'opal'

Opal.append_path 'lib'
Opal.append_path 'example/lib'
File.binwrite "example/main.js", "var electron = require('electron');\nvar {BrowserWindow, webContents, net} = electron;\nvar nodeNet = require('net');\n" + Opal::Builder.build('main').to_s
File.binwrite "example/front.js", "var electron = require('electron');" + Opal::Builder.build('front').to_s
