#  Text Rain Program
### Jerry Knoch

I chose to implement the letters using a letter object. This allowed me the
flexibility to use an array and iterate through the array and display each
letter. The letter objects have an x and y position as well as a speed. The
placement of the letters is done by using Processing's built in random function.
Each letter is also initialized with a random speed/velocity value to mimic
realistic rain. As the letters fall, once they hit the bottom of the screen they
return back up to the top of the screen. This process is continually repeated.

As the letters would fall, I designed a method that would take in a particular
pixel and return whether the pixel would be thresholded to white or black. This
is what I used to check against a global threshold value to see if the letter
should continue to fall, or if it needed to halt. Something I noticed in my
initial implementation was that the letters would hit the dark pixel and would
start to "bounce" aggressively as their y-positions were reassigned. To help
smooth out this bouncing, I chose to have another series of if/else statements
to check the grayscale value of the pixels above the current position of the
letter. If the pixels above are greater than the threshold, then the y-position
would have smaller updates (e.g. y -= 1;). If the pixels were below the
threshold value, then it would have a larger y-position update (e.g. y -= 10;).

To implement the mirror-image view and debugging view, I created two new PImages
that were copies of the original inputImage copied from the webcam, or the
provided sample videos. The first of the new images was the mirrored version of
the inputImage. This was simply done by iterating through the rows and columns
of the inputImage and swapping the pixels. The second image was generated the
same way, but then I had a separate for loop which iterated through inputImage
and checked each pixel of the image. Using a call to the thresholdPixel function
allowed me to reassign the pixels from grayscale to either black or white. This
image is used as the debuggingImage view. To enter this view, I designed the
space bar to set a global boolean value to true or false. If the space bar is
pressed, then the value is set to true and the debugging view is used. This view
shows the black and white pixels and the current threshold value is displayed in
red at the top left of the image. In addition to this debugging tool, I designed
it so that the user can increase the global threshold value by using the 'up'
and 'down' arrows. Changing this value is also updated in the debugging view
so that the user can use the program in different lightning scenarios. Using the
space bar allows the user to toggle between the normal mirror-view and the
debugging view. When in the normal view, the image is converted to grayscale
using filter(GRAY). 
