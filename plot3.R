library(sqldf)
library(dplyr)


# Approximately 66 bytes per data-row, 2,075,259 rows, therefore 136,967,094 bytes total => ~137MB

load_data <- function() {
  
  date = "substr(Date, -4)||'-'||substr('0'||replace(substr(Date, instr(Date, '/') + 1, 2), '/', ''), -2) 
  || '-' || 
  substr('0' || replace(substr(Date, 1, 2), '/', ''), -2)"
  
  sql = sprintf("select * from file where %s between '%s' and '%s';", date, "2007-02-01", "2007-02-02")
  #sql = sprintf("select * from file limit %d;", 10)
  
  consumption_data = "household_power_consumption.txt" #paste(path, "X_", data_set, ".txt", sep = "")
  
  field_types = c(
    Date = "TEXT",
    Time = "TEXT",
    Global_active_power = "REAL",
    Global_reactive_power = "REAL",
    Voltage = "REAL",
    Global_intensity = "REAL",
    Sub_metering_1 = "REAL",
    Sub_metering_2 = "REAL",
    Sub_metering_3 = "REAL"
  )
  
  df = read.csv.sql(consumption_data, sql, header = T, sep = ";", field.types = field_types, filter = )
  
  dt = as.POSIXct(paste(df$Date, df$Time), format = "%d/%m/%Y %H:%M:%S")
  
  bind_cols(data.frame(DateTime = dt), df)
}

df = load_data()

png("plot3.png", width=480, height=480)

par(pin=c(5,5), mar = c(3,5,1,1))

# Plot 3
with(df, plot(Sub_metering_1 ~ DateTime, type = "l", xlab = "", ylab = "Energy sub metering"))
with(df, points(Sub_metering_2 ~ DateTime, type = "l", col = "red"))
with(df, points(Sub_metering_3 ~ DateTime, type = "l", col = "blue"))
legend("topright", pch = NA, lwd=1, lty=1, cex = 0.8, col = c("black", "red", "blue"), legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))

dev.off()