# Chess 
A game of chess on the command line.

Completed as a capstone project of the Ruby course at [The Odin Project](https://www.theodinproject.com/lessons/ruby-ruby-final-project#assignment).
## How to Play
### Online
You can play the game on [Replit](https://replit.com/@thejwuscript/Chess).
### Local
First, make sure Ruby v2.7 or newer is installed. To verify, run `ruby -v` in the terminal. If Ruby installation is required, you can download it [here](https://www.ruby-lang.org/en/downloads/).

After Ruby is installed, clone this repo, navigate to the project's root folder and run `ruby lib/main.rb`
## Features
-   Classic rules of chess including [special moves](https://www.chess.com/terms/special-chess-moves):
	- Castling
	- Pawn promotion
	- En passant capture
-   Play against AI or another human player
-   Beginner-friendly chess move guides
-   Undo move selection
-   Save and load previous game
## Challenges
### Knowing Where to Begin
The very first challenge I faced was finding my bearings to build this project from the ground up with minimal guidance from the [project specification](https://www.theodinproject.com/lessons/ruby-ruby-final-project#assignment). I had a rough idea of what classes I needed, but I was unsure of which one to start working on. To make some visible progress, I decided to start with a model of the game board. Implementing the model was the low hanging fruit because the task was straightforward and I had a clear idea of the result I wanted: A board with all the pieces at their starting positions.

<img src="https://user-images.githubusercontent.com/88938117/200637857-3bf187ba-594e-4f8b-9ec3-7cd11475aab4.png" alt="board model" width="300px">

Because the board and pieces were just ANCI escape codes and Unicode symbols, I had a new task at hand; to make them come to life. At this point, I had some ideas of the behaviors I want for my Board class so this was a good start to writing my tests and begin the TDD process.
