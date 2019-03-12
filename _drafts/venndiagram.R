install.packages("futile.options")
install.packages("VennDiagram")
install.packages("lambda.r")
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
grid.text(label = "The Hedgehog Concept", vjust = -18, gp = gpar(fontsize = 20))
