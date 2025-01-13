# godot-swipe-controller
I recently created a cross-platform mobile app: [https://play.google.com/store/apps/details?id=com.cedricmaume.factor36&hl=en](Factor36) using Godot 4.3. For tihs I needed a responsive input handler to differentiate between taps and swipes. This can be done many different ways, but for my game it was important that the delay between swiping and it registering was small while still having a deadzone.

### Features
- Tap Threshold
- Swipe Threshold
- Dead Zones at the top and bottom of the display (To allow for mobile OS navigation gestures)
- Angle Deadzone (So that a 45 degree swipe is not counted as horizontal or vertical, as this is not clear enough of an input)


### How to recognize swiping
There is a far easier way to recognize a swipe which I used initially. This method waited until the last `InputEventScreenDrag` was fired and the player let go of the screen. It would then send the swipe signal. This meant that I player would have already finished the entire move of the finger before any animation actually happened on screen, which felt slow and laggy. The second method I used was to use the `relative` parameter returned by an `InputEventScreenDrag` in order to respond more quickly but this had the problem that slow swipes would'nt register as the value would be very small for that specific input poll. 

This new method of detecting swipes works way better and is what I should have come up with from the start. Here is how it works.
- When Touching the screen for the first time, an `InputEventScreenTouch` is returned with the `event.pressed` parameter being `true`. We then set a flag that the touch sequence has start and note the starting position
- Once the player releases the screen, another `InputEventScreenTouch` event is returned only with the `event.pressed` set to false. We can therefore end the sequence and check to make sure the distance between first and last contact are beneath a specified threshold.
- If a player swipes instead, godot returns `InputEventScreenDrag` events at a specific interval with many different parameters. We continue to check to see if the current drag is far enough away from our initial `InputEventScreenTouch` and once it is we ignore all future drags and send the signal. This allows us to drag as slowly as we want and always respect the deadzone while allowing for a relatively small deadzone compared to the relative approach.

##### Example Events:
InputEventScreenDrag:
```gdscript
# InputEventScreenTouch: index=0, pressed=false, canceled=false, position=((877.2363, 871.875)), double_tap=false
```

InputEventScreenTouch:
```gdscript
# InputEventScreenDrag: index=0, position=((669.7266, 2286.914)), relative=((-1.054688, -1.171875)), velocity=((0, 0)), pressure=1.00
```


### Usage
There are two ways to use this in your project (Created in godot 4.3 but should work for other versions as well)

1. Load the scene file (.tscn) into your scene as a child. It includes the script and you can connect to the signals that it emits
2. Create a control node in your scene and attach the script (.gd). Connect to the scripts signal in other scripts

##### Epilogue
I know this is a pretty small and simple thing, but it took me a few tries to figure out a system I liked with parameters that felt natural. I hope this can serve as a basis for your mobile project
