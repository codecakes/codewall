defmodule Codewall do
  @moduledoc """
  Documentation for Codewall.
  Author: @codecakes | @akulmat | Akul Sahariya
  Description:
    Poster wall of an image made up RGB letters
    taken from source code of a programming language.

  """

  import ParseCode, only: [parse_stream: 1]
  import ParseImg, only: [map_pixels: 4, generate_svg: 4, extract_png: 1]

  def build_poster(src_file, img, width, height, ratio) do
    with {:ok, %Imagineer.Image.PNG{pixels: pixels}} <- Imagineer.load(img) do
      parse_stream(src_file)
      |> map_pixels(pixels, ratio, width)
      |> generate_svg(width, height, ratio)
    else
      (other ->
        case other do
          {:error, reason} -> raise(reason)
          _ -> raise("Unable to load image")
        end)
    end
  end

  def generate_poster(src_file, img_file, out_file, ratio \\ 0.6) do
    %Pngstruct{width: width, height: height} = extract_png(img_file)
    res = build_poster(src_file, img_file, width, height, ratio)
    # File.open(out_file, [:write], fn(f)->
    #   IO.binwrite(f, res)
    # end)
    File.write!(out_file, res, [:binary])
  end
end
