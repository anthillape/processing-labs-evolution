/*
to add
  sensing predators and avoiding, especially when they are hunting?
  set up some initial populations with, for instance different sensor types
  set up genes that can switch on / off completely or randomise from a genetic float value, eg. ( onGene > offGene ? true : false )
  add strength param? maybe offense defence?
  add stomach size param and multiply by size?
  add egg phase + egg eaters?
  make difference in color represent difference in genetic makeup from parents : add up changes then change each color by that amount * random

*/

ArrayList critters;
ArrayList foods;
int foodSpawnRate;
float mutationRate;
int startNumCritters;
float breedingEfficiency;
float meatEatingEfficiency;
float vegEnergyPerRadius;
float maxEnergyMultiplier;
float rudderMax;
boolean ageingEnabled;

void setup()
{
  size( 1400,720 );
  smooth();
  strokeWeight(3);
  breedingEfficiency = .7;
  meatEatingEfficiency = 0.2;
  ageingEnabled = true;
  startNumCritters = 60;
  rudderMax = .02;
  foodSpawnRate = 1;
  mutationRate = 1.0;
  vegEnergyPerRadius = 10;
  maxEnergyMultiplier = 2;
  critters = new ArrayList();
  foods = new ArrayList();
  spawnFood(400);
  spawnCritters();
  cleanupCritters();
}

void draw()
{
  background(0);
  spawnFood(foodSpawnRate);
  drawRelationships();
  drawFood();
  metaboliseCritters();
  drawCritters();
  cleanupCritters();
}

void spawnFood( int rate )
{
  for ( int i = 0; i < rate; i++ )
  {
    Food food = new Food(random(width),random(height));
    foods.add( food );
  }
}

