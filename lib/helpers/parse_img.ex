defmodule Pngstruct do
  @enforce_keys [:length, :width, :height, :chunks]
  defstruct [:length, :width, :height, :bit_depth,
  :color_type, :compression_method, :filter_method, :interlace_method,
  :crc, :chunks]
end

defmodule ParseImg do
  @moduledoc """
  Helper module for image parsing functions
  """

  @doc """
  parse a png file into binary structure
  see: http://www.zohaib.me/binary-pattern-matching-in-elixir/
  """
  def extract_png(png_file_path) do
    case File.read!(png_file_path) do
      <<_png_header::size(64),
      length::size(32), "IHDR",
      width::size(32),
      height::size(32),
      bit_depth, color_type,
      compression_method, filter_method,
      interlace_method,
      crc::size(32),
      chunks::binary>> ->
        %Pngstruct{
          length: length,
          width: width,
          height: height,
          bit_depth: bit_depth,
          color_type: color_type,
          compression_method: compression_method,
          filter_method: filter_method,
          interlace_method: interlace_method,
          crc: crc,
          chunks: [] ++ parse_chunks(chunks)
        }
      _ -> raise("Unexpected png structure")
    end
  end

  defp parse_chunks(<<length::size(32), chunk_type::size(32),
  chunk_data::binary-size(length), crc::size(32), chunks::binary>>) when is_bitstring(chunks) do
    [%{length: length, chunk_type: chunk_type, chunk_data: chunk_data,
    crc: crc} | parse_chunks(chunks)]
  end

  defp parse_chunks(<<>>), do: []

  @doc """
  create the structure for svg values
  """
  def merge_code_pixels(idx, width, pixel_tuple, ratio \\ 0.6) do
    %{
      x: calc_x(idx, width) * ratio,
      y: calc_y(idx, width),
      fill: create_fill(pixel_tuple)
    }
  end

  @doc """
  takes the parsed code string
  and maps it into the pixel values
  """
  def map_pixels(code, pixels, ratio, width \\ 3150) do
    pixels
    |> List.flatten
    |> Enum.zip(code)
    # |> Flow.from_enumerable
    # |> Flow.partition
    # |> Stream.reduce(fn-> [1, []] end, fn({pixel, character}, [idx, acc]) ->
    |> Enum.reduce([1, []], fn({pixel, character}, [idx, acc]) ->
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

  @doc """
  generates the pixel values as an svg file
  """
  def generate_svg(pixel_matrix, width, height, ratio) do
    XmlBuilder.element(:svg, %{
      viewBox: "0 0 #{width*ratio} #{height}",
      xmlns: "http://www.w3.org/2000/svg",
      style: "font-family: 'Times New Roman'; font-size: 1; font-weight: 900;",
      width: width,
      height: height,
      "xml:space": "preserve"
    }, pixel_matrix)
    |> XmlBuilder.generate
  end

  @doc """
  converts each pixel integer value to a binary unsigned base encoded value
  """
  defp binary_encode(px_elem) do
    px_elem |> :binary.encode_unsigned |> Base.encode16
  end

  @doc """
  joining binary encoded integers becomes a hex string
  """
  defp to_hex({r, g, b}) do
    "#" <> (Enum.map([r,g,b], &binary_encode/1) |> Enum.join(""))
  end

  @doc """
  joining binary encoded integers becomes a hex string
  """
  defp to_hex({r, g, b, a}) do
    "#" <> (Enum.map([r,g,b,a], &binary_encode/1) |> Enum.join(""))
  end

  @doc """
  wrapper to to_hex/1 function
  """
  defp create_fill(pixel_tuple), do: to_hex(pixel_tuple)

  defp calc_x(idx, width), do: rem(idx, width)
  defp calc_y(idx, width), do: div(idx, width)

end
