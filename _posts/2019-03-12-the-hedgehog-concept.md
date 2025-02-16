---
title: The Hedgehog Concept
author: JW
date: '2019-03-12'
slug: the-hedgehog-concept
categories:
- Business
tags:
  - data visualization
  - podcasts
  - '2019'
---


I recently listened to a podcast with Jim Collins, a brilliant thinker, entrepreneur, and writer on the topics of business and leadership. One of his ideas is the "Hedgehog Concept" which is based on a famous essay by Isaiah Berlin, titled "The Hedgehog and the Fox".  The title is an ancient reference to the Greek poet Archilochus: “A fox knows many things, but a hedgehog one important thing”. And this is ultimately a metaphor for how the world is divided. On one side, there are the foxes who draw upon different experiences and ideas in which to view the world. On the other side, the hedgehogs are those which see the world through a single defining idea.

In his book Good to Great, Jim uses the metaphor of the hedgehog to explain what makes good businesses great; a deep understanding of ‘one big thing’ that lies at the intersection of three circles.

The three circles are:

* What are you passionate about?
* What can you be the best in the world at?
* What drives your economic engine?

The Hedgehog Concept can also be applied personally to one’s own life. However, it may be wise to think about the circles in more practical terms. 

![plot of chunk unnamed-chunk-1](/figure/source/2019-03-12-the-hedgehog-concept/unnamed-chunk-1-1.png)

The first circle. Following one's passion is not always the best advice and doesn't work for everyone. Rather, **what do you enjoy doing?** What gets you out of bed in the morning and makes the time fly by? This sort of thing is worth pursuing. 

This second circle is a tricky one and I am going to elaborate on it here for a moment. Being the best in the world at something is extremely rare but there are certainly things you are good at.  Jim has another idea that many of us suffer from the curse of competence. He argues that we can be good at lots of things simply because we have an abundance of talent. Yet that doesn't mean we were meant to do them. Jim firmly believes that there are things we were born to do, genetically encoded to be great, if not the best at. These things then, are the focus of the second circle which we'll call: **what am I meant to do?** I think this is the most difficult of the circles and many if not most people don't ever figure this one out. Be careful not to get too fixated on it but don't be afraid to explore new things. And remember, just because you were born to do it doesn't mean it still won't be hard at times. Everything worth doing is difficult at one time or another.

And finally, the third circle remains relatively consistent from a business standpoint. **What are people willing to pay you to do?** We all have bills to pay. Sure, I love climbing but I'm not the best climber out there. Sponsors won't be sending me free gear any time soon. I wish! 

Presumably, the sweet spot lies at where these three circles overlap. Sounds about right to me. 

Here's some code in case you want to make your own venn diagram!


```r
library(VennDiagram)

venn.plot <- draw.triple.venn(
  area1 = 65,
  area2 = 75,
  area3 = 85,
  n12 = 35,
  n23 = 15,
  n13 = 25,
  n123 = 5,
  category = c(paste("What am I \n interested in?"), paste("What am I \n good at?"), "What will people pay me to do?"),
  fill = c("salmon", "steelblue", "seagreen"),
  lty = "blank",
  cex = 0,
  cat.cex = 1.5,
  cat.default.pos = "text",
  cat.col = c("black", "black", "black") 
)

grid.draw(venn.plot)

grid.text(label = "The Sweet Spot")
grid.text(label = "The Hedgehog Concept", vjust = -20, gp = gpar(fontsize = 20))
```
