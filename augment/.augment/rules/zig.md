# Zig Guidelines

`errdefer` for cleanup. Explicit allocators. ArrayList unmanaged (`.empty` + pass allocator).
Match allocation to lifetime. Make invalid states unrepresentable.

## ArrayList (Zig 0.15)
```zig
// DO
pub const Engine = struct {
    items: std.ArrayList(Item),
    pub fn init(allocator: std.mem.Allocator) Engine {
        return .{ .allocator = allocator, .items = .empty };
    }
    pub fn deinit(self: *Engine) void { self.items.deinit(self.allocator); }
};
// DON'T: std.ArrayList(u32).init(allocator)  -- deprecated
```

## Allocation Strategy
```
Multiple temp allocs same lifetime? -> Arena
Single temp? -> defer free
Long-lived struct? -> deinit pattern
Size known upfront? -> initCapacity
Refreshing data? -> clearRetainingCapacity
```

## errdefer (multi-resource init)
```zig
pub fn init(allocator: std.mem.Allocator) !AppContext {
    try sdl.init(sdl.SDL_INIT_VIDEO);
    errdefer sdl.quit();
    const window = try sdl.createWindow("App", 1200, 800, 0);
    errdefer sdl.destroyWindow(window);
    const renderer = try sdl.createRenderer(window, null);
    errdefer sdl.destroyRenderer(renderer);
    return .{ .window = window, .renderer = renderer };
}
// DON'T: manual cleanup on every error path (fragile)
```

## Type Casting
```zig
// DO: explicit type annotation
const width: u32 = @intCast(surface.w);
const text_width: f32 = @floatFromInt(size.w);
// DON'T: const width = @as(u32, @intCast(surface.w));
```

## C Interop
- C strings: `[*:0]const u8` (sentinel-terminated)
- Convert: `allocator.dupeZ(u8, slice)` + `defer allocator.free(z)`
- Error types: specific `error{ InitFailed, AllocFailed }`

## Checklist
- [ ] ArrayList uses `.empty`?
- [ ] Allocator passed explicitly?
- [ ] errdefer for multi-resource init?
- [ ] Type annotations instead of nested @as casts?