void drawRelationships()
{
  int numCritters = critters.size() - 1;
  for ( int i = numCritters; i >= 0; i-- )
  {
    Critter critter = (Critter) critters.get(i);
     //visualise families
    for ( int j = numCritters; j >= 0; j-- )
    {
      Critter otherCritter = (Critter) critters.get(j);
      if( otherCritter.parent == critter )
      {
        //show parent relationships
        strokeWeight(2);
        stroke(critter.genome.r, critter.genome.g, critter.genome.b, 50 );
        line(critter.x,critter.y,otherCritter.x,otherCritter.y); 
      }
      else if( otherCritter.parent == critter.parent && critter.parent != null )
      {
        //show sibling relationships
        strokeWeight(1);
        stroke(critter.genome.r, critter.genome.g, critter.genome.b, 50 );
        line(critter.x,critter.y,otherCritter.x,otherCritter.y); 
      } 
    }
    
    //veg sensor blips
    noFill();
    strokeWeight(1);
    if( critter.senseVeg > 0 )
    {
      stroke(#00ff00,critter.senseVeg * 10);
      float senseRadius = critter.genome.sensorVegRadius * 2 - critter.senseVeg * 2;
      ellipse(critter.x,critter.y,senseRadius,senseRadius);
      ellipse(critter.x,critter.y,senseRadius,senseRadius);
      if( critter.targetVeg != null )
      {
         stroke(#00ff00,225);
          line(critter.x,critter.y,critter.targetVeg.x,critter.targetVeg.y);
      }
    }
  }
  
  
}

void drawFood()
{
  noStroke();
  fill(0xff225500);
  int numFoods = foods.size();
  for ( int i = 0; i < numFoods; i++ )
  {
    Food food = (Food) foods.get(i);
    float r = food.radius * 2;
    ellipse(food.x,food.y,r,r);
  }
}

void spawnCritters()
{
  for ( int i = 0; i < startNumCritters; i++ )
  {
    float deathAge = random(6000);
    float adultAge = random( deathAge / 6 );
    float energyToSpawn = random( 200 );
    float energy = random(energyToSpawn * maxEnergyMultiplier);
    float spawnEnergy = random(energyToSpawn / 2);
    float radius = random(5)+9;
    float speed = random(4);
    float sensorVegRadius = random(radius*8) + radius * 4;
    float sensorVegFrequency = 60 + random(30);
    float sensorMeatRadius = random(radius*8) + radius * 4;
    float sensorMeatFrequency = 60 + random(30);
    float r = random(255);
    float g = random(255);
    float b = random(255);
    float turnSpeed = random(.2);
    float parentDivergence = random(PI/2);
    float meatSpecialist = random(10) + 1;
    float vegSpecialist = random(10) + 1;
    float boostMeatSpeed = random(speed * 4) + speed * 2;
    float boostVegSpeed = random(speed * 4) + speed * 2;
    CritterGenome genome = new CritterGenome(speed, turnSpeed, energyToSpawn, spawnEnergy, parentDivergence, r,g,b, deathAge, adultAge, radius, meatSpecialist, vegSpecialist, sensorVegRadius,sensorVegFrequency,sensorMeatRadius,sensorMeatFrequency, boostMeatSpeed, boostVegSpeed );
    Critter critter = new Critter(random(width),random(height),random(2 * PI), energy,genome, null);
    critters.add( critter );
  }
}

void metaboliseCritters()
{
  int numCritters = critters.size() - 1;
  for ( int i = numCritters; i >= 0; i-- )
  {
    Critter critter = (Critter) critters.get(i);
    critter.metabolise( i, numCritters );
  }
}

void drawCritters()
{
  int numCritters = critters.size() - 1;
  
  for ( int i = numCritters; i >= 0; i-- )
  {
    Critter critter = (Critter) critters.get(i);
    
   //meat sensor blips
    noFill();
    strokeWeight(1);
    if( critter.senseMeat > 0 )
    {
      stroke(#ff0000,critter.senseMeat * 10);
      float senseRadius = critter.genome.sensorMeatRadius * 2 - critter.senseMeat * 2;
      ellipse(critter.x,critter.y,senseRadius,senseRadius);
      ellipse(critter.x,critter.y,senseRadius - 6,senseRadius - 6);
      if( critter.targetMeat != null )
      {
        if( !critter.targetMeat.dead )
        {
          stroke(#ff0000,225);
          line(critter.x,critter.y,critter.targetMeat.x,critter.targetMeat.y);
        }
      }
    }
    
    //digestion blips
    noStroke();
    float blipRadius = critter.genome.radius*3;
    if( critter.digestMeat > 0 )
    {
      fill(#ff0000,critter.digestMeat*22.5);
      ellipse(critter.x,critter.y,blipRadius,blipRadius);
    }
    if( critter.digestVeg > 0 )
    {
      fill(#00ff00,critter.digestVeg *22.5);
      ellipse(critter.x,critter.y,blipRadius,blipRadius);
    }
    
    //deaths
    if( critter.dead )
    {
      strokeWeight(3);
      noFill();
      stroke(0xffff0000);
      ellipse( critter.x, critter.y, critter.genome.radius * 4,critter.genome.radius * 4 );
    }
    
    //adult marker
    noStroke();
    strokeWeight(2);
    if( critter.age > critter.genome.adultAge ) stroke(0XFFFFFFFF);
    
    //main body
    fill(critter.genome.r,critter.genome.g,critter.genome.b);
    float ageRatio = min(critter.age / critter.genome.adultAge,1) / 2;
    float r = critter.genome.radius + critter.genome.radius * ageRatio;
    ellipse(critter.x,critter.y,r,r);
    
    //stripe
    int typeAlpha = 255;
    //show low alpha if critter i at max energy
    if( critter.energy / (critter.genome.energyToSpawn * maxEnergyMultiplier) >= 1 ) typeAlpha = 130;
    float rx = cos(critter.direction);
    float ry = sin(critter.direction);
    float px = critter.x + critter.genome.radius * rx;
    float py = critter.y + critter.genome.radius * ry;
    float npx = critter.x - critter.genome.radius * rx;
    float npy = critter.y - critter.genome.radius * ry;
    //dark bg
    strokeWeight(6);
    stroke(0x99000000);
    line(npx,npy, px, py);
    //white stored energy stripe
    strokeWeight(4);
    stroke(0xffffffff);
    float spawnRatio = critter.energy / (critter.genome.energyToSpawn * maxEnergyMultiplier);
    float spawnDist = critter.genome.radius - (critter.genome.radius * spawnRatio * 2);
    line(px,py,critter.x + spawnDist * rx,critter.y + spawnDist * ry );
    //show diet perference / proficiency
    strokeWeight(2);
    stroke(#00ff00,typeAlpha);
    line(px,py, npx, npy); //show green
    stroke(#ff0000,typeAlpha);
    float meatRatio = critter.genome.meatSpecialist / (critter.genome.vegSpecialist + critter.genome.meatSpecialist);
    float meatDist = critter.genome.radius - (critter.genome.radius * meatRatio * 2);
    line(px,py,critter.x + meatDist * rx,critter.y + meatDist * ry ); //show red
  }
}

void cleanupCritters()
{
  for ( int i = critters.size() - 1; i >= 0 ; i-- )
  {
    Critter critter = (Critter) critters.get(i);
    if( critter.dead ) critters.remove(i);
  }
}

class Food
{
  float x;
  float y;
  float radius;
  float energy;
  Food( float ix, float iy)
  {
    radius = 6 + random(10);
    energy = vegEnergyPerRadius * radius;
    x = ix;
    y = iy;
  }
}

class Critter
{
  float x;
  float y;
  float energy;
  float direction;
  float digestMeat;
  float digestVeg;
  int age;
  boolean dead;
  int senseVeg;
  int senseMeat;
  float rudderAngle;
  int sensorMeatCount;
  int sensorVegCount;
  boolean speedMeatBoost;
  boolean speedVegBoost;
  Food targetVeg;
  Critter targetMeat;
  CritterGenome genome;
  Critter parent;

  Critter( float ix, float iy, float idirection, float ienergy, CritterGenome igenome, Critter iParent)
  {
    age = 0;
    rudderAngle = 0;
    digestMeat = 0;
    digestVeg = 0;
    targetVeg = null;
    targetMeat = null;
    dead = false;
    senseMeat = 0;
    senseVeg = 0;
    direction = idirection;
    x = ix;
    y = iy;
    energy = ienergy;
    genome = igenome;
    direction = direction - genome.parentDivergence / 2 + random(genome.parentDivergence);
    genome.mutateAll();
    parent = iParent;
    speedMeatBoost = false;
    speedVegBoost = false;
    sensorMeatCount = floor(random(genome.sensorVegFrequency));
    sensorVegCount = floor(random(genome.sensorMeatFrequency));
  }

  void metabolise( int id, int numCritters )
  {
    if( dead ) return;
    age++;
    if( ageingEnabled )
    {
      if( age > genome.deathAge)
      {
        dead = true;
        return;
      }
    }
    
    if( digestMeat > 0 ) digestMeat--;
    if( digestVeg > 0 )  digestVeg--;
    
    //use energy for general maintenance based on size
    energy -= .04 * genome.radius;
    
    //act upon sense information
    actOnMeatSense();
    actOnVegSense();
    
    if( energy < maxEnergyMultiplier * genome.energyToSpawn )
    {
      senseForMeat( numCritters );
      senseForVeg();
    }
    
    //use bosst speed if hunting
    float useSpeed = genome.speed;
    if( speedMeatBoost )
    {
      useSpeed = genome.boostMeatSpeed;
    }
    else if( speedVegBoost )
    {
      useSpeed = genome.boostVegSpeed;
    }
    if( useEnergy( useSpeed * useSpeed * genome.radius * genome.radius * .003 ) )
    {
      move( useSpeed );
      
      //may only eat maxEnergyMultiplier times amount required to spawn offspring
      if( energy < maxEnergyMultiplier * genome.energyToSpawn )
      {
        checkEatVeg(); 
        checkEatMeat( numCritters );
      }
      
      //if old enough and have enough energy, breed
      
      if( energy > genome.energyToSpawn && random(10) > 9 )
      {
        if( age > genome.adultAge || !ageingEnabled )
        {
           critters.add(spawnChild());
        }
      }
    }
    else
    {
      // if no energy left, mark as dead for dead collector
      dead = true;
    }
  }
  
  void senseForVeg()
  {
    if( sensorVegCount >= floor(genome.sensorVegFrequency -genome.vegSpecialist +genome.meatSpecialist) && senseMeat == 0 )
    {
      targetVeg = null;
      if( useEnergy( genome.sensorVegRadius * genome.sensorVegRadius * .0005 ) )
      {
        sensorVegCount = 0;
        senseVeg = 20;
        for ( int i = foods.size() - 1; i >= 0;i--)
        {
          Food food = (Food) foods.get(i);
          if( dist( x, y, food.x,food.y) < food.radius + genome.sensorVegRadius )
          {
            rudderAngle = 0;
            targetVeg = food;
            break;
          }
        }
      }
    }
  }
  
  void senseForMeat( int numCritters )
  {
    if( sensorMeatCount >= floor(genome.sensorMeatFrequency -genome.meatSpecialist +genome.vegSpecialist) && senseVeg == 0 )
    {
      targetMeat = null;
      if( useEnergy( genome.sensorMeatRadius * genome.sensorMeatRadius * .0005 ) )
      {
        sensorMeatCount = 0;
        senseMeat = 30;
        for ( int i = numCritters; i >= 0;i--)
        {
          Critter otherCritter = (Critter) critters.get(i);
          //don't hunt relatives
          if( otherCritter.parent != parent && parent != otherCritter && this != otherCritter.parent )
          {
            //calculate who is stronger; being a meatspecialist helps as does size
            if( (otherCritter.genome.meatSpecialist / ( otherCritter.genome.meatSpecialist + otherCritter.genome.vegSpecialist ))*otherCritter.genome.radius < (genome.meatSpecialist / ( genome.meatSpecialist + genome.vegSpecialist ))*genome.radius )
            {
              if( dist( x, y, otherCritter.x,otherCritter.y) < otherCritter.genome.radius + genome.sensorMeatRadius )
              {
                rudderAngle = 0;
                targetMeat = otherCritter;
                break;
              }
            }
          }
        }
      }
    }
  }
  
  void actOnVegSense()
  {
    sensorVegCount++;
    if( senseVeg > 0 )
    {
      senseVeg -=1;
      if( targetVeg != null )
      {
        //if target is not close enought to eat
        if( dist(x,y,targetVeg.x,targetVeg.y) > targetVeg.radius + genome.radius )
        {
          speedVegBoost = true;
        }
        else
        {
          speedVegBoost = false;
        }
        direction = atan2(targetVeg.y - y,targetVeg.x - x);
      }
      else
      {
        speedVegBoost = false;
      }
    }
    else
    {
      targetVeg = null;
      speedVegBoost = false;
    }
  }
  
  void actOnMeatSense()
  {
   sensorMeatCount++;
   if( senseMeat > 0 )
    {
      senseMeat -=1;
      if( targetMeat != null )
      {
        //if target is not close enought to eat
        if( dist(x,y,targetMeat.x,targetMeat.y) > targetMeat.genome.radius + genome.radius )
        {
          speedMeatBoost = true;
        }
        else
        {
          speedMeatBoost = false;
        }
        direction = atan2(targetMeat.y - y,targetMeat.x - x);
      }
      else
      {
        speedMeatBoost = false;
      }
    }
    else
    {
      targetMeat = null;
      speedMeatBoost = false;
    } 
  }
  
  void move( float useSpeed )
  {
    float ox = x;
    float oy = y;
    if( senseMeat == 0 && senseVeg == 0 ) rudderAngle += -genome.turnSpeed / 2 + random(genome.turnSpeed);
    rudderAngle = min(max( -rudderMax, rudderAngle),rudderMax);
    direction += rudderAngle;
    y += sin(direction) * useSpeed;
    x += cos(direction) * useSpeed;
    resolveBounds( ox, oy );
  }
  
  void resolveBounds( float ox, float oy )
  {
     if( x < 0 || x > width )
      {
        flipX();
        x = ox;
        y = oy;
      }
      if( y < 0 || y > height )
      {
        flipY();
        x = ox;
        y = oy;
      }
  }
  
  void checkEatVeg()
  {
    if( random(10) > 4)
    {
      for ( int i = foods.size() - 1; i >= 0;i--)
      {
        Food food = (Food) foods.get(i);
        if( dist( x, y, food.x,food.y) < food.radius + genome.radius )
        {
          if( random(genome.vegSpecialist) > random(genome.meatSpecialist) ) eatVeg( food, i ); 
          break;
        }
      }
    }
  }
  
  void checkEatMeat( int numCritters )
  {
    if( random(10) > 5)
    {
      for ( int i = numCritters; i >= 0;i--)
      {
        Critter otherCritter = (Critter) critters.get(i);
        //dont eat young or siblings

        if( this != otherCritter.parent && otherCritter.parent != parent && parent != otherCritter )
        {
          //if( otherCritter.age > otherCritter.genome.adultAge / 2 || !ageingEnabled)
          //{
            //calculate who is stronger; being a meatspecialist helps as does size
            if( (otherCritter.genome.meatSpecialist / ( otherCritter.genome.meatSpecialist + otherCritter.genome.vegSpecialist ))*otherCritter.genome.radius < (genome.meatSpecialist / ( genome.meatSpecialist + genome.vegSpecialist ))*genome.radius )
            {
              if( dist( x, y, otherCritter.x,otherCritter.y) < otherCritter.genome.radius + genome.radius )
              {
                if( random(genome.meatSpecialist) > random(genome.vegSpecialist) )
                {
                  eatMeat( otherCritter ); 
                  break;
                }
              }
            }
          //}
        }
      }
    }
  }
  
  void eatVeg( Food food, int id )
  {
    float e = food.energy * min(genome.vegSpecialist * genome.vegSpecialist / genome.meatSpecialist / genome.meatSpecialist, 1);
    digestVeg = 10;
    energy += e;
    foods.remove(id);
  }

  void eatMeat( Critter prey )
  {
    float e = prey.energy * min(genome.meatSpecialist * genome.meatSpecialist / genome.vegSpecialist / genome.vegSpecialist, meatEatingEfficiency);
    digestMeat = 10;
    energy += e;
    prey.dead = true;
  }

  void flipX()
  {
    float dx = cos(direction);
    float dy = sin(direction);
    direction = atan2(dy,-dx);
  }

  void flipY()
  {
    float dx = cos(direction);
    float dy = sin(direction);
    direction = atan2(-dy,dx);
  }

  Critter spawnChild()
  {
    energy -= genome.spawnEnergy;
    return new Critter( x,y,direction,genome.spawnEnergy * breedingEfficiency,genome.clone(), this );
  }

  boolean useEnergy( float request )
  {
    if( energy >= request )
    {
      energy -= request;
      return true;
    }
    else
    {
      return false;
    }
  }
}

class CritterGenome
{
  float speed;
  float turnSpeed;
  float energyToSpawn;
  float spawnEnergy;
  float parentDivergence;
  float r;
  float g;
  float b;
  float deathAge;
  float adultAge;
  float radius;
  float meatSpecialist;
  float vegSpecialist;
  float sensorVegRadius;
  float sensorMeatRadius;
  float sensorVegFrequency;
  float sensorMeatFrequency;
  float boostVegSpeed;
  float boostMeatSpeed;

  CritterGenome( float ispeed, float iturnSpeed, float ienergyToSpawn, float ispawnEnergy, float iparentDivergence, float ir, float ig, float ib, float ideathAge, float iadultAge, float iradius, float imeatSpecialist, float ivegSpecialist, float isensorVegRadius, float isensorVegFrequency,float isensorMeatRadius, float isensorMeatFrequency, float iboostVegSpeed, float iboostMeatSpeed )
  {
    speed = ispeed;
    turnSpeed = iturnSpeed;
    energyToSpawn = ienergyToSpawn;
    spawnEnergy = ispawnEnergy;
    parentDivergence = iparentDivergence;
    r = ir;
    g = ig;
    b = ib;
    deathAge = ideathAge;
    adultAge = iadultAge;
    radius = iradius;
    meatSpecialist = imeatSpecialist;
    vegSpecialist = ivegSpecialist;
    sensorVegRadius = isensorVegRadius;
    sensorVegFrequency = isensorVegFrequency;
    sensorMeatRadius = isensorMeatRadius;
    sensorMeatFrequency = isensorMeatFrequency;
    boostVegSpeed = iboostVegSpeed;
    boostMeatSpeed = iboostMeatSpeed;
  }

  void mutateAll()
  {
    speed = mutate( speed );
    turnSpeed = min(mutate( turnSpeed ),0.02);
    energyToSpawn = mutate( energyToSpawn );
    spawnEnergy = max(mutate( spawnEnergy ),energyToSpawn / 2);
    parentDivergence = mutate( parentDivergence );
    r = mutateColor( r );
    g = mutateColor( g );
    b = mutateColor( b );
    adultAge = mutate( adultAge );
    deathAge = mutate( deathAge );
    radius = max(3,mutate( radius ));
    meatSpecialist = max(mutate( meatSpecialist ),2);//cannot divide by 0
    vegSpecialist = max(mutate( vegSpecialist ),2);
    sensorVegRadius = max(mutate( sensorVegRadius ), radius*3);
    sensorVegFrequency = max( 60, mutate(sensorVegFrequency) );
    sensorMeatRadius = max(mutate( sensorMeatRadius ), radius*3);
    sensorMeatFrequency = max( 60, mutate(sensorMeatFrequency) );
    boostVegSpeed = max( speed * 2, mutate(boostVegSpeed) );
    boostMeatSpeed = max( speed * 2, mutate(boostMeatSpeed) );
  }

  float mutate( float gene )
  {
    return gene - mutationRate * .5 + random(mutationRate);
  }

  float mutateColor( float gene )
  {
    return gene - mutationRate * 100 + random(mutationRate*200);
  }

  CritterGenome clone()
  {
    return new CritterGenome( speed, turnSpeed, energyToSpawn, spawnEnergy, parentDivergence, r, g, b, deathAge, adultAge, radius, meatSpecialist, vegSpecialist, sensorVegRadius, sensorVegFrequency,sensorMeatRadius, sensorMeatFrequency, boostVegSpeed, boostMeatSpeed );
  }
}

