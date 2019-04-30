defmodule ChatApp.ASCII3D do
  def decode(str) do
    Regex.scan(~r/(\d+)(\D+)/, str)
    |> Enum.map_join(fn [_, n, s] -> String.duplicate(s, String.to_integer(n)) end)
    # Backslash
    |> String.replace("B", "\\")
  end
end
