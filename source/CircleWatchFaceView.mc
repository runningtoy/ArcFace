import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.System;
import Toybox.Weather;
import Toybox.WatchUi;
using Toybox.ActivityMonitor;
import Toybox.Position;
using Toybox.Time.Gregorian;

//https://developer.garmin.com/connect-iq/reference-guides/devices-reference/

var width, height, shape, device, screenRadius;

var COLOR_BATTERY = 0x00ff55;
var COLOR_BATTERY_LOW = 0xff5500;
var COLOR_STEPS = 0xffffff;
var COLOR_FLOORS = 0xff55aa;
var COLOR_RECOVERYTIME = 0xffff00;
var partialUpdates = true;
var partialUpdatesHR = true;

class CircleWatchFaceView extends WatchUi.WatchFace {
  function initialize() {
    partialUpdates = Toybox.WatchUi.WatchFace has :onPartialUpdate;
    WatchFace.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.WatchFace(dc));
    //
    device = System.getDeviceSettings();
    height = dc.getHeight();
    width = dc.getWidth();
    screenRadius = width / 2;

    shape = device.screenShape;
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  function onPartialUpdate(dc) {
    if (partialUpdates) {
      dc.setClip(107, 166, 50, 30);
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
      dc.fillRectangle(107, 166, 50, 30);
      var view = View.findDrawableById("SecLabel") as Text;
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
      var seconds = System.getClockTime().sec;
      view.setText(seconds.format("%02d"));
      view.draw(dc);
      if (seconds % 5 == 0 && partialUpdatesHR) {
        dc.setClip(109, 40, 50, 25);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(109, 40, 50, 25);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        drawHRValuePartialUpdate(dc);
      }
    }

    // var clockTime = System.getClockTime();
    // // if (dataField == exactTime) {
    // // WatchUi.requestUpdate();
    // // }
    // // else if (clockTime.sec == 30) {
    // // WatchUi.requestUpdate();
    // // }
    // var view = View.findDrawableById("SecLabel") as Text;
    // view.setText(clockTime.sec.format("%02d"));
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // var activityInfo;
    // activityInfo = ActivityMonitor.getInfo();
    // var steps_percentage as Lang.Number = activityInfo.steps/activityInfo.stepGoal;
    // var battery_percentage as Lang.Number = System.getSystemStats().battery;

    // var dataString = (System.getSystemStats().battery + 0.5).format("%d") + " %";
    // clear the screen
    dc.clearClip();
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    // Get and show the current time
    var clockTime = System.getClockTime();
    var timeString = Lang.format("$1$:$2$", [
      clockTime.hour,
      clockTime.min.format("%02d"),
    ]);
    var view = View.findDrawableById("TimeLabel") as Text;
    view.setText(timeString);

    drawSunriseSunset();

    view = View.findDrawableById("DateLabel") as Text;
    view.setText(
      Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM).day_of_week +
        " " +
        Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM).day
    );

    view = View.findDrawableById("SecLabel") as Text;
    view.setText(clockTime.sec.format("%02d"));

    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);

    drawStep(dc);
    drawBattery(dc);
    drawTimeToRecovery(dc);
    // drawFloor(dc);
    drawHR(dc);
    drawBluetooth(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {
    Toybox.WatchUi.requestUpdate();
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() as Void {}

  function drawWatchARC(dc, percentage, arcColor, limitColor, offset) {
    var arcPenWidth = 1;
    var arcRadius = screenRadius - arcPenWidth / 2;
    dc.setPenWidth(arcPenWidth);
    if (percentage > 22) {
      arcRadius = screenRadius - offset - arcPenWidth / 2;
      dc.setColor(arcColor, Graphics.COLOR_TRANSPARENT);
      dc.drawArc(
        screenRadius,
        screenRadius,
        arcRadius,
        Graphics.ARC_COUNTER_CLOCKWISE,
        360 - 3.2 * (percentage - 22),
        0
      );
      dc.drawArc(
        screenRadius,
        screenRadius,
        arcRadius,
        Graphics.ARC_CLOCKWISE,
        70,
        70 - 3.2 * percentage
      );

      arcRadius = screenRadius - 1 - offset - arcPenWidth / 2;
      dc.drawArc(
        screenRadius,
        screenRadius,
        arcRadius,
        Graphics.ARC_COUNTER_CLOCKWISE,
        359 - 3.2 * (percentage - 22),
        1
      );
      dc.drawArc(
        screenRadius,
        screenRadius,
        arcRadius,
        Graphics.ARC_CLOCKWISE,
        69,
        70 - 3.2 * percentage
      );

      arcRadius = screenRadius - 2 - offset - arcPenWidth / 2;
      dc.drawArc(
        screenRadius,
        screenRadius,
        arcRadius,
        Graphics.ARC_COUNTER_CLOCKWISE,
        358 - 3.2 * (percentage - 22),
        2
      );
      dc.drawArc(
        screenRadius,
        screenRadius,
        arcRadius,
        Graphics.ARC_CLOCKWISE,
        68,
        70 - 3.2 * percentage
      );

      arcRadius = screenRadius - 3 - offset - arcPenWidth / 2;
      dc.drawArc(
        screenRadius,
        screenRadius,
        arcRadius,
        Graphics.ARC_COUNTER_CLOCKWISE,
        359 - 3.2 * (percentage - 22),
        1
      );
      dc.drawArc(
        screenRadius,
        screenRadius,
        arcRadius,
        Graphics.ARC_CLOCKWISE,
        69,
        70 - 3.2 * percentage
      );

      arcRadius = screenRadius - 4 - offset - arcPenWidth / 2;
      dc.drawArc(
        screenRadius,
        screenRadius,
        arcRadius,
        Graphics.ARC_COUNTER_CLOCKWISE,
        360 - 3.2 * (percentage - 22),
        0
      );
      dc.drawArc(
        screenRadius,
        screenRadius,
        arcRadius,
        Graphics.ARC_CLOCKWISE,
        70,
        70 - 3.2 * percentage
      );
    } else {
      arcRadius = screenRadius - offset - arcPenWidth / 2;
      dc.setColor(limitColor, Graphics.COLOR_TRANSPARENT);
      dc.drawArc(
        screenRadius,
        screenRadius,
        arcRadius,
        Graphics.ARC_CLOCKWISE,
        70,
        70 - 3.2 * percentage + 1
      );

      arcRadius = screenRadius - 1 - offset - arcPenWidth / 2;
      dc.drawArc(
        screenRadius,
        screenRadius,
        arcRadius,
        Graphics.ARC_CLOCKWISE,
        69,
        70 - 3.2 * percentage + 2
      );

      arcRadius = screenRadius - 2 - offset - arcPenWidth / 2;
      dc.drawArc(
        screenRadius,
        screenRadius,
        arcRadius,
        Graphics.ARC_CLOCKWISE,
        68,
        70 - 3.2 * percentage
      );

      arcRadius = screenRadius - 3 - offset - arcPenWidth / 2;
      dc.drawArc(
        screenRadius,
        screenRadius,
        arcRadius,
        Graphics.ARC_CLOCKWISE,
        69,
        70 - 3.2 * percentage + 1
      );

      arcRadius = screenRadius - 4 - offset - arcPenWidth / 2;
      dc.drawArc(
        screenRadius,
        screenRadius,
        arcRadius,
        Graphics.ARC_CLOCKWISE,
        70,
        70 - 3.2 * percentage + 2
      );
    }
  }

  function drawBattery(dc) {
    var batStat = System.getSystemStats().battery;

    if (batStat > 100) {
      batStat = 100;
    }
    if (batStat < 1) {
      batStat = 1;
    }

    // drawARC(dc, batStat, Graphics.COLOR_GREEN, Graphics.COLOR_RED, 0);
    drawWatchARC(dc, batStat, COLOR_BATTERY, COLOR_BATTERY_LOW, 0);
  }
  function drawStep(dc) {
    var activityInfo;
    activityInfo = ActivityMonitor.getInfo();
    var activityInfo_steps as Double.Number = activityInfo.steps.toDouble();
    var activityInfo_stepGoal as Double.Number =
      activityInfo.stepGoal.toDouble();
    var steps_percentage as Double.Number =
      activityInfo_steps / activityInfo_stepGoal;
    steps_percentage = steps_percentage * 100;
    if (steps_percentage > 100) {
      steps_percentage = 100;
    }
    if (steps_percentage < 1) {
      steps_percentage = 1;
    }
    drawWatchARC(dc, steps_percentage, COLOR_STEPS, COLOR_STEPS, 7);
  }

  // function drawFloor(dc) {
  //     var activityInfo;
  //     activityInfo = ActivityMonitor.getInfo();
  //     var activityInfo_floorsClimbed as Double.Number = activityInfo.floorsClimbed.toDouble();
  //     var activityInfo_floorsClimbedGoal as Double.Number = activityInfo.floorsClimbedGoal.toDouble();
  //     var floor_percentage as Double.Number = (activityInfo_floorsClimbed/activityInfo_floorsClimbedGoal);
  //     floor_percentage=floor_percentage*100;
  //     if(floor_percentage>100){floor_percentage=100;}
  //     if(floor_percentage<1){floor_percentage=1;}
  //     drawWatchARC(dc, floor_percentage, COLOR_FLOORS, COLOR_FLOORS, 15);
  // }

  function drawTimeToRecovery(dc) {
    var activityInfo;
    activityInfo = ActivityMonitor.getInfo();
    var activityInfo_timeToRecovery as Double.Number =
      activityInfo.timeToRecovery.toDouble();
    var activityInfo_timeToRecoveryGoal as Double.Number = (48).toDouble();
    var timeToRecovery_percentage as Double.Number =
      activityInfo_timeToRecovery / activityInfo_timeToRecoveryGoal;
    timeToRecovery_percentage = timeToRecovery_percentage * 100;
    timeToRecovery_percentage = 100 - timeToRecovery_percentage;
    if (timeToRecovery_percentage > 100) {
      timeToRecovery_percentage = 100;
    }
    if (timeToRecovery_percentage < 1) {
      timeToRecovery_percentage = 1;
    }

    var loc_COLOR_RECOVERYTIME = COLOR_RECOVERYTIME;
    if (timeToRecovery_percentage > 99) {
      loc_COLOR_RECOVERYTIME = COLOR_YELLOW;
    }

    drawWatchARC(
      dc,
      timeToRecovery_percentage,
      loc_COLOR_RECOVERYTIME,
      loc_COLOR_RECOVERYTIME,
      15
    );
  }

  function drawBluetooth(dc) {
    var view = View.findDrawableById("BLE") as WatchUi.Drawable;
    view.setVisible(Toybox.System.getDeviceSettings().phoneConnected);
  }

  function drawSunriseSunset() {
    // var positionInfo = Activity.getActivityInfo().currentLocation;
    var positionInfo = Toybox.Position.getInfo();
    if (positionInfo != null && positionInfo.position != null) {
      var loc = positionInfo.position.toRadians();
      var hasLocation =
        (loc[0].format("%.2f").equals("3.14") &&
          loc[1].format("%.2f").equals("3.14")) ||
        (loc[0] == 0 && loc[1] == 0)
          ? false
          : true;
      if (hasLocation) {
        var sunrise = Weather.getSunrise(positionInfo.position, Time.now());
        var sunset = Weather.getSunset(positionInfo.position, Time.now());
        var showTime = null;
        showTime = Gregorian.info(sunrise, Time.FORMAT_MEDIUM);
        if (Time.now().greaterThan(sunrise)) {
          showTime = Gregorian.info(sunset, Time.FORMAT_MEDIUM);
        }
        var timeString = Lang.format("$1$:$2$", [
          showTime.hour,
          showTime.min.format("%02d"),
        ]);
        var view = View.findDrawableById("SunRiseSet") as Text;
        view.setText(timeString);
      }
    }
  }

  function drawHR(dc) {
    var dataString = "";
    if (ActivityMonitor has :getHeartRateHistory) {
      dataString = Activity.getActivityInfo().currentHeartRate;
      var view = View.findDrawableById("HRImage") as WatchUi.Drawable;
      if (dataString != null) {
        view.setVisible(true);
        view = View.findDrawableById("HRLabel") as Text;
        view.setText(dataString.format("%03d"));
        view.setVisible(true);
      } else {
        view.setVisible(false);
        view = View.findDrawableById("HRLabel") as Text;
        view.setVisible(false);
      }
    }
  }

  function drawHRValuePartialUpdate(dc) {
    var dataString = "";
    if (ActivityMonitor has :getHeartRateHistory) {
      dataString = Activity.getActivityInfo().currentHeartRate;
      if (dataString != null) {
        var view = View.findDrawableById("HRLabel") as Text;
        view.setText(dataString.format("%03d"));
        view.draw(dc);
      }
    }
  }

  function onPowerBudgetExceeded(powerInfo) {
    if (partialUpdatesHR == false) {
      partialUpdates = false;
    }
    partialUpdatesHR = false;
  }
}
