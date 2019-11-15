import Foundation

let curDate = Date()

let curDay = Calendar.current.component(.day , from: curDate)
var curWeekday = Calendar.current.component(.weekday, from: curDate) - 1
var curMonth = Calendar.current.component(.month, from: curDate) - 1
var curYear = Calendar.current.component(.year, from: curDate)
