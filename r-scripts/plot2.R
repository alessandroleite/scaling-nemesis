args<-commandArgs(TRUE)
table <-read.table(paste(c(args[1], args[2], ".txt"), collapse = ""), sep=",",header=T)

png(paste(c(args[1], args[2], ".png"), collapse = ""), height=600,width=700, bg="white")

y_range <- range(0, table$w1, table$w2)
x_range <- range (0,table$time)

with(table,plot(table$time,table$w1,type="l",xlab="Time in seconds", ylab="Power consumption (W)", col="red", ylim=c(0,max(table$w2))))
axis(2, las=0, at=10*0:!is.null(y_range[2]))
with(table,lines(table$time,table$w2,col="darkgreen"))

#legend("bottomright", inset=.05, title="Sleep time in minutes", c("5", "10"), lty = c(1,1), horiz=TRUE, col=c("darkgreen", "red"))

dev.off()


