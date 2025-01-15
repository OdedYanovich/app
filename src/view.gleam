import behavior.{type Model, type Msg, Fight, FightStart, Hub, volume_buttons}
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html

fn text_to_element(text: List(String)) {
  use text <- list.map(text)
  html.div([], [html.text(text)])
}

pub fn view(model: Model) -> element.Element(Msg) {
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
        #("padding", "1rem"),
        #("box-sizing", "border-box"),
      ]),
    //   attribute.rel("stylesheet"),
    // attribute.href("/priv/static/style.css"),
    ],
    case model.mod {
      Hub -> {
        [
          "z fight",
          "x reset dungeon",
          "c credits",
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
                #("grid-auto-flow", "column"),
                #("grid-template", "repeat(2, 1fr) / repeat(8, 1fr)"),
                #("place-items", "center;"),
                #("width", "100%;"),
                #("height", "100%;"),
              ]),
              attribute.class("t"),
            ],
            volume_buttons
              |> list.flat_map(fn(x) { [x.0, int.to_string(x.1)] })
              |> text_to_element,
          ),
        ])
        // |> list.append([
        //   html.img([attribute.src("https://cdn2.thecatapi.com/images/b7k.jpg")]),
        // ])
      }
      Fight -> {
        todo
      }
      FightStart -> {
        ["z Hub"]
        |> text_to_element
      }
    },
  )
}
