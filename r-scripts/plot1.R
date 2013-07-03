args<-commandArgs(TRUE)
table <-read.table(paste(c(args[1], args[2], ".txt"), collapse = ""), sep=",",header=T)

png(paste(c(args[1], args[2], ".png"), collapse = ""), height=600,width=700, bg="white")

y_range <- range(0, table$w1)
x_range <- range (0,table$time)

with(table,plot(table$time,table$w1,type="l",xlab="Time in seconds", ylab="Power consumption (W)", col="red", ylim=c(0,max(table$w1))))
axis(2, las=0, at=10*0:!is.null(y_range[2]))

dev.off()


