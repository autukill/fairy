package core;

import gml.gpu.Texture;
import gml.RawAPI;
import gml.io.BufferType;
import gml.io.BufferKind;
import gml.io.Buffer;
import gml.assets.Sprite;
import gml.gpu.Surface;
import geom.Rectangle;

@:keep
@:native("ntexture")
class NTexture {
    public static var Empty(get, null):NTexture;

    private static var _empty:NTexture = null;

    public var uvRect:Rectangle;
    public var refCount:Int;
    public var lastActive:Float;

    public var root(get, null):NTexture;
    public var width(get, null):Float;
    public var height(get, null):Float;
    public var nativeTexure(get, null):Texture;

    private var _sprite:Sprite = null; // gml Sprite, has texture
    private var _spriteImgIndex:Int = 0;
    private var _nativeTexture:Texture = null; // if it jsut is surface (volatile), then its not sprite
    private var _root:NTexture = null;
    private var _region:Rectangle;

    public static function createEmptyTexture():Sprite {
        var surface = new Surface(1, 1);
        var buffer = new Buffer(4, BufferKind.Fixed, 1);
        buffer.fill(0, BufferType.u8, 255, 4);
        RawAPI.buffer_set_surface(buffer, surface, 0, 0, 0);
        var spr = RawAPI.sprite_create_from_surface(surface, 0, 0, 1, 1, false, false, 0, 0);
        buffer.destroy();
        surface.destroy();
        return spr;
    }

    private static function get_Empty():NTexture {
        if (_empty == null) {
            var spr = createEmptyTexture();
            _empty = createFromSprite(spr);
        }
        return _empty;
    }

    private function new() {}

    public static function createFromSprite(spr:Sprite, subimg:Int = 0, ?region:Rectangle, xScale:Int = 1, yScale:Int = 1):NTexture {
        var that = new NTexture();

        that._root = that;
        that._sprite = spr;
        that._spriteImgIndex = subimg;

        var texture = RawAPI.sprite_get_texture(spr, subimg);
        var textureWidth = 1 / RawAPI.texture_get_texel_width(texture);
        var textureHeight = 1 / RawAPI.texture_get_texel_height(texture);

        that._nativeTexture = texture;

        if (region != null) {
            that._region = region;
            that.uvRect = new Rectangle(
            region.x / textureWidth,
            region.y / textureHeight,
            region.width / textureWidth,
            region.height / textureHeight
            );
        } else {
            that._region = new Rectangle(0, 0, textureWidth, textureHeight);
            that.uvRect = new Rectangle(0, 0, xScale, yScale);
        }

        return that;
    }

    public static function createFromRootRegion(root:NTexture, region:Rectangle):NTexture {
        var that = new NTexture();
        that._root = root;

        region.x += root._region.x;
        region.y += root._region.y;
        that._region = region;

        that.uvRect = new Rectangle(
        region.x * root.uvRect.width / root.width,
        region.y * root.uvRect.height / root.height,
        region.width * root.uvRect.width / root.width,
        region.height * root.uvRect.height / root.height
        );

        return that;
    }

    private function get_root():NTexture {
        return this._root;
    }

    private function get_width():Float {
        return this._region.width;
    }

    private function get_height():Float {
        return this._region.height;
    }

    private function get_nativeTexure():Texture {
        return this._root != null ? this._root._nativeTexture : null;
    }
}
