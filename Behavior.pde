class Behavior {
  BehaviorState state = BehaviorState.SEARCHING;
  PVector desire;
  float prevError = 0;
  float integral = 0;
  float derivative = 0;

  Behavior(PVector desire, BehaviorState state) {
    this.state = state;
    this.desire = desire;
  }

  boolean[] behavior(PVector pos, PVector vel, boolean rails, float an) {
    boolean[] result = new boolean[4];
    //desire = desideria.copy();
    float distance = dist(pos.x, pos.y, desire.x, desire.y);

    result[0] = true;//Turn up
    result[1] = false;//Turn down
    result[2] = false; //Turn left
    result[3] = false;//Turn right

    if (rails) {
      if (desire.x < pos.x) {
        desire = new PVector(width, height/2);
        distance = dist(pos.x, pos.y, desire.x, desire.y);
      }
      if (distance > 10) {
        float angle = atan2(desire.y - pos.y, desire.x - pos.x);
        float angleDiff = angle - an;
        if (angleDiff > PI) {
          angleDiff -= TWO_PI;
        } else if (angleDiff < -PI) {
          angleDiff += TWO_PI;
        }
        float angleThreshold = radians(2);
        if (abs(angleDiff) > angleThreshold) {
          if (angleDiff > 0) {
            result[3] = true; // Turn left
          } else {
            result[2] = true; // Turn right
          }
        }
      }
    } else {
      result[0] = false;
      switch(state) {
      case HALTING:
        //result = halt(pos, vel);
        break;
      case ADJUSTING:
        //result = turnTo(pos, desire, an, turnVel); //LEAVE THE SCREEN
        break;
      case NAVIGATE:
        result = moveTo(pos, desire, vel); //LEAVE THE SCREEN
        break;
      case SEARCHING:
        //result = turnTo(pos, desire, an, turnVel);
        break;
      case MOVING:
        result = moveTo(pos, desire, vel);
        break;
      case LEAVE:
        desire = new PVector(width, height/2);
        if (state == BehaviorState.MOVING) {
          state = BehaviorState.ADJUSTING;
        } else {
          state = BehaviorState.SEARCHING;
        }
        break;
      }
    }
    return result;
  }

  public boolean[] turnTo(PVector pos, PVector desire, float angle, float currTurnVel) {
    boolean[] result = new boolean[4];
    for (int i = 0; i < 4; i++) {
      result[i] = false;
    }
    float epsilon = 0.005;
    float desiredAngle = atan2(desire.y - pos.y, desire.x - pos.x);
    float error = desiredAngle - (angle);
    ellipse(desire.x, desire.y, 20, 20);
    PVector err = PVector.fromAngle(error);
    stroke(0);
    err.mult(100);
    line(pos.x, pos.y, pos.x - err.x, pos.y - err.y);
    line(pos.x, pos.y, desire.x, desire.y);

    integral += error;
    derivative = error - prevError;

    PVector param = new PVector(0.1, 0.00, 5.02); //Regelungszeit unter Beschleunigung: ca 6.04s
    PVector controlValue = new PVector(error, integral * -1, derivative);

    float turnVel = param.dot(controlValue);

    println(
      "Desired Angle" + desiredAngle + "\n" +
      "Current Angle" + angle + "\n" +
      "Error: " + error + "\n" +
      "p: " + controlValue.x + " | i: " + controlValue.y + " | d: " + controlValue.z + "\n" +
      "turnVel: " + turnVel + "\n" +
      "currTurnVel: " + currTurnVel
      );
    if (turnVel > 0) {
      result[3] = true;
    } else if (turnVel < 0) {
      result[2]= true;
    }
    prevError = error;
    println(abs(currTurnVel) <= 0.0001, turnVel <= epsilon/100, abs(error) <= epsilon);
    if ( turnVel <= epsilon/100 && abs(error) <= epsilon*5) {
      state = BehaviorState.MOVING;
    }
    println(result);

    return result;
  }

  //-----------------------------------------------------------------

  public boolean[] moveTo(PVector pos, PVector desire, PVector vel) {
    boolean[] result = new boolean[4];
    for (int i = 0; i < 4; i++) {
      result[i] = false;
    }
    ellipse(desire.x, desire.y, 20, 20);
    stroke(0);
    line(pos.x, pos.y, desire.x, desire.y);
    float error = pos.dist(desire);
    if (pos.x > desire.x) error *= -1;

    integral += error;
    derivative = error - prevError;

    PVector param = new PVector(0.01, 0.01, 0.45);
    PVector controlValue = new PVector(error, integral, derivative);

    float moveVel = param.dot(controlValue);

    println(
      "Error: " + error + "\n" +
      "p: " + controlValue.x + " | i: " + controlValue.y + " | d: " + controlValue.z + "\n" +
      "MoveVel: " + moveVel + "\n" +
      "Pos: " + pos.toString() + " " + pos.mag() + "\n" +
      "Des: " + desire.toString() + " " + desire.mag() + "\n" +
      "Vel: " + vel.toString() + " " + vel.mag()
      );

    if (moveVel > 0 ) {
      result[0] = true;
    } else if (moveVel < 0) {
      result[1]= true;
    }
    if (error <= 30 && vel.mag()<0.1) {
      state = BehaviorState.LEAVE;
    }
    prevError = error;
    println(result);

    return result;
  }
  //----------------------------------------------------------------------------




  //----------------------------------------------------------------------------

  public float pid(float Kp, float proportion, float Ki, float integral, float Kd, float deriviative) {
    Kp = 0.1;  // Proportionalwert
    Ki = 0.09979; // Integralwert
    Kd = 0.01; // Differenzialwert
    float p = Kp * proportion;
    float i = Ki * integral *-1;
    float d = Kd * deriviative;
    println("P: "+ p + " | I: " + i + " | D: " + d);
    return p+i+d;
  }

  public float pid(PVector param, PVector controlValue) {
    //println(param.dot(controlValue));
    return param.dot(controlValue);
  }
}
