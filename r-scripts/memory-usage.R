#load the MySQL library to R
library(RMySQL)

args<-commandArgs(TRUE)

# Connecting to MySQL
db <- dbConnect(MySQL(), user='', password='', dbname='resource_monitor', host='ec2-23-21-211-172.compute-1.amazonaws.com')
#close the connection in the end of the session if not closed explictly
on.exit(dbDisconnect(db))

rs <- dbSendQuery(db, "select @rownum:=@rownum+1 as row, m.id, DATE_FORMAT(m.date,'%H:%m:%s') as time, m.size, (m.used / (1024 * 1024 * 1024)) as used from memory_state m, (SELECT @rownum:=0) r where m.date between '2013-06-24 21:56:04' and '2013-06-25 00:33:31' order by m.date asc;")

#retrieve all pending records
data <- fetch(rs, n=-1)

dbClearResult(rs)
dbDisconnect(db)

#plot the memory usage
png(paste(c(args[1],".png"), collapse = ""), height=600,width=700, bg="white")



y_range <- range(0, data$used)
x_range <- range (0,data$row)

with(data,plot(data$row,data$used,type="l",xlab="Time", ylab="Memory Usage (GB)", col="red", ylim=c(0,max(data$used))))
axis(2, las=0, at=10*0:!is.null(y_range[2]))

dev.off()
