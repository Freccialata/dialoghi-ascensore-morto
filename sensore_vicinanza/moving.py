class MovingMax:
    WINDOW_SIZE = 25
    THRESHOLD = 500

    def __init__(self):
        self.window = []
        self.moving_max = 700

    def calc_moving_max(self, val):
        if val < self.THRESHOLD:
            return self.moving_max
        self.window.append(val)
        if len(self.window) >= self.WINDOW_SIZE:
            self.window.pop(0)
            self.moving_max = round(max(self.window))
        return self.moving_max
