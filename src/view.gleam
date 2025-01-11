import behavior.{type Model, type Msg}
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html

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
      ]),
    ],
    [
      #("z start fight", "hub"),
      #("x reset dungeon", "hub"),
      #("c delete progress", "hub"),
      #("x reset dungeon", "hub"),
      #("v credits", "hub"),
      #("made by Oded Yanovich", "hub"),
      #(int.to_string(model.volume), "hub"),
      #("l -25 j -10 h -5 g -1 t +1 y +5 u +10 i +25", "hub"),
    ]
      |> list.map(fn(x) {
        element.element("state-dependent", [attribute.class(x.1)], [
          html.text(x.0),
        ])
      })
      |> list.append([model.key |> element.text])
      |> list.append([
        // html.img([attribute.src("https://cdn2.thecatapi.com/images/b7k.jpg")]),
      ]),
  )
}
