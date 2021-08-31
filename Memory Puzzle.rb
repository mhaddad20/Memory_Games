require 'ruby2d'

set width:800
set height:600
set background:'white'

$colors=["navy","aqua","teal","olive", "green", "lime", "yellow", "orange","red", "brown", "fuchsia",
         "purple","maroon","black"]


WIDTH=((Window.width-20)/100).floor
SHAPE_POSITION_Y_START = 0
SHAPE_POSITION_X_START= 50
SHAPE_POSITION_Y_END = 50
SHAPE_POSITION_X_END=100

NUM_SQUARES = 20
SIZE_SQUARE=45


class Game
  attr_reader :finished
  attr_reader :seconds
  attr_writer :seconds
  attr_reader :matched
  attr_reader :unmatched
  attr_reader :duration
  attr_writer :start_time
  attr_reader :start_time
  attr_writer :duration
  def initialize

    $square_array=[]
    $circle_array=[]
    $triangle_array=[]
    $array_filled = []
    $block_array=[]
    $finished_array=[]
    $eliminate_shapes=[]
    $arr=[]
    $arr_finished_position=[]
    $array_match_shapes=[]
    for a in 0..NUM_SQUARES/2-1
      $array_filled.push(false)
      $block_array.push(false)
      $eliminate_shapes.push(false)
      $array_match_shapes.push([])
      $finished_array.push(false)
    end
    $random_array=[]
    $colors_match_array=[]
    @seconds=0
    @duration = 0
    @start_time = Time.now

    @add_elements=false
    @match_elements=false
    @shape_click=0
    @matched=false
    @unmatched=false
    @unmatched_time=0
    @matched_time=0
    @finished=false
    @shape=Square.new(x:0,y:0,color:'white')
    @text=Text.new("")

  end
  def set_all_shapes_to_hide
    for a in 0..$block_array.size-1
      $block_array[a]=false
    end
  end

  def text_no_match
    Text.new("No Match! Try Again.",x:Window.width/100*30,y:25,color:'red')
  end
  def text_match
    Text.new("Match! Well done!",x:Window.width/100*30,y:25,color:'red')
  end


  def hide_matched_shape
    for a in 0..$block_array.size-1
      if $block_array[a]
        $eliminate_shapes[a]=true
      end
    end
  end
  def finished?
    @finished
  end
  def end_game
    if $finished_array.all?{|x|x==true}
      @duration=Time.now-@start_time
      @finished=true
    end
  end

  def shapes_match?
    $arr[0]==$arr[1]
  end

  def activate_shape(x,y)
    for a in 0..$square_array.size-1
      new_square=$square_array[a]
      @shape=Square.new(x:new_square[0],y:new_square[1],size:SIZE_SQUARE)
      if @shape.contains?(x,y) && $finished_array[a]==false
        if $block_array[a]==false
          @shape_click+=1
          $arr.push($array_match_shapes[a])
          $arr_finished_position.push(a)
        end

          $block_array[a]=true

        if@shape_click%2==0
          if shapes_match?
            hide_matched_shape
            $finished_array[$arr_finished_position[0]]=true
            $finished_array[$arr_finished_position[1]]=true
            @matched=true
            @matched_time=0
          else
            @unmatched=true
            @unmatched_time=0
          end
          $arr=[]
          $arr_finished_position=[]
        end
      else
        @text.remove
        #$block_array[a]=false
        if @shape_click%2==0
          set_all_shapes_to_hide
        end
      end
      @shape.remove
    end
  end


  def draw_shapes
    @unmatched_time+=1
    @matched_time+=1
    if @unmatched_time>=30
      @unmatched=false
    end
    if @matched_time>=30
      @matched=false
    end
    x1=SHAPE_POSITION_X_START
    y1=SHAPE_POSITION_Y_START
    x2=SHAPE_POSITION_X_END
    y2=SHAPE_POSITION_Y_END
    for a in 0..NUM_SQUARES/2-1
      if a%WIDTH==0
        y1+=75
        y2+=75
        x1=SHAPE_POSITION_X_START
        x2=SHAPE_POSITION_X_END
      end
      if @add_elements==false
        $square_array.push([x1,y1,SIZE_SQUARE])
        $circle_array.push([x1+20,y1+20,20,32])
        $triangle_array.push([(x1+x2)/2,x1,x2,y1,y2,y2])
      end
      @shape=Square.new(x:x1,y:y1,size:SIZE_SQUARE,color:'blue')
      if $block_array[a] || $eliminate_shapes[a]|| @seconds<120
        @shape.opacity=0
      end




      x1+=Window.width/WIDTH
      x2+=Window.width/WIDTH
    end
    @add_elements=true
  end


  def randomize_shapes

    for a in 0..NUM_SQUARES/2-1
      if $array_filled[a]==false
        $array_filled[a]=true
        x= rand(a..NUM_SQUARES/2)#create shape in a random position
        while $array_filled[x]!=false
          x= rand(a..NUM_SQUARES/2)
        end
        $array_filled[x]=true
        match_array=[a,x]
        y=rand(3)#create shape based on number generated
        random_color = rand($colors.size)#generate color number from array
        arr=[a,x,y,random_color]
        $random_array.push(arr)
        $colors_match_array.push(match_array)
        $array_match_shapes[a].push(y,random_color)
        $array_match_shapes[x].push(y,random_color)
      end
    end
  end


  def print_random_shapes
    #arr=[a,x,y,random_color]
    for a in 0..$random_array.size-1
      arr=$random_array[a]
      if $finished_array[arr[0]]==false && $finished_array[arr[1]]==false
      if arr[2]==0
        s_coord=$square_array[arr[0]]#create square coordinates from square array randomized position
        if $block_array[arr[0]] || @seconds<120
          shape = Square.new(x: s_coord[0], y: s_coord[1], size: SIZE_SQUARE,color:$colors[arr[3]])
        end
        draw_shapes_from_list(arr[2],arr[1],$colors[arr[3]])
      elsif arr[2]==1
        s_coord=$circle_array[arr[0]]#create square coordinates from square array randomized position
        if $block_array[arr[0]] || @seconds<120
          shape = Circle.new(x:s_coord[0], y: s_coord[1],radius:20,sections:32,color:$colors[arr[3]])
        end
        draw_shapes_from_list(arr[2],arr[1],$colors[arr[3]])
      else
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

  def draw_shapes_from_list(shape_type,position,color)
    if $block_array[position] || @seconds<120
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

game = Game.new



update do
  unless game.finished?
    game.seconds+=1
    if game.seconds<120
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
  if game.finished? && event.key=='r'
    clear
    game = Game.new
  end
end
on :mouse_down do |event|
  unless game.finished?
    game.activate_shape(event.x,event.y)
    game.end_game
  end
end
show
