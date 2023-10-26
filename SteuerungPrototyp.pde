/** //<>// //<>//
 *
 *TODO:
 *Refacture
 *Improve behavior so speeder doesnt leave map on y scale
 */


boolean controlled = false;

int move = 0;
int turn = 0;

PVector pos;
PVector vel;
float maxVel = 7;
float baseMaxVel = 7;
float boostFactor = 1.3;
float turnVel = 0;
float turnAcc = 0.2;
float turnspeed = 100;
float acc = 5.0;
float friction = 0.001;
float angle = 0;
float rotationFactor = 0.63;

Obstacle obs1;
Obstacle obs2;

Heatfield heatfield;

float boostCharge = 0;
boolean boosting = false;

boolean boostMode = false;

float coldStack = 0;
float coldStackTime = 3;

float bulletCooldown = 0;

boolean wPressed, sPressed, aPressed, dPressed, spacePressed;
boolean rails = false;

ArrayList<Projectile> projectiles = new ArrayList<Projectile>();

int trailLength = 10000;
int trailIndex = 0;
PVector[] trail = new PVector[trailLength];

Behavior behavior;

void setup() {
  frameRate(60);
  size(1200, 900, P2D);
  background(255);
  smooth(16);
  pos = new PVector(width/8, height/2);
  for (int i = 0; i < trailLength; i++) {
    trail[i] = pos.copy();
  }
  vel = new PVector(0, 0);

  heatfield = new Heatfield();
  randomizeObstacles();
  behavior = new Behavior(heatfield.pos, BehaviorState.SEARCHING);
}

