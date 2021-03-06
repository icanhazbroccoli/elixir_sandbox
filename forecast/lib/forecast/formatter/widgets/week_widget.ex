defmodule Forecast.Formatter.Widgets.WeekWidget do

  import Forecast.Formatter, only: [
    concat: 2,
    join_glyphs: 4,
    str_to_glyph: 1,
    new_canvas: 2,
  ]

  @x_offset 1
  @x_step   15

  def template do
    str_to_glyph """
    |              |              |              |              |              |
    |              |              |              |              |              |
    |              |              |              |              |              |
    |              |              |              |              |              |
    |              |              |              |              |              |
    └--------------┴--------------┴--------------┴--------------┴--------------┘
    """
  end

  def size do
    {
      template |> List.first |> length,
      template |> length
    }
  end

  def render_data(data) when is_map(data) do
    units      = Map.get(data, :units, [])
    day_glyphs = Map.get(data, :week,  [])
                  |> Enum.map fn(day_data) ->
                    render_day_data(day_data, units)
                  end
    x_offset = 1
    x_step = 15
    day_glyphs
      |> Stream.with_index
      |> Enum.reduce template, fn({ glyph, ix }, result) ->
        join_glyphs(result, x_offset + ix * x_step, 0, glyph)
      end
  end
  def render_data(_), do: raise "The argument should be a map"

  def render_day_data(day_data, units) do
    %{
      text: text,
      date: date,
      day:  day,
      high: high,
      low:  low,
    } = Enum.into(day_data, %{})
    %{
      temperature: temperature,
    } = Enum.into(units, %{})
    new_canvas(14, 5)
      |> join_glyphs(0, 0, [ String.to_char_list( date ) ])
      |> join_glyphs(0, 1, str_to_glyph(day))
      |> join_glyphs(0, 2, str_to_glyph(text))
      |> join_glyphs(0, 3, str_to_glyph("↑ #{high} °#{temperature}"))
      |> join_glyphs(0, 4, str_to_glyph("↓ #{low} °#{temperature}"))
  end

end

