defmodule EcoHabitsWeb.DateHelpers do
  @doc """
  Formats a datetime to DD/MM/YYYY HH:MM without timezone conversion.
  """
  def format_simple_datetime(datetime) when not is_nil(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y %H:%M")
  end

  def format_simple_datetime(nil), do: nil

  @doc """
  Formats a datetime to BR format with timezone conversion.
  """
  def format_br_datetime(datetime) when not is_nil(datetime) do
    datetime
    |> DateTime.shift_zone!("America/Sao_Paulo")
    |> Calendar.strftime("%d/%m/%Y %H:%M")
  end

  def format_br_datetime(nil), do: nil
end
