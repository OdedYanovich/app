pub type Mods {
  Hub
  FightStart
  Fight
}

pub type Model {
  Model(Mods, key: String, volume: Int)
}

pub type Msg {
  Key(String)
}

pub fn init(flags) -> Model {
  Model(Hub, flags, 50)
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Key(key) -> {
      Model(
        Hub,
        key,
        model.volume
          + case key {
          "l" | "j" | "k" -> 1

          _ -> -1
        },
      )
    }
  }
}
