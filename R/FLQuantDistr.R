# FLQuantDistr - «Short one line description»
# FLCore/R/FLQuantDistr.R

# Copyright 2003-2012 FLR Team. Distributed under the GPL 2 or later
# Maintainer: Iago Mosqueira, JRC
# $Id: FLQuantPoint.R 1779 2012-11-23 09:39:31Z imosqueira $

## FLQuantDistr()	{{{
setMethod("FLQuantDistr", signature(object="ANY", var="ANY"),
	function(object, var, ...) {

		# object
		object <- FLQuant(object)

		# var
		var <- new('FLArray', FLQuant(var)@.Data)

		return(FLQuantDistr(object=object, var=var, ...))
	}
)

setMethod("FLQuantDistr", signature(object="FLQuant", var="FLQuant"),
  function(object, var, ...) {
	var <- new('FLArray', var@.Data)
	return(FLQuantDistr(object, var=var, ...))
	}
)

setMethod("FLQuantDistr", signature(object="FLQuant", var="FLArray"),
  function(object, var, units='NA', distr="norm") {
		
		# set units in .Data object
		if(!missing(units))
			units(object) <- units
		
		return(new("FLQuantDistr", object, var=var, distr=distr))
	}
)
	# }}}

## show     {{{
# TODO show median(var) or [lowq-uppq]
setMethod("show", signature(object="FLQuantDistr"),
	function(object){
		cat("An object of class \"FLQuantDistr\":\n")

    v3 <- paste(format(object@.Data,digits=5),"(", format(object@var, digits=3), ")", sep="")
    print(array(v3, dim=dim(object)[1:5], dimnames=dimnames(object)[1:5]), quote=FALSE)

		cat("units: ", object@units, "\n")
		cat("distr: ", object@distr, "\n")
	}
)   # }}}

## random generators	{{{
# rnorm(FLQuantPoint, missing)
setMethod("rnorm", signature(n='numeric', mean="FLQuantPoint", sd="missing"),
	function(n=1, mean)
	rnorm(n, mean(mean), sqrt(var(mean)))
)
# rlnorm
setMethod("rlnorm", signature(n='numeric', meanlog="FLQuantPoint", sdlog="missing"),
	function(n=1, meanlog)
	rlnorm(n, mean(meanlog), sqrt(var(meanlog)))
)
# gamma
if (!isGeneric("rgamma"))
	setGeneric("rgamma", useAsDefault=rgamma)

setMethod("rgamma", signature(n='numeric', shape="FLQuantPoint", rate="missing",
	scale="missing"),
	function(n=1, shape)
	FLQuant(rgamma(n, shape=mean(shape)^2/var(shape), scale=var(shape)/mean(shape)),
		dim=c(dim(shape)[-6], n))
)
# pearson
# }}}

## accesors	{{{
if (!isGeneric("mean"))
	setGeneric("mean", function(x, ...) standardGeneric("mean"))
setMethod("mean", signature(x="FLQuantPoint"),
	function(x, ...)
		return(FLQuant(x[,,,,,'mean']))
)
setGeneric("mean<-", function(x, value) standardGeneric("mean<-"))
setMethod("mean<-", signature(x="FLQuantPoint"),
	function(x, value) {
		x[,,,,,'mean'] <- value
		return(x)
	}
)

if (!isGeneric("median"))
	setGeneric("median", function(x, na.rm=FALSE) standardGeneric("median"))
setMethod("median", signature(x="FLQuantPoint"),
	function(x, na.rm=FALSE)
		return(FLQuant(x[,,,,,'median']))
)
setGeneric("median<-", function(x, value) standardGeneric("median<-"))
setMethod("median<-", signature(x="FLQuantPoint", value="ANY"),
	function(x, value) {
		x[,,,,,'median'] <- value
		return(x)
	}
)

if (!isGeneric("var"))
	setGeneric("var", function(x, y=NULL, na.rm=FALSE, use) standardGeneric("var"))
setMethod("var", signature(x="FLQuantPoint"),
	function(x, y=NULL, na.rm=FALSE, use)
		return(FLQuant(x[,,,,,'var']))
)

