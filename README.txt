Hello, so my goal for this homework was to get something approaching the style of Spiderman: Into the spiderverse.
Firstly, if you haven't seen it, I highly recommend the movie.

The movie is highly stylized, but the parts that I decided to focus on where the halftone (dotted printing) patterns and chromatic aberration while still having sharp main characters.

Looking at the movie they have the most visable halftone patterns around areas of high brightness, so I calculate the luminosity and scale how noticable the pattern is.
In general, i noticed that the dots are pretty constant throughout the movie, so I didn't worry about projecting the pattern onto the objects. (That may be a future target)

The aberration is pretty simple, I take the linear distance and square it to prevent the main character from becoming unfocused and I have a large displacement factor so background objects get dispersed.
My final solution looks good in my demo and took a painful amount of time to get right.

Although it isn't in the movie, I wanted a outline, so I used a Sobel outline that takes both depth and normal information.
I could have used a Kuwahara filter, but I did that in the last homework, so for stylizing this I used the outlines.