import Toybox.Test;
import Toybox.Lang;

function nearlyEqual(a as Float, b as Float) as Boolean {
    var diff = a - b;
    return diff > -0.001 && diff < 0.001;
}

// The only non-trivial logic in this project is the angle math, so it's
// the only thing that gets a regression check.
(:test)
function polarPointTest(logger as Test.Logger) as Boolean {
    var view = new RingWatchFaceView();
    var top = view.polarPoint(0.0, 0.0, 10.0, 0.0);
    var right = view.polarPoint(0.0, 0.0, 10.0, 90.0);
    var bottom = view.polarPoint(0.0, 0.0, 10.0, 180.0);
    var left = view.polarPoint(0.0, 0.0, 10.0, 270.0);

    if (!nearlyEqual(top[0], 0.0) || !nearlyEqual(top[1], -10.0)) {
        logger.debug("top wrong: " + top);
        return false;
    }
    if (!nearlyEqual(right[0], 10.0) || !nearlyEqual(right[1], 0.0)) {
        logger.debug("right wrong: " + right);
        return false;
    }
    if (!nearlyEqual(bottom[0], 0.0) || !nearlyEqual(bottom[1], 10.0)) {
        logger.debug("bottom wrong: " + bottom);
        return false;
    }
    if (!nearlyEqual(left[0], -10.0) || !nearlyEqual(left[1], 0.0)) {
        logger.debug("left wrong: " + left);
        return false;
    }
    return true;
}

(:test)
function ringStepConstantsTest(logger as Test.Logger) as Boolean {
    var monthStep = 30.0;
    var dateStep = 360.0 / 31;
    var tickStep = 6.0;

    if (!nearlyEqual(monthStep * 12, 360.0)) {
        logger.debug("month step doesn't divide 360 evenly");
        return false;
    }
    if (!nearlyEqual(dateStep * 31, 360.0)) {
        logger.debug("date step doesn't divide 360 evenly");
        return false;
    }
    if (!nearlyEqual(tickStep * 60, 360.0)) {
        logger.debug("tick step doesn't divide 360 evenly");
        return false;
    }
    return true;
}