void draw() {
  float dt = 1.0 / frameRate;
  println("DT: " + dt);
  println(frameRate);
  bulletCooldown += dt;
  coldStack += dt;
  if (bulletCooldown >= 2) bulletCooldown = 2;
  if (coldStack >= coldStackTime * 10) {
    coldStack = coldStackTime * 10;
  }

  if (spacePressed && boostCharge >= 2 && !boostMode) {
    boosting = true;
  } else if (spacePressed && boostCharge >= 5 && boostMode) {
    boosting = true;
  }
  if (boosting) {
    maxVel = baseMaxVel * boostFactor;
    acc = 8.0;
    boostCharge -= dt;
    if (boostCharge <= 0) {
      boostCharge = 0;
      boosting = false;
      acc = 4.0;
    }
  } else {
    if (maxVel > baseMaxVel) maxVel -= dt;
    if (maxVel < baseMaxVel) maxVel = baseMaxVel;
    boostCharge += dt;
    if (boostCharge >= 5) boostCharge = 5;
  }

  if (dist(pos.x, pos.y, heatfield.pos.x, heatfield.pos.y) < 75 ) coldStack = 0;

  background(240);

  if (coldStack >= coldStackTime * 10) {
    textSize(24);
    fill(255, 0, 0);
    text("You're cold mate", width / 2, height / 2);
  }


  obs1.render();
  obs2.render();

  fill(0);
  textSize(18);
  text("Press M to toggle rail mode. Currently on rail: " + rails, 10, 20);
  text("Press B to toggle rail boost. Currently fix boost: " + boostMode, 10, 40);
  text("Press C to clear trail, Press Q to control yourself.", 10, 60);
  text(behavior.state.toString(), 10, 100);
  text(vel.toString(), 10, 80);

  if (mousePressed && bulletCooldown >= 2) {
    float velx = cos(angle) * 500 * dt;
    float vely = sin(angle) * 500 * dt;
    Projectile p = new Projectile(pos.x, pos.y, vel.x, vel.y, velx, vely);
    projectiles.add(p);
    bulletCooldown = 0;
  }
  if (controlled) {
    if (aPressed) {
      if (rails) {
        angle -= radians(2) * turnspeed * dt;
        vel.rotate(-radians(2) * turnspeed * rotationFactor * dt);
      } else {
        turnVel -= turnAcc * dt;
      }
    }
    if (dPressed) {
      if (rails) {
        angle += radians(2) * turnspeed * dt;
        vel.rotate(radians(2) * turnspeed * rotationFactor * dt);
      } else {
        turnVel += turnAcc * dt;
      }
    }
    if (wPressed) {
      vel.x += cos(angle) * acc * dt;
      vel.y += sin(angle) * acc * dt;
    }
    if (sPressed) {
      vel.x -= cos(angle) * acc * dt;
      vel.y -= sin(angle) * acc * dt;
    }
    if (!rails) {
      angle += turnVel *dt;
    }
  } else {
    boolean[] controller = behavior.behavior(pos, vel, rails, angle);
    if (controller[2]) {
      if (rails) {
        angle -= radians(2) * turnspeed * dt;
        vel.rotate(-radians(2) * turnspeed * rotationFactor * dt);
      } else {
        turnVel -= turnAcc * dt;
      }
    }
    if (controller[3]) {
      if (rails) {
        angle += radians(2) * turnspeed * dt;
        vel.rotate(radians(2) * turnspeed * rotationFactor * dt);
      } else {
        turnVel += turnAcc * dt;
      }
    }
    if (controller[0]) {
      vel.x += cos(angle) * acc * dt;
      vel.y += sin(angle) * acc * dt;
    }
    if (controller[1]) {
      vel.x -= cos(angle) * acc * dt;
      vel.y -= sin(angle) * acc * dt;
    }
    if (!rails) {
      angle += turnVel *dt;
    }
  }

  vel.mult(1-friction);
  vel.x = constrain(vel.x, -maxVel, maxVel);
  vel.y = constrain(vel.y, -maxVel, maxVel);

  pos.add(vel);

  if (pos.x > width ||!controlled && pos.x > width -10) {
    pos.x = 0;
    heatfield = new Heatfield();
    randomizeObstacles();
    //behavior = new Behavior(heatfield.pos, BehaviorState.HALTING);
  } else if (pos.x < 0 && controlled) {
    pos.x = width;
  } else if (pos.y > height) {
    //vel.y = vel.y * -1;
    pos.y = 0;
  } else if ( pos.y < 0) {
    //vel.y = vel.y * -1;
    pos.y = height;
  }

  loadPixels();
  if (get(Math.round(pos.x), Math.round(pos.y)) == color(1)) {
    //vel.mult(-1);
    //pos.add(vel);
  }

  trail[trailLength - 1] = pos.copy();
  for (int i = 0; i < trailLength - 1; i++) {
    trail[i] = trail[i + 1];
  }
  noFill();
  stroke(255, 30, 105);
  strokeWeight(4);
  for (int i = 0; i < trailLength; i++) {
    point(trail[i].x, trail[i].y);
  }
  strokeWeight(1);

  pushMatrix();
  translate(pos.x, pos.y);
  rotate(angle);
  fill(51, 109, 167);
  noStroke();
  if (boosting) fill(235, 190, 23);
  ellipse(0, 0, 60, 20);
  triangle(0, 18, 40, 0, 0, -18);
  popMatrix();
  

  for (Projectile p : projectiles) {
    p.update();
    p.anzeigen();
  }

  for (int i = projectiles.size() - 1; i >= 0; i--) {
    Projectile p = projectiles.get(i);
    if (p.pos.x < 0 || p.pos.x > width || p.pos.y < 0 || p.pos.y > height) {
      projectiles.remove(i);
    }
  }

  PVector richtung = new PVector(mouseX - pos.x, mouseY - pos.y);
  float winkel = atan2(richtung.y, richtung.x);

  pushMatrix();
  noFill();
  stroke(0);
  strokeWeight(2);
  //rotate(HALF_PI);
  arc(pos.x, pos.y, 100, 100, winkel - HALF_PI / 2, winkel + HALF_PI);
  popMatrix();

  fill(255, 125, 0);
  drawBar(boostCharge, 20, 5);
  fill(125, 125, 255);
  drawBar((float)int(coldStack / coldStackTime), 50, 10);
  fill(255, 65, 35);
  drawBar(bulletCooldown, 80, 2);

  heatfield.render();
}

//------------------------------------------------------------------------------------

void randomizeObstacles() {
  obs1 = new Obstacle(height/4);
  obs2 = new Obstacle(height - height/4);
}

//------------------------------------------------------------------------------------

void drawBar(float value, float x, float scale) {
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
  if ((key == 'm' || key == 'M')) {
    rails = !rails;
  }
  if ((key == 'b' || key == 'B')) {
    boostMode = !boostMode;
  }
  if ((key == 'c' || key == 'C')) {
    for (int i = 0; i < trailLength; i++) {
      trail[i] = pos.copy();
    }
  }
  if ((key == 'q' || key == 'Q')) {
    controlled = !controlled;
  }
  if (key == ' ' && boosting && !boostMode) {
    spacePressed = false;
    boosting = false;
    acc = 4.0;
  } else if (key == ' ' && boosting) {
    spacePressed = false;
  } else if (key == ' ') {
    spacePressed = false;
  }
}
