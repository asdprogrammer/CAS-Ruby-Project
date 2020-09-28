#!/usr/bin/env ruby

# snake game with text characters

require 'curses'


#if RUBY_VERSION[0..2] != '2.0'
#  puts 'Please use Ruby version 2.0'
#  exit
#end

Curses.init_screen
Curses.start_color
Curses.curs_set(0)
Curses.noecho

$width = Curses.cols
$height = Curses.lines

if $width < 70 or $height < 15
  Curses.close_screen
  puts 'Please increase the size of your window.'
  exit
end

frame_count = 0
frame_rate = 100

snake_char = '□'
apple_char = 'o'

box_vertical_char = '|'
box_horizontal_char = '-'

snake_speed = 10 # blocks per second

def reset
  $snake_length = 5
  $snake_pos = {'x' => ($width / 2).to_i, 'y' => ($height / 2).to_i}
  $snake_direction = {'x' => 1, 'y' => 0}

  $last_positions = []
  # starting body
  for i in ($snake_length-1).downto(0)
    $last_positions.push({'x' => $snake_pos['x'] - i, 'y' => $snake_pos['y']})
  end

  $apple_pos = {'x' => rand(1..$width-2), 'y' => rand(0..$height-2)}

  $score = 0
  $game_over = false
end


begin
  win = Curses::Window.new(0, 0, 0, 0)
  win.keypad = true
  win.nodelay = true
  
  reset

  loop do
    start_time = Time.now.to_f

    # controls
    key = win.getch
      
    if (key == Curses::Key::UP or key == 'w' or key == 'W') and $snake_direction['y'] != 1
      $snake_direction['y'] = -1
      $snake_direction['x'] = 0
    elsif (key == Curses::Key::DOWN or key == 's' or key == 'S') and $snake_direction['y'] != -1
      $snake_direction['y'] = 1
      $snake_direction['x'] = 0
    elsif (key == Curses::Key::LEFT or key == 'a' or key == 'A') and $snake_direction['x'] != 1
      $snake_direction['y'] = 0
      $snake_direction['x'] = -1
    elsif (key == Curses::Key::RIGHT or key == 'd' or key == 'D') and $snake_direction['x'] != -1
      $snake_direction['y'] = 0
      $snake_direction['x'] = 1
    elsif key == ' ' and $game_over
      $game_over = false
      reset
    end

    if !$game_over
      # update stuff
      if frame_count % (frame_rate / snake_speed) == 0
        win.clear
        win.box(box_vertical_char, box_horizontal_char)

        # draw
        for pos in $last_positions
          win.setpos(pos['y'], pos['x'])
          win.addstr(snake_char)
        end
      
        win.setpos($apple_pos['y'], $apple_pos['x'])
        win.addstr(apple_char)
      
        # update
        $snake_pos['x'] += $snake_direction['x']
        $snake_pos['y'] += $snake_direction['y']
      
        $last_positions.push($snake_pos.dup)
        if $last_positions.length > $snake_length
          $last_positions = $last_positions[1..$last_positions.length-1]
        end

        # eat apple
        if $snake_pos == $apple_pos
          $snake_length += 1
          $score += 1
          $apple_pos['x'] = rand(1..$width-2)
          $apple_pos['y'] = rand(1..$height-2)
        end

        # bonk
        if $snake_pos['x'] < 1 or $snake_pos['x'] > $width - 2 or
          $snake_pos['y'] < 1 or $snake_pos['y'] > $height - 2
          $game_over = true
        end

        for pos in $last_positions[0..$last_positions.length-2]
          if $snake_pos == pos
            $game_over = true
          end
        end
      end
    else # game text
      win.setpos(2, 3)
      win.addstr('GAME OVER')
      win.setpos(3, 3)
      win.addstr("SCORE: #$score")
      win.setpos(4, 3)
      win.addstr('PRESS SPACE BAR TO PLAY AGAIN')
      win.setpos(5, 3)
      win.addstr('PRESS CTRL + C TO QUIT')
    end

    frame_count += 1
    
    # adjust frame rate
    frame_time = Time.now.to_f - start_time
    sleep((1000 / frame_rate - frame_time) / 1000)

    win.refresh
  end
ensure
  Curses.close_screen
  win.close
end
