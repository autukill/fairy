package events;

interface IEventDispatcher {

    public function addEventListener (type:String, listener:Dynamic->Void, useCapture:Bool = false, priority:Int = 0):Void;
    public function dispatchEvent (event:Event):Bool;
    public function hasEventListener (type:String):Bool;
    public function removeEventListener (type:String, listener:Dynamic->Void, useCapture:Bool = false):Void;
    public function willTrigger (type:String):Bool;

}