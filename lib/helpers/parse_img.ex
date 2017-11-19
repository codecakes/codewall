defmodule ParseImg do
  defp binary_encode(px_elem) do
    px_elem |> :binary.encode_unsigned |> Base.encode16
  end

  defp to_hex({r, g, b}) do
    "#" <> (Enum.map([r,g,b], &binary_encode/1) |> Enum.join(""))
  end

  defp to_hex({r, g, b, a}) do
    "#" <> (Enum.map([r,g,b,a], &binary_encode/1) |> Enum.join(""))
  end

  defp create_fill(pixel_tuple), do: to_hex(pixel_tuple)

  defp calc_x(idx, width), do: rem(idx, width)
  defp calc_y(idx, width), do: div(idx, width)

  def merge_code_pixels(idx, width, pixel_tuple, ratio \\ 0.6) do
    %{
      x: calc_x(idx, width) * ratio,
      y: calc_y(idx, width),
      fill: create_fill(pixel_tuple)
    }
  end

  def map_pixels(code, pixels, ratio, width \\ 3150) do
    pixels
    |> List.flatten
    |> Stream.zip(code)
    |> Flow.from_enumerable
    |> Flow.partition
    |> Flow.reduce(fn-> [1, []] end, fn({pixel, character}, [idx, acc]) ->
      %{fill: fill} = res = merge_code_pixels(idx, width, pixel, ratio)
      case [idx, acc] do
        [1, _acc] ->
          [idx + 1, [{:text, res, character} | acc]]
        [idx, [{:text, %{fill: ^fill} = element, text} | acc]] ->
          [idx + 1, [{:text, element, text <> character} | acc]]
        [idx, acc] ->
          [idx + 1, [{:text, res, character} | acc]]
      end
    end)
    |> Enum.to_list
    |> Enum.fetch!(1)
  end

  def generate_svg(pixel_matrix, width, height, ratio) do
    XmlBuilder.element(:svg, %{
      viewBox: "0 0 #{width*ratio} #{height}",
      xmlns: "http://www.w3.org/2000/svg",
      style: "font-family: 'Source Code Pro'; font-size: 1; font-weight: 900;",
      width: width,
      height: height,
      "xml:space": "preserve"
    }, pixel_matrix)
    |> XmlBuilder.generate
  end

end

# defmodule SvgText do
#   @enforce_keys [:x, :y, :fill]
#   defstruct [:x, :y, :fill]
# end
