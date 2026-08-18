import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class RingWatchFaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as Array<WatchUi.Views or WatchUi.InputDelegates>? {
        return [new RingWatchFaceView()] as Array<WatchUi.Views or WatchUi.InputDelegates>;
    }
}
