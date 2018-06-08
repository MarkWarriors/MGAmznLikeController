# MGAmznLikeController
### Amazon Music Controller samples
In other words.. A Controller (for song or whatever you want) like the one at the bottom of the app Amazon Music.


![Alt Text](https://github.com/MarkWarriors/MGAmznLikeController/blob/master/appvideo.gif)


------



### SETUP


> - Copy MGAmaznLikeController.swift and MGAmaznLikeController.xib in your project
> - Add a UIView wherever you want and set its class as MGAmaznLikeController



------

### SETTINGS


```changeVibration(active: Bool, type: UIImpactFeedbackStyle? = nil)```

> This method let you turn on/off the vibration feedback of the device while using the controller and change the vibration feedback style



```setControllerImage(_ image: UIImage?, forStatus status: ControllerStatus)```

> This method is used to change the image at the center of the controller for a particular ControllerStatus. By default ControllerStatus is an enum with only 2 case, "play" and "pause"



```setControllerBackgroundImage(_ image: UIImage?)```

> This method is used to change the background image of the controller 



------

### DELEGATE METHODS


```didTapController(controllerStatus: MGAmznLikeController.ControllerStatus)```

> Called when the controller is tapped, providing the new status of the controller (default "play" or "pause" 



```didTapOnSubControllerAt(index: Int, sender: UIButton?)```

> Called when a button of the Sub Controller is pressed, providing the button and its index



```didTapOnTabBarAt(index: Int, sender: UIButton?)```

> Called when a button of the TabBar is pressed, providing the button and its index



```didPerformSwipeAction(trigger: MGAmznLikeController.ActionTriggered)```

> Called when a SwipeAction of the controller is triggered, and it provide what trigger is fired



```didOpenSubController()```

> Called when the SubController is become open and visible



```didCloseSubController()```

> Called when the SubController is become closed and not visible



```willOpenSubController()```

> Called when the SubController will become open and visible



```willCloseSubController()```

> Called when the SubController will become closed and not visible

