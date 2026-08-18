import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Three concentric rings (months / dates / 60 tick marks) plus analog
// hour/minute/second hands, drawn from scratch every onUpdate. Angles
// everywhere in this file use the "polarPoint" convention: 0 degrees is
// 12 o'clock, increasing clockwise. This differs from Dc.drawArc's own
// convention (counterclockwise from 3 o'clock) -- not an issue here since
// no arcs are drawn, only lines and text.
class RingWatchFaceView extends WatchUi.WatchFace {

    private var _monthNames as Array<String>;

    private const MONTH_RADIUS_INSET = 8;
    private const DATE_RADIUS_INSET = 28;
    private const TICK_OUTER_INSET = 46;
    private const TICK_SHORT_INSET = 50;
    private const TICK_LONG_INSET = 52;

    function initialize() {
        WatchFace.initialize();
        _monthNames = [
            WatchUi.loadResource(Rez.Strings.Jan) as String,
            WatchUi.loadResource(Rez.Strings.Feb) as String,
            WatchUi.loadResource(Rez.Strings.Mar) as String,
            WatchUi.loadResource(Rez.Strings.Apr) as String,
            WatchUi.loadResource(Rez.Strings.May) as String,
            WatchUi.loadResource(Rez.Strings.Jun) as String,
            WatchUi.loadResource(Rez.Strings.Jul) as String,
            WatchUi.loadResource(Rez.Strings.Aug) as String,
            WatchUi.loadResource(Rez.Strings.Sep) as String,
            WatchUi.loadResource(Rez.Strings.Oct) as String,
            WatchUi.loadResource(Rez.Strings.Nov) as String,
            WatchUi.loadResource(Rez.Strings.Dec) as String,
        ];
    }

    // 0 deg = 12 o'clock, clockwise. Not private so the (:test) in
    // RingWatchFaceViewTests.mc can call it directly.
    function polarPoint(cx as Float, cy as Float, radius as Float, degrees as Float) as [Float, Float] {
        var rad = Math.toRadians(degrees);
        return [cx + radius * Math.sin(rad), cy - radius * Math.cos(rad)];
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2.0;
        var cy = height / 2.0;
        var r = (width < height ? width : height) / 2.0;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        drawTicks(dc, cx, cy, r);
        drawMonthRing(dc, cx, cy, r, now.month);
        drawDateRing(dc, cx, cy, r, now.day);
        drawHands(dc, cx, cy, r, now.hour, now.min, now.sec);
    }

    private function drawTicks(dc as Graphics.Dc, cx as Float, cy as Float, r as Float) as Void {
        var outerR = r - TICK_OUTER_INSET;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 60; i += 1) {
            var bold = (i % 5 == 0);
            var innerR = r - (bold ? TICK_LONG_INSET : TICK_SHORT_INSET);
            var angle = i * 6.0;
            var outer = polarPoint(cx, cy, outerR, angle);
            var inner = polarPoint(cx, cy, innerR, angle);
            dc.setPenWidth(bold ? 3 : 1);
            dc.drawLine(outer[0], outer[1], inner[0], inner[1]);
        }
        dc.setPenWidth(1);
    }

    private function drawMonthRing(dc as Graphics.Dc, cx as Float, cy as Float, r as Float, activeMonth as Number) as Void {
        var radius = r - MONTH_RADIUS_INSET;
        for (var i = 0; i < 12; i += 1) {
            var active = (i + 1 == activeMonth);
            var angle = i * 30.0;
            var p = polarPoint(cx, cy, radius, angle);
            dc.setColor(active ? Graphics.COLOR_ORANGE : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(p[0], p[1], active ? Graphics.FONT_TINY : Graphics.FONT_XTINY,
                _monthNames[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    private function drawDateRing(dc as Graphics.Dc, cx as Float, cy as Float, r as Float, activeDay as Number) as Void {
        var radius = r - DATE_RADIUS_INSET;
        var step = 360.0 / 31;
        for (var i = 0; i < 31; i += 1) {
            var active = (i + 1 == activeDay);
            var angle = i * step;
            var p = polarPoint(cx, cy, radius, angle);
            dc.setColor(active ? Graphics.COLOR_ORANGE : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(p[0], p[1], active ? Graphics.FONT_TINY : Graphics.FONT_XTINY,
                (i + 1).toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    private function drawHands(dc as Graphics.Dc, cx as Float, cy as Float, r as Float, hour as Number, min as Number, sec as Number) as Void {
        var hourAngle = (hour % 12) * 30.0 + min * 0.5;
        var minAngle = min * 6.0 + sec * 0.1;
        var secAngle = sec * 6.0;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        drawHand(dc, cx, cy, r * 0.5, hourAngle);
        dc.setPenWidth(3);
        drawHand(dc, cx, cy, r * 0.75, minAngle);

        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        drawHand(dc, cx, cy, r * 0.85, secAngle);
        dc.setPenWidth(1);
    }

    private function drawHand(dc as Graphics.Dc, cx as Float, cy as Float, length as Float, angle as Float) as Void {
        var tip = polarPoint(cx, cy, length, angle);
        dc.drawLine(cx, cy, tip[0], tip[1]);
    }
}
