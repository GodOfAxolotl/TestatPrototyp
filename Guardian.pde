class Guardian {
  PVector pos;
  PVector vel;
  float maxVel = 7;
  float baseMaxVel = 7;

  float boostFactor = 1.3;
  float turnVel = 0;
  float turnAcc = 4.2;
  float turnspeed = 100;
  float acc = baseAcc;
  float friction = 0.001;
  float angle = 0;
  float rotationFactor = 0.63;
  float boostCharge = 0;
  boolean boosting = false;
  float coldStack = 0;
  float bulletCooldown = 0;
  int score;

  int HP = 10;
  boolean enabled = true;

  boolean reactive = true;


  int move = 0;
  int turn = 0;

  Guardian(PVector pos) {
    this.pos = pos.copy();
    this.vel = new PVector(0, 0);
  }

  Guardian(PVector pos, boolean reactive) {
    this.pos = pos.copy();
    this.vel = new PVector(0, 0);
    this.reactive = reactive;
  }

  void update(float dt) {
    if (!enabled) return;
    if (boosting) {
      boostCharge -= dt;
      if (boostCharge <= 0) {
        boostCharge = 0;
        boosting = false;
        acc = baseAcc;
      }
    } else {
      if (maxVel > baseMaxVel) maxVel -= dt;
      if (maxVel < baseMaxVel) maxVel = baseMaxVel;
      boostCharge += dt;
      if (boostCharge >= 5) boostCharge = 5;
    }

    vel.mult(1-friction);
    vel.x = constrain(vel.x, -maxVel, maxVel);
    vel.y = constrain(vel.y, -maxVel, maxVel);
    pos.add(vel);

    if (pos.x > width) {
      score++;
      pos.x = 0;
      if (reactive) {
        heatfield = new Heatfield();
        randomizeObstacles();
      } else {
        speederBehavior = new Behavior(new PVector(width/2, height/2 + random(-50, 50)), BehaviorState.SEARCHING);
      }
    } else if (pos.x < 0) {
      pos.x = 0;
    } else if (pos.y > height) {
      pos.y = height;
    } else if ( pos.y < 0) {
      pos.y = 0;
    }
  }

  void colideWithObstacles(int tollerance) {
    loadPixels();
    if (collision && get(Math.round(pos.x), Math.round(pos.y)) == color(tollerance)) {
      pos.sub(vel);
      vel.mult(-0.4);
      pos.add(vel);
    }
  }

  void gameInput(boolean[] buttons, float dt) {
    if (buttons[2]) {
      if (rails) {
        angle -= radians(2) * turnspeed * dt;
        vel.rotate(-radians(2) * turnspeed * rotationFactor * dt);
      } else {
        turnVel -= turnAcc * dt;
      }
    }
    if (buttons[3]) {
      if (rails) {
        angle += radians(2) * turnspeed * dt;
        vel.rotate(radians(2) * turnspeed * rotationFactor * dt);
      } else {
        turnVel += turnAcc * dt;
      }
    }
    if (buttons[0]) {
      vel.x += cos(angle) * acc * dt;
      vel.y += sin(angle) * acc * dt;
    }
    if (buttons[1]) {
      vel.x -= cos(angle) * acc * dt;
      vel.y -= sin(angle) * acc * dt;
    }
    if (!rails) {
      angle += turnVel *dt;
    }
  }

  void comController(boolean[] controller, float dt) {
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

  void render() {
    if (!enabled) return;
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle); 
    fill(floor(constrain(27 + coldStack * 1/coldStackTime * 10, 0, 210)),
      floor(constrain(109 + coldStack * 1/coldStackTime * 10, 0, 210)),
      floor(constrain(167 + coldStack * 1/coldStackTime * 10, 0, 255)));
    noStroke();
    if (boosting) fill(235, 190, 23);
    if (!reactive) fill(90, 12, 121);
    ellipse(0, 0, 60, 20);
    triangle(0, 18, 40, 0, 0, -18);
    popMatrix();

    if (reactive) {
      PVector richtung = new PVector(mouseX - pos.x, mouseY - pos.y);
      float winkel = atan2(richtung.y, richtung.x);
      pushMatrix();
      noFill();
      stroke(0);
      strokeWeight(2);
      arc(pos.x, pos.y, 100, 100, winkel - HALF_PI / 2, winkel + HALF_PI);
      popMatrix();
    }

    fill(0);
    textSize(20);
    if (reactive) {
      text("Guardian Score: " + score, width - 200, 40);
    } else {
      text("Speeder Score: " + score, width - 200, 70);
    }
  }

  void tickBulletCooldown(float time) {
    bulletCooldown += time;
    if (bulletCooldown >= 2) bulletCooldown = 2;
  }

  void tickColdStack(float time) {
    coldStack += time;
    if (coldStack >= coldStackTime * 10) coldStack = coldStackTime * 10;
  }

  void boosting() {
    if (boostCharge >= 5)
    {
      boosting = true;
      maxVel = baseMaxVel * boostFactor;
      acc = 8.0;
    }
  }

  boolean canShoot() {
    return bulletCooldown >= 2;
  }

  boolean isBoosting() {
    return boosting;
  }
}
