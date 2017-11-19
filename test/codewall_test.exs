defmodule CodewallTest do
  use ExUnit.Case
  doctest Codewall

  test "greets the world" do
    assert Codewall.hello() == :world
  end
end
