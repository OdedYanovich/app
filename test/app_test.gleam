import gleam/dict

// import gleam/io
import gleam/list
import gleeunit
import gleeunit/should
import root.{Keydown}
import update/update.{init, update}

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn init_test() {
  let model = init(Nil)
  should.equal(model.responses |> dict.keys |> list.length, 10)
  let model = update(model, Keydown("z"))
  should.equal(model.responses |> dict.keys |> list.length, 5)
}

pub fn update_volume_test() {
  // Check each volume button
  let model = init(Nil)
  should.equal(model.volume, 50)
  let model = update(model, Keydown("q"))
  should.equal(model.volume, 25)
  let model = update(model, Keydown("w"))
  should.equal(model.volume, 15)
  let model = update(model, Keydown("e"))
  should.equal(model.volume, 10)
  let model = update(model, Keydown("r"))
  should.equal(model.volume, 9)
  let model = update(model, Keydown("t"))
  should.equal(model.volume, 10)
  let model = update(model, Keydown("y"))
  should.equal(model.volume, 15)
  // Check for capitalization handling
  let model = update(model, Keydown("U"))
  should.equal(model.volume, 25)
  let model = update(model, Keydown("i"))
  should.equal(model.volume, 50)
  // Check volume limits
  let model =
    model
    |> update(Keydown("q"))
    |> update(Keydown("q"))
    |> update(Keydown("q"))

  should.equal(model.volume, 0)
  let model =
    model
    |> update(Keydown("i"))
    |> update(Keydown("i"))
    |> update(Keydown("i"))
    |> update(Keydown("i"))
    |> update(Keydown("i"))
    |> update(Keydown("i"))
  should.equal(model.volume, 100)
}