setGeneric("var<-", function(x, value) standardGeneric("var<-"))
setMethod("var<-", signature(x="FLQuantPoint", value="ANY"),
	function(x, value) {
		x[,,,,,'var'] <- value
		return(x)
	}
)

setGeneric("uppq", function(x, ...) standardGeneric("uppq"))
setMethod("uppq", signature(x="FLQuantPoint"),
	function(x, ...)
		return(FLQuant(x[,,,,,'uppq']))
)

setGeneric("uppq<-", function(x, value) standardGeneric("uppq<-"))
setMethod("uppq<-", signature(x="FLQuantPoint", value="ANY"),
	function(x, value) {
		x[,,,,,'uppq'] <- value
		return(x)
	}
)

setGeneric("lowq", function(x, ...) standardGeneric("lowq"))
setMethod("lowq", signature(x="FLQuantPoint"),
	function(x, ...)
		return(FLQuant(x[,,,,,'lowq']))
)

setGeneric("lowq<-", function(x, value) standardGeneric("lowq<-"))
setMethod("lowq<-", signature(x="FLQuantPoint", value="ANY"),
	function(x, value) {
		x[,,,,,'lowq'] <- value
		return(x)
	}
) # }}}

## plot	{{{
# TODO Fix, it is badly broken! 12.09.07 imosqueira
setMethod("plot", signature(x="FLQuantPoint", y="missing"),
	function(x, xlab="year", ylab=paste("data (", units(x), ")", sep=""),
		type='bar', ...) {

		# get dimensions to condition on (length !=1)
		condnames <- names(dimnames(x)[c(1,3:5)][dim(x)[c(1,3:5)]!=1])
		cond <- paste(condnames, collapse="+")
		if(cond != "") cond <- paste("|", cond)
		formula <- formula(paste("data~year", cond))
		# set strip to show conditioning dimensions names
		strip <- strip.custom(var.name=condnames, strip.names=c(TRUE,TRUE))

		pfun <- function(x, y, subscripts, groups, ...){
			larrows(x[groups[subscripts]=='lowq'], y[groups[subscripts]=='lowq'],
				x[groups[subscripts]=='uppq'], y[groups[subscripts]=='uppq'], angle=90,
				length=0.05, ends='both')
			lpoints(x[groups[subscripts]=='mean'], y[groups[subscripts]=='mean'], pch=16)
			lpoints(x[groups[subscripts]=='median'], y[groups[subscripts]=='median'], pch=3)
		}

	# using do.call to avoid eval of some arguments
	lst <- substitute(list(...))
	lst <- as.list(lst)[-1]
    lst$data <- as.data.frame(x)
	lst$x <- formula
	lst$xlab <- xlab
	lst$ylab <- ylab
	lst$strip <- strip
	lst$groups <- lst$data$iter
	lst$subscripts <- TRUE
	lst$panel <- pfun
	
	do.call("xyplot", lst)
	}
)	# }}}

## quantile   {{{
setMethod("quantile", signature(x="FLQuantPoint"),
	function(x, probs=0.25, na.rm=FALSE, dim=1:5, ...) {
		if(probs==0.25)
			return(lowq(x))
		else if (probs==0.75)
			return(uppq(x))
		else
			stop("Only the 0.25 and 0.75 quantiles are available on an FLQuantPoint object")
	}
)   # }}}

## summary          {{{
setMethod("summary", signature(object="FLQuantPoint"),
	function(object, ...){
		cat("An object of class \"FLQuantPoint\" with:\n")
		cat("dim  : ", dim(object), "\n")
		cat("quant: ", quant(object), "\n")
		cat("units: ", units(object), "\n\n")
		cat("1st Qu.: ", mean(lowq(object)), "\n")
		cat("Mean   : ", mean(mean(object)), "\n")
		cat("Median : ", mean(median(object)), "\n")
		cat("Var    : ", mean(var(object)), "\n")
		cat("3rd Qu.: ", mean(uppq(object)), "\n")
	}
)   # }}}
