/** //<>//
 *
 *TODO:
 *Refacture
 *Improve behavior so speeder doesnt leave map on y scale
 */

/**
 * CONFIG
 */
boolean controlled = true;
boolean debug = false;
boolean collision = true;
float coldStackTime = 1.7;
boolean boostMode = false;
boolean rails = true;
float baseAcc = 5.0;
int trailLength = 1000;
int trailIndex = 0;
int bulletSpeed = 400;
int winCondition = 25;
int fr = 60;
int w = 1200;
int h = 900;

Menu menu;
Guardian guardian;
Guardian speeder;

Obstacle obs1;
Obstacle obs2;

Heatfield heatfield;

Behavior behavior;
Behavior speederBehavior;
boolean wPressed, sPressed, aPressed, dPressed, spacePressed;

ArrayList<Projectile> projectiles = new ArrayList<Projectile>();
PVector[] trail = new PVector[trailLength];


void setup() {
  frameRate(60);
  size(1200, 900, P2D);
  smooth(16 );
  setter();
}

void setter() {
  background(255);
  menu = new Menu(MenuState.MAIN);
  guardian = new Guardian(new PVector(width/8, height/2));
  speeder = new Guardian(new PVector(width/8, height/2 + 30), false);
  for (int i = 0; i < trailLength; i++) {
    trail[i] = guardian.pos.copy();
  }
  heatfield = new Heatfield();
  randomizeObstacles();
  behavior = new Behavior(heatfield.pos, BehaviorState.SEARCHING);
  speederBehavior = new Behavior(new PVector(width/2 +30, height/2), BehaviorState.SEARCHING);
}

void draw() {
  background(240);
  switch(menu.state) {
  case INGAME:
    ingameUpdate();
    break;
  default:
    menu.render();
    menu.update();
    break;
  }
}


void ingameUpdate() {
  float dt = 1.0 / frameRate;
  guardian.tickBulletCooldown(dt);
  speeder.tickBulletCooldown(dt);
  guardian.tickColdStack(dt);

  if (guardian.coldStack >= coldStackTime * 10) {
    menu.state = MenuState.LOST;
  }

  if (spacePressed && !guardian.isBoosting()) {
    guardian.boosting();
  }

  if (dist(guardian.pos.x, guardian.pos.y, heatfield.pos.x, heatfield.pos.y) < 75 ) guardian.coldStack = 0;

  background(240);

  fill(0);
  textSize(18);
  text("FPS: " + 60, 10, 30);

  if (mousePressed && guardian.canShoot() && guardian.enabled) {
    float velx = cos(guardian.angle) * bulletSpeed * dt;
    float vely = sin(guardian.angle) * bulletSpeed * dt;
    projectiles.add(new Projectile(guardian.pos.x, guardian.pos.y, guardian.vel.x, guardian.vel.y, velx, vely, 0));
    guardian.bulletCooldown = 0;
  }

  if (speeder.canShoot() && speeder.pos.x + 5 < guardian.pos.x && speeder.score <= guardian.score && speeder.enabled) {
    PVector bVel = guardian.pos.copy().sub(speeder.pos).normalize().mult(dt).mult(bulletSpeed);
    projectiles.add(new Projectile(speeder.pos.x, speeder.pos.y, speeder.vel.x, speeder.vel.y, bVel.x, bVel.y, 1));
    speeder.bulletCooldown = 0;
  }

  if (controlled) {
    boolean[] c = {wPressed, sPressed, aPressed, dPressed};
    guardian.gameInput(c, dt);
  } else {
    boolean[] c = behavior.behavior(guardian.pos, guardian.vel, rails, guardian.angle);
    guardian.comController(c, dt);
  }

  boolean[] c = speederBehavior.behavior(speeder.pos, speeder.vel, true, speeder.angle);
  speeder.comController(c, dt);

  trail[trailLength - 1] = guardian.pos.copy();
  for (int i = 0; i < trailLength - 1; i++) {
    trail[i] = trail[i + 1];
  }
  noFill();
  stroke(255, 30, 105);
  strokeWeight(4);
  for (int i = 0; i < trailLength; i++) {
    point(trail[i].x, trail[i].y);
  }

  obs1.render();
  obs2.render();
  guardian.colideWithObstacles(1);
  speeder.colideWithObstacles(2);
  guardian.update(dt);
  guardian.render();
  speeder.update(dt);
  speeder.render();
  heatfield.render();

  for (Projectile p : new ArrayList<Projectile>(projectiles)) {
    p.update();
    p.render();
    if (dist(p.pos.x, p.pos.y, guardian.pos.x, guardian.pos.y) <= 20 && p.sender == 1) {
      guardian.HP--;
      if (guardian.HP <= 0) {
        menu.state = MenuState.LOST;
      }
      projectiles.remove(p);
    } else if (dist(p.pos.x, p.pos.y, speeder.pos.x, speeder.pos.y) <= 20 && p.sender == 0) {
      speeder.HP--;
      if (speeder.HP <= 0) {
        speeder = new Guardian(new PVector(width/8, height/2 + 30), false);
        speeder.enabled = false;
      }
      projectiles.remove(p);
    }
    if (p.pos.x < 0 || p.pos.x > width || p.pos.y < 0 || p.pos.y > height) {
      projectiles.remove(p);
    }
  }

  if (speeder.score >= winCondition) {
    menu.state = MenuState.LOST;
  } else if (guardian.score >= winCondition) {
    menu.state = MenuState.WON;
  }

  fill(255, 125, 0);
  drawBar(guardian.boostCharge, 20, 5);
  fill(255, 65, 35);
  drawBar(guardian.HP, 50, 10);
  fill(125, 125, 255);
  drawBar((float)int(guardian.coldStack / coldStackTime), 80, 10);
  fill(125, 65, 35);
  drawBar(guardian.bulletCooldown, 110, 2);
}

