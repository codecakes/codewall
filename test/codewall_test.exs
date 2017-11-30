defmodule CodewallTest do
  use ExUnit.Case, async: true
  import Codewall
  alias Codewall
  require Codewall

  doctest Codewall

  setup_all do
    img_path = "/home/ubuntu/Documents/elixir_files/tboox_wall/codewall/tattoo.png"

    code_path = "/home/ubuntu/Documents/elemental/_build/prod/rel/auth/releases/0.0.2/auth.script"

    img_out_path = "/home/ubuntu/Documents/elixir_files/tboox_wall/codewall/tattoo.svg"

    {:ok, %{code_path: code_path, img_path: img_path, img_out_path: img_out_path}}
  end

  test "generates poster with :ok", params do
    # IO.inspect params, label: "params"
    {src_file, img_file, out_file} = {params.code_path, params.img_path, params.img_out_path}

    assert Codewall.generate_poster(src_file, img_file, out_file)
  end
end
