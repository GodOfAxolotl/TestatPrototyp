class Menu {

  MenuState state;

  Button[] mainMenu = new Button[5];
  Button[] controllsMenu = new Button[5];
  Button[] controllsMenuInGame = new Button[5];

  Button[] creditsMenu = new Button[3];
  Button[] creditsMenuInGame = new Button[3];

  Button[] pauseMenu = new Button[5];
  Button[] gameOverScreen = new Button[3];
  Button[] victoryScreen = new Button[3];



  Menu(MenuState state) {
    this.state = state;
    mainMenu[0] = new Button(width/3, height/2 - 200, 200, 50, "Start Game", 24);
    mainMenu[1] = new Button(width/3, height/2 - 100, 200, 50, "Controlls", 24);
    mainMenu[2] = new Button(width/3, height/2, 200, 50, "Credits", 24);
    mainMenu[3] = new Button(width/3, height/2 + 100, 200, 50, "Close Game", 24);
    mainMenu[4] = new Button(width/3, height/2 -300, 500, 60, "Destiny Sparrwo Race Demo", 36);

    pauseMenu[0] = new Button(width/3, height/2 - 200, 200, 50, "Continue Game", 24);
    pauseMenu[1] = new Button(width/3, height/2 - 100, 200, 50, "Restart Game", 24);
    pauseMenu[2] = new Button(width/3, height/2, 200, 50, "Controls", 24);
    pauseMenu[3] = new Button(width/3, height/2 + 100, 200, 50, "Credits", 24);
    pauseMenu[4] = new Button(width/3, height/2 + 200, 200, 50, "Close Game", 24);

    controllsMenu[0] = new Button(width/3, height/2 - 200, 300, 50, "WASD to move", 24);
    controllsMenu[1] = new Button(width/3, height/2 - 100, 300, 50, "Space to boost", 24);
    controllsMenu[2] = new Button(width/3, height/2, 300, 50, "Left Mouse button to shoot", 24);
    controllsMenu[3] = new Button(width/3, height/2 + 100, 300, 50, "---", 24);
    controllsMenu[4] = new Button(width/3, height/2 + 200, 300, 50, "Back", 24);

    controllsMenuInGame[0] = new Button(width/3, height/2 - 200, 300, 50, "WASD to move", 24);
    controllsMenuInGame[1] = new Button(width/3, height/2 - 100, 300, 50, "Space to boost", 24);
    controllsMenuInGame[2] = new Button(width/3, height/2, 300, 50, "Left Mouse button to shoot", 24);
    controllsMenuInGame[3] = new Button(width/3, height/2 + 100, 300, 50, "---", 24);
    controllsMenuInGame[4] = new Button(width/3, height/2 + 200, 300, 50, "Back", 24);

    creditsMenu[0] = new Button(width/3, height/2 - 200, 400, 50, "Gemacht von Gruppe-06", 24);
    creditsMenu[1] = new Button(width/3, height/2 - 150, 400, 50, "Liebe Grüße an Minas.", 24);
    creditsMenu[2] = new Button(width/3, height/2 - 50, 400, 50, "Zurück", 24);

    creditsMenuInGame[0] = new Button(width/3, height/2 - 200, 400, 50, "Gemacht von Gruppe-06", 24);
    creditsMenuInGame[1] = new Button(width/3, height/2 - 150, 400, 50, "Liebe Grüße an Minas.", 24);
    creditsMenuInGame[2] = new Button(width/3, height/2 - 50, 400, 50, "Zurück", 24);

    gameOverScreen[0] = new Button(width/3, height/2 - 200, 400, 80, "Game Over", 48);
    gameOverScreen[1] = new Button(width/3, height/2 - 100, 400, 50, "New Game", 24);
    gameOverScreen[2] = new Button(width/3, height/2 - 50, 400, 50, "Close Game", 24);

    victoryScreen[0] = new Button(width/3, height/2 - 200, 400, 80, "You're winner", 48);
    victoryScreen[1] = new Button(width/3, height/2, 400, 50, "Back to Main Menu", 24);
    victoryScreen[2] = new Button(width/3, height/2 + 100, 400, 50, "Close Game", 24);
  }


  void update() {
    switch(state) {
    case MAIN:
      if (mainMenu[0].isPressed()) {
        state = MenuState.INGAME;
      }
      if (mainMenu[1].isPressed()) {
        state = MenuState.CONTROLS;
      }
      if (mainMenu[2].isPressed()) {
        state = MenuState.CREDITS;
      }
      if (mainMenu[3].isPressed()) {
        exit();
      }
      break;
    case PAUSE:
      if (pauseMenu[0].isPressed()) {
        state = MenuState.INGAME;
      }
      if (pauseMenu[1].isPressed()) {
        setter();
        state = MenuState.INGAME;
      }
      if (pauseMenu[2].isPressed()) {
        state = MenuState.CONTROLSGAME;
      }
      if (pauseMenu[3].isPressed()) {
        state = MenuState.CREDITSGAME;
      }
      if (pauseMenu[4].isPressed()) {
        exit();
      }
      break;
    case LOST:
      if (gameOverScreen[1].isPressed()) {
        setter();
        state=MenuState.MAIN;
      }
      if (gameOverScreen[2].isPressed()) {
        exit();
      }
      break;
    case WON:
      if (victoryScreen[1].isPressed()) {
        state = MenuState.MAIN;
      }
      if (victoryScreen[2].isPressed()) {
        exit();
      }
      break;
    case CREDITS:
      if (creditsMenu[2].isPressed()) {
        state = MenuState.MAIN;
      }
      break;
    case CREDITSGAME:
      if (creditsMenuInGame[3].isPressed()) {
        state = MenuState.INGAME;
      }
      break;
    case CONTROLS:
      if (controllsMenu[4].isPressed()) {
        state = MenuState.MAIN;
      }
      break;
    case CONTROLSGAME:
      if (controllsMenuInGame[4].isPressed()) {
        state = MenuState.INGAME;
      }
      break;
    default:
      break;
    }
  }

  void render() {
    switch(state) {
    case MAIN:
      for (Button b : mainMenu) {
        b.render();
      }
      textSize(24);
      fill(0);
      text("Reach a score of " + winCondition +" before your opponent.\nBeware of his shots and the cold.\nWarum up by driving through \nthe orange heatfield.", width/2+100, height/2-200);
      break;
    case PAUSE:
      for (Button b : pauseMenu) {
        b.render();
      }
      break;
    case LOST:
      for (Button b : gameOverScreen) {
        b.render();
      }
      textSize(48);
      fill(0);
      if (guardian.HP <= 0) text("Your HP dropped to 0", width/2 -140, height/4);
      if (guardian.coldStack >= coldStackTime * 10) text("You died of the cold", width/2 - 100, height/4);
      if (speeder.score >= winCondition) text("Your opponent won", width/2 - 80, height/4);
      break;
    case WON:
      for (Button b : victoryScreen) {
        b.render();
      }
      break;
    case CREDITS:
      for (Button b : creditsMenu) {
        b.render();
      }
      break;
    case CREDITSGAME:
      for (Button b : creditsMenuInGame) {
        b.render();
      }
      break;
    case CONTROLS:
      for (Button b : controllsMenu) {
        b.render();
      }
      break;
    case CONTROLSGAME:
      for (Button b : controllsMenuInGame) {
        b.render();
      }
      break;
    default:
      break;
    }
  }
}
