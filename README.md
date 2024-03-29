# Verilog Implementation of the addictive mobile game, Snake

<img alt="GitHub License" src="https://img.shields.io/github/license/hankshyu/SnakeGame?color=orange&logo=github"> <img alt="GitHub release (latest SemVer)" src="https://img.shields.io/github/v/release/hankshyu/SnakeGame?color=orange&logo=github"> <img alt="GitHub language count" src="https://img.shields.io/github/languages/count/hankshyu/SnakeGame"> <img alt="GitHub top language" src="https://img.shields.io/github/languages/top/hankshyu/SnakeGame"> <img alt="GitHub code size in bytes" src="https://img.shields.io/github/languages/code-size/hankshyu/SnakeGame"> <img alt="GitHub contributors" src="https://img.shields.io/github/contributors/hankshyu/SnakeGame?logo=git&color=green"> <img alt="GitHub commit activity" src="https://img.shields.io/github/commit-activity/y/hankshyu/SnakeGame?logo=git&color=green">  <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/hankshyu/SnakeGame?logo=git&color=green">


## Nokia's Snake, an all time classic

After launching in 1997 on the Nokia 6110, Snake quickly became a phenomenon. The game’s developer Taneli Armanto discusses its origin and digital legacy.

Snake was a milestone moment for the mobile gaming industry, and much of what we see today can be linked back to the dawn of the cellular serpent navigating the small, black-and-white screen. It brought smiles, happiness, brain stimulation, and it was just something to do now and then – or better yet fill the time on a drab afternoon bus ride back from school. It also showed us what can be done on a phone, perhaps making us a little bit more demanding for future years to come. “The tiny details that were added in to make the players’ life easier, the lack of programming errors, the beauty of the source code; it was perfect,” says Taneli on a lasting note about the game’s iconic impact. “And sometimes, every now and then, I still play it myself.”

Ayla Angelos, 23 February 2021

## How to play??

### 1.Greetings

<p align="center">
  <img src="docs/welcome_gif.gif" alt="welcome_gif" width="550"> 
</p>

A green coloured snake greets the player, press any button would proceed to the level selection state.

### 2.Select your level to play

<p align="center">
  <img src="docs/select_gif.gif" alt="welcome_gif" width="550"> 
</p>

There are 3 levels to challange, with respective game time, player could hit buttons to switch between states and select them by pushing at the  select button. There's instrucion print on the bottom part of the screen. The threee levels are: 

|  Level 1   | Level 2  | Level 2  |
|:----:|:----:|:----:|
|60 seconds| 90 seconds| 105 seconds|
|![lv1](docs/lv1.png)  |![lv1](docs/lv2.png) |![lv1](docs/lv3.png) |


### 3.Play the game

The four buttons, representing going up, down, left and right manoeuvers the snake to avoid the wall and obstacles, If the snake ran into a wall, the Health Point would drop constantly (every second) until the game is over. The goal of the game is to collect as many points as possible, in ordrer to score points, you have to gather apples and cherries spread accross the entire map by running over them. Under the gaming page, there's a countdown clock at the left upper corner. The clock tells the remaining time player has got and would turn into vibrant red and start blinking when it reaches a final 10 second countdown.


Watch our demo video on <a href="https://www.youtube.com/watch?v=i1zptkf-Fc0&list=PLOxWswkzVO8c3qGFNfc3bdy-NcbLJj4Fx">
  <img src="docs/youtube_icon.png" alt="yt" width="25">
</a>

### 4.Game Over

The game ends if you smack the wall too often or the game time is up. Display shows scored points while player may choose to challagne the same level again immediately or return to the level selection state.

<p align="center">
<img src="docs/score.JPG" alt="score" width="550">
</p>

