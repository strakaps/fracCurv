# This function calculates estimates of fractal dimension and fractal curvature based on a data set
# of x-values (negative logarithms of dilation radii) and y-values (logarithms of rescaled 
# Minkowki functionals)
# INPUT:
#	dd 	a data frame with one 'x'-column (necessary) and a number K of 'y'-columns
#	arithmetic
# 		if FALSE then a non-arithmetic fit is attempted, 
#		if TRUE (default) then an arithmetic fit is attempted.
#	frac.dim
#		Optional. A real number representing the factual dimension of the fractal. 
# 		If passed on as an argument, e.g. 'frac.dim = 1.58' for the Sierpinski Gasket, 
# 		then the fractal curvatures are estimated based on this value. 
# 		This is only implemented for one-dimensional 'y', and has been added to examine
# 		the influence of bad fractal dimension estimates on the curvature estimates. 
# 	period
# 		Optional. A real number representing the asymptotic period, if the fractal is 
# 		arithmetic. If left empty and 'arithmetic' is set, then the period is estimated. 
# 		
#
# OUTPUT: 
#	frac.dim
#		the estimate for the fractal dimension, or the optional argument 'frac.dim'.
# 	frac.curv
#		a K-vector of reals containing the estimates of the 
#		fractal curvature.
#	period	
#		the estimate of the period, if the fit is attempted as arithmetic, or the optional
# 		argument 'period'.
#	linear.fit
#		the linear lmfit object used

