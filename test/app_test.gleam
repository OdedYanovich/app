import gleam/dict

// import gleam/io
import gleam/list
import gleeunit
import gleeunit/should
import root.{Keyboard}
import update/update.{init, update}

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn init_test() {
  let model = init(Nil)
  should.equal(model.responses |> dict.keys |> list.length, 10)
  let model = update(model, Keyboard("z"))
  should.equal(model.responses |> dict.keys |> list.length, 5)
}

pub fn update_volume_test() {
  // Check each volume button
  let model = init(Nil)
  should.equal(model.volume, 50)
  let model = update(model, Keyboard("q"))
  should.equal(model.volume, 25)
  let model = update(model, Keyboard("w"))
  should.equal(model.volume, 15)
  let model = update(model, Keyboard("e"))
  should.equal(model.volume, 10)
  let model = update(model, Keyboard("r"))
  should.equal(model.volume, 9)
  let model = update(model, Keyboard("t"))
  should.equal(model.volume, 10)
  let model = update(model, Keyboard("y"))
  should.equal(model.volume, 15)
  // Check for capitalization handling
  let model = update(model, Keyboard("U"))
  should.equal(model.volume, 25)
  let model = update(model, Keyboard("i"))
  should.equal(model.volume, 50)
  // Check volume limits
  let model =
    model
    |> update(Keyboard("q"))
    |> update(Keyboard("q"))
    |> update(Keyboard("q"))

  should.equal(model.volume, 0)
  let model =
    model
    |> update(Keyboard("i"))
    |> update(Keyboard("i"))
    |> update(Keyboard("i"))
    |> update(Keyboard("i"))
    |> update(Keyboard("i"))
    |> update(Keyboard("i"))
  should.equal(model.volume, 100)
}
