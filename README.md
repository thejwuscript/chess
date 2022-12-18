# Chess 
A game of chess on the command line.

Completed as a capstone project of the Ruby course at [The Odin Project](https://www.theodinproject.com/lessons/ruby-ruby-final-project).

Play the game on [Replit](https://replit.com/@thejwuscript/Chess) 👈

## Demo

<img src="https://user-images.githubusercontent.com/88938117/201371521-12d7fefd-66df-414b-b5b0-f9f286be00e4.gif" alt="demo" width="700"><br/>
<i>1-minute demo game featuring the [Scholar's Mate](https://en.wikipedia.org/wiki/Scholar%27s_mate)</i>

## Features
-   Classic rules of chess including [special moves](https://www.chess.com/terms/special-chess-moves):
	- Castling
	- Pawn promotion
	- En passant capture
-   Play against AI or another human player
-   Beginner-friendly chess move guides
-   Undo move selection
-   Save and load previous game

## Technologies Used
- Ruby
- RSpec
- Git
- Github
- Linux terminal
- VS Code
- Replit

## Challenges
### Knowing Where to Begin
The very first challenge I faced was finding my bearings to build this project from the ground up with minimal guidance from the [project specification](https://www.theodinproject.com/lessons/ruby-ruby-final-project#assignment). I had a rough idea of what classes I needed, but I was unsure of which one to start working on. To maximize productivity, I decided to start with what I thought was the easiest to accomplish at the time; modelling the game board. Implementing the model was straightforward because I had a clear idea of the result I wanted, which was a board with all the pieces at their starting positions.

<img src="https://user-images.githubusercontent.com/88938117/200637857-3bf187ba-594e-4f8b-9ec3-7cd11475aab4.png" alt="board model" width="300">

After seeing it visually on the terminal, I started having ideas of what methods to define in the Board class. It was a good moment to write my first test and begin the test-driven development(TDD) process.

### Searching for Possible Moves
Generating a list of possible moves for a piece like bishop was relatively simple, but it quickly became complicated for a piece that has different move patterns, particularly the pawn. I will briefly describe the process in generating pawn movements below.

<img src="https://user-images.githubusercontent.com/88938117/200793310-3251cd99-3cdf-4361-aa44-a07430a1f42c.png" alt="bishop path" width="300"> <img src="https://user-images.githubusercontent.com/88938117/200790192-757b99b6-ea00-493a-8ffb-029ed600c41b.png" alt="pawn path" width="300">

First, I came up with all the different scenarios in which the pawn's movement can change.
1. By default, the pawn can move forward one step.
2. When the pawn has not moved from its initial position, it can move forward two steps (ie. double step).
3. It can move diagonally forward to capture when:
	- An enemy piece is present at the square.
	- An enemy pawn just performed double step and is adjacent (ie. en passant)

The scenario for en passant capturing move was broken down further into 4 key conditions:

<img src="https://user-images.githubusercontent.com/88938117/200894903-8ef506ec-6da5-4a84-a803-ba4385f8cf7a.png" alt="en passant condition" width="450">

Because the logic for en passant itself was quite complex and required several pieces of data, I created a new class ```EnPassantChecker``` that encapsulated the data and abstracted the logic. I then defined the core logic for each of the scenarios in pseudo code:

```ruby
# For a Black pawn,
# Initialize an array called possible_moves
# Add the results below to possible_moves:
#
# Offset self.position by [1, 0]
# Offset self.position by [2, 0] if self.position == self.initial_position and add it to possible_moves
# Capturing move:
#   Offset self.position by [1, 1] || [1, -1] if board.piece_at(offset_position).color != self.color
#   Offset self.position by [1, 1] || [1, -1] if EnPassantChecker.new.valid_capture_condition?
#
# Return possible_moves
```
By breaking things down into manageable parts, I was able to keep myself organized and implement the logic step by step. 

### Cloning the Board
I wanted to capture the state of the board along with the chess pieces by cloning the board. The board has a grid attribute that contains all the active chess pieces in a 2d array:
```ruby
class Board
  def initialize
    @grid = Array.new(8) { Array.new(8) } # chess pieces in the array
    ...
  end
end
```
At first, I tried to copy the board with #clone:
```ruby
cloned_board = board.clone
```
But I whenever I changed the state of any chess piece on the cloned board, it also changed the state of the original piece. This was not the desired behaviour.
I found out that the method #clone only makes a shallow copy of an object. This meant that it did not clone the chess pieces but only stored references to the original pieces. I confirmed it by checking the object id of a cloned piece against the original, and indeed they were the same.

I then tried to create a deep copy of the board by marshalling and unmarshalling the board object, as suggested by a [post on Stack Overflow](https://stackoverflow.com/questions/8206523/how-to-create-a-deep-copy-of-an-object-in-ruby):
```ruby
cloned_board = Marshal.load(Marshal.dump(board))
```
It was a successful copy, as I could make any changes on the cloned board without affecting the original.

## Future Additions
- [ ] Rework AI to use minimax algorithm
- [ ] More specific error messages
- [ ] More save slots
