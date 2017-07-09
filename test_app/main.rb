require 'proton'
require 'proton/ipc_main'
require 'proton/browser_window'
require 'proton/web_contents'
require_relative 'client'

@app = Proton.app

Global.main_window = nil
Global.ready = { ready: false }

$quit_debug = true
@win = nil

def create_window
  Global.main_window = Proton::BrowserWindow.new({
    width:  900,
    height: 800,
    titleBarStyle: 'hidden'
  }).tap do |bw|
    p "Je suis ici. #{bw}"
    bw.load_url "file://#{`__dirname`}/index.html"
    bw.on 'closed' do
      Global.main_window = nil
    end
  end

  @win = Proton::BrowserWindow.new({
    width:  900,
    height: 800
  }).tap do |bw|
    p bw
    bw.load_url "file://#{`__dirname`}/login.html"
  end
end

@app.on 'ready' do
  create_window
  begin
    Proton::IpcMain.on 'name' do
      @win.close
      Client.connect
    end
  rescue StandardError => e
    puts e
    @app.quit
  end

  Process.on 'SIGINT' do
    begin
      # Client.unconnect
    rescue StandardError => e
      puts e
    end

    @app.quit
  end
end

@app.on 'window-all-closed' do
  if (Process.platform != 'darwin')
    begin
      # Client.unconnect
    rescue StandardError => e
      puts e
    end
  end

  if ($quit_debug)
    begin
      # Client.unconnect
    rescue StandardError => e
      puts e
    end

    @app.quit
  end
end

puts "I'm done!"
