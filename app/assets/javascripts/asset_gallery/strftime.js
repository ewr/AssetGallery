// from https://gist.github.com/1046427
Date.prototype.strftime = function(format) {
  var options = {
    "day_names": ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],
    "abbr_day_names": ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],
    "month_names": [null,"January","February","March","April","May","June","July","August","September","October","November","December"],
    "abbr_month_names": [null,"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
  }

  var date = this;

  if (!options) {
    return date.toString();
  }

  options.meridian = options.meridian || ["AM", "PM"];

  var weekDay = date.getDay();
  var day = date.getDate();
  var year = date.getFullYear();
  var month = date.getMonth() + 1;
  var hour = date.getHours();
  var hour12 = hour;
  var meridian = hour > 11 ? 1 : 0;
  var secs = date.getSeconds();
  var mins = date.getMinutes();
  var offset = date.getTimezoneOffset();
  var absOffsetHours = Math.floor(Math.abs(offset / 60));
  var absOffsetMinutes = Math.abs(offset) - (absOffsetHours * 60);
  var timezoneoffset = (offset > 0 ? "-" : "+") + (absOffsetHours.toString().length < 2 ? "0" + absOffsetHours : absOffsetHours) + (absOffsetMinutes.toString().length < 2 ? "0" + absOffsetMinutes : absOffsetMinutes);

  if (hour12 > 12) {
    hour12 = hour12 - 12;
  } else if (hour12 === 0) {
    hour12 = 12;
  }

  var padding = function(n) {
    var s = "0" + n.toString();
    return s.substr(s.length - 2);
  };

  var f = format;
  f = f.replace("%a", options.abbr_day_names[weekDay]);
  f = f.replace("%A", options.day_names[weekDay]);
  f = f.replace("%b", options.abbr_month_names[month]);
  f = f.replace("%B", options.month_names[month]);
  f = f.replace("%d", padding(day));
  f = f.replace("%-d", day);
  f = f.replace("%H", padding(hour));
  f = f.replace("%-H", hour);
  f = f.replace("%I", padding(hour12));
  f = f.replace("%-I", hour12);
  f = f.replace("%m", padding(month));
  f = f.replace("%-m", month);
  f = f.replace("%M", padding(mins));
  f = f.replace("%-M", mins);
  f = f.replace("%p", options.meridian[meridian]);
  f = f.replace("%S", padding(secs));
  f = f.replace("%-S", secs);
  f = f.replace("%w", weekDay);
  f = f.replace("%y", padding(year));
  f = f.replace("%-y", padding(year).replace(/^0+/, ""));
  f = f.replace("%Y", year);
  f = f.replace("%z", timezoneoffset);

  return f;
};