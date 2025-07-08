import dayjs from 'dayjs'
const DEFAULT_FORMAT = 'YYYY-MM-DD HH:mm:ss'

export const longToIso = (long) => dayjs(Number(long)).format()
export const longToString = (long, format = DEFAULT_FORMAT) => dayjs(Number(long)).format(format)
export const longToDate = (long) => dayjs(Number(long)).toDate()
export const isoToDate = (iso) => dayjs(iso).toDate()
export const isoToString = (iso, format = DEFAULT_FORMAT) => dayjs(iso).format(format)
export const isoToLong = (iso) => dayjs(iso).valueOf()
export const dateToIso = (date) => dayjs(date).format()
export const dateToString = (date, format = DEFAULT_FORMAT) => dayjs(date).format(format)
export const dateToLong = (date) => dayjs(date).valueOf()
export const dateToYYMMDD = (date, format = 'YYYY-MM-DD') => dayjs(date).format(format)
export const todayToYYMMDD = () => dateToYYMMDD(new Date())
export const stringToIso = (string) => dayjs(string).format()
export const stringToDate = (string) => dayjs(string).toDate()
export const stringToLong = (string) => dayjs(string).valueOf()
export const dayjsToIso = (dayObj) => dayObj.format()
export const dayjsToString = (dayObj, format = DEFAULT_FORMAT) => dayObj.format(format)
export const dayjsToDate = (dayObj) => dayObj.toDate()
export const dayjsToLong = (dayObj) => dayObj.valueOf()
export const anyToDayjs = (arg) => dayjs(arg)

function setTime(dateObj, hour, minute, second, millSec) {
  const dateClone = new Date(dateObj)
  dateClone.setHours(hour, minute, second, millSec)
  return dateClone
}

export const dateAddYears = (dateObj, years = 0) => dayjs(dateObj).add(years, 'year').toDate()
export const dateAddMonths = (dateObj, months = 0) => dayjs(dateObj).add(months, 'month').toDate()
export const dateAddDays = (dateObj, days = 0) => dayjs(dateObj).add(days, 'day').toDate()
export const dateAddHours = (dateObj, hours = 0) => dayjs(dateObj).add(hours, 'hour').toDate()
export const dateAddMinutes = (dateObj, minutes = 0) => dayjs(dateObj).add(minutes, 'minute').toDate()
export const dateAddSeconds = (dateObj, seconds = 0) => dayjs(dateObj).add(seconds, 'second').toDate()

export const startOfDate = (dateObj) => dateObj && setTime(dateObj, 0, 0, 0, 0)
export const endOfDate = (dateObj) => dateObj && setTime(dateObj, 23, 59, 59, 999)
