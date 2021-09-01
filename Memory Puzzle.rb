require 'ruby2d'

set width:800
set height:600
set background:'white' # set background to white

$colors=["navy","aqua","teal","olive", "green", "lime", "yellow", "orange","red", "brown", "fuchsia",
         "purple","maroon","black"] # possible random colors for all the shapes in the game


WIDTH=((Window.width-20)/100).floor
SHAPE_POSITION_Y_START = 0 # start of x and y postions on the axis
SHAPE_POSITION_X_START= 50
SHAPE_POSITION_Y_END = 50
SHAPE_POSITION_X_END=100

NUM_SQUARES = 20 # number of squares the user has to guess to be divided by 2
SIZE_SQUARE=45 # size of the square that is to hide the shapes


class Game
  attr_reader :finished # allows to read if the game is finished
  attr_reader :seconds # allows to read the seconds
  attr_writer :seconds # allows to write the seconds
  attr_reader :matched #  allows to read if there is a match of shapes
  attr_reader :unmatched # allows to read if there is not a match of shapes
  attr_reader :duration # allows to read the seconds passed
  attr_writer :start_time # allows to write the start time of the game
  attr_reader :start_time # allows to read the start time of the game
  attr_writer :duration # allows to write how many seconds has passed
  def initialize

    $square_array=[] # array hold in the positions of each square to be guessed
    $circle_array=[] #array hold in the positions of each circle to be guessed
    $triangle_array=[] # array hold in the positions of each triangle to be guessed
    $array_filled = [] # array to display the random shapes holds boolean value
    $block_array=[] # array to block shape from appearing holds false and true values
    $finished_array=[] # array to stop shapes from appearing when they are correctly guessed
    $eliminate_shapes=[] # array to stop shapes from appearing when they are correctly guessed
    $arr=[]  # array that holds in the shape type and the shape color this is a 2d array
    $arr_finished_position=[] # array that holds in the position of the square that is selected by the user
    $array_match_shapes=[] # 2d array that holds in every shape and its matched color and shape into this array
    for a in 0..NUM_SQUARES/2-1 # push false values into these arrays
      $array_filled.push(false)
      $block_array.push(false)
      $eliminate_shapes.push(false)
      $array_match_shapes.push([])
      $finished_array.push(false)
    end
    $random_array=[] # array that holds in the shapes position,color,shape type as well as its match, all this randomsized data is stored inside this array for each game
    @seconds=0 # number of seconds
    @duration = 0 
    @start_time = Time.now # record the start time of the game into this variable

    @add_elements=false # bool to add shapes positions into an array
    @match_elements=false
    @shape_click=0 # number of times a shape is clicked
    @matched=false # bool to detect a match
    @unmatched=false  # bool to detect a mismatch
    @unmatched_time=0 # display no match
    @matched_time=0 # display match
    @finished=false # set how the game ends
    @shape=Square.new(x:0,y:0,color:'white') # does nothing important
    @text=Text.new("")  # does nothing important

  end
  def set_all_shapes_to_hide # hide all shapes from the user over a square
    for a in 0..$block_array.size-1
      $block_array[a]=false # block shapes from appearing 
    end
  end

  def text_no_match #display match or no match to the user if they guessed the shape correctly  or not
    Text.new("No Match! Try Again.",x:Window.width/100*30,y:25,color:'red')
  end
  def text_match
    Text.new("Match! Well done!",x:Window.width/100*30,y:25,color:'red')
  end


  def hide_matched_shape # hide the  shapes from the user after they have been matched
    for a in 0..$block_array.size-1 # loop through number of squares on the screen
      if $block_array[a]
        $eliminate_shapes[a]=true # block shapes from appearing the rest of the game
      end
    end
  end
  def finished? # check if game is finished
    @finished
  end
  def end_game # finish game immediately
    if $finished_array.all?{|x|x==true} # check if every shape has been covered so that the game will end
      @duration=Time.now-@start_time # show the time it took for the user to correctly guess all shapes
      @finished=true
    end
  end

  def shapes_match?
    $arr[0]==$arr[1] # check if shapes share the same color
  end

  def activate_shape(x,y) # mouse coordinates as parameters
    for a in 0..$square_array.size-1
      new_square=$square_array[a]
      @shape=Square.new(x:new_square[0],y:new_square[1],size:SIZE_SQUARE)
      if @shape.contains?(x,y) && $finished_array[a]==false # check if the shape has these coordinates and the shape has not been covered yet
        if $block_array[a]==false # block the shape from disappearing for a while
          @shape_click+=1 # increment the number of times a shape has been clicked
          $arr.push($array_match_shapes[a]) # get the position of the square and pushes its shape type and color into this array
          $arr_finished_position.push(a) # this position of the array is covered
        end

          $block_array[a]=true

        if@shape_click%2==0
          if shapes_match? #if shapes do match
            hide_matched_shape # hide the shapes
            $finished_array[$arr_finished_position[0]]=true # shapes have been covered and will no longer appear ever
            $finished_array[$arr_finished_position[1]]=true
            @matched=true # matched value is set to true and will display a match
            @matched_time=0 # how long  a match will appear
          else
            @unmatched=true # no match will be displayed
            @unmatched_time=0
          end
          $arr=[] # empty this array
          $arr_finished_position=[]
        end
      else
        @text.remove # nothing important
        #$block_array[a]=false
        if @shape_click%2==0
          set_all_shapes_to_hide # set shapes to hide after user clicks twice
        end
      end
      @shape.remove
    end
  end


  def draw_shapes
    @unmatched_time+=1
    @matched_time+=1
    if @unmatched_time>=30 # display a no match for half a second
      @unmatched=false # set  to false
    end
    if @matched_time>=30 # display a match for half a second
      @matched=false
    end
    x1=SHAPE_POSITION_X_START
    y1=SHAPE_POSITION_Y_START
    x2=SHAPE_POSITION_X_END
    y2=SHAPE_POSITION_Y_END
    for a in 0..NUM_SQUARES/2-1 # start drawing squares on the screen
      if a%WIDTH==0
        y1+=75
        y2+=75
        x1=SHAPE_POSITION_X_START
        x2=SHAPE_POSITION_X_END
      end
      if @add_elements==false # keep adding shape positions if this is false
        $square_array.push([x1,y1,SIZE_SQUARE]) # positions of squares,circles,triangles
        $circle_array.push([x1+20,y1+20,20,32])
        $triangle_array.push([(x1+x2)/2,x1,x2,y1,y2,y2])
      end
      @shape=Square.new(x:x1,y:y1,size:SIZE_SQUARE,color:'blue') # blue square that will conceal everything
      if $block_array[a] || $eliminate_shapes[a]|| @seconds<120 # reveal all random shapes to the user for two seconds at the start of the game to remeber where the shapes are
        @shape.opacity=0 # set the blue squares supposed to block everything to reveal the random shapes through them
      end




      x1+=Window.width/WIDTH
      x2+=Window.width/WIDTH
    end
    @add_elements=true # stop adding elements to the array that hold the positions of the shapes
  end


  def randomize_shapes # randomize the shapes

    for a in 0..NUM_SQUARES/2-1
      if $array_filled[a]==false # check if shape has not been alrady created
        $array_filled[a]=true # mark shape as created
        x= rand(a..NUM_SQUARES/2)#create shape in a random position
        while $array_filled[x]!=false
          x= rand(a..NUM_SQUARES/2) # create a random number that has not been already generated
        end
        $array_filled[x]=true
        match_array=[a,x] # array to hold in the positions of the random shapes so that they match
        y=rand(3)#create shape type based on number generated
        random_color = rand($colors.size)#generate color number from array
        arr=[a,x,y,random_color] # array to hold in position of the first shape, position of the second and 2 random colors that are the same
        $random_array.push(arr) # push this to this arrau
        $array_match_shapes[a].push(y,random_color) # array to hold the position as well as the shape type and random color
        $array_match_shapes[x].push(y,random_color) # array to hold the position as well as the shape type and random color
      end
    end
  end


  def print_random_shapes
    #arr=[a,x,y,random_color]
    for a in 0..$random_array.size-1
      arr=$random_array[a] # get details of the random shape form this array
      if $finished_array[arr[0]]==false && $finished_array[arr[1]]==false # if shape as not been covered
      if arr[2]==0 # if shape type is equal to zero create a square
        s_coord=$square_array[arr[0]]#create square coordinates from square array randomized position
        if $block_array[arr[0]] || @seconds<120 #reveal random shapes at the start of the game for two seconds
          shape = Square.new(x: s_coord[0], y: s_coord[1], size: SIZE_SQUARE,color:$colors[arr[3]]) # get coordinates from the random array and color
        end
        draw_shapes_from_list(arr[2],arr[1],$colors[arr[3]])
      elsif arr[2]==1 #if shape type is equal to zero create a circle
        s_coord=$circle_array[arr[0]]#create square coordinates from square array randomized position
        if $block_array[arr[0]] || @seconds<120
          shape = Circle.new(x:s_coord[0], y: s_coord[1],radius:20,sections:32,color:$colors[arr[3]])
        end
        draw_shapes_from_list(arr[2],arr[1],$colors[arr[3]])
      else #if shape type is equal to zero create a triangle
        s_coord=$triangle_array[arr[0]]#create square coordinates from square array randomized position
        if $block_array[arr[0]] || @seconds<120
          shape = Triangle.new(
            x1: s_coord[0],  y1: s_coord[3],
            x2: s_coord[1], y2: s_coord[4],
            x3: s_coord[2],   y3: s_coord[5],color:$colors[arr[3]])
        end
        draw_shapes_from_list(arr[2],arr[1],$colors[arr[3]])
      end
      @match_elements=true
      end
      end

  end

  def draw_shapes_from_list(shape_type,position,color) # create another shape that will match the other shapes created previously(duplicates for purposes of matching)
    if $block_array[position] || @seconds<120 # display shapes at the start for two whole seconds
      if shape_type==0
        s_coord=$square_array[position]
        Square.new(x:s_coord[0], y: s_coord[1], size: SIZE_SQUARE, color: color)
      elsif shape_type==1
        s_coord=$circle_array[position]
        Circle.new(x:s_coord[0], y: s_coord[1],radius:20,sections:32, color: color)
      else
        s_coord=$triangle_array[position]
        Triangle.new(
          x1: s_coord[0],  y1: s_coord[3],
          x2: s_coord[1], y2: s_coord[4],
          x3: s_coord[2],   y3: s_coord[5],color: color)
      end
    end
  end


end

game = Game.new # create a game



update do #update every tick/frame
  unless game.finished?
    game.seconds+=1 # 1/60th of a second
    if game.seconds<120 # display shapes for two seconds
      Text.new("Memorize these shapes quickly!",x:Window.width/100*30,y:25,color:'red')
      game.draw_shapes
      game.randomize_shapes
      game.print_random_shapes
    else
      clear
      game.draw_shapes
      game.randomize_shapes
      game.print_random_shapes
      if game.unmatched
        game.text_no_match
      elsif
      game.matched
        game.text_match
      end
    end
  end
  if game.finished?
    clear
    Text.new("Game over! Completed in #{game.duration.round(3)} seconds",x:Window.width/100*30,y:25,color:'red')
    Text.new("Press 'R' to Try Again",x:Window.width/100*40,y:50,color:'red')
  end

end


on :key_down do |event|
  if game.finished? && event.key=='r' #restart game
    clear
    game = Game.new # create a new game
  end
end
on :mouse_down do |event|
  unless game.finished?
    game.activate_shape(event.x,event.y) # record mouse coodinates
    game.end_game
  end
end
show
