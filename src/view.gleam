import behavior.{type Model, type Msg, Fight, FightStart, Hub}
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html

pub fn view(model: Model) -> element.Element(Msg) {
  case model.mod {
    Hub -> {
      html.div(
        [
          attribute.style([
            #("display", "grid"),
            #("grid-template", "repeat(5, 1fr) / repeat(2, 1fr)"),
            #("place-items", "center;"),
            #("grid-auto-flow", "column"),
            #("height", "100vh"),
            #("background-color", "black"),
            #("color", "white"),
            #("font-size", "1.6rem"),
          ]),
        ],
        [
          "q fight",
          "w reset dungeon",
          "v credits",
          "made by Oded Yanovich",
          model.key,
          int.to_string(model.volume),
        ]
          |> list.map(fn(text) { html.div([], [html.text(text)]) })
          |> list.append([
            html.div(
              [
                attribute.style([
                  #("display", "grid"),
                  #("grid-template", "repeat(2, 1fr) / repeat(8, 1fr)"),
                  #("place-items", "center;"),
                  #("padding", "0"),
                  #("border", "0"),
                ]),
              ],
              [
                "l", "k", "j", "h", "y", "u", "i", "o", "-25", "-10", "-5", "-1",
                "+1", "+5", "+10", "+25",
              ]
                |> list.map(fn(text) { html.div([], [html.text(text)]) }),
            ),
          ]),
        // |> list.append([
      //   html.img([attribute.src("https://cdn2.thecatapi.com/images/b7k.jpg")]),
      // ]),
      )
    }
    FightStart -> {
      html.div(
        [
          attribute.style([
            #("display", "grid"),
            #("grid-template", "repeat(5, 1fr) / repeat(2, 1fr)"),
            #("place-items", "center;"),
            #("grid-auto-flow", "column"),
            #("height", "100vh"),
            #("background-color", "black"),
            #("color", "white"),
            #("font-size", "1.6rem"),
          ]),
        ],
        ["a Hub"]
          |> list.map(fn(text) { html.div([], [html.text(text)]) }),
      )
    }
    Fight -> {
      todo
    }
  }
}
