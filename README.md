https://yhara.github.io/clockcapsimulator/

## How does it work?

index.html contains all the system. `clock.svg` is not actually used because JavaScript cannot handle a svg file; instead, the content of `clock.svg` is copy&pasted into index.html so that you can modify it with JavaScript.

The core logic is this:

```js
  // Mapping from select id to svg areas.
  areas: {
    "clockcap-dial": ["id4"],
    "clockcap-numbers": ["id5", "id6", "id7", "id8"],
    "clockcap-crown": ["id12"],
    "clockcap-base": ["id3"],
    "clockcap-hand": ["id9", "id10", "id11"],
  },
```

This table defines the area in the svg to paint the selected color. For example, `"id4"` corresponds to the first `path` tag in the `<g id="id4">`. This `path` is filled with `rgb(255,255,102)` at first but will change its color when dial color is selected.

```svg
       <g id="id4">
        <rect class="BoundingBox" stroke="none" fill="none" x="4299" y="5399" width="11804" height="11804"/>
        <path fill="rgb(255,255,102)" stroke="none" d="M 5046,5400 C 4673,5400 4300,5773 4300,6146 L 4300,16453 C 4300,16826 4673,17200 5046,17200 L 15353,17200 C 15726,17200 16100,16826 16100,16453 L 16100,6146 C 16100,5773 15726,5400 15353,5400 L 5046,5400 Z M 4300,5400 L 4300,5400 Z M 16101,17201 L 16101,17201 Z"/>
```

## License

MIT
