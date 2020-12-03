/**
 CSci-4611 Assignment #1 Text Rain
 **/


import processing.video.*;

// Global variables for handling video data and the input selection screen
String[] cameras;
Capture cam;
Movie mov;
PImage inputImage;
boolean inputMethodSelected = false;

//***My additions**
// mirror view and debug view from cam/mov
PImage mirrorImage;
PImage debugImage;

//check if we are in debug view
boolean debugMode = false;

PFont f;
// Shel Silverstein "Rain" poem that will fall as rain.
String message = "I opened my eyes And looked up at the rain And it Dripped int my head And flowed into my brain And all that I hear as I lie in my bed is the slishity slosh of the rain in my head"; 
// An array of Letter objects
Letter[] letters;
int threshold = 128;

void setup() {
  size(1280, 720);  
  inputImage = createImage(width, height, RGB);

  // create our font and mirror/debug views
  mirrorImage = createImage(width, height, RGB);
  debugImage = createImage(width, height, RGB);
  f = createFont("Arial", 20, true);
  textFont(f);
  // Initialize Letters at a random x location
  letters = new Letter[message.length()];
  for (int i = 0; i < message.length(); i++) {
    int x = int(random(1, 1280));
    int y = int(random(1, 10));
    letters[i] = new Letter(x, y, message.charAt(i), int(random(2, 7)));
  }
} 


void draw() {
  // When the program first starts, draw a menu of different options for which camera to use for input
  // The input method is selected by pressing a key 0-9 on the keyboard
  if (!inputMethodSelected) {
    cameras = Capture.list();
    int y=40;
    text("O: Offline mode, test with TextRainInput.mov movie file instead of live camera feed.", 20, y);
    y += 40; 
    for (int i = 0; i < min(9, cameras.length); i++) {
      text(i+1 + ": " + cameras[i], 20, y);
      y += 40;
    }
    return;
  }


  // This part of the draw loop gets called after the input selection screen, during normal execution of the program.


  // STEP 1.  Load an image, either from a movie file or from a live camera feed. Store the result in the inputImage variable

  if ((cam != null) && (cam.available())) {
    cam.read();
    inputImage.copy(cam, 0, 0, cam.width, cam.height, 0, 0, inputImage.width, inputImage.height);
  } else if ((mov != null) && (mov.available())) {
    mov.read();
    inputImage.copy(mov, 0, 0, mov.width, mov.height, 0, 0, inputImage.width, inputImage.height);
  }



  // Fill in your code to implement the rest of TextRain here..


  // Load the pixels to then create two versions of inputImage.
  // This 'for' loop makes two mirrored copies of inputImage. 
  // 'mirrorImage' is the grayscale version to be normally used and the
  // 'debugImage' is used to see which pixels have been thresholded to 
  // white or black.
  loadPixels();
  for (int j = 0; j < height; j++) {
    for (int i = 0; i < width; i++) {  
      //idx is location of where we are now, swapCol is the column we will mirror  
      int idx = i + j*inputImage.width;
      int swapCol = (inputImage.width - i - 1) + j * inputImage.width;       
      mirrorImage.pixels[idx] = inputImage.pixels[swapCol];
      debugImage.pixels[idx] = inputImage.pixels[swapCol];
    }
  }

  // This creates our debug view which we threshold the pixels of the mirrored image to white or black.
  int dimension = inputImage.width * inputImage.height;
  for (int i = 0; i < dimension; i++) {
    color thrasher = color(thresholdPixel(mirrorImage.pixels[i]));
    debugImage.pixels[i] = thrasher;
  }


  //toggle between normal view and debugging mode.
  if (debugMode) {
    set(0, 0, debugImage);
    filter(THRESHOLD);
    fill(#FF0516);
    text("Threshold Value is: " + threshold, inputImage.width - 1260, inputImage.height - 680);
  } else {
    set(0, 0, mirrorImage);
    filter(GRAY);
  }
  mirrorImage.updatePixels();

  //This loop does the actual work for stopping the letters on darker pixels
  for (int i = 0; i < letters.length; i++) {
    // Display all letters
    letters[i].display();
    //check to see if letter is still on the screen
    if (letters[i].y > 0  && letters[i].y < inputImage.height) {
      //index of the 1D array for pixels[].
      int index1D = letters[i].y * mirrorImage.width+ letters[i].x;
      color c = mirrorImage.pixels[index1D];
      int cthresh = thresholdPixel(c);

      //check if our pixel is white or black
      if (cthresh > threshold) {   
        letters[i].fall();
      }

     // Here we check if the pixel 5 rows above is black or white.
      else {  
        if (index1D > width*5) { 
          int upperIndex = index1D - width*5;
          color c2 = mirrorImage.pixels[upperIndex];
          int c2thresh = thresholdPixel(c2);
          if (c2thresh > threshold) {
            letters[i].y -= 1;
          } else {
            letters[i].y -= 10;
          }
        } else {
          letters[i].y -=3;
        }
      } 
    } else {  
      letters[i].repeat();
    }
  }
  debugImage.updatePixels();
} 



//function to thresh pixel to white or black
color thresholdPixel(color inputPixel) {
  if (brightness(inputPixel) > threshold) {
    return 255;       //return white
  } else {
    return 0;         //return black
  }
}



// A class to describe a single Letter
class Letter {
  char letter;
  // where letter is at currently
  int x, y;
  //speed of letter falling
  int speed;


  Letter (int x_, int y_, char letter_, int speed_) {
    x = x_; 
    y = y_; 
    letter = letter_; 
    speed = speed_;
  }

  // display the letter
  void display() {
    fill(#D90BDE);
    text(letter, x, y);
  }

  // make the letter fall.  
  void fall() {
    y += speed;
  }

  // Return the back to start
  void repeat() {
    x = int(random(1280));
    y = int(random(1,9));
  }
}

void keyPressed() {

  if (!inputMethodSelected) {
    // If we haven't yet selected the input method, then check for 0 to 9 keypresses to select from the input menu
    if ((key >= '0') && (key <= '9')) { 
      int input = key - '0';
      if (input == 0) {
        println("Offline mode selected.");
        mov = new Movie(this, "TextRainInput.mov");
        mov.loop();
        inputMethodSelected = true;
      } else if ((input >= 1) && (input <= 9)) {
        println("Camera " + input + " selected.");           
        // The camera can be initialized directly using an element from the array returned by list():
        cam = new Capture(this, cameras[input-1]);
        cam.start();
        inputMethodSelected = true;
      }
    }
    return;
  }


  // This part of the keyPressed routine gets called after the input selection screen during normal execution of the program
  // Fill in your code to handle keypresses here..

  if (key == CODED) {
    if (keyCode == UP) {
      // up arrow key pressed
      if (threshold < 256) {
        threshold++;
      }
    } else if (keyCode == DOWN) {
      // down arrow key pressed
      if (threshold > -1) {
        threshold--;
      }
    }
  } else if (key == ' ') {
    // space bar pressed
    if (!debugMode) {
      debugMode = true;
    } else {
      debugMode = false;
    }
  }
}
