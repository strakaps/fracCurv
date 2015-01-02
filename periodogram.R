gasket <- read.table("~/Dropbox/estim-fracdim/daten/gasket.dat", header=TRUE, quote="\"")

attach(gasket)

length(x) / (max(x) - min(x)) -> h


ts(data = cbind(y0,y1,y2),frequency = h) -> Z

spec.pgram(Z,demean = TRUE,detrend = TRUE,xlim=c(0,3),pad=10,main="",xlab="frequency",ylab="periodogram",col=c(1,1,1),lty=c(1,2,3), lwd=c(1,1.5,1.9))
abline(v=1/log(2), lty=2)
abline(v=2/log(2), lty=2)

legend("bottomleft", c("y0", "y1", "y2"), lty = c(1, 2, 3), lwd = c(1.1,1.5,1.9), col=c(1,1,1), merge = TRUE
       #, bg = "gray90"
)


##########################

detach(gasket)
triangle <- read.table("~/Dropbox/estim-fracdim/daten/triangle.dat", header=TRUE, quote="\"")
attach(triangle)

require(rgl)
plot3d(y0,y1,y2)
rgl.postscript("cloud-uncropped.pdf",fmt="pdf")