//------------------------------------------------------------------------------------

void randomizeObstacles() {
  obs1 = new Obstacle(height/4);
  obs2 = new Obstacle(height - height/4);
}

//------------------------------------------------------------------------------------

void drawBar(float value, float x, float scale) {
  stroke(0);
  strokeWeight(2);
  float barHeight = map(value, 0, scale, 0, 100);
  rect(x, height - 10 - barHeight, 20, barHeight);
}

//------------------------------------------------------------------------------------

void keyPressed() {
  if (key == 'w' || key == 'W') {
    wPressed = true;
    sPressed = false;
  } else if (key == 's' || key == 'S') {
    sPressed = true;
    wPressed = false;
  }
  if (key == 'a' || key == 'A') {
    aPressed = true;
    dPressed = false;
  } else if (key == 'd' || key == 'D') {
    dPressed = true;
    aPressed = false;
  }
  if (key == ' ') {
    spacePressed = true;
  }
  if (key == ESC) {
    key = 0;
  }
}

void keyReleased() {
  if ((key == 'w' || key == 'W') && !sPressed) {
    wPressed = false;
  }
  if ((key == 's' || key == 'S') && !wPressed) {
    sPressed = false;
  }
  if ((key == 'a' || key == 'A') && !dPressed) {
    aPressed = false;
  }
  if ((key == 'd' || key == 'D') && !aPressed) {
    dPressed = false;
  }
  if ((key == 'c' || key == 'C')) {
    for (int i = 0; i < trailLength; i++) {
      trail[i] = guardian.pos.copy();
    }
  }
  /*if ((key == 'm' || key == 'M')) {
   rails = !rails;
   }
   if ((key == 'b' || key == 'B')) {
   boostMode = !boostMode;
   }
  if ((key == 'q' || key == 'Q')) {
   controlled = !controlled;
   }*/
  if (key == ' ') {
    spacePressed = false;
  }
  if (key == ESC) {
    if (menu.state == MenuState.INGAME)
      menu.state = MenuState.PAUSE;
  }
}
