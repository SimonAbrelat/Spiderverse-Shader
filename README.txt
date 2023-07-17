My goal for this was a cartoon-y, painting-y style shader.

For this I used Minneart Lighting for shadows, Gooch for adding some color, and Kuwahara Filters to make it look like actual strokes.

I failed to achive my original target of a oil painting shader, but they are using totally different tech, so that is okay. 
Here is the unity asset store link https://assetstore.unity.com/packages/vfx/shaders/fullscreen-camera-effects/oil-painting-136385.

I found a repo and paper that go over a lot of different BRDF functions:
    github: https://github.com/wdas/brdf,
    paper: https://digibug.ugr.es/bitstream/handle/10481/19751/rmontes_LSI-2012-001TR.pdf
Minneart shading was very old (1941) and was used to describes the moon's reflectance, which I thought was pretty cool.
    original paper: https://adsabs.harvard.edu/full/1941ApJ....93..403M
Team Dogpit also had an open patreon post for using Minneart shading to get good looking lighting for darker skin, which is another interesting perk.
    post: https://www.patreon.com/posts/minnaert-for-who-47518737

For the painting aspect, I choise a Kuwahara filter since it is a perfect fit. If I had more time I would use an anisotropic Kuwahara filter, but it is too complex
a homework like this.
    Kuwahara Filter Code: http://www.shaderslab.com/demo-63---oil-painting.html 
I found a Kuwahara implementation, that actually worked, and noticed that the code was pretty inefficient which is sad.
With it, I made an ImageEffect and added it to my "artistic" shader.

For the Gooch, I used the resourced provided in an earlier homework.

To achieve a more cartoon-y vibe, I added a simple rim to the image, which also helps distinguish it. 
When thinking about it as a painting, I would assume imagine that artists would add an effect around the edges to make subjects more noticable,
so that's what I did.

I got shader blocked, and didn't know what to do, so I did a lot of research on different BRDFs and various anisotropic things. Like which shadowing techniques work for microfacet distributions.
After doing that for many hours, I started to google cool shaders and bumped into the oil painting one of the asset store.
The final product isn't great, but it was the best I could do.


TLDR; I got a little stuck and didn't know what to do, so i added Gooch shading, Kuwahara filters, and a Rim effect to mimic a comic book effect and added a simple and (i think) interesting lighting setup.
