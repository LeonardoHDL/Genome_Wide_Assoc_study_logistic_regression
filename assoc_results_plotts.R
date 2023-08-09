

args <- commandArgs(trailingOnly = TRUE)
directory <- args[1]
file_path <- paste(directory, ".assoc.logistic", sep = "")

# construct the file path
data <- read.table(file_path, header = TRUE) # read the data from the file
head(data)
output_for_qq <- args[2]
output_for_man <- args[3]

library(lattice)
manhattan.plot<-function(chr, pos, pvalue, 
                         sig.level=NA, annotate=NULL, ann.default=list(),
                         should.thin=T, thin.pos.places=2, thin.logp.places=2, 
                         xlab="Chromosome", ylab=expression(-log[10](p-value)),
                         col=c("gray","darkgray"), panel.extra=NULL, pch=20, cex=0.8,...) {
  
  if (length(chr)==0) stop("chromosome vector is empty")
  if (length(pos)==0) stop("position vector is empty")
  if (length(pvalue)==0) stop("pvalue vector is empty")
  
  #make sure we have an ordered factor
  if(!is.ordered(chr)) {
    chr <- ordered(chr)
  } else {
    chr <- chr[,drop=T]
  }
  
  #make sure positions are in kbp
  if (any(pos>1e6)) pos<-pos/1e6;
  
  #calculate absolute genomic position
  #from relative chromosomal positions
  posmin <- tapply(pos,chr, min);
  posmax <- tapply(pos,chr, max);
  posshift <- head(c(0,cumsum(posmax)),-1);
  names(posshift) <- levels(chr)
  genpos <- pos + posshift[chr];
  getGenPos<-function(cchr, cpos) {
    p<-posshift[as.character(cchr)]+cpos
    return(p)
  }
  
  #parse annotations
  grp <- NULL
  ann.settings <- list()
  label.default<-list(x="peak",y="peak",adj=NULL, pos=3, offset=0.5, 
                      col=NULL, fontface=NULL, fontsize=NULL, show=F)
  parse.label<-function(rawval, groupname) {
    r<-list(text=groupname)
    if(is.logical(rawval)) {
      if(!rawval) {r$show <- F}
    } else if (is.character(rawval) || is.expression(rawval)) {
      if(nchar(rawval)>=1) {
        r$text <- rawval
      }
    } else if (is.list(rawval)) {
      r <- modifyList(r, rawval)
    }
    return(r)
  }
  
  if(!is.null(annotate)) {
    if (is.list(annotate)) {
      grp <- annotate[[1]]
    } else {
      grp <- annotate
    } 
    if (!is.factor(grp)) {
      grp <- factor(grp)
    }
  } else {
    grp <- factor(rep(1, times=length(pvalue)))
  }
  
  ann.settings<-vector("list", length(levels(grp)))
  ann.settings[[1]]<-list(pch=pch, col=col, cex=cex, fill=col, label=label.default)
  
  if (length(ann.settings)>1) { 
    lcols<-trellis.par.get("superpose.symbol")$col 
    lfills<-trellis.par.get("superpose.symbol")$fill
    for(i in 2:length(levels(grp))) {
      ann.settings[[i]]<-list(pch=pch, 
                              col=lcols[(i-2) %% length(lcols) +1 ], 
                              fill=lfills[(i-2) %% length(lfills) +1 ], 
                              cex=cex, label=label.default);
      ann.settings[[i]]$label$show <- T
    }
    names(ann.settings)<-levels(grp)
  }
  for(i in 1:length(ann.settings)) {
    if (i>1) {ann.settings[[i]] <- modifyList(ann.settings[[i]], ann.default)}
    ann.settings[[i]]$label <- modifyList(ann.settings[[i]]$label, 
                                          parse.label(ann.settings[[i]]$label, levels(grp)[i]))
  }
  if(is.list(annotate) && length(annotate)>1) {
    user.cols <- 2:length(annotate)
    ann.cols <- c()
    if(!is.null(names(annotate[-1])) && all(names(annotate[-1])!="")) {
      ann.cols<-match(names(annotate)[-1], names(ann.settings))
    } else {
      ann.cols<-user.cols-1
    }
    for(i in seq_along(user.cols)) {
      if(!is.null(annotate[[user.cols[i]]]$label)) {
        annotate[[user.cols[i]]]$label<-parse.label(annotate[[user.cols[i]]]$label, 
                                                    levels(grp)[ann.cols[i]])
      }
      ann.settings[[ann.cols[i]]]<-modifyList(ann.settings[[ann.cols[i]]], 
                                              annotate[[user.cols[i]]])
    }
  }
  rm(annotate)
  
  #reduce number of points plotted
  if(should.thin) {
    thinned <- unique(data.frame(
      logp=round(-log10(pvalue),thin.logp.places), 
      pos=round(genpos,thin.pos.places), 
      chr=chr,
      grp=grp)
    )
    logp <- thinned$logp
    genpos <- thinned$pos
    chr <- thinned$chr
    grp <- thinned$grp
    rm(thinned)
  } else {
    logp <- -log10(pvalue)
  }
  rm(pos, pvalue)
  gc()
  
  #custom axis to print chromosome names
  axis.chr <- function(side,...) {
    if(side=="bottom") {
      panel.axis(side=side, outside=T,
                 at=((posmax+posmin)/2+posshift),
                 labels=levels(chr), 
                 ticks=F, rot=0,
                 check.overlap=F
      )
    } else if (side=="top" || side=="right") {
      panel.axis(side=side, draw.labels=F, ticks=F);
    }
    else {
      axis.default(side=side,...);
    }
  }
  
  #make sure the y-lim covers the range (plus a bit more to look nice)
  prepanel.chr<-function(x,y,...) { 
    A<-list();
    maxy<-ceiling(max(y, ifelse(!is.na(sig.level), -log10(sig.level), 0)))+.5;
    A$ylim=c(0,maxy);
    A;
  }
  
  xyplot(logp~genpos, chr=chr, groups=grp,
         axis=axis.chr, ann.settings=ann.settings, 
         prepanel=prepanel.chr, scales=list(axs="i"),
         panel=function(x, y, ..., getgenpos) {
           if(!is.na(sig.level)) {
             #add significance line (if requested)
             panel.abline(h=-log10(sig.level), lty=2);
           }
           panel.superpose(x, y, ..., getgenpos=getgenpos);
           if(!is.null(panel.extra)) {
             panel.extra(x,y, getgenpos, ...)
           }
         },
         panel.groups = function(x,y,..., subscripts, group.number) {
           A<-list(...)
           #allow for different annotation settings
           gs <- ann.settings[[group.number]]
           A$col.symbol <- gs$col[(as.numeric(chr[subscripts])-1) %% length(gs$col) + 1]    
           A$cex <- gs$cex[(as.numeric(chr[subscripts])-1) %% length(gs$cex) + 1]
           A$pch <- gs$pch[(as.numeric(chr[subscripts])-1) %% length(gs$pch) + 1]
           A$fill <- gs$fill[(as.numeric(chr[subscripts])-1) %% length(gs$fill) + 1]
           A$x <- x
           A$y <- y
           do.call("panel.xyplot", A)
           #draw labels (if requested)
           if(gs$label$show) {
             gt<-gs$label
             names(gt)[which(names(gt)=="text")]<-"labels"
             gt$show<-NULL
             if(is.character(gt$x) | is.character(gt$y)) {
               peak = which.max(y)
               center = mean(range(x))
               if (is.character(gt$x)) {
                 if(gt$x=="peak") {gt$x<-x[peak]}
                 if(gt$x=="center") {gt$x<-center}
               }
               if (is.character(gt$y)) {
                 if(gt$y=="peak") {gt$y<-y[peak]}
               }
             }
             if(is.list(gt$x)) {
               gt$x<-A$getgenpos(gt$x[[1]],gt$x[[2]])
             }
             do.call("panel.text", gt)
           }
         },
         xlab=xlab, ylab=ylab, 
         panel.extra=panel.extra, getgenpos=getGenPos, ...
  );
}
#newQQ Plot
#' QQ plot adapted From Hoffman et al Bioinformatics 2013
#' QQ plot and lambda_GC optimized for large datasets.
#' @param p_values vector, matrix or list of p-values
#' @param col colors corresponding to the number of columns in matrix, or entries in the list
#' @param main title
#' @param pch pch
#' @param errors show 95\% confidence interval
#' @param lambda calculate and show genomic control lambda.  Lambda_GC is calcualted using the 'median' method on p-values > p_thresh.
#' @param p_thresh Lambda_GC is calcualted using the 'median' method on p-values > p_thresh.
#' @param showNames show column names or list keys in the legend
#' @param ylim ylim 
#' @param xlim xlim
#' @param plot make a plot.  If FALSE, returns lamda_GC values without making plot
#' @param new make a new plot.  If FALSE, overlays QQ over current plot
#' @param box.lty box line type
#' @param collapse combine entries in matrix or list into a single vector
#' @param ... other arguments
#' 
#' @examples
#' p = runif(5e6)
#' p<-c(runif(.9*5e6),runif(.09*5e6,0,.5),runif(.009*5e6,0,0.05),runif(.001*5e6,0,.00001))
#' QQ_plot(p)
#' 
#' # get lambda_GC median values without making plot
#' lambda = QQ_plot(p, plot=FALSE)
#'
#' @export 
QQ_plot = function(p_values, col=((min(length(p_values), ncol(p_values)))), main="", pch=20, errors=TRUE, lambda=TRUE, p_thresh = 1e-5, showNames=FALSE, ylim=NULL, xlim=NULL, plot=TRUE,new=TRUE, box.lty=par("lty"), collapse=FALSE,...){
  
  if( collapse ){
    p_values = as.vector(unlist(p_values, use.names=FALSE))
  }
  
  # convert array, vector or matrix into list
  if( ! is.list(p_values) ){
    
    names(p_values) = c()
    keys = colnames(p_values)
    
    # if there is am empty name
    if( "" %in% keys ){
      keys[which("" %in% keys)] = "NULL"
    }
    
    p_values = as.matrix(p_values)
    p_values_list = list()
    
    for(i in 1:ncol(p_values) ){
      p_values_list[[i]] = p_values[,i]
    }
    
    names(p_values_list) = keys
    p_values = p_values_list
    rm( p_values_list )
  }		
  
  rge = range(p_values, na.rm=TRUE)
  
  if( rge[1] < 0 || rge[2] > 1 ){
    stop("p_values outside of range [0,1]")
  }
  
  # assign names to list entries if they don't exist
  if( is.null( names( p_values ) ) ){
    names( p_values ) = 1:length( p_values )
  }
  
  # set pch values if not defined
  if( is.null( pch ) ){
    pch = rep(20, length(p_values))
  }
  if( length(pch) == 1){
    pch = rep(pch, length(p_values))
  }
  
  p_values = as.list(p_values)
  
  # Set the x and y ranges of the plot to the largest such values 
  #	encountered in the data 
  ry = 0; rx = 0
  
  for( key in names( p_values ) ){
    
    # remove NA values
    p_values[[key]] = p_values[[key]][which( ! is.na( p_values[[key]] ))]
    
    j = which(p_values[[key]] == 0)
    
    if( length(j) > 0){
      p_values[[key]][j] = min(p_values[[key]][-j])
    }
    
    ry = max(ry, -log10(min(p_values[[key]])) )
    rx = max(rx, -log10( 1/(length(p_values[[key]])+1)  ))		
  }
  
  if( ! is.null(ylim) ){
    ry = max(ylim)
  }
  if( ! is.null(xlim) ){
    rx = max(xlim)
  }
  
  r = max(rx, ry)
  
  xlab = expression(-log[10]('expected p-value'))
  ylab = expression(-log[10]('observed p-value'))
  
  if( plot && new ){
    # make initial plot with proper ranges
    plot(1, type='n', las=1, pch=20, xlim=c(0, rx), ylim=c(0, ry), xlab=xlab, ylab=ylab, main=main,...)
    abline(0, 1,col='green')		
  }
  
  
  lambda_values = c()
  lambda_values90 = c()
  lambda_values99 = c()
  lambda_values999 = c()
  se = c()
  
  # Plots points for each p-value set
  # Since 90% of p-values should be < .1 and 99% < 0.01, plotting all of these points is
  # time consuming and takes up space, even though all the points appear on top of each other
  # Therefore, thin the p-values at the beginning and increases density for smaller p-values
  # This allows saving QQ plots as a PDF.....with out thinning, a PDF can be VERY large
  i = 1
  for( key in names( p_values ) ){
    
    observed = sort(p_values[[key]], decreasing=TRUE)
    obs = sort(p_values[[key]][which(p_values[[key]] > p_thresh)], decreasing=TRUE)
    lambda_values[i] = qchisq(quantile(obs,.5), 1, lower.tail = FALSE) / qchisq(0.5, 1)
    lambda_values90[i] = qchisq(quantile( obs,0.1), 1, lower.tail = FALSE) / qchisq(0.9, 1)
    lambda_values99[i] = qchisq(quantile( obs,0.01), 1, lower.tail = FALSE) / qchisq(0.99, 1)
    lambda_values999[i] = qchisq(quantile( obs,0.001), 1, lower.tail = FALSE) / qchisq(0.999, 1)
    
    # Plot lambda values, if desired
    if( plot && lambda ){
      # Calculated lambda using estlambda() from GenABLE
      # As of Sept24, 2013, I calculated it much faster using the sorted observed p-values
      #result = sapply( p_values, estlambda, plot=FALSE,method=method) # Better call GenABEL before uncommenting this
      #result = matrix(unlist(result), ncol=2, byrow=TRUE)
      #lambda_values = result[,1]
      #se = result[,2]
      
      if( ! showNames ){
        namesStrings = rep('', length(names( p_values )) )
      }else{
        namesStrings = paste( names( p_values ), ": ", sep='')
      }
      if(length(names(p_values))>1){
        legend("topleft", legend = paste(namesStrings, format(lambda_values, digits = 4, nsmall = 3)), col=col, pch=15, pt.cex=1.5, title=expression(lambda['GC']), box.lty=box.lty)
      }else{
        #output multiquantile lambdaGC
        abline(v=-log10(0.5),col='light grey')
        abline(v=-log10(0.1),col='light grey')
        abline(v=-log10(0.01),col='light grey')
        abline(v=-log10(0.001),col='light grey')
        mqLegend=rbind(paste('0.50  ',format(lambda_values[i],digits = 4, nsmall = 3)),
                       paste('0.10  ',format(lambda_values90[i],digits = 4, nsmall = 3)),
                       paste('0.01  ',format(lambda_values99[i],digits = 4, nsmall = 3)),
                       paste('0.001',format(lambda_values999[i],digits = 4, nsmall = 3)))
        legend("topleft", legend = paste(mqLegend), col=col, pch=".", pt.cex=1.5, title=c(expression(lambda['GC'])), box.lty=box.lty)
        
      }
    }
    
    # Standard errors 
    # From Supplementary information from Listgarten et al. 2010. PNAS	
    if( plot && errors ){
      error_quantile = 0.95
      
      # Using M:1 plots too many points near zero that are not discernable 
      # 	Reduce the number of points near zero 
      
      #plot(1, type='n', las=1, pch=20, xlim=c(0, rx), ylim=c(0, ry))
      
      M = length(p_values[[key]])
      alpha = seq(M, M/10 + 1, length.out=1000)
      
      if( M/10 > 1) alpha = append(alpha, seq(M/10, M/100 + 1, length.out=1000))
      if( M/100 > 1) alpha = append(alpha, seq(M/100, M/1000 + 1, length.out=1000))
      if( M/1000 > 1) alpha = append(alpha, seq(M/1000, M/10000 + 1, length.out=10000))
      alpha = append(alpha, seq(min(alpha), 1, length.out=10000))
      
      alpha = round(alpha)
      beta = M - alpha + 1
      
      x_top = qbeta(error_quantile, alpha, beta)
      x_bot = qbeta(1-error_quantile, alpha, beta)
      
      polygon(-log10(c(alpha/(M+1),rev(alpha/(M+1)))),-log10(c(x_top,rev(x_bot))),density=NA, col="gray",border="dark grey",lwd=1)
      #lines( -log10(alpha/(M+1)), -log10(x_top),col="dark grey")
      #lines( -log10(alpha/(M+1)), -log10(x_bot),col="dark grey")
      abline(0, 1,col='green')	
    }
    if( plot ){
      # if a p-value is exactly zero, set it equal to the smallest nonzero p-value
      j = which( observed == 0)
      
      if( length(j) > 0){
        observed[j] = min(observed[-j])
      }
      
      expected = (length(observed):1) / (length(observed)+1)		
      p = length(expected)
      
      if( p < 1e6 ){
        # Thin p-values near 1, and increase density for smaller p-values 
        intervals = ceiling(c(1, 0.2*p, 0.4*p, 0.7*p, 0.9*p, 0.95*p, 0.99*p, p))
        scaling = c(28, 200, 800, 1000, 3000, 5000, p)
      }else{
        intervals = ceiling(c(1, 0.2*p, 0.4*p, 0.7*p, 0.9*p, 0.95*p, 0.99*p, 0.995*p, 0.999*p, p))
        scaling = c(28, 200, 800, 1000, 3000, 5000, 10000, 50000, p)
      }
      
      for( j in 1:length(scaling) ){
        k = seq(intervals[j], intervals[j+1], intervals[j+1]/scaling[j])
        points(-log10(expected[k]), -log10(observed[k]),  col=col[i], pch=pch[i])#,...)
      }
    }
    
    i = i + 1
  }
  
  return( invisible(lambda_values) )
}

p_vals<-data$P
png(file= output_for_qq,
    width=900, height=600)
QQplot<-QQ_plot(p_vals)
dev.off()

png(file=output_for_man,
    width=900, height=600)
manhattan.plot(data$CHR, data$BP, data$P, sig.level=5e-8, col=c("orange","blue","purple", "green", "brown"))
dev.off()