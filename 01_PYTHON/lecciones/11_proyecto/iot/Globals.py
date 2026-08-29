class GlobalState:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._init()
        return cls._instance

    def _init(self):
        self.temperature = 0.0
        self.humidity = 0.0
        # ... add more global variables as needed
        self.local_error_message = ""


shared = GlobalState()