fracCurv <- function(dd,arithmetic=TRUE,...) {

## First, a Helper function
estimatePeriod <- function(dd) {
# estimate the period of the fit by finding the peak in the periodogram of dd. 
# Transform into a time-series object first
dd <- dd[order(dd$x),]
m  <- dim(dd)[2]
# make dd into a time series object
dd.ts <- ts(data=dd[,2:length(dd)], start=min(dd$x), deltat=(max(dd$x)-min(dd$x))/length(dd$x))
pgram <- spec.pgram(dd.ts,xlim=c(0,5),pad=9,demean=TRUE,detrend=TRUE,plot=TRUE)
# cut off frequencies: we only admit period lengths from 0.1 to half the range of x.
min.freq   <- 2/(max(dd$x)-min(dd$x))
max.freq   <- 10
ind <- which(min.freq < pgram$freq & pgram$freq < max.freq)
pgram$spec <- matrix(pgram$spec,ncol=m-1) # casting into matrix avoids indexing problems
pgram$spec <- pgram$spec[ind,]
pgram$freq <- pgram$freq[ind]
peak.index <- which(max(pgram$spec)==pgram$spec,arr.ind=TRUE)
peak.freq  <- pgram$freq[peak.index[1]]
period     <- 1/peak.freq
# plot(pgram$freq,pgram$spec)
# the period is denoted h in our paper.
period
}

if (length(which(names(dd)=="x")) == 0) stop("At least one column must be labelled with 'x'.")

K <- length(dd) - 1   # the number of 'y'-columns
optional.args <- list(...)
if (length(optional.args$frac.dim) >0 ) frac.dim <- optional.args$frac.dim

dim.known <- exists("frac.dim")

period <- if (!arithmetic) NA
else if (length(optional.args$period) > 0) period <- optional.args$period
else estimatePeriod(dd)

mu <- 2*pi/period # the parameter for the sine and cosine functions.


# now preparing the formula 'fml' and data frame 'data' for the linear model fit below.
if (K > 1){		# regression with multiple factors
  if (dim.known) stop("Estimation of fractal curvature at known fractal dimension implemented for 1-dimensional response only")
  # for more than one 'y'-column these need to be stacked
  data <- cbind(dd$x,stack(dd,-x))
  names(data) <- c("x","y","k")
    if(arithmetic){
      fml <- y ~ k + x + (
		  cos(mu*x) 	+ I(-sin(mu*x))
		+ cos(2*mu*x)   + I(-sin(2*mu*x))
		+ cos(3*mu*x) 	+ I(-sin(3*mu*x)) 
		+ cos(4*mu*x) 	+ I(-sin(4*mu*x)) 
#		+ cos(5*mu*x) 	+ I(-sin(5*mu*x)) 
#		+ cos(6*mu*x) 	+ I(-sin(6*mu*x)) 
#		+ cos(7*mu*x) 	+ I(-sin(7*mu*x)) 
#		+ cos(8*mu*x) 	+ I(-sin(8*mu*x)) 
		   ):k
    } else fml <- y ~ k + x
} else if (K==1 && !dim.known) {  # regression with one single factor, unknown dimension
  data <- dd # no need to stack
    if(arithmetic){
      fml <- as.formula(paste(names(dd)[which(names(dd)!="x")],
	paste("~x+ cos(mu*x) + I(-sin(mu*x)) + cos(2*mu*x) + I(-sin(2*mu*x)) + cos(3*mu*x) + I(-sin(3*mu*x)) + cos(4*mu*x) + I(-sin(4*mu*x))")))
    } else{
    fml <- as.formula(paste(names(dd)[which(names(dd)!="x")],paste("~x"))) #y ~ x + cos(mu*x) + .... 
    }
} else if (K==1 && dim.known){  # regression with one single factor, known dimension
  frac.dim <- list(...)[[1]]
  print(paste("Fractal Dimension assumed to be", sprintf("%f",frac.dim)))
  data <- dd  
  data[,which(names(dd)!="x")] <- data[,which(names(dd)!="x")] - frac.dim * data$x
    if(arithmetic){
      fml <- as.formula(paste(names(dd)[which(names(dd)!="x")],
	paste("~cos(mu*x) + I(-sin(mu*x)) + cos(2*mu*x) + I(-sin(2*mu*x)) + cos(3*mu*x) + I(-sin(3*mu*x)) + cos(4*mu*x) + I(-sin(4*mu*x)) + cos(4*mu*x)")))
    } else {
      fml <- as.formula(paste(names(dd)[which(names(dd)!="x")],
	paste("~1")))
    }
} else if (K==0) stop("Input dimension too small")


## fit a linear model
dd.fit <- lm(fml,data)

## plot the fitted values

if(dim.known) {
	ind <- which(names(dd)!="x")
	data[[ind]] <- data[[ind]] + frac.dim * data[["x"]]
	dd.fit$fitted <- dd.fit$fitted + frac.dim * data[["x"]]
}

plot(data[,1:2],type='n')
legend("topleft", legend = c("y0", "y1", "y2"),
       text.width = strwidth("1,000,000"),
       lty = 1:3, lwd = 2)
# for more than one 'y'-column these need to be stacked
data <- cbind(dd$x,stack(dd,-x))
names(data) <- c("x","y","k")

lines(data[data$k == "y0", 1:2], lwd = 2, lty = 1)
lines(data[data$k == "y1", 1:2], lwd = 2, lty = 2)
lines(data[data$k == "y2", 1:2], lwd = 2, lty = 3)

n <- length(dd$x)
for (i in 0:(K-1)){
	lines(dd$x,dd.fit$fitted[(i*n+1):((i+1)*n)],col='red', lwd = 2)
}

## prepare the output

# dimension estimate
if(!dim.known) frac.dim <- dd.fit$coef[["x"]]

# intercepts
intercepts <- if(K==1) dd.fit$coef[[1]] else c(0,dd.fit$coef[2:K]) + dd.fit$coef[1] #lm returns intercepts relative to the 1st factor
names(intercepts) <- if(K>1) levels(data$k) else names(dd)[which(names(dd)!="x")]

# fractal Curvature
frac.curv <- vector(length = K)


if (!arithmetic) frac.curv <- exp(intercepts)
else {  # in the arithmetic case, 'exp(intercepts)' is asymptotically biased by the average of the sine and cosine functions,
	# plugged into the exponential function
  if(!dim.known) stopifnot(length(dd.fit$coef) == 1 + K + 4 * 2 * K) else stopifnot(length(dd.fit$coef) == 1 + 4 * 2)
  # 8 can be seen as a parameter, the cut-off of the Fourier series
    amplitudes <- tail(dd.fit$coef,4 * 2 * K)
    amplitudes.matrix <- matrix(amplitudes,nrow=K)
      for (i in 1:K){
	pfun <- function(x){
	exp ( amplitudes.matrix[i,] %*%	rbind(	  
		  cos(mu*x), 	sin(mu*x),
		 cos(2*mu*x),   sin(2*mu*x),
		 cos(3*mu*x), 	sin(3*mu*x),
		 cos(4*mu*x), 	sin(4*mu*x)
#		 cos(5*mu*x), 	sin(5*mu*x), 
#		 cos(6*mu*x),	sin(6*mu*x),
#		 cos(7*mu*x),	sin(7*mu*x),
#		 cos(8*mu*x),	sin(8*mu*x)
  ) )
	}  
	frac.curv[[i]] <- integrate(pfun,0,period)$value / period * exp(intercepts[[i]])
      }
} 

names(frac.curv) <- if(K>1) levels(data$k) else names(dd)[which(names(dd)!="x")]

return(list(frac.dim = frac.dim, frac.curv = frac.curv, period = period, fit = dd.fit))

}
