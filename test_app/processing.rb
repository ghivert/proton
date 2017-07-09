require 'proton'
require_relative 'shared'

def unconnect
  $values.client.write("SORT/#{$values.user}/\n")
  $values.client.end
end

def process_data(data)
  puts "#{data}"
  @chan = Global.main_window.web_contents
  puts "Je suis la."
  # Get what the server tells.
  input = data.to_s.split(/\n|\//).select { |num| num != ''}
  puts input

  while input.length > 0
    case input.shift
      # Log in messages.
    when 'BIENVENUE'
      if input.shift != $values.user
        puts 'Wrong user. What happend ?'
        begin
          unconnect
        rescue Exception => err
          puts err
        end
        raise 'Wrong User'
      end
      @chan.send('add-opponent', $values.user)
    when 'CONNECTE'
      name = input.shift
      @chan.send('add-opponent', name)
      $values.opponents[name] = 0
    when 'DECONNEXION'
      name = input.shift
      @chan.send('delete-opponent', name)
      $values.opponents[name] = nil
    when 'SESSION'
      # stream = input.shift
      input.shift
      readBoard
    when 'VAINQUEUR'
      readWinner(input.shift)
    when 'TOUR'
      convert_enigma(input.shift)
      read_winner(input.shift)
      initBoard
      $values.state = "REFLEXION"
    when 'TUASTROUVE'
      $values.state = "ENCHERES"
    when 'ILATROUVE'
      $values.state = "ENCHERES"
      user = input.shift
      moves = input.shift
      values.solution << [user, moves]
      @chan.send('il-a-trouve', [user, moves])
    when 'FINREFLEXION'
      $values.state = "ENCHERES"
      @chan.send('fin-reflexion')
    when 'VALIDATION'
      puts input
    when 'ECHEC'
      @chan.senc('echec', input.shift)
    when 'NOUVELLEENCHERE'
      puts input
      user = input.shift
      moves = input.shift
      @chan.send('nouvelle-enchere', [user, moves])
      $values.solution << [user, moves]
    when 'FINENCHERE'
      user = input.shift
      @chan.send('fin-enchere', [user, input.shift])
      if user == $values.user
        $values.state = "SOLUTION"
      else
        $values.state = "WAIT"
      end
    when 'SASOLUTION'
      input.shift
      @chan.send('sa-solution', input.shift)
    when 'BONNE'
      @chan.send('bonne')
    when 'MAUVAISE'
      user = input.shift
      @chan.send('mauvaise', user)
      if user == $values.user
        $values.state = "SOLUTION"
      else
        $values.state = "WAIT"
      end
    when 'FINRESO'
      $values.state = "WAIT"
      $values.solution = []
    when 'TROPLONG'
      user = input.shift
      @chan.send('trop-long', user)
      if user == $values.user
        $values.state = "SOLUTION"
      else
        $values.state = "WAIT"
      end
    when 'CHAT'
      @chan.send('chat', [input.shift, input.shift])
    end
  end
end

# Read a board state and fill the board variable with it.
def readBoard
  walls = @stream.split(/\(|\)|\,/).select { |val| val != ''}
  if walls.length == 0
    puts 'No board... Why ?'
    begin
      unconnect
    rescue Exception => err
      puts err
    end
    raise 'Wrong board.'
  end
  # Board is an array of tuples [x, y, orient] for each wall.
  while walls.length != 0
    @x = walls.shift
    @y = walls.shift
    @orient = walls.shift
    $values.board << [@x, @y, @orient]
    paintWall
  end
end

def paintWall
  case orient
  when "H"
    x1 = (@x - 1) * 40
    y1 = (@y - 1) * 40
    x2 = (@x - 1) * 40 + 40
    y2 = (@y - 1) * 40
  when "B"
    x1 = (@x - 1) * 40
    y1 = (@y - 1) * 40 + 40
    x2 = (@x - 1) * 40 + 40
    y2 = (@y - 1) * 40 + 40
  when "G"
    x1 = (@x - 1) * 40
    y1 = (@y - 1) * 40
    x2 = (@x - 1) * 40
    y2 = (@y - 1) * 40 + 40
  when "D"
    x1 = (@x - 1) * 40 + 40
    y1 = (@y - 1) * 40
    x2 = (@x - 1) * 40 + 40
    y2 = (@y - 1) * 40 + 40
  end
  @chan.send('update-walls', [x1, y1, x2, y2])
end

# Read a end state and updates scores.
def read_winner(stream)
  score = stream.split(/\(|\)|\,/).select { |val| val != ''}
  if score.length == 0
    puts 'No score... Why ?'
    begin
      unconnect
    rescue Exception => err
      puts err
    end
    raise 'Wrong score.'
  end

  # Update the score of opponents.
  $values.round = score.shift
  while score.length != 0
    $values.opponents[score.shift] = score.shift
    @chan.send('update-score')
  end
end

# Convert the enigma.
def convert_enigma(stream)
  enigma = stream.split(/\(|\)|\,/).select { |val| val != ''}

  $values.enigma.red.x,    $values.enigma.red.y    = enigma[0], enigma[1]
  $values.enigma.blue.x,   $values.enigma.blue.y   = enigma[2], enigma[3]
  $values.enigma.yellow.x, $values.enigma.yellow.y = enigma[4], enigma[5]
  $values.enigma.green.x,  $values.enigma.green.y  = enigma[6], enigma[7]
  $values.enigma.target.x, $values.enigma.target.y = enigma[8], enigma[9]
  $values.enigma.color                             = enigma[10]
end

def init_board
  @chan.send('update-graphics', [
    $values.enigma.red.x,    $values.enigma.red.y,
    $values.enigma.blue.x,   $values.enigma.blue.y,
    $values.enigma.yellow.x, $values.enigma.yellow.y,
    $values.enigma.green.x,  $values.enigma.green.y,
    $values.enigma.target.x, $values.enigma.target.y,
    $values.enigma.color
  ])
end
