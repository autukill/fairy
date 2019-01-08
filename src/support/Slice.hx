package support;

@:forward
@:access(SliceImpl)
abstract Slice<T>(SliceImpl<T>) from SliceImpl<T>{

    public inline function new(?arrayRef:Array<T>) {
        this = new SliceImpl(arrayRef);
    }

    @:arrayAccess
    public inline function getAccessor(index:Int):T {
        return this.array[index];
    }

    @:arrayAccess
    public inline function setAccessor(index:Int, value:T):T {
        this.array[index] = value;
        return value;
    }
}

@:native("slice")
@:keep
class SliceImpl<T> {
    public var array:Array<T>;

    public var length (get, never):Int;

    @:native("length")
    private function get_length() {
        return this.array.length;
    }

    public function new(?arrayRef:Array<T>) {
        if (arrayRef == null) this.array = new Array<T>();
        else this.array = arrayRef;
    }

    public function setArray(arrayRef:Array<T>) {
        this.array = arrayRef;
    }

    public function get(index:Int) {
        return this.array[index];
    }

    public function set(index:Int, value:T):T {
        this.array[index] = value;
        return value;
    }

    @:native("string")
    public function toString():String return this.array.toString();

    public function push(value:T):Int return this.array.push(value);

    public function unshift(value:T) return this.array.unshift(value);

    public function insert(pos:Int, value:T):Void this.array.insert(pos, value);

    @:native("index")
    public function indexOf(val:T, i:Int = 0):Int return this.array.indexOf(val, i);

    @:native("last_index")
    public function lastIndexOf(val:T, i:Int = -1):Int return this.array.lastIndexOf(val, i);

    // 附加元素后返回一个新的 slice, 原 slice 不变
    public function concat(arr:Array<T>):Slice<T> return new Slice<T>(this.array.concat(arr));

    public function join(sep:String):String return this.array.join(sep);

    public function reverse():Void this.array.reverse();

    public function slice(pos:Int, ?end:Int):Slice<T> return new Slice(this.array.slice(pos, end));

    public function copy():Slice<T> return new Slice(this.array.copy());

    public function sort(fn:T -> T -> Int):Void this.array.sort(fn);

    public function map<S>(fn:T -> S):Slice<S> return new Slice(this.array.map(fn));

    public function filter(fn:T -> Bool):Slice<T> return new Slice(this.array.filter(fn));

    // 移除最后一个元素并返回它
    public function pop():Null<T> {
        var len = this.array.length;
        if (len == 0) return null;
        var lastOne = this.array[len - 1];
        this.array = this.array.slice(0, len - 1);
        return lastOne;
    }

    // 移除第一个元素并返回它
    public function shift():Null<T> {
        var len = this.array.length;
        if (len == 0) return null;
        var firstOne = this.array[0];
        this.array = this.array.slice(1, len);
        return firstOne;
    }

    // 移除第一次出现的 v
    public function remove(v:T):Bool {
        var index = this.array.indexOf(v);
        if (index == -1) return false;
        this.array = this.array.slice(index, index + 1);
        return true;
    }
    // 从 pos 位置开始移除 len 长度的元素,包括 pos 索引,然后返回它们
    public function splice(pos:Int, len:Int):Slice<T> {
        var arrayLength = this.array.length;
        if (len < 0 || pos >= arrayLength) return new Slice<T> ();
        if (pos < 0) {
            pos += len;
            if (pos < 0) pos = 0;
        }
        if (pos + len > arrayLength) len = arrayLength - pos;
        var end = pos + len;
        var old = this.array;
        this.array = new Array();
        var out = new Slice();
        for (i in 0...arrayLength) {
            if (i >= pos && i < end) {
                out.push(old[i]);
            } else {
                this.array.push(old[i]);
            }
        }
        return out;
    }

    public inline function iterator():Iterator<T> {
        return new SliceIterator(this);
    }
}

@:native("slice_hx_iterator")
@:nativeGen private class SliceIterator<T> {
    public function new(sliceRef:Slice<T>) {
        this.slice = sliceRef;
        this.index = 0;
    }

    public dynamic function hasNext():Bool {
        return index < this.slice.length;
    }

    public dynamic function next():T {
        return slice.get(index++);
    }
    public var slice:Slice<T>;
    public var index:Int;
}